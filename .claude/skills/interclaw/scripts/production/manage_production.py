#!/usr/bin/env python3
"""Manage IRIS productions — check status, start, stop, recover, and clean.

Uses the InteropEditors REST API (v3).

Usage:
  manage_production.py --server myserver --namespace CLAUDE --status
  manage_production.py --server myserver --namespace CLAUDE --start Demo.Production
  manage_production.py --server myserver --namespace CLAUDE --stop
  manage_production.py --server myserver --namespace CLAUDE --start Demo.Production --stop-first
  manage_production.py --server myserver --namespace CLAUDE --recover
  manage_production.py --server myserver --namespace CLAUDE --clean
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (common_arg_parser, get_server_and_creds,
                      build_interop_url, make_interop_request,
                      make_request)

# Production states returned by GetProductionStatus
PROD_STATES = {
    1: "Running",
    2: "Stopped",
    3: "Suspended",
    4: "Troubled",
    5: "NetworkStopped",
}


def get_status(interop_url, username, password):
    """Get running production name and status text."""
    url = f"{interop_url}/productions/status"
    status, body = make_interop_request(url, username, password)
    if status != 200:
        return "", "Unknown"
    state_code = body.get("State", 2)
    prod_name = body.get("ProdRunning", "")
    return prod_name, PROD_STATES.get(state_code, f"Unknown({state_code})")


def list_productions(interop_url, username, password):
    """List all productions in the namespace."""
    url = f"{interop_url}/productions"
    status, body = make_interop_request(url, username, password)
    if status == 200:
        return body.get("productions", [])
    return []


def start_production(interop_url, username, password, name):
    """Start a production. Returns (success, message)."""
    url = f"{interop_url}/productions/state/{name}"
    status, body = make_interop_request(url, username, password, method="POST",
                                        query_params={"state": "start", "hostID": "0"},
                                        timeout=120)
    if status == 200 and body.get("Success"):
        return True, "OK"
    error = body.get("summary", body.get("errors", str(body)))
    return False, f"ERROR: {error}"


def stop_production(interop_url, username, password, name, force=False):
    """Stop a production. Returns (success, message).

    If force=True, uses state=force which calls StopProduction(10, 1).
    """
    state = "force" if force else "stop"
    url = f"{interop_url}/productions/state/{name}"
    status, body = make_interop_request(url, username, password, method="POST",
                                        query_params={"state": state, "hostID": "0"},
                                        timeout=120)
    if status == 200 and body.get("Success"):
        return True, "OK"
    error = body.get("summary", body.get("errors", str(body)))
    return False, f"ERROR: {error}"


def recover_production(interop_url, username, password, name):
    """Recover a suspended production. Returns (success, message)."""
    url = f"{interop_url}/productions/state/{name}"
    status, body = make_interop_request(url, username, password, method="POST",
                                        query_params={"state": "recover", "hostID": "0"},
                                        timeout=120)
    if status == 200 and body.get("Success"):
        return True, "OK"
    error = body.get("summary", body.get("errors", str(body)))
    return False, f"ERROR: {error}"


def _ensure_exec_function(base_url, namespace, username, password):
    """Create a reusable SQL function for executing ObjectScript (once per namespace)."""
    query_url = f"{base_url}/v1/{namespace}/action/query"
    sql = ("CREATE OR REPLACE FUNCTION Tmp.ExecOS(code VARCHAR(32000)) "
           "RETURNS VARCHAR(32000) LANGUAGE OBJECTSCRIPT "
           "{ new result  xecute code  quit $get(result) }")
    make_request(query_url, username, password, method="POST",
                 data={"query": sql}, timeout=30)


def exec_objectscript(server_config, namespace, username, password, code):
    """Execute ObjectScript code via SQL function. Returns the result string.

    The code should set a local variable `result` to return a value.
    Example: 'set result=##class(Ens.Director).CleanProduction(0)'
    """
    base_url = "{scheme}://{host}:{port}{pathPrefix}/api/atelier".format(**server_config["webServer"])
    _ensure_exec_function(base_url, namespace, username, password)

    query_url = f"{base_url}/v1/{namespace}/action/query"
    sql = f"SELECT Tmp.ExecOS('{code}')"
    status, body = make_request(query_url, username, password, method="POST",
                                data={"query": sql}, timeout=60)
    if status == 200:
        content = body.get("result", {}).get("content", [])
        if content:
            return content[0].get("Expression_1", "")
    return None


def clean_production(server_config, namespace, username, password):
    """Clean a production via Ens.Director.CleanProduction().

    NOTE: The InteropEditors API state=clean is a no-op (bug in IRIS).
    We call CleanProduction() directly via a SQL function wrapper.
    """
    result = exec_objectscript(server_config, namespace, username, password,
                               "set result=##class(Ens.Director).CleanProduction(0)")
    if result is not None:
        # CleanProduction returns a %Status — 1 means OK
        if result == "1" or result == "":
            return True, "OK"
        return False, f"ERROR: {result}"
    return False, "ERROR: Failed to execute CleanProduction"


def main():
    parser = common_arg_parser("Manage IRIS productions — check status, start, stop")
    parser.add_argument("--status", action="store_true",
                        help="Show which production is running")
    parser.add_argument("--start", metavar="PRODUCTION",
                        help="Start a production by class name")
    parser.add_argument("--stop", action="store_true",
                        help="Stop the currently running production")
    parser.add_argument("--stop-first", action="store_true",
                        help="Stop any running production before starting (use with --start)")
    parser.add_argument("--recover", action="store_true",
                        help="Recover a suspended production")
    parser.add_argument("--clean", action="store_true",
                        help="Clean production state (clears Suspended/Troubled)")
    parser.add_argument("--list", action="store_true",
                        help="List all productions in the namespace")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    if not any([args.status, args.start, args.stop, args.recover, args.clean, args.list]):
        parser.error("Specify --status, --start, --stop, --recover, --clean, --list, or a combination")

    server_config, _, username, password = get_server_and_creds(args)
    interop_url = build_interop_url(server_config, args.namespace)

    # --list
    if args.list:
        prods = list_productions(interop_url, username, password)
        if prods:
            print("Productions:")
            for p in prods:
                print(f"  {p}")
        else:
            print("No productions found")

    # --status
    if args.status:
        name, state = get_status(interop_url, username, password)
        if name:
            print(f"Production: {name}")
            print(f"Status:     {state}")
        else:
            print("No production is running")

    # --clean
    if args.clean:
        name, state = get_status(interop_url, username, password)
        if name:
            print(f"Cleaning {name}...")
            ok, msg = clean_production(server_config, args.namespace, username, password)
            if ok:
                print(f"OK: Cleaned {name}")
            else:
                print(msg, file=sys.stderr)
        else:
            print("No production to clean")

    # --recover
    if args.recover:
        name, state = get_status(interop_url, username, password)
        if name and state == "Suspended":
            print(f"Recovering {name}...")
            ok, msg = recover_production(interop_url, username, password, name)
            if ok:
                print(f"OK: Recovered {name}")
            else:
                print(msg, file=sys.stderr)
        elif name:
            print(f"Production {name} is {state}, not Suspended")
        else:
            print("No production to recover")

    # --stop (or --stop-first before --start)
    if args.stop or (args.stop_first and args.start):
        name, state = get_status(interop_url, username, password)
        if name and state not in ("Stopped",):
            # If suspended, try recover → force stop → clean (escalating)
            if state == "Suspended":
                print(f"Recovering {name} from Suspended state...")
                recover_production(interop_url, username, password, name)
            print(f"Stopping {name}...")
            ok, msg = stop_production(interop_url, username, password, name)
            if not ok:
                print(f"Normal stop failed. Trying force stop...")
                ok, msg = stop_production(interop_url, username, password, name, force=True)
            # Verify it actually stopped
            _, new_state = get_status(interop_url, username, password)
            if new_state in ("Stopped",) or not _:
                print(f"OK: Stopped {name}")
            else:
                # Still not stopped — use CleanProduction as last resort
                print(f"State still {new_state}. Using CleanProduction...")
                ok2, msg2 = clean_production(server_config, args.namespace, username, password)
                if ok2:
                    print(f"OK: Cleaned {name}")
                else:
                    print(msg2, file=sys.stderr)
                    if args.start:
                        sys.exit(1)
        elif args.stop and not args.start:
            print("No production is running")

    # --start
    if args.start:
        name, state = get_status(interop_url, username, password)
        if name and state != "Stopped":
            if name == args.start:
                print(f"Production {name} is already running")
                return
            else:
                print(f"ERROR: Production {name} is already running. Use --stop-first to stop it.",
                      file=sys.stderr)
                sys.exit(1)

        print(f"Starting {args.start}...")
        ok, msg = start_production(interop_url, username, password, args.start)
        if ok:
            print(f"OK: Started {args.start}")
        else:
            print(msg, file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
