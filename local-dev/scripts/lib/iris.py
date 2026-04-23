#!/usr/bin/env python3
"""Generic authenticated HTTP client for InterSystems IRIS Atelier REST API.

The universal tool for making Atelier API calls. Claude constructs URLs and
payloads directly; this script handles auth, cookies, and JSON parsing.

Usage:
    # GET a document
    iris.py --server myserver GET /v1/HSLIB/doc/My.Class.cls

    # List documents
    iris.py --server myserver GET /v1/HSLIB/action/index?type=cls

    # Run a SQL query
    iris.py --server myserver POST /v1/HSLIB/action/query --body '{"query":"SELECT TOP 10 Name FROM Some.Table"}'

    # Search code
    iris.py --server myserver GET '/v2/HSLIB/action/search?query=OnProcessInput&files=*.cls'

    # PUT a document from file
    iris.py --server myserver PUT /v1/HSLIB/doc/My.Class.cls --input src/HSLIB/My/Class.cls

    # PUT a document with JSON body
    iris.py --server myserver PUT /v1/HSLIB/doc/My.Class.cls --body '{"enc":false,"content":["line1","line2"]}'

    # POST compile
    iris.py --server myserver POST /v1/HSLIB/action/compile --body '["My.Class.cls"]'

    # Send raw body to a service URL (HL7, JSON, etc.)
    iris.py --server myserver POST /csp/healthshare/hslib/Service.cls?CfgItem=MyService --raw --input message.hl7
    iris.py --server myserver POST /csp/healthshare/hslib/Service.cls?CfgItem=MyService --raw --input payload.json --content-type application/json

    # HEAD request (e.g., logout)
    iris.py --server myserver HEAD '/?CacheLogout=end'

    # Show just the result.content (unwrap Atelier envelope)
    iris.py --server myserver GET /v1/HSLIB/doc/My.Class.cls --unwrap

    # Quiet mode (just exit code, no output)
    iris.py --server myserver GET /v1/HSLIB/doc/My.Class.cls --quiet
"""

import argparse
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import load_servers, build_base_url, resolve_password, make_request


