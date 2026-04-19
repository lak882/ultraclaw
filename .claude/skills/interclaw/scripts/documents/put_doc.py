#!/usr/bin/env python3
"""Push a document (class, routine, etc.) to an IRIS server."""
import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (common_arg_parser, get_server_and_creds, make_request,
                      parse_atelier_response, AtelierError)
from portal_urls import classify_component, classify_from_source


def get_existing_document(base_url, namespace, doc_name, username, password):
    """Get the current timestamp and content of a document.

    Used for concurrency control (timestamp check).

    Returns:
        Tuple of (timestamp, content_string). Both are None if the document
        doesn't exist yet (new document).
    """
    url = f"{base_url}/v1/{namespace}/doc/{doc_name}"
    status, body = make_request(url, username, password)

    if status == 404:
        return None, None  # New document

    if status == 200 and isinstance(body, dict):
        result = body.get("result", {})
        ts = result.get("ts")
        content = result.get("content", [])
        if isinstance(content, list):
            return ts, "\n".join(str(line) for line in content)
        return ts, str(content) if content else None

    return None, None


def main():
    parser = common_arg_parser("Push a document to an IRIS namespace")
    parser.add_argument("--doc", "-d", required=True,
                        help="Document name (e.g. My.Package.ClassName.cls)")
    parser.add_argument("--input", "-i", default=None,
                        help="Input file path (default: stdin)")
    parser.add_argument("--compile", action="store_true",
                        help="Compile the document after saving")
    parser.add_argument("--flags", default="cuk",
                        help="Compile flags (default: cuk)")
    parser.add_argument("--force", action="store_true",
                        help="Skip timestamp concurrency check (use when overwriting server changes)")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    server_config, base_url, username, password = get_server_and_creds(args)

    # Read content
    if args.input:
        if not os.path.exists(args.input):
            print(f"ERROR: File not found: {args.input}", file=sys.stderr)
            sys.exit(1)
        with open(args.input, "r", encoding="utf-8") as f:
            text = f.read()
    else:
        text = sys.stdin.read()

    lines = text.split("\n")

    # Fetch current state for concurrency control (timestamp)
    ts, before_content = get_existing_document(base_url, args.namespace, args.doc, username, password)
    is_update = ts is not None

    put_data = {
        "enc": False,
        "content": lines
    }
    if not args.force and ts is not None:
        put_data["ts"] = ts

    # PUT the document — use ?ignoreConflict=1 for updates (required by Atelier API)
    url = f"{base_url}/v1/{args.namespace}/doc/{args.doc}"
    put_url = f"{url}?ignoreConflict=1" if is_update else url
    status, body = make_request(put_url, username, password, method="PUT", data=put_data)

    # If 409 conflict and --force, delete and retry as new document
    if status == 409 and args.force:
        print(f"Conflict detected, deleting and re-saving...", file=sys.stderr)
        make_request(url, username, password, method="DELETE")
        put_data.pop("ts", None)
        status, body = make_request(url, username, password, method="PUT", data=put_data)

    if status is None:
        print(f"ERROR: Could not reach server - {body}", file=sys.stderr)
        sys.exit(1)

    if status == 401:
        print("ERROR: Authentication failed (401)", file=sys.stderr)
        sys.exit(1)

    if status not in (200, 201):
        print(f"ERROR: Save failed with status {status}", file=sys.stderr)
        if isinstance(body, dict):
            try:
                parse_atelier_response(body)
            except AtelierError as e:
                print(f"  {e}", file=sys.stderr)
        sys.exit(1)

    if status == 201:
        print(f"OK: Created '{args.doc}' in {args.namespace}")
    else:
        print(f"OK: Updated '{args.doc}' in {args.namespace}")

    push_action = "create" if status == 201 else "push"

    # Track compile status for the doc_put audit event
    _compile_status = "not_compiled"
    _compile_messages = ""

    # Optionally compile
    if args.compile:
        compile_url = f"{base_url}/v1/{args.namespace}/action/compile"
        compile_data = [args.doc]
        c_status, c_body = make_request(compile_url, username, password,
                                        method="POST", data=compile_data)

        if c_status == 200:
            try:
                result = parse_atelier_response(c_body)
                _compile_status = "success"
                print(f"OK: Compiled '{args.doc}'")
                # Show any compilation messages
                _compile_msg_lines = []
                if isinstance(result, list):
                    for item in result:
                        if isinstance(item, dict) and item.get("content"):
                            for line in item["content"]:
                                _compile_msg_lines.append(str(line))
                                print(f"  {line}")
                _compile_messages = "\n".join(_compile_msg_lines)
                # Determine component type deterministically from source code
                class_name = args.doc
                if class_name.endswith('.cls'):
                    class_name = class_name[:-4]
                # Primary: parse Extends clause from actual source
                comp_type = classify_from_source(text)
                # Fallback: name heuristics (for non-class docs or missing Extends)
                if not comp_type:
                    comp_type = classify_component(class_name)
                    if comp_type == "unknown":
                        comp_type = None

                # Emit /goto for Angular interop-editor auto-navigation
                goto_flags = {"dtl": "--dtl", "rule": "--rule", "bpl": "--bpl", "lookup": "--lookup"}
                flag = goto_flags.get(comp_type, "")
                print(f"/goto {flag + ' ' if flag else ''}{class_name}")
            except AtelierError as e:
                _compile_status = "error"
                _compile_messages = str(e)
                print(f"COMPILE ERROR: {e}", file=sys.stderr)
                sys.exit(1)
        else:
            _compile_status = "error"
            _compile_messages = f"HTTP {c_status}"
            print(f"COMPILE ERROR: Compilation failed with status {c_status}", file=sys.stderr)
            sys.exit(1)

    # Emit doc_put audit event (after compile so we have compile status)
    try:
        from audit import log_event
        log_event("doc_put",
                  server=args.server,
                  namespace=args.namespace,
                  document_name=args.doc,
                  action=push_action,
                  is_new=(status == 201),
                  before_content=before_content or "",
                  after_content=text or "",
                  compile_status=_compile_status,
                  compile_messages=_compile_messages)
    except Exception:
        pass  # Best-effort


if __name__ == "__main__":
    main()
