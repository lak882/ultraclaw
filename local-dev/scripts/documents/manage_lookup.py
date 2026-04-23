#!/usr/bin/env python3
"""Manage lookup tables on an IRIS server — list, get, set, clear, delete.

Usage:
  manage_lookup.py --server myserver --namespace HSLIB --list-tables
  manage_lookup.py --server myserver --namespace HSLIB --table FacilityMap --list
  manage_lookup.py --server myserver --namespace HSLIB --table FacilityMap --set HOSP1=Hospital_One HOSP2=Hospital_Two
  manage_lookup.py --server myserver --namespace HSLIB --table FacilityMap --clear
  manage_lookup.py --server myserver --namespace HSLIB --table FacilityMap --set HOSP1=Hospital_One --clear-first
  manage_lookup.py --server myserver --namespace HSLIB --table FacilityMap --count
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import json
import sys

from iris_api import (common_arg_parser, get_server_and_creds, make_request,
                      parse_atelier_response, AtelierError)


def run_sql(base_url, namespace, username, password, sql):
    """Execute SQL and return (status, content)."""
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


def extract_rows(content):
    """Extract rows from Atelier query response."""
    if not isinstance(content, dict):
        return []
    rows = content.get("content", content.get("rows", []))
    cols = content.get("cols", content.get("columns", []))
    if isinstance(cols, list) and cols and isinstance(cols[0], dict):
        col_names = [c.get("name", c.get("Name", "")) for c in cols]
    elif isinstance(cols, list):
        col_names = cols
    else:
        col_names = []

    result = []
    for row in (rows if isinstance(rows, list) else []):
        if isinstance(row, dict):
            result.append(row)
        elif isinstance(row, list) and col_names:
            result.append(dict(zip(col_names, row)))
    return result


def escape_sql(value):
    """Escape single quotes for SQL string literals."""
    return str(value).replace("'", "''")


def list_tables(base_url, ns, username, password):
    """List all distinct table names."""
    sql = "SELECT DISTINCT TableName FROM Ens_Util.LookupTable ORDER BY TableName"
    status, content = run_sql(base_url, ns, username, password, sql)
    if status != 200:
        print(f"ERROR: {status} — {content}", file=sys.stderr)
        return 1

    rows = extract_rows(content)
    if not rows:
        print("No lookup tables found.")
        return 0

    print(f"Lookup tables ({len(rows)}):")
    for row in rows:
        name = row.get("TableName", row.get("tablename", ""))
        print(f"  {name}")
    return 0


def list_entries(base_url, ns, username, password, table, fmt):
    """List all entries in a lookup table."""
    sql = (f"SELECT KeyName, DataValue FROM Ens_Util.LookupTable "
           f"WHERE TableName = '{escape_sql(table)}' ORDER BY KeyName")
    status, content = run_sql(base_url, ns, username, password, sql)
    if status != 200:
        print(f"ERROR: {status} — {content}", file=sys.stderr)
        return 1

    rows = extract_rows(content)
    if not rows:
        print(f"Table '{table}' is empty or does not exist.")
        return 0

    if fmt == "json":
        data = {}
        for row in rows:
            k = row.get("KeyName", row.get("keyname", ""))
            v = row.get("DataValue", row.get("datavalue", ""))
            data[k] = v
        print(json.dumps(data, indent=2))
    else:
        # Aligned table
        max_key = max(len(row.get("KeyName", row.get("keyname", "")))
                      for row in rows)
        max_key = max(max_key, 3)  # minimum "Key" header width
        print(f"Table: {table} ({len(rows)} entries)")
        print(f"  {'Key'.ljust(max_key)}  Value")
        print(f"  {'-' * max_key}  -----")
        for row in rows:
            k = row.get("KeyName", row.get("keyname", ""))
            v = row.get("DataValue", row.get("datavalue", ""))
            print(f"  {k.ljust(max_key)}  {v}")
    return 0


def count_entries(base_url, ns, username, password, table):
    """Count entries in a lookup table."""
    sql = (f"SELECT COUNT(*) AS cnt FROM Ens_Util.LookupTable "
           f"WHERE TableName = '{escape_sql(table)}'")
    status, content = run_sql(base_url, ns, username, password, sql)
    if status != 200:
        print(f"ERROR: {status} — {content}", file=sys.stderr)
        return 1
    rows = extract_rows(content)
    cnt = rows[0].get("cnt", rows[0].get("Cnt", 0)) if rows else 0
    print(f"{table}: {cnt} entries")
    return 0


def set_entries(base_url, ns, username, password, table, pairs):
    """Upsert key=value pairs into a lookup table."""
    ok = 0
    fail = 0
    for pair in pairs:
        if "=" not in pair:
            print(f"  SKIP: '{pair}' — expected key=value format", file=sys.stderr)
            fail += 1
            continue
        key, value = pair.split("=", 1)
        key = key.strip()
        value = value.strip()

        # INSERT OR UPDATE (run_query.py does this auto-conversion, but we use
        # iris_api directly, so just do INSERT OR UPDATE)
        sql = (f"INSERT OR UPDATE INTO Ens_Util.LookupTable "
               f"(TableName, KeyName, DataValue) VALUES "
               f"('{escape_sql(table)}', '{escape_sql(key)}', '{escape_sql(value)}')")
        status, content = run_sql(base_url, ns, username, password, sql)
        if status == 200:
            print(f"  {key} = {value}")
            ok += 1
        else:
            print(f"  FAILED: {key} = {value} ({status})", file=sys.stderr)
            fail += 1

    print(f"\n{ok} set, {fail} failed")
    return 1 if fail > 0 else 0


def clear_table(base_url, ns, username, password, table):
    """Delete all entries from a lookup table."""
    sql = f"DELETE FROM Ens_Util.LookupTable WHERE TableName = '{escape_sql(table)}'"
    status, content = run_sql(base_url, ns, username, password, sql)
    if status == 200:
        print(f"Cleared table: {table}")
        return 0
    else:
        print(f"ERROR clearing {table}: {status} — {content}", file=sys.stderr)
        return 1


def main():
    parser = common_arg_parser("Manage lookup tables on an IRIS server")
    parser.add_argument("--list-tables", action="store_true",
                        help="List all lookup table names")
    parser.add_argument("--table", "-t",
                        help="Lookup table name to operate on")
    parser.add_argument("--list", "-l", action="store_true",
                        help="List entries in the table")
    parser.add_argument("--count", action="store_true",
                        help="Count entries in the table")
    parser.add_argument("--set", nargs="+", metavar="KEY=VALUE",
                        help="Set key=value pairs (upsert)")
    parser.add_argument("--clear", action="store_true",
                        help="Delete all entries from the table")
    parser.add_argument("--clear-first", action="store_true",
                        help="Clear table before setting new values")
    parser.add_argument("--format", "-f", choices=["table", "json"], default="table",
                        help="Output format for --list (default: table)")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    if not args.list_tables and not args.table:
        parser.error("Either --list-tables or --table is required")

    _, base_url, username, password = get_server_and_creds(args)
    ns = args.namespace.upper()

    if args.list_tables:
        sys.exit(list_tables(base_url, ns, username, password))

    table = args.table

    # Clear first if requested
    if args.clear_first and args.set:
        rc = clear_table(base_url, ns, username, password, table)
        if rc != 0:
            sys.exit(rc)

    # Clear only
    if args.clear and not args.set:
        sys.exit(clear_table(base_url, ns, username, password, table))

    # Set entries
    if args.set:
        sys.exit(set_entries(base_url, ns, username, password, table, args.set))

    # Count
    if args.count:
        sys.exit(count_entries(base_url, ns, username, password, table))

    # Default: list entries
    sys.exit(list_entries(base_url, ns, username, password, table, args.format))


if __name__ == "__main__":
    main()
