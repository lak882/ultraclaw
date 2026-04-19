#!/usr/bin/env python3
"""Query error-level events from the IRIS event log and errored/suspended messages.

Queries Ens_Util.Log for Error/Warning events and Ens.MessageHeader for
messages with Status = Error (5) or Suspended (6). Optionally filters by
package name and time window.
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import json
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (common_arg_parser, get_server_and_creds, make_request,
                      parse_atelier_response, AtelierError)


def format_table(columns, rows):
    """Format results as an aligned text table."""
    if not columns:
        return ""
    widths = [len(str(c)) for c in columns]
    for row in rows:
        for i, val in enumerate(row):
            if i < len(widths):
                widths[i] = max(widths[i], len(str(val)))
    header = " | ".join(str(c).ljust(widths[i]) for i, c in enumerate(columns))
    separator = "-+-".join("-" * w for w in widths)
    lines = [header, separator]
    for row in rows:
        line = " | ".join(
            str(val).ljust(widths[i]) if i < len(widths) else str(val)
            for i, val in enumerate(row)
        )
        lines.append(line)
    return "\n".join(lines)


def run_query(base_url, namespace, username, password, sql):
    """Execute a SQL query and return (columns, rows)."""
    url = f"{base_url}/v1/{namespace}/action/query"
    query_data = {"query": sql}
    status, body = make_request(url, username, password, method="POST",
                                data=query_data, timeout=30)

    if status is None:
        print(f"ERROR: Could not reach server - {body}", file=sys.stderr)
        sys.exit(2)
    if status == 401:
        print("ERROR: Authentication failed (401)", file=sys.stderr)
        sys.exit(2)
    if status != 200:
        print(f"ERROR: Query failed with status {status}", file=sys.stderr)
        if isinstance(body, dict):
            try:
                parse_atelier_response(body)
            except AtelierError as e:
                print(f"  {e}", file=sys.stderr)
        sys.exit(2)

    try:
        content = parse_atelier_response(body)
    except AtelierError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(2)

    columns = []
    rows = []
    if isinstance(content, list) and len(content) > 0:
        first = content[0]
        if isinstance(first, dict) and "content" in first:
            columns = first["content"]
            rows = [item.get("content", item) if isinstance(item, dict) else item
                    for item in content[1:]]
        else:
            columns = body.get("result", {}).get("columns", [])
            rows = content
    elif isinstance(content, dict):
        columns = content.get("columns", [])
        rows = content.get("rows", content.get("content", []))

    return columns, rows


def build_time_filter(since_value):
    """Build a SQL time filter clause from --since value.

    Accepts HH:MM (today) or YYYY-MM-DD (from that date).
    Returns a SQL fragment like "TimeLogged >= '2026-04-02 14:30:00'"
    """
    since = since_value.strip()
    if ":" in since and len(since) <= 5:
        # HH:MM format — today
        return f"CURRENT_DATE || ' {since}:00'"
    else:
        # YYYY-MM-DD or other date format
        return f"'{since} 00:00:00'"


def main():
    parser = common_arg_parser("Query errors from the IRIS event log and message headers")
    parser.add_argument("--package", help="Filter by package name (ConfigName LIKE 'package.%%')")
    parser.add_argument("--count", type=int, default=20,
                        help="Number of recent errors to show (default: 20)")
    parser.add_argument("--since",
                        help="Only show errors since this time (HH:MM or YYYY-MM-DD)")
    parser.add_argument("--format", "-f", default="table",
                        choices=["table", "json"],
                        help="Output format (default: table)")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    _, base_url, username, password = get_server_and_creds(args)

    # --- Query 1: Event Log errors/warnings ---
    log_conditions = ["Type IN ('Error', 'Warning')"]
    if args.package:
        log_conditions.append(f"ConfigName LIKE '{args.package}.%'")
    if args.since:
        time_expr = build_time_filter(args.since)
        log_conditions.append(f"TimeLogged >= {time_expr}")

    where_clause = " AND ".join(log_conditions)
    log_sql = (
        f"SELECT TOP {args.count} ID, TimeLogged, Type, ConfigName, "
        f"SourceClass, SourceMethod, Text "
        f"FROM Ens_Util.Log "
        f"WHERE {where_clause} "
        f"ORDER BY ID DESC"
    )

    log_columns, log_rows = run_query(base_url, args.namespace, username, password, log_sql)

    # --- Query 2: Errored/Suspended messages ---
    msg_conditions = ["Status IN (5, 6)"]
    if args.package:
        msg_conditions.append(
            f"(SourceConfigName LIKE '{args.package}.%' "
            f"OR TargetConfigName LIKE '{args.package}.%')"
        )
    if args.since:
        time_expr = build_time_filter(args.since)
        msg_conditions.append(f"TimeCreated >= {time_expr}")

    msg_where = " AND ".join(msg_conditions)
    msg_sql = (
        f"SELECT TOP {args.count} ID, TimeCreated, SessionId, "
        f"SourceConfigName, TargetConfigName, "
        f"CASE Status WHEN 5 THEN 'Error' WHEN 6 THEN 'Suspended' ELSE Status END AS Status "
        f"FROM Ens.MessageHeader "
        f"WHERE {msg_where} "
        f"ORDER BY ID DESC"
    )

    msg_columns, msg_rows = run_query(base_url, args.namespace, username, password, msg_sql)

    # --- Output ---
    found_errors = False

    if args.format == "json":
        output = {"event_log": [], "messages": []}
        for row in log_rows:
            if isinstance(row, list) and log_columns:
                output["event_log"].append(dict(zip(log_columns, row)))
            else:
                output["event_log"].append(row)
        for row in msg_rows:
            if isinstance(row, list) and msg_columns:
                output["messages"].append(dict(zip(msg_columns, row)))
            else:
                output["messages"].append(row)
        print(json.dumps(output, indent=2))
        found_errors = bool(output["event_log"] or output["messages"])
    else:
        # Table format
        print("=== Event Log Errors/Warnings ===\n")
        if log_rows:
            print(format_table(log_columns, log_rows))
            print(f"\n{len(log_rows)} event(s)\n")
            found_errors = True
        else:
            print("No error/warning events found.\n")

        print("=== Errored/Suspended Messages ===\n")
        if msg_rows:
            print(format_table(msg_columns, msg_rows))
            print(f"\n{len(msg_rows)} message(s)\n")
            found_errors = True
        else:
            print("No errored/suspended messages found.\n")

        # Suggestion line for first error component
        if found_errors:
            first_config = None
            # Try event log ConfigName first
            for row in log_rows:
                if isinstance(row, list) and log_columns:
                    d = dict(zip(log_columns, row))
                elif isinstance(row, dict):
                    d = row
                else:
                    continue
                cn = d.get("ConfigName", d.get("configname", ""))
                if cn:
                    first_config = cn
                    break
            # Fall back to message SourceConfigName
            if not first_config:
                for row in msg_rows:
                    if isinstance(row, list) and msg_columns:
                        d = dict(zip(msg_columns, row))
                    elif isinstance(row, dict):
                        d = row
                    else:
                        continue
                    cn = d.get("SourceConfigName", d.get("sourceconfigname", ""))
                    if cn:
                        first_config = cn
                        break
            if first_config:
                print(f"Suggestion: Run /trace --component {first_config} for details")
            else:
                print("Suggestion: Run /trace to see recent message flow")

    if not found_errors:
        print("System is clean — no errors or suspended messages.")

    # Exit code: 0 = no errors, 1 = errors found
    sys.exit(1 if found_errors else 0)


if __name__ == "__main__":
    main()
