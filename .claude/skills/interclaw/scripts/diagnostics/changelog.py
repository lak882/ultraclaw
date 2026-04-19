#!/usr/bin/env python3
"""Record and query class change history for InterClaw push operations.

Stores before/after snapshots locally as JSON files under changelog/<server>/<namespace>/.
Optionally pushes metadata to an InterClaw.ChangeLog table in IRIS for SQL queries.

CLI usage:
  changelog.py --list   --server vmdev1 --namespace HSLIB [--class MyPkg.DTL.*] [--count 20]
  changelog.py --show   --server vmdev1 --namespace HSLIB --id abc12345
  changelog.py --diff   --server vmdev1 --namespace HSLIB --id abc12345
  changelog.py --deploy --server vmdev1 --namespace HSLIB   # create InterClaw.ChangeLog table

Module usage (from put_doc.py):
  from changelog import save_change, format_summary
  entry, path = save_change("vmdev1", "HSLIB", "My.Class.cls", "push", before, after)
  print(format_summary(entry))
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import sys
import os
import json
import difflib
import uuid
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


def _get_project_root():
    """Get the project root (5 levels up from this script)."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))


def _get_changelog_dir():
    """Get the changelog directory (project_root/changelog/)."""
    return os.path.join(_get_project_root(), "changelog")


# ---------------------------------------------------------------------------
# Core functions (used as module API by put_doc.py)
# ---------------------------------------------------------------------------

def save_change(server, namespace, class_name, action, before_content, after_content):
    """Save a before/after snapshot to the local changelog.

    Args:
        server: Server name from config/servers.json.
        namespace: IRIS namespace.
        class_name: Document name (e.g. My.Class.cls).
        action: "create", "push", "delete", or "revert".
        before_content: Full source before the change (None if new).
        after_content: Full source after the change (None if deleted).

    Returns:
        Tuple of (entry_dict, file_path).
    """
    base_dir = os.path.join(_get_changelog_dir(), server, namespace)
    os.makedirs(base_dir, exist_ok=True)

    now = datetime.now()
    ts_str = now.strftime("%Y-%m-%d_%H%M%S")
    safe_name = class_name.replace(".cls", "").replace("/", ".").replace("\\", ".")
    filename = f"{ts_str}_{action}_{safe_name}.json"
    filepath = os.path.join(base_dir, filename)

    # Generate unified diff
    before_lines = (before_content or "").splitlines(keepends=True)
    after_lines = (after_content or "").splitlines(keepends=True)
    diff_lines = list(difflib.unified_diff(
        before_lines, after_lines,
        fromfile=f"server:{class_name}",
        tofile=f"local:{class_name}",
    ))

    added = sum(1 for l in diff_lines if l.startswith('+') and not l.startswith('+++'))
    removed = sum(1 for l in diff_lines if l.startswith('-') and not l.startswith('---'))

    entry = {
        "id": uuid.uuid4().hex[:8],
        "timestamp": now.isoformat(),
        "server": server,
        "namespace": namespace,
        "class_name": class_name,
        "action": action,
        "is_new": before_content is None,
        "lines_added": added,
        "lines_removed": removed,
        "lines_before": len(before_lines) if before_content else 0,
        "lines_after": len(after_lines) if after_content else 0,
        "diff": "".join(diff_lines),
        "before": before_content,
        "after": after_content,
    }

    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(entry, f, indent=2, ensure_ascii=False)

    return entry, filepath


def list_changes(server, namespace, class_filter=None, count=20, since=None):
    """List recent changelog entries (newest first), without full content.

    Args:
        server: Server name.
        namespace: IRIS namespace.
        class_filter: Substring filter on class name (case-insensitive).
        count: Max entries to return.
        since: ISO timestamp or HH:MM — only return entries after this time.

    Returns:
        List of entry dicts (without before/after/diff content).
    """
    base_dir = os.path.join(_get_changelog_dir(), server, namespace)
    if not os.path.isdir(base_dir):
        return []

    entries = []
    for fname in sorted(os.listdir(base_dir), reverse=True):
        if not fname.endswith(".json"):
            continue
        fpath = os.path.join(base_dir, fname)
        with open(fpath, encoding="utf-8") as f:
            entry = json.load(f)

        if class_filter and class_filter.lower() not in entry.get("class_name", "").lower():
            continue
        if since and entry.get("timestamp", "") < since:
            continue

        # Strip large fields for listing
        summary = {k: v for k, v in entry.items() if k not in ("before", "after", "diff")}
        entries.append(summary)
        if len(entries) >= count:
            break

    return entries


