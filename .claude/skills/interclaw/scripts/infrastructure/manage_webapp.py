#!/usr/bin/env python3
"""Manage IRIS CSP web applications — create, modify, delete, list.

Creates Security.Applications entries that map URL paths to namespaces
and dispatch classes. Supports REST, WSGI, and CSP/Zen applications.

Usage:
  manage_webapp.py --server myserver --list
  manage_webapp.py --server myserver --exists /api/myapp
  manage_webapp.py --server myserver --get /api/myapp
  manage_webapp.py --server myserver --create /api/myapp --namespace MYNS --type rest --dispatch MyApp.REST.Dispatch
  manage_webapp.py --server myserver --create /myapp --namespace MYNS --type wsgi --wsgi-location /opt/myapp/ --wsgi-module app --wsgi-callable app [--wsgi-async]
  manage_webapp.py --server myserver --create /csp/myapp --namespace MYNS --type csp [--path /opt/myapp/static]
  manage_webapp.py --server myserver --delete /api/myapp
  manage_webapp.py --server myserver --enable /api/myapp
  manage_webapp.py --server myserver --disable /api/myapp
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import sys
import os
import argparse
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_terminal import ws_run_objectscript
from iris_api import load_servers, resolve_password

SYS_NAMESPACE = "%SYS"

# Module-level state set by main()
_server_name = None
_config_path = None


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _run(code, timeout=120):
    """Run ObjectScript in %SYS via WebSocket terminal and return output."""
    return ws_run_objectscript(code, server=_server_name, namespace=SYS_NAMESPACE,
                               config_path=_config_path, timeout=timeout)


def _check_status(result, action):
    """Check result for OK/ERROR. Returns True on success."""
    if result is None:
        print(f"ERROR: No response from server for {action}")
        return False
    result = result.strip()
    lines = result.splitlines()
    last = lines[-1].strip() if lines else ""
    if last == "OK" or "OK" in last:
        return True
    if "ERROR" in result:
        print(f"ERROR ({action}): {result}")
        return False
    # Ambiguous — print it
    print(f"Output ({action}): {result}")
    return "ERROR" not in result


# ---------------------------------------------------------------------------
# List web applications
# ---------------------------------------------------------------------------

def list_webapps(filter_ns=None):
    """List all CSP web applications."""
    code = (
        'set rs=##class(%ResultSet).%New("Security.Applications:List") '
        'do rs.Execute("*") '
        'while rs.Next() { '
        '  set name=rs.Get("Name") '
        '  set ns=rs.Get("Namespace") '
        '  set enabled=rs.Get("Enabled") '
        '  set dispatch=rs.Get("DispatchClass") '
        '  write name_"|"_ns_"|"_enabled_"|"_dispatch,! '
        '}'
    )
    result = _run(code)
    if result is None:
        print("ERROR: Could not list web applications")
        return []

    apps = []
    for line in result.strip().splitlines():
        line = line.strip()
        if not line or "|" not in line:
            continue
        parts = line.split("|", 3)
        if len(parts) < 4:
            continue
        app = {
            "name": parts[0],
            "namespace": parts[1],
            "enabled": parts[2] == "1",
            "dispatch": parts[3] if parts[3] else ""
        }
        if filter_ns and app["namespace"].upper() != filter_ns.upper():
            continue
        apps.append(app)
    return apps


# ---------------------------------------------------------------------------
# Check existence / get config
# ---------------------------------------------------------------------------

def webapp_exists(name):
    """Check if a web application exists."""
    result = _run(f'write ##class(Security.Applications).Exists("{name}"),!')
    return result.strip() == "1"


def get_webapp(name):
    """Get web application properties as a dict."""
    code = (
        f'set sc=##class(Security.Applications).Get("{name}",.props) '
        f'if $system.Status.IsError(sc) {{ write "ERROR: "_$system.Status.GetErrorText(sc),! quit }} '
        f'set key="" for {{ set key=$order(props(key)) quit:key=""  write key_"="_props(key),! }}'
    )
    result = _run(code)
    if result is None or "ERROR" in (result or ""):
        return None

    props = {}
    for line in result.strip().splitlines():
        line = line.strip()
        if "=" in line:
            key, val = line.split("=", 1)
            props[key] = val
    return props


# ---------------------------------------------------------------------------
# Create web application
# ---------------------------------------------------------------------------

def create_webapp(name, namespace, app_type="rest",
                  dispatch=None, path=None, auth=64, serve_files=None,
                  wsgi_location=None, wsgi_module=None, wsgi_callable=None,
                  wsgi_async=False, cors_origins=None, dry_run=False):
    """Create a new CSP web application.

    app_type: 'rest', 'wsgi', or 'csp'
    """
    if webapp_exists(name):
        print(f"ERROR: Web application '{name}' already exists")
        return False

    # Build properties based on type
    props = {
        "NameSpace": namespace,
        "Type": "2",
        "Enabled": "1",
        "AutheEnabled": str(auth),
        "UseCookies": "1",
        "Timeout": "900",
    }

    if app_type == "rest":
        if not dispatch:
            print("ERROR: --dispatch is required for REST applications")
            return False
        props["DispatchClass"] = dispatch
        props["CSPZENEnabled"] = "0"
        props["ServeFiles"] = str(serve_files) if serve_files is not None else "0"
        if path:
            props["Path"] = path

    elif app_type == "wsgi":
        if not all([wsgi_location, wsgi_module, wsgi_callable]):
            print("ERROR: --wsgi-location, --wsgi-module, and --wsgi-callable are required for WSGI apps")
            return False
        props["DispatchClass"] = "%SYS.Python.WSGI"
        props["Path"] = wsgi_location
        props["WSGIAppLocation"] = wsgi_location
        props["WSGIAppName"] = wsgi_module
        props["WSGICallable"] = wsgi_callable
        props["WSGIType"] = "2" if wsgi_async else "1"
        props["CSPZENEnabled"] = "0"
        props["ServeFiles"] = str(serve_files) if serve_files is not None else "0"

    elif app_type == "csp":
        props["DispatchClass"] = dispatch or ""
        props["CSPZENEnabled"] = "1"
        props["ServeFiles"] = str(serve_files) if serve_files is not None else "1"
        if path:
            props["Path"] = path

    else:
        print(f"ERROR: Unknown app type '{app_type}'. Use 'rest', 'wsgi', or 'csp'")
        return False

    if cors_origins:
        props["CorsAllowlist"] = cors_origins
        props["CorsCredentialsAllowed"] = "1"

    if dry_run:
        print("=== DRY RUN — no changes will be made ===\n")
        print(f"Would create web application: {name}")
        print(f"  Type: {app_type.upper()}")
        for k, v in sorted(props.items()):
            print(f"  {k}: {v}")
        return True

    # Build ObjectScript to create
    set_lines = []
    for k, v in props.items():
        escaped_v = v.replace('"', '""')
        set_lines.append(f'set props("{k}")="{escaped_v}"')

    sets = " ".join(set_lines)
    code = (
        f'kill props {sets} '
        f'set sc=##class(Security.Applications).Create("{name}",.props) '
        f'write $select($system.Status.IsError(sc):"ERROR: "_$system.Status.GetErrorText(sc),1:"OK"),!'
    )

    print(f"Creating {app_type.upper()} web application: {name}")
    result = _run(code)
    ok = _check_status(result, "create")
    if ok:
        print(f"  OK: Web application '{name}' created")
        print(f"  Namespace: {namespace}")
        if dispatch:
            print(f"  Dispatch: {dispatch}")
        elif app_type == "wsgi":
            print(f"  WSGI: {wsgi_module}.{wsgi_callable} from {wsgi_location}")
    return ok


# ---------------------------------------------------------------------------
# Delete web application
# ---------------------------------------------------------------------------

def delete_webapp(name, dry_run=False):
    """Delete a web application."""
    if not webapp_exists(name):
        print(f"Web application '{name}' does not exist")
        return True

    if dry_run:
        print("=== DRY RUN — no changes will be made ===\n")
        print(f"Would delete web application: {name}")
        return True

    print(f"Deleting web application: {name}")
    code = (
        f'set sc=##class(Security.Applications).Delete("{name}") '
        f'write $select($system.Status.IsError(sc):"ERROR: "_$system.Status.GetErrorText(sc),1:"OK"),!'
    )
    result = _run(code)
    ok = _check_status(result, "delete")
    if ok:
        print(f"  OK: Web application '{name}' deleted")
    return ok


# ---------------------------------------------------------------------------
# Enable / Disable
# ---------------------------------------------------------------------------

def set_enabled(name, enabled):
    """Enable or disable a web application."""
    if not webapp_exists(name):
        print(f"ERROR: Web application '{name}' does not exist")
        return False

    val = "1" if enabled else "0"
    action = "enable" if enabled else "disable"
    code = (
        f'kill props set props("Enabled")="{val}" '
        f'set sc=##class(Security.Applications).Modify("{name}",.props) '
        f'write $select($system.Status.IsError(sc):"ERROR: "_$system.Status.GetErrorText(sc),1:"OK"),!'
    )
    result = _run(code)
    ok = _check_status(result, action)
    if ok:
        print(f"  OK: Web application '{name}' {action}d")
    return ok


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Manage IRIS CSP web applications — create, delete, list, enable/disable")
    parser.add_argument("--server", "-s", required=True,
                        help="Server name from config/servers.json")

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--list", action="store_true",
                       help="List all web applications")
    group.add_argument("--exists", metavar="NAME",
                       help="Check if web application exists")
    group.add_argument("--get", metavar="NAME",
                       help="Get web application properties")
    group.add_argument("--create", metavar="NAME",
                       help="Create a new web application (URL path, e.g. /api/myapp)")
    group.add_argument("--delete", metavar="NAME",
                       help="Delete a web application")
    group.add_argument("--enable", metavar="NAME",
                       help="Enable a web application")
    group.add_argument("--disable", metavar="NAME",
                       help="Disable a web application")

    # Create options
    parser.add_argument("--namespace", "-n",
                        help="IRIS namespace (required for --create)")
    parser.add_argument("--type", choices=["rest", "wsgi", "csp"], default="rest",
                        help="Application type (default: rest)")
    parser.add_argument("--dispatch",
                        help="Dispatch class name (REST/CSP)")
    parser.add_argument("--path",
                        help="Physical directory for static files")
    parser.add_argument("--auth", type=int, default=64,
                        help="AutheEnabled bitmask (32=password, 64=unauthenticated, default: 64)")
    parser.add_argument("--serve-files", type=int, choices=[0, 1, 2, 3],
                        help="Static file serving (0=no, 1=always, 2=cached, 3=security)")
    parser.add_argument("--cors-origins",
                        help="Comma-separated CORS allowed origins")

    # WSGI options
    parser.add_argument("--wsgi-location",
                        help="WSGI: Filesystem path to Python app directory")
    parser.add_argument("--wsgi-module",
                        help="WSGI: Python module name (without .py)")
    parser.add_argument("--wsgi-callable",
                        help="WSGI: WSGI/ASGI callable object name")
    parser.add_argument("--wsgi-async", action="store_true",
                        help="WSGI: Use ASGI mode (WSGIType=2, for FastAPI)")

    # Common options
    parser.add_argument("--filter-namespace",
                        help="Filter --list by namespace")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would happen without making changes")
    parser.add_argument("--config", "-c",
                        help="Path to servers.json")
    parser.add_argument("--format", choices=["table", "json"], default="table",
                        help="Output format (default: table)")

    args = parser.parse_args()

    global _server_name, _config_path
    _server_name = args.server
    _config_path = getattr(args, "config", None)

    if args.list:
        apps = list_webapps(args.filter_namespace)
        if not apps:
            print("No web applications found")
            return

        if args.format == "json":
            print(json.dumps(apps, indent=2))
        else:
            print(f"{'Name':<40} {'Namespace':<15} {'Enabled':<8} {'Dispatch'}")
            print("-" * 100)
            for app in sorted(apps, key=lambda a: a["name"]):
                enabled = "Yes" if app["enabled"] else "No"
                print(f"{app['name']:<40} {app['namespace']:<15} {enabled:<8} {app['dispatch']}")
            print(f"\n{len(apps)} web application(s)")

    elif args.exists:
        exists = webapp_exists(args.exists)
        print("yes" if exists else "no")
        sys.exit(0 if exists else 1)

    elif args.get:
        props = get_webapp(args.get)
        if props is None:
            print(f"ERROR: Could not get web application '{args.get}'")
            sys.exit(1)
        if args.format == "json":
            print(json.dumps(props, indent=2))
        else:
            for k, v in sorted(props.items()):
                print(f"  {k}: {v}")

    elif args.create:
        if not args.namespace:
            print("ERROR: --namespace is required for --create")
            sys.exit(1)
        ok = create_webapp(
            name=args.create,
            namespace=args.namespace,
            app_type=args.type,
            dispatch=args.dispatch,
            path=args.path,
            auth=args.auth,
            serve_files=args.serve_files,
            wsgi_location=args.wsgi_location,
            wsgi_module=args.wsgi_module,
            wsgi_callable=args.wsgi_callable,
            wsgi_async=args.wsgi_async,
            cors_origins=args.cors_origins,
            dry_run=args.dry_run,
        )
        sys.exit(0 if ok else 1)

    elif args.delete:
        ok = delete_webapp(args.delete, args.dry_run)
        sys.exit(0 if ok else 1)

    elif args.enable:
        ok = set_enabled(args.enable, True)
        sys.exit(0 if ok else 1)

    elif args.disable:
        ok = set_enabled(args.disable, False)
        sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
