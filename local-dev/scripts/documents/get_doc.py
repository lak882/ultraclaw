#!/usr/bin/env python3
"""Pull a document (class, routine, etc.) from an IRIS server."""
import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import common_arg_parser, get_server_and_creds, make_request, parse_atelier_response


def main():
    parser = common_arg_parser("Get a document from an IRIS namespace")
    parser.add_argument("--doc", "-d", required=True,
                        help="Document name (e.g. My.Package.ClassName.cls)")
    parser.add_argument("--output", "-o", default=None,
                        help="Output file path (default: stdout)")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    _, base_url, username, password = get_server_and_creds(args)

    url = f"{base_url}/v1/{args.namespace}/doc/{args.doc}"
    status, body = make_request(url, username, password)

    if status is None:
        print(f"ERROR: Could not reach server - {body}", file=sys.stderr)
        sys.exit(1)

    if status == 404:
        print(f"ERROR: Document '{args.doc}' not found in {args.namespace}", file=sys.stderr)
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

    # Content is an array of lines
    if isinstance(content, list):
        text = "\n".join(str(line) for line in content)
    else:
        text = str(content)

    # Emit doc_get audit event with full content
    try:
        from audit import log_event
        line_count = text.count("\n") + (1 if text and not text.endswith("\n") else 0)
        log_event("doc_get",
                  server=args.server,
                  namespace=args.namespace,
                  document_name=args.doc,
                  content=text,
                  line_count=line_count)
    except Exception:
        pass  # Best-effort

    if args.output:
        # Ensure output directory exists
        out_dir = os.path.dirname(args.output)
        if out_dir:
            os.makedirs(out_dir, exist_ok=True)
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(text)
        print(f"Saved to {args.output}", file=sys.stderr)
    else:
        print(text)


if __name__ == "__main__":
    main()
