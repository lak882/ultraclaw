#!/usr/bin/env python3
"""Audit trail for InterClaw script operations.

Records every API call, terminal command, and file change to:
  1. HTTP POST to AuditHTTPService on port 9881 (real-time, UnifiedEvent format).
     Falls back to file queue if POST fails.
  2. A permanent local archive (audit_log/<server>/<namespace>/YYYY-MM-DD.jsonl)
     for historical queries.

Correlation IDs (read from environment, set by chatbot backend):
  INTERCLAW_SESSION_ID — conversation-level (groups all events from same chat session)
  INTERCLAW_MESSAGE_ID — message-turn-level (groups events from same prompt/response)

Usage as module (auto-enabled by iris_api.get_server_and_creds):
  from audit import log_event
  log_event("api_call", server="myserver", namespace="HSLIB",
            url="/api/atelier/v1/...", method="GET", status=200, duration_ms=150)

Usage as CLI:
  audit.py --list --server myserver --namespace HSLIB [--type api_call] [--count 50]
  audit.py --tail --server myserver --namespace HSLIB
  audit.py --clear-queue   # clear the shared queue (for debugging)
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import json
import os
import sys
import fcntl
from datetime import datetime

# ---------------------------------------------------------------------------
# HTTP endpoint for real-time audit events (AuditHTTPService)
# ---------------------------------------------------------------------------
AUDIT_HTTP_URL = "http://localhost:9881/"

# ---------------------------------------------------------------------------
# Queue file — fallback when HTTP POST fails (polled by ScriptAudit)
# ---------------------------------------------------------------------------
from platform import INTERCLAW_TEMP

AUDIT_QUEUE_DIR = INTERCLAW_TEMP
AUDIT_QUEUE_FILE = os.path.join(AUDIT_QUEUE_DIR, "audit_queue.jsonl")

# ---------------------------------------------------------------------------
# Source mapping: event_type → UnifiedEvent.Source value
# ---------------------------------------------------------------------------
_SOURCE_MAP = {
    "api_call": "audit_api",
    "terminal": "audit_terminal",
    "file_change": "audit_file_change",
    "interop_api": "audit_interop",
    "doc_get": "audit_doc_get",
    "doc_put": "audit_doc_put",
    "doc_compile": "audit_doc_compile",
    "doc_query": "audit_doc_query",
}


def _get_project_root():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))


def _get_archive_dir():
    return os.path.join(_get_project_root(), "audit_log")


# ---------------------------------------------------------------------------
# Write API (called by iris_api.py, ws_terminal.py, put_doc.py, etc.)
# ---------------------------------------------------------------------------

def _build_summary(event_type, kwargs):
    """Build a one-line summary for the event."""
    if event_type == "api_call" or event_type == "interop_api":
        method = kwargs.get("method", "?")
        url = kwargs.get("url", "?")
        if "/api/" in url:
            url = "/api/" + url.split("/api/", 1)[1]
        status = kwargs.get("status", "?")
        dur = kwargs.get("duration_ms", 0)
        return f"{method} {url} -> {status} ({dur:.0f}ms)"
    elif event_type == "terminal":
        ns = kwargs.get("namespace", "?")
        code = kwargs.get("code", "?")[:200]
        return f"Terminal [{ns}]: {code}"
    elif event_type == "file_change":
        cls = kwargs.get("class_name", "?")
        added = kwargs.get("lines_added", 0)
        removed = kwargs.get("lines_removed", 0)
        if kwargs.get("is_new"):
            return f"Created {cls} ({added} lines)"
        return f"Updated {cls} (+{added} -{removed})"
    elif event_type == "doc_get":
        doc = kwargs.get("document_name", "?")
        lines = kwargs.get("line_count", 0)
        return f"Pulled {doc} ({lines} lines)"
    elif event_type == "doc_put":
        doc = kwargs.get("document_name", "?")
        action = kwargs.get("action", "push")
        compile_status = kwargs.get("compile_status", "not_compiled")
        added = kwargs.get("lines_added", 0)
        removed = kwargs.get("lines_removed", 0)
        if kwargs.get("is_new"):
            return f"Created {doc} ({added} lines) compile={compile_status}"
        return f"Updated {doc} (+{added} -{removed}) compile={compile_status}"
    elif event_type == "doc_compile":
        doc = kwargs.get("document_name", "?")
        status = kwargs.get("compile_status", "?")
        dur = kwargs.get("duration_ms", 0)
        return f"Compiled {doc} -> {status} ({dur:.0f}ms)"
    elif event_type == "doc_query":
        sql = kwargs.get("sql", "?")[:80]
        rows = kwargs.get("row_count", 0)
        dur = kwargs.get("duration_ms", 0)
        return f"Query ({rows} rows, {dur:.0f}ms): {sql}"
    return kwargs.get("summary", event_type)


def _post_to_production(event_type, entry):
    """POST event to AuditHTTPService as type-specific JSON. Returns True on success.

    JSON property names match IRIS class property names exactly (PascalCase).
    AuditHTTPService inspects 'Source' to instantiate the correct subclass.
    """
    try:
        import urllib.request

        # Common fields (BaseEvent properties)
        payload = {
            "Source": _SOURCE_MAP.get(event_type, "audit_" + event_type),
            "EventType": event_type,
            "ChatSessionId": os.environ.get("INTERCLAW_SESSION_ID", ""),
            "MessageId": os.environ.get("INTERCLAW_MESSAGE_ID", ""),
            "OriginalTimestamp": entry.get("ts", ""),
            "Server": entry.get("server", ""),
            "Namespace": entry.get("namespace", ""),
            "Summary": entry.get("_summary", ""),
        }

        # Type-specific fields
        if event_type in ("api_call", "interop_api"):
            payload.update({
                "Method": entry.get("method", ""),
                "URL": entry.get("url", "")[:2000],
                "StatusCode": int(entry.get("status", 0) or 0),
                "Duration": float(entry.get("duration_ms", 0) or 0),
                "RequestBody": entry.get("request_body", ""),
                "ResponseBody": entry.get("response_body", ""),
            })
        elif event_type == "terminal":
            payload.update({
                "Code": entry.get("code", ""),
                "Output": entry.get("output", ""),
                "Duration": float(entry.get("duration_ms", 0) or 0),
                "Success": bool(entry.get("success", False)),
            })
        elif event_type == "file_change":
            payload.update({
                "ClassName": entry.get("class_name", ""),
                "Action": entry.get("action", ""),
                "IsNew": bool(entry.get("is_new", False)),
                "LinesAdded": int(entry.get("lines_added", 0)),
                "LinesRemoved": int(entry.get("lines_removed", 0)),
                "BeforeContent": entry.get("before_content", ""),
                "AfterContent": entry.get("after_content", ""),
            })
        elif event_type == "doc_get":
            payload.update({
                "DocumentName": entry.get("document_name", ""),
                "Content": entry.get("content", ""),
                "LineCount": int(entry.get("line_count", 0)),
            })
        elif event_type == "doc_put":
            payload.update({
                "DocumentName": entry.get("document_name", ""),
                "Action": entry.get("action", ""),
                "IsNew": bool(entry.get("is_new", False)),
                "LinesAdded": int(entry.get("lines_added", 0)),
                "LinesRemoved": int(entry.get("lines_removed", 0)),
                "BeforeContent": entry.get("before_content", ""),
                "AfterContent": entry.get("after_content", ""),
                "CompileStatus": entry.get("compile_status", "not_compiled"),
                "CompileMessages": entry.get("compile_messages", ""),
            })
        elif event_type == "doc_compile":
            payload.update({
                "DocumentName": entry.get("document_name", ""),
                "CompileStatus": entry.get("compile_status", ""),
                "CompileMessages": entry.get("compile_messages", ""),
                "Duration": float(entry.get("duration_ms", 0) or 0),
            })
        elif event_type == "doc_query":
            payload.update({
                "SQL": entry.get("sql", ""),
                "RowCount": int(entry.get("row_count", 0)),
                "StatusCode": int(entry.get("status", 0) or 0),
                "Duration": float(entry.get("duration_ms", 0) or 0),
            })

        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            AUDIT_HTTP_URL,
            data=data,
            method="POST",
            headers={"Content-Type": "application/json"},
        )
        with urllib.request.urlopen(req, timeout=2) as resp:
            return resp.status < 300
    except Exception:
        return False


def _write_to_queue(line):
    """Fallback: append to shared queue file for ScriptAudit BS."""
    try:
        os.makedirs(AUDIT_QUEUE_DIR, mode=0o777, exist_ok=True)
        try:
            os.chmod(AUDIT_QUEUE_DIR, 0o777)
        except OSError:
            pass
        fd = os.open(AUDIT_QUEUE_FILE, os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o666)
        with os.fdopen(fd, "a") as f:
            fcntl.flock(f, fcntl.LOCK_EX)
            f.write(line)
            fcntl.flock(f, fcntl.LOCK_UN)
    except Exception:
        pass


def log_event(event_type, **kwargs):
    """Append an audit event to the production (via HTTP) and local archive.

    Args:
        event_type: One of "api_call", "terminal", "file_change", "interop_api".
        **kwargs: Event-specific fields (server, namespace, url, method,
                  status, duration_ms, class_name, action, summary, detail, etc.)
    """
    entry = {
        "type": event_type,
        "ts": datetime.now().isoformat(),
        **kwargs,
    }
    # Build summary and stash it for the HTTP POST
    entry["_summary"] = kwargs.get("summary") or _build_summary(event_type, kwargs)
    line = json.dumps({k: v for k, v in entry.items() if not k.startswith("_")},
                      ensure_ascii=False) + "\n"

    # 1. Try HTTP POST to AuditHTTPService (real-time)
    posted = _post_to_production(event_type, entry)

    # 2. Fall back to file queue if POST failed
    if not posted:
        _write_to_queue(line)

    # 3. Always append to permanent local archive
    server = kwargs.get("server", "unknown")
    namespace = kwargs.get("namespace", "unknown")
    try:
        archive_dir = os.path.join(_get_archive_dir(), server, namespace)
        os.makedirs(archive_dir, exist_ok=True)
        date_str = datetime.now().strftime("%Y-%m-%d")
        archive_file = os.path.join(archive_dir, f"{date_str}.jsonl")
        with open(archive_file, "a") as f:
            f.write(line)
    except Exception:
        pass  # Best-effort


# ---------------------------------------------------------------------------
# Read API (called by InterClaw.BS.ScriptAudit from IRIS embedded Python)
# ---------------------------------------------------------------------------

def drain_queue():
    """Read and clear all events from the shared queue file.

    Called by InterClaw.BS.ScriptAudit every poll interval.
    Returns a list of event dicts.
    """
    if not os.path.exists(AUDIT_QUEUE_FILE):
        return []

    try:
        with open(AUDIT_QUEUE_FILE, "r+") as f:
            fcntl.flock(f, fcntl.LOCK_EX)
            lines = f.readlines()
            f.seek(0)
            f.truncate()
            fcntl.flock(f, fcntl.LOCK_UN)
    except Exception:
        return []

    events = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        try:
            events.append(json.loads(line))
        except json.JSONDecodeError:
            continue

    return events


# ---------------------------------------------------------------------------
# Query API (for CLI use and /history command)
# ---------------------------------------------------------------------------

def list_events(server, namespace, event_type=None, count=50, since=None):
    """List recent events from the local archive, newest first."""
    archive_dir = os.path.join(_get_archive_dir(), server, namespace)
    if not os.path.isdir(archive_dir):
        return []

    # Read files in reverse date order
    all_events = []
    for fname in sorted(os.listdir(archive_dir), reverse=True):
        if not fname.endswith(".jsonl"):
            continue
        fpath = os.path.join(archive_dir, fname)
        with open(fpath, encoding="utf-8") as f:
            file_events = []
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if event_type and entry.get("type") != event_type:
                    continue
                if since and entry.get("ts", "") < since:
                    continue
                file_events.append(entry)
            # Reverse to get newest first within each file
            all_events.extend(reversed(file_events))
            if len(all_events) >= count:
                break

    return all_events[:count]


def format_event(event):
    """Format a single event for display."""
    ts = event.get("ts", "?")[:19]
    etype = event.get("type", "?")

    if etype == "api_call":
        method = event.get("method", "?")
        url = event.get("url", "?")
        # Shorten URL: strip host, keep path
        if "/api/" in url:
            url = "/api/" + url.split("/api/", 1)[1]
        status = event.get("status", "?")
        dur = event.get("duration_ms", 0)
        return f"{ts}  API  {method:<6} {status} {dur:>6.0f}ms  {url}"

    elif etype == "terminal":
        ns = event.get("namespace", "?")
        code = event.get("code", "?")[:60]
        dur = event.get("duration_ms", 0)
        return f"{ts}  TERM {ns:<10} {dur:>6.0f}ms  {code}"

    elif etype == "file_change":
        cls = event.get("class_name", "?")
        action = event.get("action", "?")
        added = event.get("lines_added", 0)
        removed = event.get("lines_removed", 0)
        delta = f"+{added} -{removed}" if not event.get("is_new") else "new"
        return f"{ts}  FILE {action:<6} {delta:<10} {cls}"

    elif etype == "interop_api":
        method = event.get("method", "?")
        url = event.get("url", "?")
        if "/api/" in url:
            url = "/api/" + url.split("/api/", 1)[1]
        status = event.get("status", "?")
        dur = event.get("duration_ms", 0)
        return f"{ts}  IAPI {method:<6} {status} {dur:>6.0f}ms  {url}"

    elif etype == "doc_get":
        doc = event.get("document_name", "?")
        lines = event.get("line_count", 0)
        return f"{ts}  DGET {doc:<40} {lines} lines"

    elif etype == "doc_put":
        doc = event.get("document_name", "?")
        action = event.get("action", "?")
        added = event.get("lines_added", 0)
        removed = event.get("lines_removed", 0)
        compile_st = event.get("compile_status", "?")
        delta = f"+{added} -{removed}" if not event.get("is_new") else "new"
        return f"{ts}  DPUT {action:<6} {delta:<10} {compile_st:<8} {doc}"

    elif etype == "doc_compile":
        doc = event.get("document_name", "?")
        status = event.get("compile_status", "?")
        dur = event.get("duration_ms", 0)
        return f"{ts}  DCMP {status:<8} {dur:>6.0f}ms  {doc}"

    elif etype == "doc_query":
        sql = event.get("sql", "?")[:60]
        rows = event.get("row_count", 0)
        dur = event.get("duration_ms", 0)
        return f"{ts}  DQRY {rows:>5} rows {dur:>6.0f}ms  {sql}"

    else:
        return f"{ts}  {etype:<5} {json.dumps(event)[:80]}"


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    import argparse
    parser = argparse.ArgumentParser(description="View InterClaw audit trail")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--list", action="store_true", help="List recent events")
    mode.add_argument("--tail", action="store_true", help="Show most recent events")
    mode.add_argument("--clear-queue", action="store_true", help="Clear the shared queue")
    mode.add_argument("--queue-size", action="store_true", help="Show queue file size")

    parser.add_argument("--server", "-s", default="unknown")
    parser.add_argument("--namespace", "-n", default="unknown")
    parser.add_argument("--type", dest="event_type",
                        choices=["api_call", "terminal", "file_change",
                                 "doc_get", "doc_put", "doc_compile", "doc_query"])
    parser.add_argument("--count", type=int, default=50)
    parser.add_argument("--since", help="ISO timestamp or HH:MM filter")
    parser.add_argument("--format", choices=["table", "json"], default="table")
    args = parser.parse_args()

    if args.list or args.tail:
        count = 20 if args.tail else args.count
        events = list_events(args.server, args.namespace,
                             event_type=args.event_type,
                             count=count, since=args.since)
        if not events:
            print("No audit events found.")
            return

        if args.format == "json":
            print(json.dumps(events, indent=2))
        else:
            for event in events:
                print(format_event(event))

    elif args.clear_queue:
        if os.path.exists(AUDIT_QUEUE_FILE):
            with open(AUDIT_QUEUE_FILE, "w") as f:
                f.truncate()
            print("Queue cleared.")
        else:
            print("Queue file does not exist.")

    elif args.queue_size:
        if os.path.exists(AUDIT_QUEUE_FILE):
            size = os.path.getsize(AUDIT_QUEUE_FILE)
            with open(AUDIT_QUEUE_FILE) as f:
                lines = sum(1 for _ in f)
            print(f"Queue: {lines} events, {size} bytes")
        else:
            print("Queue: empty (file does not exist)")


if __name__ == "__main__":
    main()
