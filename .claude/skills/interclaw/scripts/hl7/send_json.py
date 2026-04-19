#!/usr/bin/env python3
"""Send JSON payloads to an IRIS production HTTP service via CSP web gateway."""
import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import base64
import json
import re
import sys
import os
import urllib.request
import urllib.error

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import load_servers, build_base_url, resolve_password, common_arg_parser


def send_json(host, port, path, username, password, payload, scheme="http"):
    """POST a JSON payload and return the response.

    Args:
        host: Server hostname.
        port: Server port.
        path: URL path for the HTTP service.
        username: Basic auth username.
        password: Basic auth password.
        payload: JSON string to send.
        scheme: http or https.

    Returns:
        Tuple of (status_code, response_body_text, content_type).
    """
    url = f"{scheme}://{host}:{port}{path}"
    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()

    body = payload.encode("utf-8")

    req = urllib.request.Request(url, data=body, method="POST")
    req.add_header("Authorization", f"Basic {credentials}")
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json, text/plain")

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            ct = resp.headers.get("Content-Type", "")
            return resp.status, resp.read().decode("utf-8", errors="replace"), ct
    except urllib.error.HTTPError as e:
        body_text = ""
        ct = ""
        if e.fp:
            body_text = e.read().decode("utf-8", errors="replace")
            ct = e.headers.get("Content-Type", "") if e.headers else ""
        return e.code, body_text, ct
    except urllib.error.URLError as e:
        return None, str(e.reason), ""


def main():
    parser = common_arg_parser("Send JSON payload to IRIS HTTP service")
    parser.add_argument("--url", "-u", required=True,
                        help="URL path for the HTTP service (e.g. /irishealth/csp/healthshare/jsondemo/Demo.JSON.BS.JSONHTTPService.cls?CfgItem=JSON.HTTPService)")
    parser.add_argument("--input", "-i", default=None,
                        help="File containing JSON payload (default: stdin)")

    # Override namespace as not required for this script
    parser._option_string_actions["--namespace"].required = False
    args = parser.parse_args()

    # Fix Git Bash MSYS path mangling on Windows
    if sys.platform == "win32" and not args.url.startswith("/"):
        match = re.match(r'[A-Za-z]:[/\\].*?(/iris\w*/.*)', args.url)
        if match:
            print(f"Detected MSYS path mangling, fixing: {args.url} -> {match.group(1)}",
                  file=sys.stderr)
            args.url = match.group(1)

    # Load server config
    servers = load_servers(getattr(args, "config", None))
    server_name = args.server
    if server_name not in servers:
        print(f"ERROR: Server '{server_name}' not found in config/servers.json", file=sys.stderr)
        print(f"Available servers: {', '.join(servers.keys())}", file=sys.stderr)
        sys.exit(1)

    server_config = servers[server_name]
    ws = server_config["webServer"]
    host = ws["host"]
    port = ws.get("port", 80)
    scheme = ws.get("scheme", "http")
    username = server_config.get("username", "superuser")
    password = resolve_password(server_name, server_config, getattr(args, "password", None))

    # Read JSON content
    if args.input:
        if not os.path.exists(args.input):
            print(f"ERROR: File not found: {args.input}", file=sys.stderr)
            sys.exit(1)
        with open(args.input, "r", encoding="utf-8") as f:
            text = f.read()
    else:
        text = sys.stdin.read()

    if not text.strip():
        print("ERROR: No JSON content provided", file=sys.stderr)
        sys.exit(1)

    # Validate JSON
    try:
        json.loads(text)
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"Sending JSON to {scheme}://{host}:{port}{args.url}")

    status, response, content_type = send_json(
        host, port, args.url, username, password, text, scheme
    )

    if status is None:
        print(f"FAILED: {response}")
        sys.exit(1)

    print(f"HTTP {status}")
    if response.strip():
        # Try to pretty-print JSON responses
        if "json" in content_type.lower():
            try:
                parsed = json.loads(response)
                print(json.dumps(parsed, indent=2))
            except json.JSONDecodeError:
                print(response[:500])
        else:
            print(response[:500])

    sys.exit(0 if 200 <= status < 300 else 1)


if __name__ == "__main__":
    main()