def main():
    parser = argparse.ArgumentParser(
        description="Generic HTTP client for InterSystems IRIS Atelier REST API",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Path is appended to the Atelier API base URL: {scheme}://{host}:{port}{pathPrefix}/api/atelier")

    parser.add_argument("--server", "-s", required=True,
                        help="Server name from config/servers.json")
    parser.add_argument("method", choices=["GET", "POST", "PUT", "DELETE", "HEAD"],
                        help="HTTP method")
    parser.add_argument("path",
                        help="API path (e.g., /v1/HSLIB/doc/My.Class.cls). Appended to base URL unless --full-url is set.")
    parser.add_argument("--body", "-b",
                        help="JSON request body (string)")
    parser.add_argument("--input", "-i", dest="input_file",
                        help="Read request body from file. For --raw, sends file content as-is. Otherwise, wraps file lines in Atelier doc format.")
    parser.add_argument("--raw", action="store_true",
                        help="Send --input file as raw body (for HL7/JSON messages to services), don't wrap in Atelier format")
    parser.add_argument("--content-type", default=None,
                        help="Content-Type header for --raw requests (default: auto-detect)")
    parser.add_argument("--full-url", action="store_true",
                        help="Treat path as a full URL path (don't prepend /api/atelier)")
    parser.add_argument("--unwrap", "-u", action="store_true",
                        help="Unwrap Atelier response envelope — print only result.content")
    parser.add_argument("--quiet", "-q", action="store_true",
                        help="Suppress output, just set exit code (0=success, 1=error)")
    parser.add_argument("--timeout", "-t", type=int, default=30,
                        help="Request timeout in seconds (default: 30)")
    parser.add_argument("--password", "-p",
                        help="Password (overrides config)")
    parser.add_argument("--config", "-c",
                        help="Path to servers.json")
    args = parser.parse_args()

    # Load server config
    servers = load_servers(getattr(args, "config", None))
    server_name = args.server
    if server_name not in servers:
        if not args.quiet:
            print(f"ERROR: Server '{server_name}' not found. Available: {', '.join(servers.keys())}",
                  file=sys.stderr)
        sys.exit(1)

    server_config = servers[server_name]
    base_url = build_base_url(server_config)
    username = server_config.get("username", "superuser")
    password = resolve_password(server_name, server_config, getattr(args, "password", None))

    # Build full URL
    if args.full_url:
        ws = server_config["webServer"]
        scheme = ws.get("scheme", "http")
        host = ws["host"]
        port = ws.get("port", 80)
        prefix = ws.get("pathPrefix", "")
        url = f"{scheme}://{host}:{port}{prefix}{args.path}"
    else:
        url = f"{base_url}{args.path}"

    # Build request body
    data = None
    if args.body:
        try:
            data = json.loads(args.body)
        except json.JSONDecodeError:
            if not args.quiet:
                print("ERROR: --body must be valid JSON", file=sys.stderr)
            sys.exit(1)

    elif args.input_file:
        if not os.path.exists(args.input_file):
            if not args.quiet:
                print(f"ERROR: File not found: {args.input_file}", file=sys.stderr)
            sys.exit(1)

        if args.raw:
            # Send file content as raw body (for HL7, JSON messages to services)
            with open(args.input_file, "rb") as f:
                raw_bytes = f.read()

            # Detect content type
            content_type = args.content_type
            if not content_type:
                if args.input_file.endswith(".hl7"):
                    content_type = "application/hl7-v2"
                elif args.input_file.endswith(".json"):
                    content_type = "application/json"
                elif args.input_file.endswith(".xml"):
                    content_type = "application/xml"
                else:
                    content_type = "text/plain"

            # Use raw request path (bypass make_request's JSON handling)
            import base64
            import urllib.request
            import urllib.error

            credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
            req = urllib.request.Request(url, data=raw_bytes, method=args.method)
            req.add_header("Authorization", f"Basic {credentials}")
            req.add_header("Content-Type", content_type)

            try:
                with urllib.request.urlopen(req, timeout=args.timeout) as resp:
                    resp_text = resp.read().decode("utf-8", errors="replace")
                    if not args.quiet:
                        print(resp_text)
                    sys.exit(0)
            except urllib.error.HTTPError as e:
                if not args.quiet:
                    print(f"ERROR: HTTP {e.code}", file=sys.stderr)
                    try:
                        print(e.read().decode(), file=sys.stderr)
                    except Exception:
                        pass
                sys.exit(1)
            except urllib.error.URLError as e:
                if not args.quiet:
                    print(f"ERROR: {e.reason}", file=sys.stderr)
                sys.exit(1)

        else:
            # Wrap file content in Atelier document format
            with open(args.input_file, "r", encoding="utf-8") as f:
                text = f.read()
            lines = text.split("\n")
            data = {"enc": False, "content": lines}

    # Make the request
    status, body = make_request(url, username, password, method=args.method,
                                data=data, timeout=args.timeout)

    if status is None:
        if not args.quiet:
            print(f"ERROR: Could not reach server - {body}", file=sys.stderr)
        sys.exit(1)

    if args.quiet:
        sys.exit(0 if status < 400 else 1)

    # Format output
    if isinstance(body, dict):
        if args.unwrap:
            # Extract result.content from Atelier envelope
            # result can be a dict (with "content" key) or a list directly
            result = body.get("result", {})
            if isinstance(result, dict):
                content = result.get("content", result)
            else:
                content = result

            # Check for errors
            errors = body.get("status", {}).get("errors", [])
            if errors:
                for e in errors:
                    msg = e.get("error", str(e)) if isinstance(e, dict) else str(e)
                    print(f"ERROR: {msg}", file=sys.stderr)
                sys.exit(1)

            print(json.dumps(content, indent=2))
        else:
            print(json.dumps(body, indent=2))
    else:
        print(body)

    sys.exit(0 if status < 400 else 1)


if __name__ == "__main__":
    main()
