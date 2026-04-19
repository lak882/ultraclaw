#!/usr/bin/env python3
"""Send HL7 messages to an IRIS server via HTTP, TCP/MLLP, or file drop.

Transport is selected explicitly (--http, --tcp, --file) or auto-detected
from the target component's class name.
"""
import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import base64
import os
import re
import shutil
import socket
import sys
import time
import urllib.error
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import load_servers, build_base_url, resolve_password, common_arg_parser

# MLLP framing
VT = b"\x0b"
FS = b"\x1c"
CR = b"\x0d"


# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------

def parse_ack(response_text):
    """Parse an HL7 ACK response.  Returns (ack_code, control_id, text)."""
    for segment in response_text.replace("\n", "\r").split("\r"):
        fields = segment.split("|")
        if fields[0] == "MSA" and len(fields) >= 2:
            return (
                fields[1] if len(fields) > 1 else None,
                fields[2] if len(fields) > 2 else None,
                fields[3] if len(fields) > 3 else None,
            )
    return None, None, None


def split_hl7_messages(text):
    """Split text containing multiple HL7 messages on MSH boundaries."""
    text = text.replace("\r\n", "\r").replace("\n", "\r")
    messages, current = [], []
    for line in text.split("\r"):
        if not line.strip():
            continue
        if line.startswith("MSH") and current:
            messages.append("\r".join(current))
            current = []
        current.append(line)
    if current:
        messages.append("\r".join(current))
    return messages


def msg_info(msg):
    """Extract (msg_type, control_id) from an HL7 message string."""
    fields = msg.split("\r")[0].split("|") if msg else []
    return (
        fields[8] if len(fields) > 8 else "unknown",
        fields[9] if len(fields) > 9 else "msg?",
    )


def format_result(i, msg_type, control_id, ack_code, ack_text, response, elapsed, raw):
    """Format a single send result line."""
    if raw:
        return f"  [{i}] Response ({elapsed}ms):\n    {response}"

    if ack_code in ("AA", "CA"):
        return f"  [{i}] {msg_type} ({control_id}): ACCEPTED ({elapsed}ms)"
    if ack_code in ("AE", "CE"):
        return f"  [{i}] {msg_type} ({control_id}): ERROR - {ack_text or response} ({elapsed}ms)"
    if ack_code in ("AR", "CR"):
        return f"  [{i}] {msg_type} ({control_id}): REJECTED - {ack_text or response} ({elapsed}ms)"
    if response and response.strip():
        return f"  [{i}] {msg_type} ({control_id}): Response ({elapsed}ms)\n    {response[:200]}"
    return f"  [{i}] {msg_type} ({control_id}): No response ({elapsed}ms)"


# ---------------------------------------------------------------------------
# HTTP transport
# ---------------------------------------------------------------------------

def send_http(host, port, path, username, password, message, content_type, scheme="http"):
    """POST a single HL7 message via HTTP.  Returns (status, body_text)."""
    url = f"{scheme}://{host}:{port}{path}"
    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
    req = urllib.request.Request(url, data=message.encode("utf-8"), method="POST")
    req.add_header("Authorization", f"Basic {credentials}")
    req.add_header("Content-Type", content_type)
    req.add_header("Accept", "application/hl7-v2, text/plain")
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.status, resp.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace") if e.fp else ""
        return e.code, body
    except urllib.error.URLError as e:
        return None, str(e.reason)


# ---------------------------------------------------------------------------
# TCP / MLLP transport
# ---------------------------------------------------------------------------

def send_mllp(host, port, message, timeout=30):
    """Send a single HL7 message over TCP/MLLP.  Returns (response_text, elapsed_ms)."""
    payload = VT + message.encode("utf-8") + FS + CR
    start = time.monotonic()
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        sock.connect((host, port))
        sock.sendall(payload)
        buf = b""
        while True:
            chunk = sock.recv(4096)
            if not chunk:
                break
            buf += chunk
            if FS in buf:
                break
        sock.close()
        elapsed = int((time.monotonic() - start) * 1000)
        resp = buf
        if resp.startswith(VT):
            resp = resp[1:]
        idx = resp.find(FS)
        if idx != -1:
            resp = resp[:idx]
        return resp.decode("utf-8", errors="replace"), elapsed
    except socket.timeout:
        return None, int((time.monotonic() - start) * 1000)
    except OSError:
        return None, 0


