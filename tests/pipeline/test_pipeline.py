#!/usr/bin/env python3
"""End-to-end test suite for the InterClaw native-IRIS pipeline.

Exercises both REST dispatch classes after a fresh install:
  - InterClaw.REST.Dispatch  — /api/interclaw/api/*      (control plane)
  - InterClaw.REST.Chat      — /api/interclaw/production/api/*  (chat stream)

Usage:
  python3 tests/pipeline/test_pipeline.py \
      --base http://vmdev1.iscinternal.com/interclaw-dev \
      --user superuser --password SYS

Exits non-zero on any failure. Prints a summary table.
"""
import argparse
import base64
import json
import sys
import time
from urllib import request, error, parse


class Client:
    def __init__(self, base: str, user: str, password: str, namespace: str = "INTERCLAW"):
        self.base = base.rstrip("/")
        self.namespace = namespace
        token = base64.b64encode(f"{user}:{password}".encode()).decode()
        self.auth = f"Basic {token}"

    def req(self, method: str, path: str, body=None, params=None, timeout: int = 60):
        url = self.base + path
        if params:
            url += "?" + parse.urlencode(params)
        data = None
        headers = {"Authorization": self.auth}
        if body is not None:
            data = json.dumps(body).encode("utf-8")
            headers["Content-Type"] = "application/json"
        r = request.Request(url, data=data, method=method, headers=headers)
        try:
            with request.urlopen(r, timeout=timeout) as resp:
                raw = resp.read()
                code = resp.getcode()
        except error.HTTPError as e:
            raw = e.read() if e.fp else b""
            code = e.code
        txt = raw.decode("utf-8", errors="replace")
        try:
            parsed = json.loads(txt) if txt else None
        except json.JSONDecodeError:
            parsed = None
        return code, parsed, txt


RESULTS = []


def run(name: str, fn):
    t0 = time.time()
    try:
        fn()
        RESULTS.append((name, True, f"{(time.time()-t0)*1000:.0f}ms", ""))
        print(f"  [PASS] {name}")
    except AssertionError as e:
        RESULTS.append((name, False, f"{(time.time()-t0)*1000:.0f}ms", str(e)))
        print(f"  [FAIL] {name}: {e}")
    except Exception as e:
        RESULTS.append((name, False, f"{(time.time()-t0)*1000:.0f}ms", f"{type(e).__name__}: {e}"))
        print(f"  [ERR]  {name}: {type(e).__name__}: {e}")


def test_control_health(c: Client):
    code, parsed, _ = c.req("GET", "/api/interclaw/api/health")
    assert code == 200, f"expected 200, got {code}"
    assert parsed and parsed.get("status") == "ok", f"bad body: {parsed}"
    assert parsed.get("service") == "interclaw-control", f"expected interclaw-control, got {parsed.get('service')}"


def test_chat_health(c: Client):
    code, parsed, _ = c.req("GET", "/api/interclaw/production/api/health")
    assert code == 200, f"expected 200, got {code}"
    assert parsed and parsed.get("status") == "ok", f"bad body: {parsed}"
    assert parsed.get("service") == "interclaw-v2", f"expected interclaw-v2, got {parsed.get('service')}"


def test_config(c: Client):
    code, parsed, _ = c.req("GET", "/api/interclaw/api/config")
    assert code in (200, 404), f"expected 200/404, got {code}"


def test_commands(c: Client):
    code, parsed, _ = c.req("GET", "/api/interclaw/api/commands")
    assert code in (200, 404), f"expected 200/404, got {code}"


def test_auth_status(c: Client):
    code, parsed, _ = c.req("GET", "/api/interclaw/api/auth-status")
    assert code == 200, f"expected 200, got {code}"
    assert parsed is not None, "no body"
    assert "authenticated" in parsed, f"missing authenticated field: {parsed}"
    assert parsed.get("provider") == "bedrock", f"expected bedrock, got {parsed.get('provider')}"


def test_get_namespace(c: Client):
    code, parsed, _ = c.req("GET", "/api/interclaw/api/namespace")
    assert code == 200, f"expected 200, got {code}"
    assert parsed and parsed.get("namespace"), f"no namespace: {parsed}"


def test_get_model(c: Client):
    code, parsed, _ = c.req("GET", "/api/interclaw/api/model")
    assert code == 200, f"expected 200, got {code}"
    assert parsed and parsed.get("model"), f"no model: {parsed}"


def test_permissions_roundtrip(c: Client):
    code, parsed, _ = c.req("GET", "/api/interclaw/api/permissions")
    assert code == 200, f"expected 200, got {code}"
    # don't assert content — may be {error: "Config not available"}


