#!/usr/bin/env python3
"""Query message traces from Ens.MessageHeader and format with Visual Trace links.

Usage:
  trace.py --server myserver --namespace HSLIB
  trace.py --server myserver --namespace HSLIB --component From_HTTP --count 10
  trace.py --server myserver --namespace HSLIB --session 12345
  trace.py --server myserver --namespace HSLIB --format json
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import json
import sys

from iris_api import (common_arg_parser, get_server_and_creds, make_request,
                      parse_atelier_response, AtelierError, load_servers)


def build_portal_base(server_config, namespace):
    """Build the portal base URL for Visual Trace links."""
    ws = server_config["webServer"]
    scheme = ws.get("scheme", "http")
    host = ws["host"]
    port = ws.get("port", 80)
    prefix = ws.get("pathPrefix", "")
    return f"{scheme}://{host}:{port}{prefix}/csp/healthshare/{namespace.lower()}"


def run_sql(base_url, namespace, username, password, sql):
    """Execute SQL and return parsed content."""
    url = f"{base_url}/v1/{namespace}/action/query"
    status, body = make_request(url, username, password, method="POST",
                                data={"query": sql})
    if status != 200:
        return status, body
    try:
        content = parse_atelier_response(body)
    except AtelierError as e:
        return None, str(e)
    return status, content


def query_traces(base_url, namespace, username, password, component=None,
                 session=None, count=20):
    """Query Ens.MessageHeader for recent messages."""
    cols = ("ID, TimeCreated, SessionId, SourceConfigName, TargetConfigName, "
            "MessageBodyClassName, Status")

    where_parts = []
    if component:
        where_parts.append(
            f"(SourceConfigName = '{component}' OR TargetConfigName = '{component}')")
    if session:
        where_parts.append(f"SessionId = {session}")

    where = f" WHERE {' AND '.join(where_parts)}" if where_parts else ""
    sql = f"SELECT TOP {count} {cols} FROM Ens.MessageHeader{where} ORDER BY ID DESC"

    return run_sql(base_url, namespace, username, password, sql)


def query_session_detail(base_url, namespace, username, password, session_id):
    """Get all messages in a session, ordered chronologically."""
    cols = ("ID, TimeCreated, SessionId, SourceConfigName, TargetConfigName, "
            "MessageBodyClassName, Status")
    sql = (f"SELECT {cols} FROM Ens.MessageHeader "
           f"WHERE SessionId = {session_id} ORDER BY ID ASC")
    return run_sql(base_url, namespace, username, password, sql)


def query_event_log(base_url, namespace, username, password, session_id):
    """Get event log entries for a session."""
    sql = (f"SELECT TOP 50 ID, TimeLogged, Type, ConfigName, Text "
           f"FROM Ens_Util.Log WHERE SessionId = {session_id} ORDER BY ID ASC")
    return run_sql(base_url, namespace, username, password, sql)


STATUS_MAP = {
    "1": "Created", "2": "Queued", "3": "Delivered", "4": "Discarded",
    "5": "Error", "6": "Suspended", "7": "Deferred", "8": "Aborted",
    "9": "Completed",
}


def format_status(status_val):
    """Convert numeric status to human-readable."""
    s = str(status_val).strip()
    return STATUS_MAP.get(s, s)


def extract_columns(content):
    """Extract column names and rows from Atelier query response."""
    if not isinstance(content, dict):
        return [], []

    # Try different response formats
    cols = content.get("cols", [])
    if isinstance(cols, list) and cols and isinstance(cols[0], dict):
        col_names = [c.get("name", c.get("Name", "")) for c in cols]
    elif isinstance(cols, list) and cols and isinstance(cols[0], str):
        col_names = cols
    else:
        col_names = content.get("columns", [])

    rows = content.get("content", content.get("rows", []))
    if not isinstance(rows, list):
        rows = []

    return col_names, rows


def format_table(col_names, rows, portal_base=None):
    """Format query results as aligned text table with Visual Trace links."""
    if not rows:
        return "No messages found."

    # Build row dicts
    data = []
    for row in rows:
        if isinstance(row, dict):
            data.append(row)
        elif isinstance(row, list):
            data.append(dict(zip(col_names, row)))
        else:
            continue

    # Determine display columns
    display_cols = ["ID", "TimeCreated", "SessionId", "Source", "Target", "Status"]
    display_rows = []
    session_ids = set()

    for d in data:
        sid = str(d.get("SessionId", d.get("sessionid", "")))
        session_ids.add(sid)
        status_raw = str(d.get("Status", d.get("status", "")))
        display_rows.append({
            "ID": str(d.get("ID", d.get("id", ""))),
            "TimeCreated": str(d.get("TimeCreated", d.get("timecreated", "")))[:19],
            "SessionId": sid,
            "Source": str(d.get("SourceConfigName", d.get("sourceconfigname", ""))),
            "Target": str(d.get("TargetConfigName", d.get("targetconfigname", ""))),
            "Status": format_status(status_raw),
        })

    # Calculate column widths
    widths = {c: len(c) for c in display_cols}
    for row in display_rows:
        for c in display_cols:
            widths[c] = max(widths[c], len(row.get(c, "")))

    # Header
    header = "  ".join(c.ljust(widths[c]) for c in display_cols)
    sep = "  ".join("-" * widths[c] for c in display_cols)
    lines = [header, sep]

    # Rows
    for row in display_rows:
        lines.append("  ".join(row.get(c, "").ljust(widths[c]) for c in display_cols))

    # Visual Trace links
    if portal_base and session_ids:
        lines.append("")
        lines.append("Visual Trace links:")
        for sid in sorted(session_ids, key=lambda x: int(x) if x.isdigit() else 0,
                          reverse=True):
            if sid and sid != "None":
                url = f"{portal_base}/EnsPortal.VisualTrace.zen?SESSIONID={sid}"
                lines.append(f"  Session {sid}: {url}")

    # Summary counts
    status_counts = {}
    for row in display_rows:
        s = row["Status"]
        status_counts[s] = status_counts.get(s, 0) + 1

    summary_parts = [f"{count} {status}" for status, count in
                     sorted(status_counts.items(), key=lambda x: -x[1])]
    lines.append("")
    lines.append(f"{len(display_rows)} message(s): {', '.join(summary_parts)}")

    return "\n".join(lines)


def format_json(col_names, rows):
    """Format query results as JSON."""
    data = []
    for row in rows:
        if isinstance(row, dict):
            r = dict(row)
        elif isinstance(row, list):
            r = dict(zip(col_names, row))
        else:
            continue
        # Resolve status
        if "Status" in r or "status" in r:
            key = "Status" if "Status" in r else "status"
            r["StatusText"] = format_status(str(r[key]))
        data.append(r)
    return json.dumps(data, indent=2)


def main():
    parser = common_arg_parser("Query message traces from Ens.MessageHeader")
    parser.add_argument("--component", "-C",
                        help="Filter by SourceConfigName or TargetConfigName")
    parser.add_argument("--session", "-S",
                        help="Show all messages in a specific session (chronological)")
    parser.add_argument("--count", type=int, default=20,
                        help="Number of messages to return (default: 20)")
    parser.add_argument("--events", action="store_true",
                        help="Also show event log entries (requires --session)")
    parser.add_argument("--format", "-f", choices=["table", "json"], default="table",
                        help="Output format (default: table)")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    server_config, base_url, username, password = get_server_and_creds(args)
    ns = args.namespace.upper()

    portal_base = build_portal_base(server_config, ns)

    if args.session:
        # Session detail mode — show all messages in chronological order
        print(f"Session {args.session} — all messages:\n", file=sys.stderr)
        status, content = query_session_detail(base_url, ns, username, password,
                                               args.session)
        if status != 200:
            print(f"ERROR: {status} — {content}", file=sys.stderr)
            sys.exit(1)

        col_names, rows = extract_columns(content)
        if args.format == "json":
            print(format_json(col_names, rows))
        else:
            print(format_table(col_names, rows, portal_base))

        # Event log entries if requested
        if args.events:
            print(f"\n--- Event Log (Session {args.session}) ---\n",
                  file=sys.stderr)
            ev_status, ev_content = query_event_log(base_url, ns, username,
                                                    password, args.session)
            if ev_status == 200:
                ev_cols, ev_rows = extract_columns(ev_content)
                if ev_rows:
                    for row in ev_rows:
                        if isinstance(row, dict):
                            d = row
                        elif isinstance(row, list):
                            d = dict(zip(ev_cols, row))
                        else:
                            continue
                        print(f"  [{d.get('Type', '')}] {d.get('ConfigName', '')}: "
                              f"{d.get('Text', '')}")
                else:
                    print("  No event log entries for this session.")
    else:
        # List mode — recent messages
        label = f"component={args.component}" if args.component else "all"
        print(f"Recent {args.count} messages ({label}):\n", file=sys.stderr)

        status, content = query_traces(base_url, ns, username, password,
                                       component=args.component,
                                       count=args.count)
        if status != 200:
            print(f"ERROR: {status} — {content}", file=sys.stderr)
            sys.exit(1)

        col_names, rows = extract_columns(content)
        if args.format == "json":
            print(format_json(col_names, rows))
        else:
            print(format_table(col_names, rows, portal_base))


if __name__ == "__main__":
    main()