# ---------------------------------------------------------------------------
# File transport
# ---------------------------------------------------------------------------

def send_file(directory, filepath):
    """Copy a file into a file-service input directory.  Returns dest path."""
    dest = os.path.join(directory, os.path.basename(filepath))
    shutil.copy2(filepath, dest)
    return dest


# ---------------------------------------------------------------------------
# Auto-detect transport from component class name
# ---------------------------------------------------------------------------

TCP_CLASSES = {
    "EnsLib.HL7.Service.TCPService",
    "EnsLib.TCP.PassthroughService",
}
FILE_CLASSES = {
    "EnsLib.HL7.Service.FileService",
    "EnsLib.File.PassthroughService",
    "EnsLib.RecordMap.Service.FileService",
    "EnsLib.EDI.XML.Service.FileService",
}
HTTP_CLASSES = {
    "EnsLib.HL7.Service.HTTPService",
    "EnsLib.HTTP.GenericService",
}


def detect_transport(class_name):
    """Return 'tcp', 'file', or 'http' based on the service class name."""
    if class_name in TCP_CLASSES:
        return "tcp"
    if class_name in FILE_CLASSES:
        return "file"
    if class_name in HTTP_CLASSES:
        return "http"
    # Heuristic fallback
    lower = class_name.lower()
    if "tcp" in lower or "mllp" in lower:
        return "tcp"
    if "file" in lower:
        return "file"
    return "http"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = common_arg_parser("Send HL7 messages via HTTP, TCP/MLLP, or file drop")

    # Transport mode (mutually exclusive)
    mode_group = parser.add_mutually_exclusive_group()
    mode_group.add_argument("--http", action="store_const", dest="transport", const="http",
                            help="Send via HTTP POST (default)")
    mode_group.add_argument("--tcp", action="store_const", dest="transport", const="tcp",
                            help="Send via TCP/MLLP")
    mode_group.add_argument("--file", action="store_const", dest="transport", const="file",
                            help="Copy to file service input directory")

    # Common
    parser.add_argument("--input", "-i", default=None,
                        help="File containing HL7 message(s) (default: stdin)")
    parser.add_argument("--raw", action="store_true",
                        help="Print raw response without parsing ACK")
    parser.add_argument("--to", default=None,
                        help="Target config item name (auto-detects transport from class)")

    # HTTP-specific
    parser.add_argument("--url", "-u", default=None,
                        help="HTTP URL path (overrides --to for HTTP)")
    parser.add_argument("--content-type", default="application/hl7-v2",
                        help="HTTP Content-Type (default: application/hl7-v2)")

    # TCP-specific
    parser.add_argument("--port", type=int, default=None,
                        help="TCP port for MLLP")
    parser.add_argument("--host", default=None,
                        help="Target hostname (default: from server config)")
    parser.add_argument("--timeout", type=int, default=30,
                        help="TCP socket timeout in seconds (default: 30)")

    # File-specific
    parser.add_argument("--dir", default=None,
                        help="File service input directory (overrides auto-detect)")

    parser._option_string_actions["--namespace"].required = False
    args = parser.parse_args()

    # Fix Git Bash MSYS path mangling
    if args.url and sys.platform == "win32" and not args.url.startswith("/"):
        m = re.match(r'[A-Za-z]:[/\\].*?(/iris\w*/.*)', args.url)
        if m:
            args.url = m.group(1)

    # Load server config
    servers = load_servers(getattr(args, "config", None))
    server_name = args.server
    if server_name not in servers:
        print(f"ERROR: Server '{server_name}' not found", file=sys.stderr)
        sys.exit(1)
    server_config = servers[server_name]
    ws = server_config["webServer"]
    host = args.host or ws["host"]
    web_port = ws.get("port", 80)
    scheme = ws.get("scheme", "http")
    username = server_config.get("username", "superuser")
    password = resolve_password(server_name, server_config, getattr(args, "password", None))

    # Read HL7 content
    if args.input:
        if not os.path.exists(args.input):
            print(f"ERROR: File not found: {args.input}", file=sys.stderr)
            sys.exit(1)
        with open(args.input, "r", encoding="utf-8") as f:
            text = f.read()
    else:
        text = sys.stdin.read()
    if not text.strip():
        print("ERROR: No HL7 message content provided", file=sys.stderr)
        sys.exit(1)

    messages = split_hl7_messages(text)
    transport = args.transport  # may be None (auto-detect)

    # -----------------------------------------------------------------------
    # Auto-detect from --to (config item name)
    # -----------------------------------------------------------------------
    tcp_port = args.port
    file_dir = args.dir
    http_url = args.url

    if args.to and not transport:
        # Parse production XData to find the component's class and settings
        try:
            import json
            ns = args.namespace or ""
            base = build_base_url(server_config)
            cred = base64.b64encode(f"{username}:{password}".encode()).decode()
            prefix = ws.get("pathPrefix", "")

            # Use Interop Editors API to get running production status
            interop_url = f"{scheme}://{host}:{web_port}{prefix}/api/interop-editors/v1/{ns}/productions"
            req = urllib.request.Request(interop_url)
            req.add_header("Authorization", f"Basic {cred}")
            with urllib.request.urlopen(req, timeout=10) as r:
                prods = json.loads(r.read())

            # Find running production name
            prod_name = None
            prod_list = prods if isinstance(prods, list) else prods.get("productions", [])
            for p in prod_list:
                if isinstance(p, dict) and p.get("status") in ("Running", "running", 2, "2"):
                    prod_name = p.get("name") or p.get("Name")
                    break

            # Fallback: list all productions from Ens_Config and try first
            if not prod_name:
                q_url = f"{base}/v8/{ns}/action/query"
                sql = "SELECT Name FROM Ens_Config.Production"
                req2 = urllib.request.Request(q_url, method="POST",
                                             data=json.dumps({"query": sql}).encode())
                req2.add_header("Authorization", f"Basic {cred}")
                req2.add_header("Content-Type", "application/json")
                with urllib.request.urlopen(req2, timeout=10) as r2:
                    q_data = json.loads(r2.read())
                rows = q_data.get("result", {}).get("content", [])
                # Pick the non-Foundation production if possible
                for row in rows:
                    name = row.get("Name", "")
                    if "Foundation" not in name:
                        prod_name = name
                        break
                if not prod_name and rows:
                    prod_name = rows[0].get("Name")

            if prod_name:
                # Fetch production source and parse XML for the target item
                doc_url = f"{base}/v8/{ns}/doc/{prod_name}.cls"
                req_doc = urllib.request.Request(doc_url)
                req_doc.add_header("Authorization", f"Basic {cred}")
                with urllib.request.urlopen(req_doc, timeout=10) as rd:
                    prod_src = json.loads(rd.read())
                content = "\n".join(prod_src.get("result", {}).get("content", []))

                # Find the <Item> block for --to
                pattern = rf'<Item\s[^>]*Name="{re.escape(args.to)}".*?</Item>'
                item_match = re.search(pattern, content, re.DOTALL)
                if item_match:
                    item_xml = item_match.group()
                    cls_match = re.search(r'ClassName="([^"]+)"', item_xml)
                    if cls_match:
                        cls = cls_match.group(1)
                        transport = detect_transport(cls)
                        print(f"Auto-detected transport: {transport} (from {cls})")

                    if transport == "tcp" and not tcp_port:
                        port_match = re.search(r'Name="Port">(\d+)<', item_xml)
                        if port_match:
                            tcp_port = int(port_match.group(1))

                    if transport == "file" and not file_dir:
                        fp_match = re.search(r'Name="FilePath">([^<]+)<', item_xml)
                        if fp_match:
                            file_dir = fp_match.group(1)
                else:
                    print(f"Warning: component '{args.to}' not found in {prod_name}", file=sys.stderr)
        except Exception as e:
            print(f"Warning: auto-detect failed ({e}), falling back to HTTP", file=sys.stderr)

    # Default transport
    if not transport:
        transport = "http"

    # -----------------------------------------------------------------------
    # Send via selected transport
    # -----------------------------------------------------------------------
    success_count = 0
    error_count = 0

    if transport == "http":
        # Build URL
        if not http_url:
            if args.to:
                ns = (args.namespace or "").lower()
                prefix = ws.get("pathPrefix", "")
                http_url = f"{prefix}/csp/healthshare/{ns}/EnsLib.HL7.Service.HTTPService.cls?CfgItem={args.to}"
            else:
                print("ERROR: --url or --to required for HTTP transport", file=sys.stderr)
                sys.exit(1)

        print(f"Sending {len(messages)} message(s) via HTTP to {scheme}://{host}:{web_port}{http_url}")
        for i, msg in enumerate(messages, 1):
            msg_type, control_id = msg_info(msg)
            start = time.monotonic()
            status, response = send_http(host, web_port, http_url, username, password,
                                         msg, args.content_type, scheme)
            elapsed = int((time.monotonic() - start) * 1000)
            if status is None:
                print(f"  [{i}] {msg_type} ({control_id}): FAILED - {response}")
                error_count += 1
            else:
                ack_code, _, ack_text = parse_ack(response)
                is_ok = ack_code in ("AA", "CA") or (not ack_code and status == 200)
                print(format_result(i, msg_type, control_id, ack_code, ack_text, response, elapsed, args.raw))
                if is_ok:
                    success_count += 1
                else:
                    error_count += 1

    elif transport == "tcp":
        if not tcp_port:
            print("ERROR: --port required for TCP transport (or use --to with a namespace to auto-detect)", file=sys.stderr)
            sys.exit(1)
        print(f"Sending {len(messages)} message(s) via MLLP to {host}:{tcp_port}")
        for i, msg in enumerate(messages, 1):
            msg_type, control_id = msg_info(msg)
            response, elapsed = send_mllp(host, tcp_port, msg, args.timeout)
            if response is None:
                print(f"  [{i}] {msg_type} ({control_id}): TIMEOUT after {elapsed}ms")
                error_count += 1
            else:
                ack_code, _, ack_text = parse_ack(response)
                is_ok = ack_code in ("AA", "CA") or (not ack_code and response.strip())
                print(format_result(i, msg_type, control_id, ack_code, ack_text, response, elapsed, args.raw))
                if is_ok:
                    success_count += 1
                else:
                    error_count += 1

    elif transport == "file":
        if not file_dir:
            print("ERROR: --dir required for file transport (or use --to with a namespace to auto-detect)", file=sys.stderr)
            sys.exit(1)
        if not os.path.isdir(file_dir):
            print(f"ERROR: Directory not found: {file_dir}", file=sys.stderr)
            sys.exit(1)
        if args.input:
            dest = send_file(file_dir, args.input)
            print(f"Copied {args.input} -> {dest}")
            success_count = len(messages)
        else:
            # Write stdin content to a temp file in the target dir
            import datetime
            ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            dest = os.path.join(file_dir, f"send_{ts}.hl7")
            with open(dest, "w", encoding="utf-8") as f:
                f.write(text)
            print(f"Wrote {len(messages)} message(s) to {dest}")
            success_count = len(messages)

    # Summary
    if len(messages) > 1:
        print(f"\nSent: {len(messages)} | Accepted: {success_count} | Errors: {error_count}")

    sys.exit(1 if error_count > 0 else 0)


if __name__ == "__main__":
    main()