def get_change(server, namespace, entry_id):
    """Get a specific changelog entry by ID (includes full content).

    Args:
        server: Server name.
        namespace: IRIS namespace.
        entry_id: The short hex ID of the entry.

    Returns:
        The full entry dict, or None if not found.
    """
    base_dir = os.path.join(_get_changelog_dir(), server, namespace)
    if not os.path.isdir(base_dir):
        return None

    for fname in sorted(os.listdir(base_dir), reverse=True):
        if not fname.endswith(".json"):
            continue
        fpath = os.path.join(base_dir, fname)
        with open(fpath, encoding="utf-8") as f:
            entry = json.load(f)
        if entry.get("id") == entry_id:
            return entry

    return None


def format_summary(entry):
    """Format a one-line summary of a change for console output.

    Args:
        entry: A changelog entry dict.

    Returns:
        A string like "CHANGELOG: Created My.Class.cls (42 lines)"
        or "CHANGELOG: Updated My.Class.cls (+15 -3 lines)"
    """
    cls = entry.get("class_name", "?")
    added = entry.get("lines_added", 0)
    removed = entry.get("lines_removed", 0)

    if entry.get("is_new"):
        return f"CHANGELOG: Created {cls} ({entry.get('lines_after', 0)} lines)"

    parts = []
    if added:
        parts.append(f"+{added}")
    if removed:
        parts.append(f"-{removed}")
    delta = " ".join(parts) if parts else "no changes"
    return f"CHANGELOG: Updated {cls} ({delta})"


# ---------------------------------------------------------------------------
# IRIS metadata push (optional — requires InterClaw.ChangeLog class deployed)
# ---------------------------------------------------------------------------

