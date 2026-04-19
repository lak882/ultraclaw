#!/usr/bin/env python3
"""Manage IRIS namespaces — create, delete, list, check existence.

Uses the Atelier WebSocket terminal to execute ObjectScript remotely.
Create uses HS.Util.Installer.Foundation.Install() for full HealthShare Foundation setup.
Delete uses Config.Namespaces/Config.Databases in %SYS.

Usage:
  manage_namespace.py --server myserver --list
  manage_namespace.py --server myserver --exists MYNS
  manage_namespace.py --server myserver --create MYNS [--dry-run]
  manage_namespace.py --server myserver --delete MYNS [--dry-run]
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_terminal import ws_run_objectscript
from iris_api import load_servers, resolve_password

SYS_NAMESPACE = "%SYS"
HSCUSTOM_NAMESPACE = "HSCUSTOM"

# Module-level state set by main()
_server_name = None
_config_path = None


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _run(code, namespace, timeout=120):
    """Run ObjectScript via WebSocket terminal and return output string."""
    return ws_run_objectscript(code, server=_server_name, namespace=namespace,
                               config_path=_config_path, timeout=timeout)


# ---------------------------------------------------------------------------
# Namespace / database checks
# ---------------------------------------------------------------------------

def namespace_exists(name):
    """Check if a namespace exists. Returns True/False."""
    result = _run(f'write ##class(Config.Namespaces).Exists("{name}"),!', SYS_NAMESPACE)
    return result.strip() == "1"


def database_exists(name):
    """Check if a database configuration exists. Returns True/False."""
    result = _run(f'write ##class(Config.Databases).Exists("{name}"),!', SYS_NAMESPACE)
    return result.strip() == "1"


def list_namespaces():
    """List all namespaces."""
    code = ('set rs=##class(%ResultSet).%New("Config.Namespaces:List") '
            'do rs.Execute("*") while rs.Next() { write rs.Get("Namespace"),! }')
    result = _run(code, SYS_NAMESPACE)
    return [line.strip() for line in result.splitlines() if line.strip()]


# ---------------------------------------------------------------------------
# Production stop (best effort)
# ---------------------------------------------------------------------------

def stop_production_in_namespace(namespace):
    """Stop any running production in a namespace. Best effort."""
    code = ('set sc=##class(Ens.Director).StopProduction(10,1) '
            'write $select($system.Status.IsError(sc):"ERROR: "_$system.Status.GetErrorText(sc),1:"OK"),!')
    try:
        result = _run(code, namespace)
        if "OK" in result:
            print("  Production stopped")
        else:
            print(f"  Warning: Could not stop production: {result}")
    except Exception:
        print("  Warning: Could not stop production (namespace may not have interop)")


def get_production_status(namespace):
    """Check production status. Returns (name, state) or (None, None)."""
    code = ('set sc=##class(Ens.Director).GetProductionStatus(.name,.state) '
            'write $select($system.Status.IsError(sc):"NONE",1:name_"|"_state),!')
    try:
        result = _run(code, namespace)
        if result and result != "NONE" and "|" in result:
            parts = result.strip().split("|", 1)
            return parts[0], parts[1]
    except Exception:
        pass
    return None, None


# ---------------------------------------------------------------------------
# Create namespace (Foundation)
# ---------------------------------------------------------------------------

def create_namespace(name, dry_run):
    """Create a HealthShare Foundation namespace."""
    name_upper = name.upper()

    if namespace_exists(name_upper):
        print(f"ERROR: Namespace '{name_upper}' already exists")
        return False

    if dry_run:
        print("=== DRY RUN — no changes will be made ===\n")
        print(f"Would create HealthShare Foundation namespace: {name_upper}")
        print(f"  - Database and namespace configuration")
        print(f"  - HSLIB/HSCUSTOM mappings")
        print(f"  - HS.* and Ens.* class packages")
        print(f"  - Interoperability enabled")
        return True

    print(f"Creating Foundation namespace {name_upper}...")
    print("  (This may take a minute — Foundation install configures mappings and classes)")
    code = (f'set sc=##class(HS.Util.Installer.Foundation).Install("{name_upper}") '
            f'write $select($system.Status.IsError(sc):"ERROR: "_$system.Status.GetErrorText(sc),1:"OK"),!')
    result = _run(code, HSCUSTOM_NAMESPACE, timeout=300)
    if result is None:
        print("ERROR: No response from server (possible timeout)")
        return False

    lines = result.strip().splitlines()
    last_line = lines[-1].strip() if lines else ""

    if last_line == "OK":
        print(f"  OK: Foundation namespace '{name_upper}' created successfully")
        return True
    elif "ERROR" in result:
        print(f"ERROR: {result}")
        return False
    else:
        if namespace_exists(name_upper):
            print(f"  OK: Foundation namespace '{name_upper}' created successfully")
            return True
        print(f"ERROR: Unexpected output:\n{result}")
        return False


# ---------------------------------------------------------------------------
# Delete namespace
# ---------------------------------------------------------------------------

def delete_namespace(name, dry_run):
    """Delete a namespace and its database configuration."""
    name_upper = name.upper()

    ns_exists = namespace_exists(name_upper)
    db_exists = database_exists(name_upper)

    if not ns_exists and not db_exists:
        print(f"Nothing to delete: namespace '{name_upper}' and database '{name_upper}' do not exist")
        return True

    prod_name, prod_state = None, None
    if ns_exists:
        prod_name, prod_state = get_production_status(name_upper)

    if dry_run:
        print("=== DRY RUN — no changes will be made ===\n")
        print(f"Would delete:")
        if ns_exists:
            print(f"  Namespace: {name_upper}")
        if db_exists:
            print(f"  Database config: {name_upper}")
        if prod_name and prod_state and str(prod_state) == "1":
            print(f"\n  WARNING: Production '{prod_name}' is currently RUNNING")
            print(f"  It will be stopped before deletion")
        print(f"\n  Note: Physical database files are NOT deleted from disk")
        return True

    if ns_exists and prod_name and prod_state and str(prod_state) == "1":
        print(f"Stopping production '{prod_name}'...")
        stop_production_in_namespace(name_upper)

    if ns_exists:
        print(f"Deleting namespace {name_upper}...")
        code = (f'set sc=##class(Config.Namespaces).Delete("{name_upper}") '
                f'write $select($system.Status.IsError(sc):"ERROR: "_$system.Status.GetErrorText(sc),1:"OK"),!')
        result = _run(code, SYS_NAMESPACE)
        if "ERROR" in result:
            print(f"ERROR deleting namespace: {result}")
            return False
        print(f"  OK: Namespace deleted")

    if db_exists:
        print(f"Deleting database config {name_upper}...")
        code = (f'set sc=##class(Config.Databases).Delete("{name_upper}") '
                f'write $select($system.Status.IsError(sc):"ERROR: "_$system.Status.GetErrorText(sc),1:"OK"),!')
        result = _run(code, SYS_NAMESPACE)
        if "ERROR" in result:
            print(f"ERROR deleting database config: {result}")
            return False
        print(f"  OK: Database config deleted")

    print(f"\nNamespace {name_upper} deleted successfully")
    print(f"Note: Physical database files were NOT deleted from disk")
    return True


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    global _server_name, _config_path
    import argparse

    parser = argparse.ArgumentParser(
        description="Manage IRIS namespaces — create, delete, list, check")
    parser.add_argument("--server", "-s", required=True,
                        help="Server name from config/servers.json")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--exists", metavar="NAME",
                       help="Check if namespace exists (exit 0=yes, 1=no)")
    group.add_argument("--list", action="store_true",
                       help="List all namespaces")
    group.add_argument("--create", metavar="NAME",
                       help="Create a new HealthShare Foundation namespace")
    group.add_argument("--delete", metavar="NAME",
                       help="Delete a namespace and its database config")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would happen without making changes")
    parser.add_argument("--config", "-c",
                        help="Path to servers.json")
    args = parser.parse_args()

    _server_name = args.server
    _config_path = getattr(args, "config", None)

    if args.list:
        namespaces = list_namespaces()
        if namespaces:
            print("Namespaces:")
            for ns in sorted(namespaces):
                print(f"  {ns}")
        else:
            print("No namespaces found (or could not list)")

    elif args.exists:
        name = args.exists.upper()
        exists = namespace_exists(name)
        print("yes" if exists else "no")
        sys.exit(0 if exists else 1)

    elif args.create:
        ok = create_namespace(args.create, args.dry_run)
        sys.exit(0 if ok else 1)

    elif args.delete:
        ok = delete_namespace(args.delete, args.dry_run)
        sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
