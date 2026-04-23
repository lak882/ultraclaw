#!/usr/bin/env python3
"""
interclaw_ask.py — Send a prompt to a running InterClaw instance and stream the response.

Wraps the two-endpoint chat pipeline:
  POST  {base}/api/interclaw/production/api/start    → {bridge_id}
  GET   {base}/api/interclaw/production/api/events?bridge_id=...&after=N → {events, done}

The CLI resolves the target server from one of (in priority order):
  1. --conn <url>       — full connection string, e.g.
                          `http://user:pass@host:port/path-prefix`
                          `interclaw://user:pass@host:port/path-prefix`  (alias)
  2. --server <name>    — entry in config/servers.json at repo root
  3. INTERCLAW_CONN env — same format as --conn
  4. "default" key in config/servers.json

Usage examples:
  python3 interclaw_ask.py "list all DTLs in INTERCLAW"
  python3 interclaw_ask.py --namespace TESTING --model haiku "show productions"
  python3 interclaw_ask.py --conn http://super:SYS@vmdev1:80/interclaw-test "hello"
  python3 interclaw_ask.py --session-id local-abc "follow-up question"
  python3 interclaw_ask.py --json "list classes"   # raw event stream as ndjson

Exit codes:
  0  — turn completed successfully
  1  — HTTP / connection error
  2  — server returned an error event
  3  — argument error
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path


# ────────────────────────────────────────────────────────────────────────────
# Config resolution
# ────────────────────────────────────────────────────────────────────────────


def find_servers_json(start: Path) -> Path | None:
    """Walk up from `start` looking for config/servers.json."""
    for parent in [start] + list(start.parents):
        candidate = parent / "config" / "servers.json"
        if candidate.is_file():
            return candidate
    return None


def parse_conn(conn: str) -> dict:
    """
    Parse a connection string into {scheme, host, port, path_prefix, username, password}.
    Accepts `http://`, `https://`, or `interclaw://` (→ http).
    """
    # Allow interclaw:// as a convenience alias.
    if conn.startswith("interclaw://"):
        conn = "http://" + conn[len("interclaw://"):]
    parsed = urllib.parse.urlparse(conn)
    if parsed.scheme not in ("http", "https"):
        raise ValueError(f"connection scheme must be http/https/interclaw, got {parsed.scheme!r}")
    if not parsed.hostname:
        raise ValueError("connection string missing host")
    return {
        "scheme": parsed.scheme,
        "host": parsed.hostname,
        "port": parsed.port or (443 if parsed.scheme == "https" else 80),
        "path_prefix": (parsed.path or "").rstrip("/"),
        "username": urllib.parse.unquote(parsed.username) if parsed.username else None,
        "password": urllib.parse.unquote(parsed.password) if parsed.password else None,
    }


def resolve_target(args: argparse.Namespace) -> dict:
    if args.conn:
        return parse_conn(args.conn)

    env_conn = os.environ.get("INTERCLAW_CONN")
    if env_conn and not args.server:
        return parse_conn(env_conn)

    servers_path = (
        Path(args.config).expanduser().resolve()
        if args.config
        else find_servers_json(Path(__file__).resolve().parent)
    )
    if not servers_path or not servers_path.is_file():
        raise SystemExit("Could not locate config/servers.json. Pass --conn or --config.")

    with servers_path.open() as fh:
        cfg = json.load(fh)

    servers = cfg.get("intersystems.servers") or cfg.get("servers") or {}
    name = args.server or cfg.get("default")
    if not name:
        raise SystemExit("No --server given and config/servers.json has no default.")
    if name not in servers:
        raise SystemExit(f"Server {name!r} not found in {servers_path}")
    entry = servers[name]
    web = entry.get("webServer", {})
    return {
        "scheme": web.get("scheme", "http"),
        "host": web.get("host", "localhost"),
        "port": web.get("port", 80),
        "path_prefix": (web.get("pathPrefix") or "").rstrip("/"),
        "username": entry.get("username"),
        "password": entry.get("password"),
    }


# ────────────────────────────────────────────────────────────────────────────
# HTTP
# ────────────────────────────────────────────────────────────────────────────


def build_base_url(target: dict) -> str:
    return f"{target['scheme']}://{target['host']}:{target['port']}{target['path_prefix']}/api/interclaw/production"


def auth_header(target: dict) -> dict:
    if target.get("username") and target.get("password"):
        token = base64.b64encode(
            f"{target['username']}:{target['password']}".encode()
        ).decode("ascii")
        return {"Authorization": f"Basic {token}"}
    return {}


def http_post_json(url: str, body: dict, headers: dict, timeout: float = 30.0) -> dict:
    data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        method="POST",
        headers={"Content-Type": "application/json", **headers},
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def http_get_json(url: str, headers: dict, timeout: float = 35.0) -> dict:
    req = urllib.request.Request(url, method="GET", headers=headers)
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


# ────────────────────────────────────────────────────────────────────────────
# Chat loop
# ────────────────────────────────────────────────────────────────────────────


def start_turn(base: str, headers: dict, payload: dict) -> str:
    resp = http_post_json(f"{base}/api/start", payload, headers)
    if "error" in resp:
        raise RuntimeError(f"start failed: {resp['error']}")
    bid = resp.get("bridge_id")
    if not bid:
        raise RuntimeError(f"start returned no bridge_id: {resp}")
    return bid


def poll_events(
    base: str,
    headers: dict,
    bridge_id: str,
    on_event,
    poll_timeout: float = 35.0,
    overall_timeout: float = 600.0,
) -> None:
    """Long-poll /api/events until done. Calls `on_event(evt_dict)` for each event."""
    after = 0
    started = time.time()
    while True:
        if time.time() - started > overall_timeout:
            raise TimeoutError(f"overall timeout {overall_timeout}s exceeded")
        qs = urllib.parse.urlencode({"bridge_id": bridge_id, "after": after})
        try:
            resp = http_get_json(f"{base}/api/events?{qs}", headers, timeout=poll_timeout)
        except urllib.error.URLError as exc:
            # Transient network blip: retry once before giving up.
            time.sleep(0.5)
            resp = http_get_json(f"{base}/api/events?{qs}", headers, timeout=poll_timeout)
        if "error" in resp:
            raise RuntimeError(f"events failed: {resp['error']}")
        for evt in resp.get("events", []):
            seq = evt.get("seq") or 0
            if seq > after:
                after = seq
            on_event(evt.get("data") or {})
        if resp.get("done"):
            return


# ────────────────────────────────────────────────────────────────────────────
# Event rendering
# ────────────────────────────────────────────────────────────────────────────


class TextCollector:
    """Renders events in text mode: streams deltas, surfaces tool calls + final output."""

    def __init__(self, stream: bool = True, quiet: bool = False):
        self.stream = stream
        self.quiet = quiet
        self.output = []
        self.error = None
        self.session_id = None
        self.printed_output = False

    def __call__(self, data: dict) -> None:
        etype = data.get("type") or ""
        if etype == "delta":
            text = data.get("text") or ""
            if text and self.stream:
                sys.stdout.write(text)
                sys.stdout.flush()
            self.output.append(text)
        elif etype == "output":
            text = (data.get("text") or "").strip()
            if text:
                if self.stream and not self.printed_output:
                    # If we streamed deltas, the output is usually the same content
                    # rendered after a non-delta pause; don't print twice.
                    pass
                elif not self.stream:
                    self.output = [text]
                self.printed_output = True
        elif etype == "thinking":
            if not self.quiet:
                text = data.get("text") or ""
                if text:
                    sys.stderr.write(f"[thinking] {text}")
                    sys.stderr.flush()
        elif etype == "tool_use":
            if not self.quiet:
                name = data.get("name") or data.get("tool") or "tool"
                sys.stderr.write(f"\n[tool_use] {name}\n")
                sys.stderr.flush()
        elif etype == "tool_result":
            if not self.quiet:
                text = (data.get("text") or "")[:400]
                sys.stderr.write(f"[tool_result] {text}\n")
                sys.stderr.flush()
        elif etype == "error":
            self.error = data.get("text") or "unknown server error"
            sys.stderr.write(f"\n[error] {self.error}\n")
            sys.stderr.flush()
        elif etype == "status":
            if not self.quiet:
                text = data.get("text") or ""
                if text and text not in ("Ready", "Connected"):
                    sys.stderr.write(f"[status] {text}\n")
                    sys.stderr.flush()
        elif etype == "done":
            sid = data.get("session_id")
            if sid:
                self.session_id = sid


class JsonCollector:
    """Emits each event as one JSON line on stdout."""

    def __init__(self):
        self.error = None
        self.session_id = None

    def __call__(self, data: dict) -> None:
        sys.stdout.write(json.dumps(data, ensure_ascii=False) + "\n")
        sys.stdout.flush()
        etype = data.get("type") or ""
        if etype == "error":
            self.error = data.get("text") or "unknown server error"
        if etype == "done":
            sid = data.get("session_id")
            if sid:
                self.session_id = sid


# ────────────────────────────────────────────────────────────────────────────
# CLI
# ────────────────────────────────────────────────────────────────────────────


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Send a prompt to a running InterClaw instance and print the response.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("prompt", nargs="*", help="The prompt to send (positional words joined with spaces).")
    ap.add_argument("--stdin", action="store_true", help="Read the prompt from stdin instead of the positional args.")
    ap.add_argument("--conn", help="Full connection string, e.g. http://user:pass@host:port/path-prefix")
    ap.add_argument("--server", help="Server entry in config/servers.json")
    ap.add_argument("--config", help="Path to servers.json (default: walk up from this script)")
    ap.add_argument("--namespace", help="Override namespace (default: server-side default)")
    ap.add_argument("--model", help="Model alias: opus | sonnet | haiku", default="opus")
    ap.add_argument("--effort", choices=["low", "medium", "high", "max"], help="Thinking effort (default: medium)")
    ap.add_argument("--session-id", help="Reuse an existing session id (default: one-shot)")
    ap.add_argument("--json", action="store_true", help="Stream events as ndjson on stdout instead of text")
    ap.add_argument("--quiet", action="store_true", help="Suppress thinking / tool-call chatter on stderr")
    ap.add_argument("--no-stream", action="store_true", help="Wait for the final output instead of streaming deltas")
    ap.add_argument("--timeout", type=float, default=600.0, help="Overall turn timeout in seconds (default: 600)")
    args = ap.parse_args()

    # Resolve the prompt from positional args or stdin.
    if args.stdin:
        prompt = sys.stdin.read()
    else:
        prompt = " ".join(args.prompt).strip()
    if not prompt:
        ap.print_help(sys.stderr)
        sys.stderr.write("\nerror: no prompt given (pass as args or use --stdin)\n")
        return 3

    try:
        target = resolve_target(args)
    except (SystemExit, ValueError) as exc:
        sys.stderr.write(f"error: {exc}\n")
        return 3

    base = build_base_url(target)
    headers = auth_header(target)

    payload = {"prompt": prompt, "model": args.model}
    if args.namespace:
        payload["namespace"] = args.namespace.upper()
    if args.effort:
        payload["effort"] = args.effort
    if args.session_id:
        payload["session_id"] = args.session_id

    try:
        bid = start_turn(base, headers, payload)
    except urllib.error.HTTPError as exc:
        sys.stderr.write(f"start failed: HTTP {exc.code} {exc.reason}\n")
        try:
            sys.stderr.write(exc.read().decode("utf-8") + "\n")
        except Exception:
            pass
        return 1
    except urllib.error.URLError as exc:
        sys.stderr.write(f"start failed: {exc.reason}\n")
        return 1
    except Exception as exc:
        sys.stderr.write(f"start failed: {exc}\n")
        return 1

    if args.json:
        collector = JsonCollector()
    else:
        collector = TextCollector(stream=not args.no_stream, quiet=args.quiet)

    try:
        poll_events(base, headers, bid, collector, overall_timeout=args.timeout)
    except urllib.error.HTTPError as exc:
        sys.stderr.write(f"events failed: HTTP {exc.code} {exc.reason}\n")
        return 1
    except urllib.error.URLError as exc:
        sys.stderr.write(f"events failed: {exc.reason}\n")
        return 1
    except Exception as exc:
        sys.stderr.write(f"events failed: {exc}\n")
        return 1

    # In text mode, if we suppressed deltas, print the final output now.
    if not args.json and isinstance(collector, TextCollector):
        if args.no_stream:
            sys.stdout.write("".join(collector.output).strip() + "\n")
        elif not collector.printed_output and collector.output:
            # Fallback: delta stream produced nothing; print the accumulated text.
            sys.stdout.write("\n")
        else:
            # Streaming path already emitted the content; ensure a trailing newline.
            if collector.output:
                sys.stdout.write("\n")
        if collector.session_id:
            sys.stderr.write(f"[session_id] {collector.session_id}\n")
        if collector.error:
            return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
