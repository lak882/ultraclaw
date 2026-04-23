#!/usr/bin/env python3
"""Reset/delete a production package from an IRIS server and clean up local files.

Deletes all classes in a package, removes lookup tables, and cleans src/ directory.

Usage:
  reset_package.py --server myserver --namespace HSLIB --package Demo.VaccineToASIIS
  reset_package.py --server myserver --namespace HSLIB --package Demo.VaccineToASIIS --lookup Facility_To_SII
  reset_package.py --server myserver --namespace HSLIB --package Demo.VaccineToASIIS --dry-run
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import sys
import os
import shutil

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (common_arg_parser, get_server_and_creds, make_request,
                      parse_atelier_response, AtelierError)


def run_sql(base_url, namespace, username, password, sql):
    """Execute a SQL query and return (status, content)."""
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


def list_package_docs(base_url, namespace, username, password, package):
    """List all documents matching a package prefix."""
    docs = []
    for doc_type in ["cls", "mac", "inc"]:
        url = f"{base_url}/v1/{namespace}/docnames/{doc_type}?generated=0"
        status, body = make_request(url, username, password)
        if status != 200:
            continue
        try:
            content = parse_atelier_response(body)
        except AtelierError:
            continue
        if isinstance(content, list):
            for item in content:
                name = item.get("name", str(item)) if isinstance(item, dict) else str(item)
                # Match package prefix (e.g., "Demo.VaccineToASIIS." matches "Demo.VaccineToASIIS.Production.cls")
                bare_name = name
                for ext in [".cls", ".mac", ".inc"]:
                    if bare_name.endswith(ext):
                        bare_name = bare_name[:-len(ext)]
                        break
                if bare_name == package or bare_name.startswith(package + "."):
                    docs.append(name)
    return sorted(docs)


def delete_doc(base_url, namespace, username, password, doc_name):
    """Delete a document from the server."""
    url = f"{base_url}/v1/{namespace}/doc/{doc_name}"
    status, body = make_request(url, username, password, method="DELETE")
    return status, body


def delete_lookup_table(base_url, namespace, username, password, table_name):
    """Delete all entries from a lookup table."""
    sql = f"DELETE FROM Ens_Util.LookupTable WHERE TableName = '{table_name}'"
    return run_sql(base_url, namespace, username, password, sql)


def count_package_messages(base_url, namespace, username, password, package):
    """Count messages related to a specific package."""
    sql = (f"SELECT COUNT(*) AS cnt FROM Ens.MessageHeader "
           f"WHERE SourceConfigName LIKE '{package}.%' OR TargetConfigName LIKE '{package}.%'")
    status, content = run_sql(base_url, namespace, username, password, sql)
    if status == 200 and isinstance(content, list) and len(content) > 0:
        return content[0].get("cnt", 0)
    return 0


def purge_messages(base_url, namespace, username, password, package=None):
    """Purge message headers and bodies, optionally scoped to a package."""
    if package:
        sql = (f"DELETE FROM Ens.MessageHeader "
               f"WHERE SourceConfigName LIKE '{package}.%' OR TargetConfigName LIKE '{package}.%'")
    else:
        sql = "DELETE FROM Ens.MessageHeader"
    status, content = run_sql(base_url, namespace, username, password, sql)
    return status, content


def find_local_src(package):
    """Find the local src/ directory for a package."""
    # Package "Demo.VaccineToASIIS" -> src/Demo/VaccineToASIIS/
    parts = package.split(".")
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
    src_path = os.path.join(project_root, "src", *parts)
    return src_path


def scan_dtl_for_lookups(src_path, namespace=None):
    """Scan DTL class files in src/ for ..Lookup("TableName") references.

    Also checks src/<Namespace>/<Package>/ if namespace is provided.
    Returns a sorted list of unique table names.
    """
    import re
    tables = set()
    pattern = re.compile(r'\.\.Lookup\("([^"]+)"')

    search_dirs = [src_path]
    if namespace:
        # Also check src/<Namespace>/<PackageParts>/
        script_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
        ns_path = os.path.join(project_root, "src", namespace)
        if os.path.isdir(ns_path):
            # Find the package subdir under the namespace
            pkg_name = os.path.basename(src_path)
            ns_pkg = os.path.join(ns_path, pkg_name)
            if os.path.isdir(ns_pkg) and ns_pkg != src_path:
                search_dirs.append(ns_pkg)

    for search_dir in search_dirs:
        if not os.path.isdir(search_dir):
            continue
        for root, dirs, files in os.walk(search_dir):
            for f in files:
                if f.endswith(".cls"):
                    filepath = os.path.join(root, f)
                    try:
                        with open(filepath, "r", encoding="utf-8") as fh:
                            for match in pattern.finditer(fh.read()):
                                tables.add(match.group(1))
                    except (IOError, OSError):
                        pass
    return sorted(tables)


def main():
    parser = common_arg_parser("Reset a production package — delete from server and clean local files")
    parser.add_argument("--package", "-P", required=True,
                        help="Package name to reset (e.g., Demo.VaccineToASIIS)")
    parser.add_argument("--lookup",
                        help="Comma-separated lookup table names to delete")
    parser.add_argument("--auto-lookup", action="store_true",
                        help="Auto-detect lookup tables from DTL source in src/")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would be deleted without actually deleting")
    parser.add_argument("--keep-local", action="store_true",
                        help="Don't delete local src/ files")
    parser.add_argument("--no-purge", action="store_true",
                        help="Skip purging message headers and bodies (purge is on by default)")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    _, base_url, username, password = get_server_and_creds(args)
    package = args.package
    dry_run = args.dry_run

    if dry_run:
        print("=== DRY RUN — no changes will be made ===\n")

    # 1. Find all server-side documents in this package
    print(f"Scanning server for {package}.* documents...")
    docs = list_package_docs(base_url, args.namespace, username, password, package)

    if docs:
        print(f"Found {len(docs)} document(s) on server:")
        for d in docs:
            print(f"  {d}")
    else:
        print("  No documents found on server")

    # 2. Find lookup tables to delete
    lookups = []
    if args.lookup:
        lookups = [lt.strip() for lt in args.lookup.split(",") if lt.strip()]

    # Auto-detect lookups from DTL source if requested
    if args.auto_lookup:
        src_path_check = find_local_src(package)
        auto_tables = scan_dtl_for_lookups(src_path_check, args.namespace)
        for t in auto_tables:
            if t not in lookups:
                lookups.append(t)
        if auto_tables:
            print(f"\nAuto-detected lookup tables from DTL source: {', '.join(auto_tables)}")

    if lookups:
        print(f"\nLookup tables to clear: {', '.join(lookups)}")

    # 3. Find local src/ directory
    src_path = find_local_src(package)
    has_local = os.path.isdir(src_path) and not args.keep_local

    if has_local:
        local_files = []
        for root, dirs, files in os.walk(src_path):
            for f in files:
                local_files.append(os.path.relpath(os.path.join(root, f), src_path))
        print(f"\nLocal files in {os.path.relpath(src_path)}/ ({len(local_files)} files)")
    elif args.keep_local:
        print(f"\nLocal files: keeping (--keep-local)")
    else:
        print(f"\nNo local files at {os.path.relpath(src_path, os.getcwd()) if os.path.exists(os.path.join(src_path, '..')) else src_path}")

    if not args.no_purge:
        msg_count = count_package_messages(base_url, args.namespace, username, password, package)
        print(f"\nMessage purge: {msg_count} message(s) matching {package}.* (by SourceConfigName or TargetConfigName)")

    # Confirm
    total = len(docs) + len(lookups) + (1 if has_local else 0) + (1 if not args.no_purge else 0)
    if total == 0:
        print("\nNothing to reset.")
        return

    if dry_run:
        print(f"\n=== DRY RUN complete — {len(docs)} docs + {len(lookups)} lookups + {'local dir' if has_local else 'no local'} would be deleted ===")
        return

    print(f"\n--- Deleting ---")

    # 4. Delete server documents
    errors = 0
    for doc in docs:
        status, body = delete_doc(base_url, args.namespace, username, password, doc)
        if status in (200, 204):
            print(f"  Deleted: {doc}")
        else:
            print(f"  FAILED: {doc} (status {status})")
            errors += 1

    # 5. Delete lookup tables
    for lt in lookups:
        status, content = delete_lookup_table(base_url, args.namespace, username, password, lt)
        if status == 200:
            print(f"  Cleared lookup table: {lt}")
        else:
            print(f"  FAILED: lookup table {lt} (status {status})")
            errors += 1

    # 6. Purge messages
    if not args.no_purge:
        status, content = purge_messages(base_url, args.namespace, username, password, package)
        if status == 200:
            print(f"  Purged message headers")
        else:
            print(f"  FAILED: purge messages (status {status})")
            errors += 1

    # 7. Delete local files
    if has_local:
        shutil.rmtree(src_path)
        print(f"  Deleted local: {os.path.relpath(src_path)}/")

        # Clean up empty parent dirs in src/
        parent = os.path.dirname(src_path)
        while parent and parent != os.path.join(os.path.dirname(src_path), ".."):
            if os.path.isdir(parent) and not os.listdir(parent):
                os.rmdir(parent)
                parent = os.path.dirname(parent)
            else:
                break

    # Summary
    print(f"\n--- Reset complete ---")
    print(f"  Server: {len(docs) - errors} deleted, {errors} failed")
    if lookups:
        print(f"  Lookup tables: {len(lookups)} cleared")
    if not args.no_purge:
        print(f"  Messages: purged")
    if has_local:
        print(f"  Local files: removed")

    sys.exit(1 if errors > 0 else 0)


if __name__ == "__main__":
    main()