def test_portal_urls(c: Client):
    code, parsed, _ = c.req("GET", "/api/interclaw/production/api/portal-urls")
    assert code in (200, 404), f"expected 200/404, got {code}"


def test_chats_list(c: Client):
    code, parsed, _ = c.req("GET", "/api/interclaw/production/api/chats")
    assert code == 200, f"expected 200, got {code}"
    assert parsed is not None, "no body"
    assert "chats" in parsed, f"missing chats: {parsed}"


def test_chats_put_get(c: Client):
    chat_id = "test-" + str(int(time.time()))
    body = {
        "title": "Pipeline test chat",
        "messages": [{"role": "user", "content": "hello world"}],
        "model": "opus",
        "namespace": c.namespace,
    }
    code, parsed, txt = c.req("PUT", f"/api/interclaw/production/api/chats/{chat_id}", body=body)
    assert code == 200, f"PUT expected 200, got {code}: {txt[:200]}"
    code, parsed, _ = c.req("GET", f"/api/interclaw/production/api/chats/{chat_id}")
    assert code == 200, f"GET expected 200, got {code}"
    assert parsed.get("title") == "Pipeline test chat"
    # Cleanup
    c.req("DELETE", f"/api/interclaw/production/api/chats/{chat_id}")


def test_start_returns_bridge(c: Client):
    """Call /api/start with a trivial prompt; just verify we get a bridge_id back.
    The full streaming path requires a valid Bedrock credential, which may not be
    present — so we accept either a bridge_id OR a 503/500 with a descriptive error.
    """
    body = {"prompt": "ping", "session_id": "pipeline-test", "model": "opus", "namespace": c.namespace}
    code, parsed, txt = c.req("POST", "/api/interclaw/production/api/start", body=body, timeout=15)
    if code == 503:
        # production not running — acceptable only if we report it as the cause
        assert parsed and "error" in parsed, f"503 without error body: {txt[:200]}"
        return
    assert code == 200, f"expected 200 or 503, got {code}: {txt[:200]}"
    assert parsed and parsed.get("bridge_id"), f"no bridge_id: {parsed}"


def test_events_unknown_bridge(c: Client):
    code, parsed, _ = c.req("GET", "/api/interclaw/production/api/events", params={"bridge_id": "does-not-exist"})
    assert code == 200, f"expected 200, got {code}"
    assert parsed and "error" in parsed, f"expected error body: {parsed}"


def test_approve_noop(c: Client):
    code, parsed, _ = c.req("POST", "/api/interclaw/production/api/approve", body={})
    assert code == 200, f"expected 200, got {code}"
    assert parsed and parsed.get("ok") is True, f"expected ok:true, got {parsed}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", required=True, help="e.g. http://vmdev1.iscinternal.com/interclaw-dev")
    ap.add_argument("--user", default="superuser")
    ap.add_argument("--password", default="SYS")
    ap.add_argument("--namespace", default="INTERCLAW")
    args = ap.parse_args()

    c = Client(args.base, args.user, args.password, args.namespace)
    print(f"Target: {args.base}")

    tests = [
        ("control: /api/health",           lambda: test_control_health(c)),
        ("chat:    /api/health",           lambda: test_chat_health(c)),
        ("control: /api/config",           lambda: test_config(c)),
        ("control: /api/commands",         lambda: test_commands(c)),
        ("control: /api/auth-status",      lambda: test_auth_status(c)),
        ("control: /api/namespace (GET)",  lambda: test_get_namespace(c)),
        ("control: /api/model (GET)",      lambda: test_get_model(c)),
        ("control: /api/permissions (GET)",lambda: test_permissions_roundtrip(c)),
        ("chat:    /api/portal-urls",      lambda: test_portal_urls(c)),
        ("chat:    /api/chats (list)",     lambda: test_chats_list(c)),
        ("chat:    /api/chats (put/get)",  lambda: test_chats_put_get(c)),
        ("chat:    /api/start",            lambda: test_start_returns_bridge(c)),
        ("chat:    /api/events (unknown)", lambda: test_events_unknown_bridge(c)),
        ("chat:    /api/approve (no-op)",  lambda: test_approve_noop(c)),
    ]

    for name, fn in tests:
        run(name, fn)

    passed = sum(1 for _, ok, _, _ in RESULTS if ok)
    total = len(RESULTS)
    print()
    print(f"{'Test':45} {'Result':6} {'ms':>7}  Note")
    print("-" * 80)
    for name, ok, ms, note in RESULTS:
        status = "PASS" if ok else "FAIL"
        print(f"{name:45} {status:6} {ms:>7}  {note}")
    print(f"\n{passed}/{total} passed")
    sys.exit(0 if passed == total else 1)


if __name__ == "__main__":
    main()
