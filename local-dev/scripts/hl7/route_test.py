#!/usr/bin/env python3
"""Run route-coverage tests from a manifest file.

Reads a route-manifest.json, sends each test message via file drop,
then verifies routing outcomes: which targets received the message,
whether alerts fired, and optional SQL assertions.

Usage:
  route_test.py --server myserver --namespace TESTING --manifest tests/Sanford/route-manifest.json
  route_test.py --server myserver --namespace TESTING --manifest tests/Sanford/route-manifest.json --test B1-R1
  route_test.py --server myserver --namespace TESTING --manifest tests/Sanford/route-manifest.json --format json
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import json
import os
import shutil
import sys
import time

from iris_api import (common_arg_parser, get_server_and_creds, make_request,
                      build_interop_url, make_interop_request,
                      parse_atelier_response, AtelierError)


def run_sql(base_url, namespace, username, password, sql):
    """Execute SQL and return list of row dicts."""
    url = f"{base_url}/v1/{namespace}/action/query"
    status, body = make_request(url, username, password, method="POST",
                                data={"query": sql}, timeout=30)
    if status != 200:
        return []
    try:
        content = parse_atelier_response(body)
    except AtelierError:
        return []
    if not isinstance(content, list) or len(content) < 1:
        return []
    first = content[0]
    # Modern format: list of row dicts [{col: val, ...}, ...]
    if isinstance(first, dict) and "content" not in first:
        return content
    # Legacy format: [{content: [col_names]}, {content: [val1, val2]}, ...]
    if isinstance(first, dict) and "content" in first:
        columns = first["content"]
        rows = []
        for item in content[1:]:
            vals = item.get("content", item) if isinstance(item, dict) else item
            if isinstance(vals, list):
                rows.append(dict(zip(columns, vals)))
        return rows
    return []


def get_max_header_id(base_url, namespace, username, password):
    """Get the current max message header ID."""
    rows = run_sql(base_url, namespace, username, password,
                   "SELECT TOP 1 ID FROM Ens.MessageHeader ORDER BY ID DESC")
    return int(rows[0]["ID"]) if rows else 0


def extract_filepath_from_settings(settings_blob):
    """Extract FilePath value from Ens_Config.Item Settings blob.

    The Settings field stores settings as a binary-encoded string.
    FilePath values appear after 'FilePath' + control chars + 'Adapter' + length byte.
    We extract the path using a simple string search.
    """
    if not settings_blob:
        return None
    # Find 'FilePath' in the blob
    idx = settings_blob.find("FilePath")
    if idx < 0:
        return None
    # The path follows after some control characters
    # Pattern: FilePath<tab><ctrl>Adapter<length-byte><actual-path>
    after = settings_blob[idx + len("FilePath"):]
    # Find the start of the actual path (starts with /)
    path_start = after.find("/")
    if path_start < 0:
        return None
    # Extract until next control char or end
    path = []
    for ch in after[path_start:]:
        if ord(ch) < 32 and ch not in ('\t',):
            break
        path.append(ch)
    result = "".join(path).strip()
    return result if result else None


def get_service_filepath_from_production(base_url, namespace, username, password,
                                          production_name, service_name):
    """Get FilePath from Ens_Config.Item Settings blob."""
    sql = (f"SELECT Settings FROM Ens_Config.Item "
           f"WHERE Production = '{production_name}' "
           f"AND Name = '{service_name}'")
    rows = run_sql(base_url, namespace, username, password, sql)
    if rows:
        settings = rows[0].get("Settings", "")
        return extract_filepath_from_settings(settings)
    return None


def get_session_messages(base_url, namespace, username, password, after_id, wait=6):
    """Get all new message headers after the given ID, grouped by session."""
    time.sleep(wait)
    sql = (f"SELECT ID, SessionId, SourceConfigName, TargetConfigName, Status, IsError "
           f"FROM Ens.MessageHeader WHERE ID > {after_id} ORDER BY ID ASC")
    return run_sql(base_url, namespace, username, password, sql)


def get_session_alerts(base_url, namespace, username, password, session_id):
    """Check for alert entries in event log for a session.

    Ens_Util.Log Type values: 2=Error, 3=Warning, 4=Info, 6=Alert.
    """
    sql = (f"SELECT ID, Type, Text FROM Ens_Util.Log "
           f"WHERE SessionId = '{session_id}' AND Type IN (3, 6) "
           f"ORDER BY ID DESC")
    return run_sql(base_url, namespace, username, password, sql)


def resolve_test_file(manifest_dir, test_file):
    """Resolve the full path to a test file relative to the manifest directory."""
    return os.path.join(manifest_dir, test_file)


def copy_to_service(filepath, service_dir):
    """Copy a test file to a service's input directory."""
    import shutil
    os.makedirs(service_dir, exist_ok=True)
    dest = os.path.join(service_dir, os.path.basename(filepath))
    shutil.copy2(filepath, dest)
    return dest