def push_metadata_to_iris(entry, base_url, namespace, username, password):
    """Push change metadata to the InterClaw.ChangeLog table in IRIS via SQL.

    This is optional — the local JSON is the source of truth.
    Fails silently if the table doesn't exist.

    Args:
        entry: A changelog entry dict.
        base_url: Atelier API base URL.
        namespace: IRIS namespace.
        username: Auth username.
        password: Auth password.

    Returns:
        True if inserted successfully, False otherwise.
    """
    from iris_api import make_request

    sql = (
        "INSERT INTO InterClaw.ChangeLog "
        "(ClassName, Namespace, Action, LinesAdded, LinesRemoved, IsNew, ChangedBy, Summary) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    )
    # Atelier API doesn't support parameterized queries directly,
    # so we build a safe SQL string with escaped values.
    def esc(s):
        return str(s).replace("'", "''")

    cls = esc(entry.get("class_name", ""))
    ns = esc(entry.get("namespace", ""))
    action = esc(entry.get("action", ""))
    added = entry.get("lines_added", 0)
    removed = entry.get("lines_removed", 0)
    is_new = 1 if entry.get("is_new") else 0
    changed_by = esc(entry.get("changed_by", "InterClaw"))
    summary = esc(format_summary(entry)[:1000])

    sql = (
        f"INSERT INTO InterClaw.ChangeLog "
        f"(ClassName, Namespace, Action, LinesAdded, LinesRemoved, IsNew, ChangedBy, Summary) "
        f"VALUES ('{cls}', '{ns}', '{action}', {added}, {removed}, {is_new}, '{changed_by}', '{summary}')"
    )

    url = f"{base_url}/v1/{namespace}/action/query"
    status, body = make_request(url, username, password, method="POST", data={"query": sql})

    return status == 200


# ---------------------------------------------------------------------------
# CLI interface
# ---------------------------------------------------------------------------

def main():
    from iris_api import common_arg_parser

    parser = common_arg_parser("View InterClaw change history")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--list", action="store_true",
                      help="List recent changes")
    mode.add_argument("--show", metavar="ID",
                      help="Show full before/after for a change")
    mode.add_argument("--diff", metavar="ID",
                      help="Show unified diff for a change")
    mode.add_argument("--deploy", action="store_true",
                      help="Deploy InterClaw.ChangeLog table to the namespace")

    parser.add_argument("--class", dest="class_filter",
                        help="Filter by class name (substring match)")
    parser.add_argument("--count", type=int, default=20,
                        help="Number of entries to show (default: 20)")
    parser.add_argument("--since",
                        help="Only show changes after this time (ISO or HH:MM)")
    parser.add_argument("--format", choices=["table", "json"], default="table",
                        help="Output format (default: table)")
    args = parser.parse_args()

    ns = args.namespace or "unknown"

    if args.list:
        entries = list_changes(args.server, ns,
                               class_filter=args.class_filter,
                               count=args.count, since=args.since)
        if not entries:
            print("No changes recorded.")
            return

        if args.format == "json":
            print(json.dumps(entries, indent=2))
        else:
            print(f"{'ID':<10} {'Timestamp':<20} {'Action':<8} {'Class':<40} {'Changes'}")
            print("-" * 95)
            for e in entries:
                ts = e.get("timestamp", "?")[:19]
                added = e.get("lines_added", 0)
                removed = e.get("lines_removed", 0)
                is_new = e.get("is_new", False)
                delta = "new" if is_new else f"+{added} -{removed}"
                print(f"{e.get('id', '?'):<10} {ts:<20} {e.get('action', '?'):<8} "
                      f"{e.get('class_name', '?'):<40} {delta}")

    elif args.show:
        entry = get_change(args.server, ns, args.show)
        if not entry:
            print(f"Change '{args.show}' not found.", file=sys.stderr)
            sys.exit(1)

        if args.format == "json":
            print(json.dumps(entry, indent=2))
        else:
            print(f"=== {entry['class_name']} ({entry['action']}) at {entry['timestamp']}")
            is_new = entry.get("is_new", False)
            print(f"=== {'NEW FILE' if is_new else 'MODIFIED'} | "
                  f"+{entry.get('lines_added', 0)} -{entry.get('lines_removed', 0)}")
            print()
            if entry.get("before"):
                print("--- BEFORE (server) ---")
                print(entry["before"])
                print()
            else:
                print("--- BEFORE: (empty — new file) ---")
                print()
            print("--- AFTER (local) ---")
            print(entry.get("after", ""))

    elif args.diff:
        entry = get_change(args.server, ns, args.diff)
        if not entry:
            print(f"Change '{args.diff}' not found.", file=sys.stderr)
            sys.exit(1)

        diff_text = entry.get("diff", "")
        if diff_text:
            print(diff_text)
        else:
            print("No diff available (identical content or new file).")

    elif args.deploy:
        _deploy_changelog_table(args)


def _deploy_changelog_table(args):
    """Deploy the InterClaw.ChangeLog persistent class to the namespace."""
    from iris_api import get_server_and_creds, make_request

    if not args.namespace:
        print("ERROR: --namespace is required for --deploy", file=sys.stderr)
        sys.exit(1)

    server_config, base_url, username, password = get_server_and_creds(args)

    # Read the class source from the project
    cls_path = os.path.join(_get_project_root(), "src", "InterClaw", "ChangeLog.cls")
    if not os.path.exists(cls_path):
        print(f"ERROR: Class file not found: {cls_path}", file=sys.stderr)
        sys.exit(1)

    with open(cls_path, encoding="utf-8") as f:
        lines = f.read().split("\n")

    put_data = {"enc": False, "content": lines}
    url = f"{base_url}/v1/{args.namespace}/doc/InterClaw.ChangeLog.cls"
    status, body = make_request(url, username, password, method="PUT", data=put_data)

    if status in (200, 201):
        print(f"OK: Deployed InterClaw.ChangeLog to {args.namespace}")
        # Compile
        compile_url = f"{base_url}/v1/{args.namespace}/action/compile"
        c_status, _ = make_request(compile_url, username, password,
                                   method="POST", data=["InterClaw.ChangeLog.cls"])
        if c_status == 200:
            print("OK: Compiled InterClaw.ChangeLog")
        else:
            print(f"WARNING: Compile returned status {c_status}", file=sys.stderr)
    else:
        print(f"ERROR: Deploy failed with status {status}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
