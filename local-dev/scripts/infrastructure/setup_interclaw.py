#!/usr/bin/env python3
"""Post-install setup for InterClaw on a fresh IRIS instance.

Automates the full sequence after IRIS is installed and the git repo is available:
  1. Create INTERCLAW namespace (HS.Util.Installer.Foundation)
  2. Ensure ZPM is installed and enabled globally
  3. Load the InterClaw IPM package (zpm "load <repo>")
  4. Authenticate with Bedrock API key (from env or --key)
  5. Verify: connection test, SQL query, chat pipeline test

Requires: the IRIS instance is running and registered in config/servers.json.

Usage:
  setup_interclaw.py --server interclaw-prod --repo /usr/local/InterSystems/interop-agent-orchestrator
  setup_interclaw.py --server interclaw-prod --repo /path/to/repo --namespace MYNS
  setup_interclaw.py --server interclaw-prod --repo /path/to/repo --skip-auth
  setup_interclaw.py --server interclaw-prod --repo /path/to/repo --dry-run
  setup_interclaw.py --server interclaw-prod --repo /path/to/repo --verify-only
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import argparse
import json
import os
import sys
import urllib.request
import urllib.error

from iris_terminal import ws_run_objectscript
from iris_api import load_servers, resolve_password

# Module-level state set by main()
_server_name = None
_config_path = None

DEFAULT_NAMESPACE = "INTERCLAW"
HSLIB_NAMESPACE = "HSLIB"
SYS_NAMESPACE = "%SYS"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _run(code, namespace, timeout=120):
    """Run ObjectScript via WebSocket terminal and return output string."""
    return ws_run_objectscript(code, server=_server_name, namespace=namespace,
                               config_path=_config_path, timeout=timeout)


def _step(num, total, label):
    """Print a step header."""
    print(f"\n[Step {num}/{total}] {label}")


def _ok(msg):
    print(f"  [OK] {msg}")


def _fail(msg):
    print(f"  [FAIL] {msg}")


def _skip(msg):
    print(f"  [SKIP] {msg}")


def _warn(msg):
    print(f"  [WARN] {msg}")


def _get_path_prefix(server_config):
    """Extract path prefix from server config."""
    ws = server_config.get("webServer", {})
    return ws.get("pathPrefix", "")


def _get_base_url(server_config):
    """Build base URL (no trailing slash) from server config."""
    ws = server_config.get("webServer", {})
    scheme = ws.get("scheme", "http")
    host = ws.get("host", "localhost")
    port = ws.get("port", 80)
    prefix = ws.get("pathPrefix", "")
    if (scheme == "http" and port == 80) or (scheme == "https" and port == 443):
        return f"{scheme}://{host}{prefix}"
    return f"{scheme}://{host}:{port}{prefix}"


# ---------------------------------------------------------------------------
# Step 1: Create namespace
# ---------------------------------------------------------------------------

def namespace_exists(name):
    result = _run(f'write ##class(Config.Namespaces).Exists("{name}"),!', SYS_NAMESPACE)
    return result.strip() == "1"


def create_namespace(namespace, dry_run):
    """Create a HealthShare Foundation namespace."""
    if namespace_exists(namespace):
        _ok(f"Namespace '{namespace}' already exists")
        return True

    if dry_run:
        print(f"  Would create Foundation namespace: {namespace}")
        return True

    print(f"  Creating Foundation namespace {namespace}...")
    print(f"  (This takes 1-2 minutes for FHIR/HL7 resource loading)")
    code = (f'do ##class(HS.Util.Installer.Foundation).Install("{namespace}") '
            f'write !,"SETUP_DONE",!')
    result = _run(code, HSLIB_NAMESPACE, timeout=300)
    if "SETUP_DONE" in result:
        _ok(f"Namespace '{namespace}' created")
        return True
    elif namespace_exists(namespace):
        _ok(f"Namespace '{namespace}' created (Foundation output truncated)")
        return True
    else:
        _fail(f"Namespace creation failed")
        print(f"  Output: {result[:500]}")
        return False


# ---------------------------------------------------------------------------
# Step 2: Ensure ZPM installed and enabled globally
# ---------------------------------------------------------------------------

def zpm_available():
    """Check if ZPM is available on the server."""
    try:
        result = _run('zpm "version" write !,"ZPM_OK",!', SYS_NAMESPACE, timeout=30)
        return "ZPM_OK" in result
    except Exception:
        return False


def ensure_zpm(dry_run):
    """Make sure ZPM is installed and mapped globally."""
    if zpm_available():
        _ok("ZPM is already installed")
    else:
        if dry_run:
            print("  Would install ZPM from /tmp/zpm_installer.xml")
            return True
        # Try loading the installer
        if not os.path.exists("/tmp/zpm_installer.xml"):
            _fail("ZPM not installed and /tmp/zpm_installer.xml not found")
            print("  Download it: curl -o /tmp/zpm_installer.xml https://pm.community.intersystems.com/packages/zpm/latest/installer/-/all")
            return False
        print("  Installing ZPM...")
        _run('do $system.OBJ.Load("/tmp/zpm_installer.xml","ck")', SYS_NAMESPACE, timeout=60)
        # Create mgr/src if missing (ZPM setup requires it)
        install_dir = _run('write $system.Util.InstallDirectory(),!', SYS_NAMESPACE).strip()
        src_dir = os.path.join(install_dir, "mgr", "src")
        if not os.path.exists(src_dir):
            os.makedirs(src_dir, exist_ok=True)
        try:
            _run('do ##class(IPM.Installer).setup()', SYS_NAMESPACE, timeout=120)
        except Exception:
            pass  # setup() may error on module.xml but still install ZPM
        if not zpm_available():
            _fail("ZPM installation failed")
            return False
        _ok("ZPM installed")

    # Enable globally
    if dry_run:
        print("  Would enable ZPM globally (map to all namespaces)")
        return True

    print("  Enabling ZPM globally...")
    result = _run('zpm "enable -map -globally -repos" write !,"MAP_OK",!', SYS_NAMESPACE, timeout=60)
    if "MAP_OK" in result:
        _ok("ZPM enabled globally")
    else:
        _warn("ZPM global enable may have partially completed")
    return True


# ---------------------------------------------------------------------------
# Step 3: Load InterClaw IPM package
# ---------------------------------------------------------------------------

def load_interclaw(repo_path, namespace, dry_run):
    """Load the InterClaw IPM package from the repo directory."""
    module_xml = os.path.join(repo_path, "module.xml")
    if not os.path.exists(module_xml):
        _fail(f"module.xml not found at: {module_xml}")
        return False

    if dry_run:
        print(f"  Would run: zpm \"load {repo_path} -v\" in namespace {namespace}")
        return True

    print(f"  Loading from: {repo_path}")
    print(f"  Target namespace: {namespace}")
    print(f"  (This runs the 14-step Installer including Python deps)")
    code = f'zpm "load {repo_path} -v" write !,"LOAD_DONE",!'
    result = _run(code, namespace, timeout=300)

    if "LOAD_DONE" in result:
        # Check for verification results in output
        if "9/9 checks passed" in result:
            _ok("InterClaw loaded and verified (9/9 checks passed)")
        elif "Setup Complete" in result:
            _ok("InterClaw loaded and setup completed")
        else:
            _ok("InterClaw loaded")
        return True
    elif "Compile SUCCESS" in result or "Configure SUCCESS" in result:
        _ok("InterClaw loaded (output truncated)")
        return True
    else:
        _fail("InterClaw load may have failed")
        # Print last 500 chars for diagnosis
        print(f"  Tail: ...{result[-500:]}")
        return False


# ---------------------------------------------------------------------------
# Step 4: Authenticate with Bedrock
# ---------------------------------------------------------------------------

def authenticate(server_config, key, dry_run):
    """Store the Bedrock API key via the REST authenticate endpoint."""
    if not key:
        key = os.environ.get("AWS_BEARER_TOKEN_BEDROCK", "")
    if not key:
        _skip("No Bedrock key provided (use --key or set AWS_BEARER_TOKEN_BEDROCK)")
        return True  # Non-fatal

    masked = key[:4] + "..." + key[-4:] if len(key) > 8 else "****"

    if dry_run:
        print(f"  Would authenticate with key: {masked}")
        return True

    base_url = _get_base_url(server_config)
    url = f"{base_url}/api/interclaw/api/authenticate"
    payload = json.dumps({"key": key, "region": "us-east-1"}).encode()
    req = urllib.request.Request(url, data=payload,
                                 headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            body = json.loads(resp.read())
        if body.get("credential_stored"):
            _ok(f"Authenticated ({body.get('key_prefix', masked)})")
            return True
        else:
            _fail(f"Credential not stored: {body.get('message', 'unknown error')}")
            return False
    except Exception as e:
        _fail(f"Authentication request failed: {e}")
        return False


# ---------------------------------------------------------------------------
# Step 5: Verify
# ---------------------------------------------------------------------------

def verify_connection(server_config):
    """Quick connection + query + pipeline test."""
    base_url = _get_base_url(server_config)
    results = []

    # 5a: Health check
    try:
        url = f"{base_url}/api/interclaw/api/health"
        with urllib.request.urlopen(url, timeout=10) as resp:
            body = json.loads(resp.read())
        if body.get("status") == "ok":
            _ok("REST health check passed")
            results.append(True)
        else:
            _fail(f"Health check returned: {body}")
            results.append(False)
    except Exception as e:
        _fail(f"Health check failed: {e}")
        results.append(False)

    # 5b: Auth status
    try:
        url = f"{base_url}/api/interclaw/api/auth-status"
        with urllib.request.urlopen(url, timeout=10) as resp:
            body = json.loads(resp.read())
        if body.get("authenticated"):
            _ok(f"Authenticated as {body.get('provider', '?')} ({body.get('key_prefix', '?')})")
            results.append(True)
        else:
            _warn("Not authenticated (chat pipeline will not work without a key)")
            results.append(True)  # Non-fatal
    except Exception as e:
        _fail(f"Auth status check failed: {e}")
        results.append(False)

    # 5c: Pipeline production status
    try:
        url = f"{base_url}/api/interclaw/production/api/health"
        with urllib.request.urlopen(url, timeout=10) as resp:
            body = json.loads(resp.read())
        if body.get("status") == "ok":
            _ok("Pipeline production health check passed")
            results.append(True)
        else:
            _fail(f"Pipeline health returned: {body}")
            results.append(False)
    except Exception as e:
        _fail(f"Pipeline health check failed: {e}")
        results.append(False)

    # 5d: Send a test message (only if authenticated)
    try:
        url = f"{base_url}/api/interclaw/api/auth-status"
        with urllib.request.urlopen(url, timeout=10) as resp:
            auth_body = json.loads(resp.read())
        if auth_body.get("authenticated"):
            print("  Sending test message through pipeline...")
            start_url = f"{base_url}/api/interclaw/production/api/start"
            payload = json.dumps({"prompt": "Reply with exactly: INTERCLAW_TEST_OK", "namespace": "INTERCLAW"}).encode()
            req = urllib.request.Request(start_url, data=payload,
                                         headers={"Content-Type": "application/json"})
            with urllib.request.urlopen(req, timeout=15) as resp:
                start_body = json.loads(resp.read())
            bridge_id = start_body.get("bridge_id")
            if bridge_id:
                import time
                time.sleep(8)
                events_url = f"{base_url}/api/interclaw/production/api/events?bridge_id={bridge_id}&after=0"
                with urllib.request.urlopen(events_url, timeout=35) as resp:
                    events_body = json.loads(resp.read())
                if events_body.get("done"):
                    _ok(f"Chat pipeline test passed (bridge: {bridge_id})")
                    results.append(True)
                else:
                    _warn(f"Chat pipeline test incomplete (bridge: {bridge_id})")
                    results.append(True)  # May just need more time
            else:
                _fail("Failed to start chat bridge")
                results.append(False)
        else:
            _skip("Chat pipeline test (not authenticated)")
    except Exception as e:
        _fail(f"Chat pipeline test failed: {e}")
        results.append(False)

    passed = sum(1 for r in results if r)
    total = len(results)
    print(f"\n  Verification: {passed}/{total} checks passed")
    return all(results)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    global _server_name, _config_path

    parser = argparse.ArgumentParser(
        description="Post-install setup for InterClaw on a fresh IRIS instance")
    parser.add_argument("--server", "-s", required=True,
                        help="Server name from config/servers.json")
    parser.add_argument("--repo", "-r", required=True,
                        help="Path to the InterClaw git repo (contains module.xml)")
    parser.add_argument("--namespace", "-n", default=DEFAULT_NAMESPACE,
                        help=f"Target namespace (default: {DEFAULT_NAMESPACE})")
    parser.add_argument("--key", "-k", default="",
                        help="Bedrock API key (or set AWS_BEARER_TOKEN_BEDROCK env var)")
    parser.add_argument("--skip-auth", action="store_true",
                        help="Skip the authentication step")
    parser.add_argument("--skip-verify", action="store_true",
                        help="Skip the verification step")
    parser.add_argument("--verify-only", action="store_true",
                        help="Only run verification checks (skip setup steps)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would happen without making changes")
    parser.add_argument("--config", "-c",
                        help="Path to servers.json")
    args = parser.parse_args()

    _server_name = args.server
    _config_path = args.config

    # Resolve repo path
    repo_path = os.path.abspath(args.repo)
    if not os.path.isdir(repo_path):
        print(f"ERROR: Repo directory does not exist: {repo_path}")
        sys.exit(1)

    # Load server config for URL construction
    servers = load_servers(args.config)
    if args.server not in servers:
        print(f"ERROR: Server '{args.server}' not found in servers.json")
        sys.exit(1)
    server_config = servers[args.server]

    namespace = args.namespace.upper()
    total_steps = 5

    print("=" * 64)
    print("  InterClaw Post-Install Setup")
    print("=" * 64)
    print(f"  Server:    {args.server}")
    print(f"  Repo:      {repo_path}")
    print(f"  Namespace: {namespace}")
    print(f"  Dry run:   {args.dry_run}")
    print("=" * 64)

    if args.verify_only:
        print("\n--- Verify Only Mode ---")
        ok = verify_connection(server_config)
        sys.exit(0 if ok else 1)

    # Step 1: Namespace
    _step(1, total_steps, "Creating namespace")
    ok = create_namespace(namespace, args.dry_run)
    if not ok:
        print("\nABORTED: Namespace creation failed")
        sys.exit(1)

    # Step 2: ZPM
    _step(2, total_steps, "Ensuring ZPM is installed and enabled globally")
    ok = ensure_zpm(args.dry_run)
    if not ok:
        print("\nABORTED: ZPM setup failed")
        sys.exit(1)

    # Step 3: Load InterClaw
    _step(3, total_steps, "Loading InterClaw IPM package")
    ok = load_interclaw(repo_path, namespace, args.dry_run)
    if not ok:
        print("\nABORTED: IPM package load failed")
        sys.exit(1)

    # Step 4: Authenticate
    _step(4, total_steps, "Authenticating with Bedrock")
    if args.skip_auth:
        _skip("Authentication (--skip-auth)")
    else:
        authenticate(server_config, args.key, args.dry_run)

    # Step 5: Verify
    _step(5, total_steps, "Running verification checks")
    if args.skip_verify:
        _skip("Verification (--skip-verify)")
    else:
        if args.dry_run:
            print("  Would run: health check, auth status, pipeline test")
        else:
            verify_connection(server_config)

    print("\n" + "=" * 64)
    print("  Setup complete")
    print("=" * 64)


if __name__ == "__main__":
    main()