def run_test(test, manifest_dir, service_paths, base_url, namespace, username, password, wait):
    """Run a single route test. Returns a result dict."""
    result = {
        "id": test["id"],
        "name": test["name"],
        "branch": test.get("branch", ""),
        "status": "FAIL",
        "errors": [],
        "actual_targets": [],
        "session_id": "",
    }

    # Resolve test file
    test_file = resolve_test_file(manifest_dir, test["file"])
    if not os.path.exists(test_file):
        result["status"] = "ERROR"
        result["errors"].append(f"Test file not found: {test_file}")
        return result

    # Find service input directory
    service_name = test["service"]
    service_dir = service_paths.get(service_name)
    if not service_dir:
        result["status"] = "ERROR"
        result["errors"].append(f"Cannot find FilePath for service: {service_name}")
        return result

    # Record pre-send max header ID
    pre_max = get_max_header_id(base_url, namespace, username, password)

    # Copy file to service input
    try:
        copy_to_service(test_file, service_dir)
    except Exception as e:
        result["status"] = "ERROR"
        result["errors"].append(f"Failed to copy file: {e}")
        return result

    # Wait and get new messages
    messages = get_session_messages(base_url, namespace, username, password, pre_max, wait=wait)

    if not messages:
        # No messages — could be expected (discard at service level?) or a problem
        expect = test.get("expect", {})
        expected_targets = expect.get("targets", [])
        if not expected_targets and not expect.get("alert", False):
            # Expected no downstream routing — but service should still pick up
            # Check if a session was created at all
            result["status"] = "PASS"
            result["actual_targets"] = []
            return result
        else:
            result["errors"].append("No messages found after sending")
            return result

    # Group by session — find the session that starts with our service
    sessions = {}
    for msg in messages:
        sid = str(msg.get("SessionId", ""))
        if sid not in sessions:
            sessions[sid] = []
        sessions[sid].append(msg)

    # Find the session from our service
    our_session = None
    our_session_id = None
    for sid, msgs in sessions.items():
        for m in msgs:
            if m.get("SourceConfigName") == service_name:
                our_session = msgs
                our_session_id = sid
                break
        if our_session:
            break

    if not our_session:
        # Service may not appear in headers if it's the initial source
        # Take the first session after our send
        first_sid = messages[0].get("SessionId", "")
        our_session_id = str(first_sid)
        our_session = sessions.get(our_session_id, messages)

    result["session_id"] = our_session_id

    # Extract actual targets
    actual_targets = set()
    has_error = False
    for msg in our_session:
        target = msg.get("TargetConfigName", "")
        source = msg.get("SourceConfigName", "")
        is_error = msg.get("IsError", 0)
        # Target is what we care about for routing verification
        if target and target != service_name:
            actual_targets.add(target)
        if is_error:
            has_error = True
            result["errors"].append(f"Error in message {msg.get('ID')}: {source} -> {target}")

    result["actual_targets"] = sorted(actual_targets)

    # Check expected outcomes
    expect = test.get("expect", {})
    expected_targets = set(expect.get("targets", []))

    # Routing check — filter out infrastructure/intermediary targets
    # These appear in message headers but aren't business destinations
    infra_targets = {"Ens.Alert", "BadMessageHandler"}
    final_actual = set()
    for t in actual_targets:
        if t in infra_targets:
            continue
        # Skip routing engines (intermediaries, not destinations)
        if ".Rule." in t or t.endswith("RoutingRule"):
            continue
        final_actual.add(t)

    if expected_targets != final_actual:
        missing = expected_targets - final_actual
        extra = final_actual - expected_targets
        if missing:
            result["errors"].append(f"Missing expected targets: {sorted(missing)}")
        # Extra targets are OK if they're intermediaries (BPLs, routers)
        # Only flag unexpected operations
        unexpected_ops = {t for t in extra if ".BO." in t or ".Operation" in t.lower()}
        if unexpected_ops:
            result["errors"].append(f"Unexpected operation targets: {sorted(unexpected_ops)}")

    # Alert check
    alert_target_present = "Ens.Alert" in actual_targets
    if expect.get("alert", False):
        alerts = get_session_alerts(base_url, namespace, username, password, our_session_id)
        if not alerts and not alert_target_present:
            result["errors"].append("Expected alert but none found")
        elif expect.get("alert_contains"):
            alert_text = " ".join(a.get("Text", "") for a in alerts) if alerts else ""
            if expect["alert_contains"].lower() not in alert_text.lower():
                result["errors"].append(
                    f"Alert text doesn't contain '{expect['alert_contains']}': {alert_text[:200]}")
    elif not expect.get("alert", True):
        # Alert NOT expected — verify no alerts
        alerts = get_session_alerts(base_url, namespace, username, password, our_session_id)
        if alerts or alert_target_present:
            alert_texts = [a.get("Text", "")[:100] for a in alerts] if alerts else ["(Ens.Alert target)"]
            result["errors"].append(f"Unexpected alert(s): {alert_texts}")

    # SQL assertion check
    if "sql_after" in expect:
        sql_rows = run_sql(base_url, namespace, username, password, expect["sql_after"])
        sql_expect = expect.get("sql_expect", {})
        if sql_rows:
            row = sql_rows[0]
            for key, expected_val in sql_expect.items():
                actual_val = row.get(key)
                # Compare as strings for flexibility
                if str(actual_val) != str(expected_val):
                    result["errors"].append(
                        f"SQL check failed: {key} = {actual_val} (expected {expected_val})")
        elif sql_expect:
            result["errors"].append(f"SQL query returned no rows: {expect['sql_after']}")

    # Final status
    if not result["errors"]:
        result["status"] = "PASS"

    return result


