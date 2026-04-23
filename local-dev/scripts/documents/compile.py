#!/usr/bin/env python3
"""Compile one or more documents on an IRIS server.

Supports both synchronous (default) and async compilation.
Async mode uses the /work endpoint to queue compilation and polls for completion,
which avoids HTTP timeout issues on large compilations.

Usage:
    compile.py --server myserver --namespace HSLIB --docs "Class1.cls,Class2.cls"
    compile.py --server myserver --namespace HSLIB --docs "BigClass.cls" --async
    compile.py --server myserver --namespace HSLIB --docs "Class1.cls" --flags "cukb"
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import sys
import os
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (common_arg_parser, get_server_and_creds, make_request,
                      parse_atelier_response, AtelierError)


# ---------------------------------------------------------------------------
# Compile result display (shared between sync and async)
# ---------------------------------------------------------------------------

def _display_compile_result(result):
    """Display compilation output. Returns True if errors found."""
    has_errors = False
    if isinstance(result, list):
        for item in result:
            if isinstance(item, dict):
                doc_name = item.get("name", "unknown")
                content = item.get("content", [])

                if content:
                    print(f"\n{doc_name}:")
                    for line in content:
                        if isinstance(line, dict):
                            severity = line.get("severity", "")
                            text = line.get("text", str(line))
                            if severity:
                                print(f"  [{severity}] {text}")
                                if severity.lower() == "error":
                                    has_errors = True
                            else:
                                print(f"  {text}")
                        else:
                            print(f"  {line}")
                else:
                    print(f"{doc_name}: OK")
    else:
        print(f"Result: {result}")
    return has_errors


# ---------------------------------------------------------------------------
# Synchronous compile
# ---------------------------------------------------------------------------

def compile_sync(base_url, namespace, username, password, doc_list, flags="cuk"):
    """Compile documents synchronously. Returns (success, has_errors)."""
    url = f"{base_url}/v1/{namespace}/action/compile"
    status, body = make_request(url, username, password, method="POST",
                                data=doc_list, timeout=120)

    if status is None:
        print(f"ERROR: Could not reach server - {body}", file=sys.stderr)
        return False, True

    if status == 401:
        print("ERROR: Authentication failed (401)", file=sys.stderr)
        return False, True

    if status != 200:
        print(f"ERROR: Compilation failed with status {status}", file=sys.stderr)
        if isinstance(body, dict):
            try:
                parse_atelier_response(body)
            except AtelierError as e:
                print(f"  {e}", file=sys.stderr)
        return False, True

    try:
        result = parse_atelier_response(body)
    except AtelierError as e:
        print(f"COMPILE ERROR: {e}", file=sys.stderr)
        return False, True

    has_errors = _display_compile_result(result)
    return True, has_errors


# ---------------------------------------------------------------------------
# Async compile via /work endpoint
# ---------------------------------------------------------------------------

def compile_async(base_url, namespace, username, password, doc_list, flags="cuk",
                  max_wait=300, poll_start=0.5, poll_max=5.0):
    """Compile documents asynchronously via /work endpoint.

    1. POST /work to queue compilation
    2. GET /work/{id} to poll with exponential backoff
    3. Return results when complete

    Args:
        max_wait: Maximum seconds to wait for completion (default 300).
        poll_start: Initial poll interval in seconds.
        poll_max: Maximum poll interval in seconds.

    Returns:
        Tuple of (success, has_errors).
    """
    # 1. Queue the compile job
    url = f"{base_url}/v1/{namespace}/work"
    payload = {
        "action": "compile",
        "docs": doc_list,
        "flags": flags,
    }
    status, body = make_request(url, username, password, method="POST",
                                data=payload, timeout=30)

    if status is None:
        print(f"ERROR: Could not reach server - {body}", file=sys.stderr)
        return False, True

    if status == 401:
        print("ERROR: Authentication failed (401)", file=sys.stderr)
        return False, True

    if status not in (200, 201, 202):
        print(f"ERROR: Failed to queue compilation (HTTP {status})", file=sys.stderr)
        if isinstance(body, dict):
            errors = body.get("status", {}).get("errors", [])
            for e in errors:
                msg = e.get("error", str(e)) if isinstance(e, dict) else str(e)
                print(f"  {msg}", file=sys.stderr)
        return False, True

    # Extract job ID
    result = body.get("result", {})
    job_id = result.get("id")
    if not job_id:
        # Some versions return the ID differently
        job_id = result.get("content", {}).get("id") if isinstance(result.get("content"), dict) else None

    if not job_id:
        print("ERROR: No job ID returned from /work endpoint", file=sys.stderr)
        print(f"  Response: {body}", file=sys.stderr)
        # Fall back to sync
        print("  Falling back to synchronous compile...", file=sys.stderr)
        return compile_sync(base_url, namespace, username, password, doc_list, flags)

    print(f"  Queued compile job: {job_id}")

    # 2. Poll for completion
    poll_url = f"{base_url}/v1/{namespace}/work/{job_id}"
    interval = poll_start
    elapsed = 0.0

    while elapsed < max_wait:
        time.sleep(interval)
        elapsed += interval

        status, body = make_request(poll_url, username, password, method="GET", timeout=15)

        if status is None:
            print(f"  Warning: poll failed, retrying...", file=sys.stderr)
            interval = min(interval * 1.5, poll_max)
            continue

        if status == 404:
            # Job completed and was cleaned up, or never existed
            print(f"  Job {job_id} not found (may have completed already)")
            return True, False

        if status != 200:
            interval = min(interval * 1.5, poll_max)
            continue

        result = body.get("result", {})
        job_status = result.get("status", "")

        if job_status in ("complete", "completed", "done"):
            print(f"  Job completed in {elapsed:.1f}s")
            # Get the compilation results
            content = result.get("content", result)
            try:
                parsed = parse_atelier_response(body) if isinstance(body, dict) else content
            except AtelierError as e:
                print(f"COMPILE ERROR: {e}", file=sys.stderr)
                return False, True

            has_errors = _display_compile_result(
                parsed if isinstance(parsed, list) else [parsed])

            # Clean up the job
            make_request(f"{poll_url}", username, password, method="DELETE", timeout=5)
            return True, has_errors

        elif job_status in ("error", "failed"):
            errors = result.get("errors", result.get("content", []))
            print(f"ERROR: Compile job failed", file=sys.stderr)
            if errors:
                _display_compile_result(errors if isinstance(errors, list) else [errors])
            # Clean up
            make_request(f"{poll_url}", username, password, method="DELETE", timeout=5)
            return False, True

        # Still running — exponential backoff
        progress = result.get("progress", "")
        if progress:
            print(f"  [{elapsed:.0f}s] {progress}")
        interval = min(interval * 1.5, poll_max)

    # Timeout
    print(f"ERROR: Compile job timed out after {max_wait}s", file=sys.stderr)
    # Cancel the job
    make_request(f"{poll_url}", username, password, method="DELETE", timeout=5)
    return False, True


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = common_arg_parser("Compile documents on an IRIS server")
    parser.add_argument("--docs", "-d", required=True,
                        help="Comma-separated list of document names to compile")
    parser.add_argument("--flags", default="cuk",
                        help="Compile flags (default: cuk)")
    parser.add_argument("--async", dest="use_async", action="store_true",
                        help="Use async compilation via /work endpoint (better for large compiles)")
    parser.add_argument("--max-wait", type=int, default=300,
                        help="Max seconds to wait for async compile (default: 300)")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    server_config, base_url, username, password = get_server_and_creds(args)

    doc_list = [d.strip() for d in args.docs.split(",") if d.strip()]
    if not doc_list:
        print("ERROR: No documents specified", file=sys.stderr)
        sys.exit(1)

    mode = "async" if args.use_async else "sync"
    print(f"Compiling {len(doc_list)} document(s) in {args.namespace} ({mode})...")

    if args.use_async:
        success, has_errors = compile_async(
            base_url, args.namespace, username, password, doc_list,
            flags=args.flags, max_wait=args.max_wait)
    else:
        success, has_errors = compile_sync(
            base_url, args.namespace, username, password, doc_list,
            flags=args.flags)

    # Emit doc_compile audit event
    compile_status = "success" if (success and not has_errors) else "error"
    try:
        from audit import log_event
        log_event("doc_compile",
                  server=args.server,
                  namespace=args.namespace,
                  document_name=args.docs,
                  compile_status=compile_status,
                  compile_messages="",
                  duration_ms=0)
    except Exception:
        pass  # Best-effort

    if not success or has_errors:
        msg = "ERRORS" if has_errors else "FAILED"
        print(f"\nCompilation completed with {msg}", file=sys.stderr)
        sys.exit(1)
    else:
        print(f"\nCompilation completed successfully ({len(doc_list)} document(s))")


if __name__ == "__main__":
    main()
