#!/usr/bin/env python3
"""Execute SQL queries against an IRIS server via the Atelier API."""
import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import csv
import io
import json
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (common_arg_parser, get_server_and_creds, make_request,
                      parse_atelier_response, AtelierError)


def format_table(columns, rows):
    """Format query results as an aligned text table."""
    if not columns:
        return ""

    # Calculate column widths
    widths = [len(str(c)) for c in columns]
    for row in rows:
        for i, val in enumerate(row):
            if i < len(widths):
                widths[i] = max(widths[i], len(str(val)))

    # Build header
    header = " | ".join(str(c).ljust(widths[i]) for i, c in enumerate(columns))
    separator = "-+-".join("-" * w for w in widths)

    lines = [header, separator]
    for row in rows:
        line = " | ".join(str(val).ljust(widths[i]) if i < len(widths) else str(val)
                          for i, val in enumerate(row))
        lines.append(line)

    return "\n".join(lines)


def format_csv_output(columns, rows):
    """Format query results as CSV."""
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(columns)
    for row in rows:
        writer.writerow(row)
    return output.getvalue()


def main():
    parser = common_arg_parser("Execute SQL via the Atelier API")
    parser.add_argument("--sql", "-q", required=True,
                        help="SQL query to execute")
    parser.add_argument("--format", "-f", default="table",
                        choices=["table", "json", "csv"],
                        help="Output format (default: table)")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    server_config, base_url, username, password = get_server_and_creds(args)

    # Auto-convert INSERT INTO Ens_Util.LookupTable to INSERT OR UPDATE
    sql = args.sql.strip()
    sql_upper = sql.upper()
    if (sql_upper.startswith("INSERT INTO") and "OR UPDATE" not in sql_upper
            and "ENS_UTIL.LOOKUPTABLE" in sql_upper):
        sql = sql[:6] + " OR UPDATE" + sql[6:]

    import time as _time
    url = f"{base_url}/v1/{args.namespace}/action/query"
    query_data = {"query": sql}
    _query_start = _time.time()
    status, body = make_request(url, username, password, method="POST", data=query_data)
    _query_duration_ms = (_time.time() - _query_start) * 1000

    if status is None:
        print(f"ERROR: Could not reach server - {body}", file=sys.stderr)
        sys.exit(1)

    if status == 401:
        print("ERROR: Authentication failed (401)", file=sys.stderr)
        sys.exit(1)

    if status != 200:
        print(f"ERROR: Query failed with status {status}", file=sys.stderr)
        if isinstance(body, dict):
            try:
                parse_atelier_response(body)
            except AtelierError as e:
                print(f"  {e}", file=sys.stderr)
        sys.exit(1)

    try:
        content = parse_atelier_response(body)
    except AtelierError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

    # Parse columns and rows from response
    # Atelier query response format: content is a list where first element
    # has column info, rest are data rows
    columns = []
    rows = []

    if isinstance(content, list) and len(content) > 0:
        # First element contains column names
        first = content[0]
        if isinstance(first, dict) and "content" in first:
            columns = first["content"]
            rows = [item.get("content", item) if isinstance(item, dict) else item
                    for item in content[1:]]
        else:
            # Try alternate format: content is list of row arrays
            # with column names in result.columns or similar
            columns = body.get("result", {}).get("columns", [])
            rows = content
    elif isinstance(content, dict):
        columns = content.get("columns", [])
        rows = content.get("rows", content.get("content", []))

    # Emit doc_query audit event
    try:
        from audit import log_event
        log_event("doc_query",
                  server=args.server,
                  namespace=args.namespace,
                  sql=sql,
                  row_count=len(rows),
                  status=status,
                  duration_ms=_query_duration_ms)
    except Exception:
        pass  # Best-effort

    # Output
    if args.format == "json":
        result = []
        for row in rows:
            if isinstance(row, list) and columns:
                result.append(dict(zip(columns, row)))
            else:
                result.append(row)
        print(json.dumps(result, indent=2))
    elif args.format == "csv":
        print(format_csv_output(columns, rows))
    else:
        if columns or rows:
            print(format_table(columns, rows))
            print(f"\n{len(rows)} row(s)", file=sys.stderr)
        else:
            print("Query executed successfully (no results)")


if __name__ == "__main__":
    main()
