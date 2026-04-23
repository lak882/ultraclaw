#!/usr/bin/env python3
"""Search code on the IRIS server via the Atelier action/search endpoint.

Server-side grep — find references, usages, and patterns across an entire namespace
without downloading all source files.

Uses: GET /api/atelier/v8/{namespace}/action/search (API v2+)

Usage:
    search_code.py --server myserver --namespace HSLIB --query "HTTPService"
    search_code.py --server myserver --namespace HSLIB --query "OnProcessInput" --files "*.cls"
    search_code.py --server myserver --namespace HSLIB --query "EnsLib\\.HL7" --regex
    search_code.py --server myserver --namespace HSLIB --query "TODO" --max 50 --json
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import argparse
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from iris_api import load_servers, build_base_url, resolve_password, make_request, common_arg_parser


def search_code(base_url, namespace, username, password, query,
                files="*.cls,*.mac,*.int,*.inc", regex=False, case_sensitive=False,
                include_system=False, include_generated=False, max_results=100,
                timeout=30):
    """Search code on the server.

    Args:
        base_url: Atelier API base URL.
        namespace: IRIS namespace.
        username/password: Credentials.
        query: Search string or regex pattern.
        files: File pattern filter (default: *.cls,*.mac,*.int,*.inc).
        regex: If True, query is treated as a regex.
        case_sensitive: If True, search is case-sensitive.
        include_system: If True, include system (%SYS) files.
        include_generated: If True, include generated files.
        max_results: Maximum number of results.
        timeout: Request timeout.

    Returns:
        List of dicts: [{"doc": "Name.cls", "matches": [{"text": "...", "line": N, "member": "...", "attr": "..."}]}]
    """
    import urllib.parse

    params = {
        "query": query,
        "files": files,
        "sys": "1" if include_system else "0",
        "gen": "1" if include_generated else "0",
        "max": str(max_results),
        "regex": "1" if regex else "0",
        "case": "1" if case_sensitive else "0",
    }

    qs = urllib.parse.urlencode(params)
    url = f"{base_url}/v2/{namespace}/action/search?{qs}"

    status, body = make_request(url, username, password, method="GET", timeout=timeout)

    if status != 200:
        error = body if isinstance(body, str) else json.dumps(body)
        raise RuntimeError(f"Search failed (HTTP {status}): {error}")

    if not isinstance(body, dict):
        return []

    result = body.get("result", [])
    # result is a list directly (not wrapped in {"content": [...]})
    if isinstance(result, dict):
        result = result.get("content", [])

    results = []
    for item in result:
        doc = item.get("doc", "")
        matches = []
        for m in item.get("matches", []):
            matches.append({
                "text": m.get("text", ""),
                "line": m.get("line", 0),
                "member": m.get("member", ""),
                "attr": m.get("attr", ""),
            })
        if matches:
            results.append({"doc": doc, "matches": matches})

    return results


def format_as_text(results, show_context=True):
    """Format search results as human-readable text."""
    if not results:
        return "No matches found."

    total_matches = sum(len(r["matches"]) for r in results)
    lines = [f"Found {total_matches} match(es) in {len(results)} file(s):", ""]

    for r in results:
        doc = r["doc"]
        lines.append(f"  {doc}")
        if show_context:
            for m in r["matches"]:
                line_num = m["line"]
                text = m["text"].strip()
                member = m.get("member", "")
                prefix = f"    {line_num:5d}: "
                if member:
                    prefix = f"    {line_num:5d} [{member}]: "
                lines.append(f"{prefix}{text}")
        lines.append("")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = common_arg_parser("Search code on the IRIS server (server-side grep)")
    parser.add_argument("--query", "-q", required=True,
                        help="Search string or regex pattern")
    parser.add_argument("--files", "-f", default="*.cls,*.mac,*.int,*.inc",
                        help="File pattern filter (default: *.cls,*.mac,*.int,*.inc)")
    parser.add_argument("--regex", "-r", action="store_true",
                        help="Treat query as regex")
    parser.add_argument("--case", action="store_true",
                        help="Case-sensitive search")
    parser.add_argument("--system", action="store_true",
                        help="Include system (%%SYS) files")
    parser.add_argument("--generated", action="store_true",
                        help="Include generated files")
    parser.add_argument("--max", type=int, default=100,
                        help="Maximum results (default: 100)")
    parser.add_argument("--json", dest="output_json", action="store_true",
                        help="Output as JSON")
    parser.add_argument("--format", choices=["json", "text"], default=None,
                        help="Output format (default: text)")
    args = parser.parse_args()

    use_json = args.output_json or args.format == "json"

    servers = load_servers(getattr(args, "config", None))
    server_name = args.server
    if server_name not in servers:
        print(f"ERROR: Server '{server_name}' not found", file=sys.stderr)
        sys.exit(1)

    server_config = servers[server_name]
    base_url = build_base_url(server_config)
    username = server_config.get("username", "superuser")
    password = resolve_password(server_name, server_config, getattr(args, "password", None))
    namespace = args.namespace or "USER"

    try:
        results = search_code(
            base_url, namespace, username, password,
            query=args.query,
            files=args.files,
            regex=args.regex,
            case_sensitive=args.case,
            include_system=args.system,
            include_generated=args.generated,
            max_results=args.max,
        )
    except RuntimeError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

    if use_json:
        print(json.dumps(results, indent=2))
    else:
        print(format_as_text(results))


if __name__ == "__main__":
    main()
