#!/usr/bin/env python3
"""List documents (classes, routines, includes) in an IRIS namespace."""
import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import fnmatch
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import common_arg_parser, get_server_and_creds, make_request, parse_atelier_response
from portal_urls import classify_component, build_portal_base, get_zen_url


def main():
    parser = common_arg_parser("List documents in an IRIS namespace")
    parser.add_argument("--type", "-t", default="cls",
                        choices=["cls", "mac", "inc", "csp"],
                        help="Document type to list (default: cls)")
    parser.add_argument("--filter", "-f", default=None,
                        help="Filter pattern (glob-style, e.g. 'HS.Hub*')")
    parser.add_argument("--json", action="store_true",
                        help="Output as JSON array")
    parser.add_argument("--links", action="store_true",
                        help="Include portal links for DTL/Rule/BPL/Production classes")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    _, base_url, username, password = get_server_and_creds(args)

    # Atelier API uses 'rtn' endpoint for mac/inc/int routines
    api_type = "rtn" if args.type in ("mac", "inc") else args.type
    ext_filter = f".{args.type}" if args.type in ("mac", "inc") else None

    url = f"{base_url}/v1/{args.namespace}/docnames/{api_type}?generated=0"
    status, body = make_request(url, username, password)

    if status is None:
        print(f"ERROR: Could not reach server - {body}", file=sys.stderr)
        sys.exit(1)

    if status == 401:
        print("ERROR: Authentication failed (401)", file=sys.stderr)
        sys.exit(1)

    if status != 200:
        print(f"ERROR: Unexpected status {status}", file=sys.stderr)
        sys.exit(1)

    try:
        content = parse_atelier_response(body)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

    # Extract document names
    if isinstance(content, list):
        docs = []
        for item in content:
            if isinstance(item, dict):
                docs.append(item.get("name", str(item)))
            else:
                docs.append(str(item))
    else:
        docs = []

    # Filter by extension for mac/inc (rtn endpoint returns all routine types)
    if ext_filter:
        docs = [d for d in docs if d.endswith(ext_filter)]

    # Exclude system classes (%-prefixed) when no filter specified
    if not args.filter and args.type == "cls":
        docs = [d for d in docs if not d.startswith("%")]

    # Apply filter
    if args.filter:
        pattern = args.filter
        if "*" not in pattern and "?" not in pattern:
            # Treat as substring match if no glob chars
            docs = [d for d in docs if pattern.lower() in d.lower()]
        else:
            docs = [d for d in docs if fnmatch.fnmatch(d.lower(), pattern.lower())]

    docs.sort()

    # Classify and generate portal links for cls documents
    if args.links and args.type == "cls":
        server_config, _, _, _ = get_server_and_creds(args)
        portal_base = build_portal_base(server_config, args.namespace)

    if args.json:
        import json
        if args.links and args.type == "cls":
            server_config, _, _, _ = get_server_and_creds(args)
            portal_base = build_portal_base(server_config, args.namespace)
            items = []
            for doc in docs:
                name = doc[:-4] if doc.endswith(".cls") else doc
                comp = classify_component(name)
                entry = {"name": doc, "type": comp}
                url, _ = get_zen_url(portal_base, args.namespace, name, comp)
                if url:
                    entry["url"] = url
                items.append(entry)
            print(json.dumps(items, indent=2))
        else:
            print(json.dumps(docs, indent=2))
    else:
        if args.links and args.type == "cls":
            for doc in docs:
                name = doc[:-4] if doc.endswith(".cls") else doc
                comp = classify_component(name)
                url, _ = get_zen_url(portal_base, args.namespace, name, comp)
                if url:
                    print(f"{doc}  [{comp}]  PORTAL_URL: [View in Portal]({url})")
                else:
                    print(doc)
        else:
            for doc in docs:
                print(doc)

    if not args.json:
        print(f"\n{len(docs)} document(s) found", file=sys.stderr)


if __name__ == "__main__":
    main()
