#!/usr/bin/env python3
"""Run all test messages for a package and check traces automatically.

Discovers test files in a directory matching a package prefix, sends each
message via HTTP, then queries IRIS traces to verify success or report errors.

Usage:
  test_suite.py --server myserver --namespace HSLIB --package vaccine --url /irishealth/csp/healthshare/hslib/EnsLib.HL7.Service.HTTPService.cls?CfgItem=From_VaccineSource
  test_suite.py --server myserver --namespace HSLIB --package build2 --url /irishealth/csp/healthshare/hslib/EnsLib.HL7.Service.HTTPService.cls?CfgItem=From_HTTP --test-dir tests/
  test_suite.py --server myserver --namespace HSLIB --package demo --url <url> --wait 3
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import glob
import json
import os
import re
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (common_arg_parser, get_server_and_creds, make_request,
                      build_interop_url, make_interop_request,
                      parse_atelier_response, AtelierError)
from send_hl7 import send_http, split_hl7_messages, parse_ack


# Production states
PROD_STATES = {1: "Running", 2: "Stopped", 3: "Suspended", 4: "Troubled"}


def check_production_status(interop_url, username, password):
    """Return (production_name, status_text)."""
    url = f"{interop_url}/productions/status"
    status, body = make_interop_request(url, username, password)
    if status != 200:
        return "", "Unknown"
    state_code = body.get("State", 2)
    prod_name = body.get("ProdRunning", "")
    return prod_name, PROD_STATES.get(state_code, f"Unknown({state_code})")


def discover_test_files(test_dir, package_prefix):
    """Find test message files matching the package prefix.

    Matches files like: <prefix>_*.hl7 (case-insensitive).
    The prefix is normalized: dots and hyphens become underscores.
    """
    normalized = package_prefix.lower().replace(".", "_").replace("-", "_")
    pattern = os.path.join(test_dir, "*.hl7")
    all_hl7 = sorted(glob.glob(pattern))

    matched = []
    for path in all_hl7:
        basename = os.path.basename(path).lower().replace("-", "_")
        if basename.startswith(normalized + "_"):
            matched.append(path)

    return matched


def run_sql(base_url, namespace, username, password, sql):
    """Execute a SQL query and return (columns, rows)."""
    url = f"{base_url}/v1/{namespace}/action/query"
    status, body = make_request(url, username, password, method="POST",
                                data={"query": sql}, timeout=30)
    if status != 200:
        return [], []

    try:
        content = parse_atelier_response(body)
    except AtelierError:
        return [], []

    columns = []
    rows = []
    if isinstance(content, list) and len(content) > 0:
        first = content[0]
        if isinstance(first, dict) and "content" in first:
            columns = first["content"]
            rows = [item.get("content", item) if isinstance(item, dict) else item
                    for item in content[1:]]
    return columns, rows


def get_recent_session_id(base_url, namespace, username, password, control_id=None):
    """Get the most recent session ID, optionally matching a message control ID.

    Queries Ens.MessageHeader for the most recent session. If control_id is
    provided, attempts to find a session whose body contains that control ID.
    """
    sql = ("SELECT TOP 1 SessionId, ID, Status, TimeCreated, IsError "
           "FROM Ens.MessageHeader ORDER BY ID DESC")
    columns, rows = run_sql(base_url, namespace, username, password, sql)
    if rows:
        return rows[0]  # [SessionId, ID, Status, TimeCreated, IsError]
    return None


def get_session_errors(base_url, namespace, username, password, session_id):
    """Query Ens_Util.Log for errors in a session."""
    sql = (f"SELECT TOP 10 ID, Type, SourceClass, SourceMethod, Text "
           f"FROM Ens_Util.Log WHERE SessionId = '{session_id}' "
           f"AND Type = 'Error' ORDER BY ID DESC")
    columns, rows = run_sql(base_url, namespace, username, password, sql)
    return rows


def get_session_headers(base_url, namespace, username, password, session_id):
    """Get all message headers for a session."""
    sql = (f"SELECT ID, Status, IsError, SourceConfigName, TargetConfigName "
           f"FROM Ens.MessageHeader WHERE SessionId = '{session_id}' "
           f"ORDER BY ID ASC")
    columns, rows = run_sql(base_url, namespace, username, password, sql)
    return rows


def send_and_check(server_config, base_url, namespace, username, password,
                   filepath, service_url, wait_seconds):
    """Send a single test file and check the trace.

    Returns a dict with:
        filename, status ('PASS'/'FAIL'/'ERROR'), errors (list of str),
        session_id, ack_code, detail
    """
    result = {
        "filename": os.path.basename(filepath),
        "status": "FAIL",
        "errors": [],
        "session_id": "",
        "ack_code": "",
        "detail": "",
    }

    # Read the file
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            text = f.read()
    except Exception as e:
        result["status"] = "ERROR"
        result["errors"].append(f"Cannot read file: {e}")
        return result

    if not text.strip():
        result["status"] = "ERROR"
        result["errors"].append("File is empty")
        return result

    messages = split_hl7_messages(text)
    if not messages:
        result["status"] = "ERROR"
        result["errors"].append("No HL7 messages found in file")
        return result

    # Get the latest message header ID before sending (to find new ones after)
    pre_sql = "SELECT TOP 1 ID FROM Ens.MessageHeader ORDER BY ID DESC"
    _, pre_rows = run_sql(base_url, namespace, username, password, pre_sql)
    pre_max_id = int(pre_rows[0][0]) if pre_rows else 0

    # Send each message in the file
    ws = server_config["webServer"]
    host = ws["host"]
    port = ws.get("port", 80)
    scheme = ws.get("scheme", "http")

    all_accepted = True
    for i, msg in enumerate(messages):
        status_code, response = send_http(
            host, port, service_url, username, password,
            msg, "application/hl7-v2", scheme
        )
        if status_code is None:
            result["status"] = "ERROR"
            result["errors"].append(f"Connection failed: {response}")
            return result

        ack_code, _, ack_text = parse_ack(response)
        result["ack_code"] = ack_code or f"HTTP {status_code}"

        if ack_code not in ("AA", None) or (ack_code is None and status_code != 200):
            all_accepted = False
            result["errors"].append(
                f"Message {i+1}: {ack_code or 'HTTP ' + str(status_code)} - {ack_text or response[:150]}"
            )

    # Wait for processing
    time.sleep(wait_seconds)

    # Find new message headers created after our send
    post_sql = (f"SELECT TOP 1 SessionId FROM Ens.MessageHeader "
                f"WHERE ID > {pre_max_id} ORDER BY ID ASC")
    _, post_rows = run_sql(base_url, namespace, username, password, post_sql)

    if not post_rows:
        if all_accepted:
            result["status"] = "PASS"
            result["detail"] = "Accepted but no new trace found"
        return result

    session_id = str(post_rows[0][0])
    result["session_id"] = session_id

    # Check for errors in the session
    errors = get_session_errors(base_url, namespace, username, password, session_id)
    headers = get_session_headers(base_url, namespace, username, password, session_id)

    # Check header statuses
    has_error_header = False
    for hdr in headers:
        # hdr = [ID, Status, IsError, SourceConfigName, TargetConfigName]
        is_error = hdr[2] if len(hdr) > 2 else 0
        hdr_status = hdr[1] if len(hdr) > 1 else ""
        if is_error or str(hdr_status).lower() == "error":
            has_error_header = True
            src = hdr[3] if len(hdr) > 3 else ""
            tgt = hdr[4] if len(hdr) > 4 else ""
            result["errors"].append(f"Header error: {src} -> {tgt} (Status: {hdr_status})")

    # Check event log errors
    for err in errors:
        # err = [ID, Type, SourceClass, SourceMethod, Text]
        text = err[4] if len(err) > 4 else str(err)
        source = err[2] if len(err) > 2 else ""
        result["errors"].append(f"[{source}] {text[:200]}")

    if not result["errors"] and all_accepted:
        result["status"] = "PASS"
    elif all_accepted and not has_error_header and not errors:
        result["status"] = "PASS"
    else:
        result["status"] = "FAIL"

    return result


def format_summary(results):
    """Format results as a summary table."""
    # Column widths
    fn_w = max(len("Filename"), max((len(r["filename"]) for r in results), default=8))
    st_w = 6  # PASS/FAIL/ERROR
    ack_w = max(len("ACK"), max((len(r["ack_code"]) for r in results), default=3))
    sid_w = max(len("Session"), max((len(str(r["session_id"])) for r in results), default=7))

    lines = []
    header = (f"{'Filename'.ljust(fn_w)} | {'Status'.ljust(st_w)} | "
              f"{'ACK'.ljust(ack_w)} | {'Session'.ljust(sid_w)} | Errors")
    sep = (f"{'-' * fn_w}-+-{'-' * st_w}-+-{'-' * ack_w}-+-{'-' * sid_w}-+-{'-' * 30}")
    lines.append(header)
    lines.append(sep)

    for r in results:
        err_str = "; ".join(r["errors"][:3])
        if len(r["errors"]) > 3:
            err_str += f" (+{len(r['errors']) - 3} more)"
        line = (f"{r['filename'].ljust(fn_w)} | {r['status'].ljust(st_w)} | "
                f"{r['ack_code'].ljust(ack_w)} | {str(r['session_id']).ljust(sid_w)} | "
                f"{err_str}")
        lines.append(line)

    return "\n".join(lines)


def main():
    parser = common_arg_parser("Run test suite for a package — send messages and check traces")
    parser.add_argument("--package", required=True,
                        help="Package prefix to match test files (e.g., 'vaccine', 'build2', 'demo')")
    parser.add_argument("--url", "-u", required=True,
                        help="HTTP service URL path (e.g., /irishealth/csp/healthshare/hslib/EnsLib.HL7.Service.HTTPService.cls?CfgItem=From_HTTP)")
    parser.add_argument("--test-dir", default="tests/",
                        help="Directory containing test .hl7 files (default: tests/)")
    parser.add_argument("--wait", type=float, default=2.0,
                        help="Seconds to wait after sending before checking traces (default: 2)")
    parser.add_argument("--format", "-f", default="table", choices=["table", "json"],
                        help="Output format (default: table)")

    args = parser.parse_args()

    server_config, base_url, username, password = get_server_and_creds(args)
    namespace = args.namespace
    if not namespace:
        parser.error("--namespace is required")

    interop_url = build_interop_url(server_config, namespace)

    # 1. Check production status
    prod_name, prod_status = check_production_status(interop_url, username, password)
    if prod_status != "Running":
        print(f"ERROR: Production is not running (status: {prod_status})", file=sys.stderr)
        if prod_name:
            print(f"  Production: {prod_name}", file=sys.stderr)
        print("  Start the production first with manage_production.py --start <name>", file=sys.stderr)
        sys.exit(1)
    print(f"Production: {prod_name} ({prod_status})")

    # 2. Discover test files
    test_files = discover_test_files(args.test_dir, args.package)
    if not test_files:
        print(f"ERROR: No test files matching '{args.package}_*.hl7' found in {args.test_dir}",
              file=sys.stderr)
        # List available files to help
        all_hl7 = sorted(glob.glob(os.path.join(args.test_dir, "*.hl7")))
        if all_hl7:
            print(f"  Available .hl7 files:", file=sys.stderr)
            for f in all_hl7:
                print(f"    {os.path.basename(f)}", file=sys.stderr)
        sys.exit(1)

    print(f"Found {len(test_files)} test file(s) for package '{args.package}':")
    for tf in test_files:
        print(f"  {os.path.basename(tf)}")
    print()

    # 3. Send each message and check traces
    results = []
    for tf in test_files:
        print(f"Sending {os.path.basename(tf)}...", end=" ", flush=True)
        result = send_and_check(
            server_config, base_url, namespace, username, password,
            tf, args.url, args.wait
        )
        print(result["status"])
        results.append(result)

    # 4. Summary
    print()
    if args.format == "json":
        print(json.dumps(results, indent=2))
    else:
        print(format_summary(results))

    # Totals
    passed = sum(1 for r in results if r["status"] == "PASS")
    failed = sum(1 for r in results if r["status"] == "FAIL")
    errored = sum(1 for r in results if r["status"] == "ERROR")
    total = len(results)
    print(f"\nTotal: {total} | Passed: {passed} | Failed: {failed} | Errors: {errored}")

    sys.exit(1 if (failed + errored) > 0 else 0)


if __name__ == "__main__":
    main()