def format_results(results, verbose=False):
    """Format results as a summary table."""
    lines = []

    # Header
    id_w = max(6, max((len(r["id"]) for r in results), default=6))
    name_w = min(55, max(20, max((len(r["name"]) for r in results), default=20)))
    st_w = 5

    header = f"{'ID'.ljust(id_w)} | {'Status'.ljust(st_w)} | {'Branch / Test Name'}"
    sep = f"{'-' * id_w}-+-{'-' * st_w}-+-{'-' * 60}"
    lines.append(header)
    lines.append(sep)

    for r in results:
        status_marker = "PASS" if r["status"] == "PASS" else r["status"]
        name = r["name"][:55]
        line = f"{r['id'].ljust(id_w)} | {status_marker.ljust(st_w)} | {name}"
        lines.append(line)

        if r["errors"] and verbose:
            for err in r["errors"]:
                lines.append(f"{''.ljust(id_w)}   {''.ljust(st_w)}   -> {err[:80]}")

    return "\n".join(lines)


def format_coverage(results):
    """Format branch coverage summary."""
    lines = []
    total = len(results)
    passed = sum(1 for r in results if r["status"] == "PASS")
    failed = sum(1 for r in results if r["status"] == "FAIL")
    errored = sum(1 for r in results if r["status"] == "ERROR")

    lines.append("")
    lines.append(f"Coverage: {passed}/{total} branches PASS "
                 f"({passed/total*100:.0f}%)" if total > 0 else "No tests")
    if failed:
        lines.append(f"  Failed: {failed}")
    if errored:
        lines.append(f"  Errors: {errored}")

    # Group by component
    by_component = {}
    for r in results:
        branch = r.get("branch", "")
        component = branch.split(":")[0].strip() if ":" in branch else r["id"].split("-")[0]
        if component not in by_component:
            by_component[component] = {"pass": 0, "fail": 0, "total": 0}
        by_component[component]["total"] += 1
        if r["status"] == "PASS":
            by_component[component]["pass"] += 1
        else:
            by_component[component]["fail"] += 1

    if by_component:
        lines.append("")
        lines.append("By component:")
        for comp, stats in sorted(by_component.items()):
            pct = stats["pass"] / stats["total"] * 100 if stats["total"] > 0 else 0
            status = "ALL PASS" if stats["fail"] == 0 else f"{stats['fail']} FAIL"
            lines.append(f"  {comp}: {stats['pass']}/{stats['total']} ({pct:.0f}%) — {status}")

    return "\n".join(lines)


