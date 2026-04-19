#!/usr/bin/env python3
"""Test connectivity to an InterSystems IRIS server via the Atelier REST API."""
import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import sys
import os

# Ensure imports work regardless of working directory
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import load_servers, build_base_url, make_request, resolve_password


def test_server(server_name, servers, namespace=None, cli_password=None):
    """Test connection to a server and optionally a namespace."""
    if server_name not in servers:
        print(f"ERROR: Server '{server_name}' not found in config/servers.json")
        print(f"Available servers: {', '.join(servers.keys())}")
        return False

    config = servers[server_name]
    base_url = build_base_url(config)
    username = config.get("username", "superuser")
    password = resolve_password(server_name, config, cli_password)

    # Step 1: Test basic connectivity
    print(f"\n--- Connecting to '{server_name}' ---")
    print(f"URL: {base_url}/")

    status, body = make_request(f"{base_url}/", username, password)

    if status is None:
        print(f"FAILED: Could not reach server - {body}")
        return False

    if status == 401:
        print("FAILED: Authentication failed (401). Check username/password.")
        return False

    if status != 200:
        print(f"FAILED: Unexpected status {status}")
        print(body)
        return False

    # Parse server info
    result = body.get("result", {}).get("content", body.get("result", {}))
    version = result.get("version", "unknown")
    platform = result.get("platform", "unknown")
    print(f"OK: Connected to IRIS {version} on {platform}")

    # Step 2: List namespaces
    ns_status, ns_body = make_request(f"{base_url}/v1/", username, password)
    namespaces = []
    if ns_status == 200:
        ns_result = ns_body.get("result", {}).get("content", [])
        if isinstance(ns_result, list):
            namespaces = [ns.get("name", ns) if isinstance(ns, dict) else ns for ns in ns_result]
        print(f"Namespaces: {', '.join(namespaces) if namespaces else '(could not list)'}")

    # Step 3: Test namespace if specified
    if namespace:
        print(f"\n--- Testing namespace '{namespace}' ---")
        if namespaces and namespace.upper() not in [n.upper() for n in namespaces]:
            print(f"WARNING: '{namespace}' not in listed namespaces")

        # Quick check: just hit the namespace endpoint, don't list all classes
        ns_check_url = f"{base_url}/v1/{namespace}"
        doc_status, doc_body = make_request(ns_check_url, username, password, timeout=10)

        if doc_status == 200:
            print(f"OK: Namespace '{namespace}' accessible")
        else:
            print(f"FAILED: Could not access namespace '{namespace}' (status {doc_status})")
            return False

    print("\nConnection test PASSED")
    return True


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Test IRIS Atelier API connectivity")
    parser.add_argument("--server", "-s", help="Server name from config/servers.json")
    parser.add_argument("--namespace", "-n", help="Namespace to test (optional)")
    parser.add_argument("--password", "-p", help="Password (overrides config, avoids prompt)")
    parser.add_argument("--config", "-c", help="Path to servers.json (default: config/servers.json)")
    parser.add_argument("--list", "-l", action="store_true", help="List available servers and exit")

    args = parser.parse_args()
    servers = load_servers(args.config)

    if args.list:
        print("Available servers:")
        for name in servers:
            url = build_base_url(servers[name])
            print(f"  {name}: {url}")
        return

    if not args.server:
        parser.error("--server is required (unless using --list)")

    success = test_server(args.server, servers, args.namespace, args.password)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