def main():
    parser = common_arg_parser("Run route-coverage tests from a manifest file")
    parser.add_argument("--manifest", "-m", required=True,
                        help="Path to route-manifest.json")
    parser.add_argument("--test", "-t",
                        help="Run only the test with this ID (e.g., B1-R1)")
    parser.add_argument("--wait", type=float, default=6.0,
                        help="Seconds to wait after each message for processing (default: 6)")
    parser.add_argument("--format", "-f", default="table", choices=["table", "json"],
                        help="Output format (default: table)")
    parser.add_argument("--verbose", "-v", action="store_true",
                        help="Show error details in table output")

    args = parser.parse_args()

    server_config, base_url, username, password = get_server_and_creds(args)
    namespace = args.namespace
    if not namespace:
        parser.error("--namespace is required")

    # Load manifest
    manifest_path = args.manifest
    if not os.path.exists(manifest_path):
        print(f"ERROR: Manifest not found: {manifest_path}", file=sys.stderr)
        sys.exit(1)

    with open(manifest_path) as f:
        manifest = json.load(f)

    manifest_dir = os.path.dirname(os.path.abspath(manifest_path))
    production = manifest.get("production", "")
    tests = manifest.get("tests", [])

    if args.test:
        tests = [t for t in tests if t["id"] == args.test]
        if not tests:
            print(f"ERROR: Test ID '{args.test}' not found in manifest", file=sys.stderr)
            sys.exit(1)

    print(f"Production: {production}")
    print(f"Manifest: {manifest_path}")
    print(f"Tests: {len(tests)}")
    print()

    # Resolve service file paths — prefer manifest, fall back to DB query
    service_names = set(t["service"] for t in tests)
    service_paths = dict(manifest.get("service_paths", {}))

    # For any services not in the manifest, try the DB
    for svc in service_names:
        if svc not in service_paths:
            path = get_service_filepath_from_production(
                base_url, namespace, username, password, production, svc)
            if path:
                service_paths[svc] = path
            else:
                print(f"  WARNING: Could not resolve FilePath for {svc}",
                      file=sys.stderr)
                print(f"    Add it to manifest service_paths or check production config",
                      file=sys.stderr)

    if not service_paths:
        print("ERROR: Could not resolve any service file paths", file=sys.stderr)
        print("  Add service_paths to your manifest or check production config",
              file=sys.stderr)
        sys.exit(1)

    print(f"Service paths resolved: {len(service_paths)}/{len(service_names)}")
    for svc, path in sorted(service_paths.items()):
        print(f"  {svc}: {path}")
    print()

    # Sort tests by dependency order
    dep_map = {t["id"]: t.get("depends_on", None) for t in tests}
    ordered = []
    added = set()

    def add_test(test_id):
        if test_id in added:
            return
        dep = dep_map.get(test_id)
        if dep and dep not in added:
            # Find and add the dependency first
            for t in tests:
                if t["id"] == dep:
                    add_test(dep)
                    break
        for t in tests:
            if t["id"] == test_id:
                ordered.append(t)
                added.add(test_id)
                break

    for t in tests:
        add_test(t["id"])

    # Run tests
    results = []
    for test in ordered:
        print(f"[{test['id']}] {test['name'][:60]}...", end=" ", flush=True)
        result = run_test(test, manifest_dir, service_paths,
                         base_url, namespace, username, password, args.wait)
        emoji = "PASS" if result["status"] == "PASS" else result["status"]
        print(emoji)
        if result["errors"] and args.verbose:
            for err in result["errors"]:
                print(f"  -> {err[:100]}")
        results.append(result)

    # Output
    print()
    if args.format == "json":
        print(json.dumps(results, indent=2))
    else:
        print(format_results(results, verbose=args.verbose))
        print(format_coverage(results))

    # Exit code
    failed = sum(1 for r in results if r["status"] != "PASS")
    sys.exit(1 if failed > 0 else 0)


if __name__ == "__main__":
    main()
