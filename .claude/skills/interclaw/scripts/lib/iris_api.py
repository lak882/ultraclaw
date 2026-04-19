#!/usr/bin/env python3
"""Core library for InterSystems IRIS Atelier REST API interactions.

Provides shared HTTP/auth logic, URL construction, and response parsing
used by all Atelier API scripts.
"""

import argparse
import base64
import getpass
import json
import os
import sys
import time
import urllib.request
import urllib.error
import urllib.parse


class AtelierError(Exception):
    """Error returned by the Atelier API."""

    def __init__(self, message, status_code=None, errors=None):
        super().__init__(message)
        self.status_code = status_code
        self.errors = errors or []


# ---------------------------------------------------------------------------
# Session cookie cache (per-process, avoids re-auth on every request)
# ---------------------------------------------------------------------------
# Key: "host:port" → dict of cookie name → value
_cookie_cache = {}

# ---------------------------------------------------------------------------
# Audit context (set by get_server_and_creds, used by make_request)
# ---------------------------------------------------------------------------
_audit_context = {}   # {"server": "myserver", "namespace": "HSLIB"}
_in_audit = False     # Prevent recursive audit logging


def set_audit_context(server, namespace):
    """Enable automatic API call auditing for this process.

    Called automatically by get_server_and_creds(). After this, every
    make_request() call is logged to the audit trail.
    """
    global _audit_context
    _audit_context = {"server": server, "namespace": namespace}


def load_servers(config_path=None):
    """Load server configs from config/servers.json.

    Walks up from the script directory to find the project root.
    Returns the dict under "intersystems.servers".
    """
    if config_path is None:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
        config_path = os.path.join(project_root, "config", "servers.json")

    with open(config_path) as f:
        data = json.load(f)
    return data.get("intersystems.servers", {})


def build_base_url(server_config):
    """Build the Atelier API base URL from server config.

    Returns URL like: http://host:port/prefix/api/atelier
    """
    ws = server_config["webServer"]
    scheme = ws.get("scheme", "http")
    host = ws["host"]
    port = ws.get("port", 80)
    prefix = ws.get("pathPrefix", "")
    return f"{scheme}://{host}:{port}{prefix}/api/atelier"


def build_interop_url(server_config, namespace, version="v3"):
    """Build the InteropEditors API base URL.

    Returns URL like: http://host:port/prefix/api/interop-editors/{version}/{namespace}
    """
    ws = server_config["webServer"]
    scheme = ws.get("scheme", "http")
    host = ws["host"]
    port = ws.get("port", 80)
    prefix = ws.get("pathPrefix", "")
    return f"{scheme}://{host}:{port}{prefix}/api/interop-editors/{version}/{namespace}"


def make_interop_request(url, username, password, method="GET", query_params=None, timeout=30):
    """Make a request to the InteropEditors API.

    Unlike the Atelier API which uses JSON bodies, the InteropEditors API
    uses query parameters for POST data.

    Args:
        url: Base URL (without query string).
        username: Basic auth username.
        password: Basic auth password.
        method: HTTP method.
        query_params: Dict of query parameters to append.
        timeout: Request timeout in seconds.

    Returns:
        Tuple of (status_code, body_dict).
    """
    start = time.time()

    if query_params:
        qs = urllib.parse.urlencode(query_params)
        url = f"{url}?{qs}"

    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
    body_bytes = b"" if method == "POST" else None

    req = urllib.request.Request(url, data=body_bytes, method=method)
    req.add_header("Authorization", f"Basic {credentials}")
    req.add_header("Accept", "application/json")

    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            resp_body = json.loads(resp.read().decode())
            _audit_interop_request(url, method, resp.status, start, response_body=resp_body)
            return resp.status, resp_body
    except urllib.error.HTTPError as e:
        try:
            error_body = json.loads(e.read().decode())
            _audit_interop_request(url, method, e.code, start, response_body=error_body)
            return e.code, error_body
        except (json.JSONDecodeError, AttributeError):
            _audit_interop_request(url, method, e.code, start)
            return e.code, str(e)
    except urllib.error.URLError as e:
        _audit_interop_request(url, method, 0, start)
        return None, str(e.reason)


def resolve_username(server_config, cli_username=None):
    """Resolve username with priority: CLI arg > env var > config.

    Args:
        server_config: Server config dict from servers.json.
        cli_username: Username passed via CLI argument (highest priority).

    Returns:
        The resolved username string.
    """
    if cli_username:
        return cli_username
    env_username = os.environ.get("IRIS_USERNAME")
    if env_username:
        return env_username
    return server_config.get("username", "superuser")


def resolve_password(server_name, server_config, cli_password=None):
    """Resolve password with priority: CLI arg > env var > config > interactive prompt.

    Args:
        server_name: Server name (for prompt display).
        server_config: Server config dict from servers.json.
        cli_password: Password passed via CLI argument (highest priority).

    Returns:
        The resolved password string.
    """
    if cli_password:
        return cli_password
    env_password = os.environ.get("IRIS_PASSWORD")
    if env_password:
        return env_password
    config_password = server_config.get("password")
    if config_password:
        return config_password
    username = server_config.get("username", "superuser")
    return getpass.getpass(f"Password for {username}@{server_name}: ")


def _extract_host_key(url):
    """Extract 'host:port' from a URL for cookie cache keying."""
    parsed = urllib.parse.urlparse(url)
    return f"{parsed.hostname}:{parsed.port or (443 if parsed.scheme == 'https' else 80)}"


def _parse_set_cookies(resp):
    """Extract cookie name=value pairs from Set-Cookie response headers."""
    cookies = {}
    for header, value in resp.getheaders():
        if header.lower() == "set-cookie":
            # Take just the name=value part (before first ;)
            cookie_part = value.split(";")[0].strip()
            if "=" in cookie_part:
                name, val = cookie_part.split("=", 1)
                cookies[name.strip()] = val.strip()
    return cookies


def _build_cookie_header(host_key):
    """Build a Cookie header string from cached cookies for this host."""
    cookies = _cookie_cache.get(host_key, {})
    if not cookies:
        return None
    return "; ".join(f"{k}={v}" for k, v in cookies.items())


def _update_cookies(host_key, new_cookies):
    """Merge new cookies into the cache for this host (by name, not append)."""
    if host_key not in _cookie_cache:
        _cookie_cache[host_key] = {}
    _cookie_cache[host_key].update(new_cookies)


def _do_request(url, method, body_bytes, headers, timeout):
    """Execute a single HTTP request. Returns (status, body_dict, response)."""
    req = urllib.request.Request(url, data=body_bytes, method=method)
    for k, v in headers.items():
        req.add_header(k, v)

    try:
        resp = urllib.request.urlopen(req, timeout=timeout)
        resp_body = json.loads(resp.read().decode())
        return resp.status, resp_body, resp
    except urllib.error.HTTPError as e:
        try:
            error_body = json.loads(e.read().decode())
            return e.code, error_body, e
        except (json.JSONDecodeError, AttributeError):
            return e.code, str(e), e
    except urllib.error.URLError as e:
        return None, str(e.reason), None


def make_request(url, username, password, method="GET", data=None, timeout=30):
    """Make an authenticated request to the Atelier API.

    Uses cookie-first auth: if we have cached session cookies for this host,
    try them first. On 401, fall back to Basic Auth and cache the new cookies.
    Pattern from intersystems-community/intersystems-servermanager.

    Automatically logs to the audit trail if audit context is set
    (via set_audit_context or get_server_and_creds).

    Args:
        url: Full URL to request.
        username: Basic auth username.
        password: Basic auth password.
        method: HTTP method (GET, PUT, POST, DELETE).
        data: Dict to send as JSON body (for PUT/POST).
        timeout: Request timeout in seconds (default: 30).

    Returns:
        Tuple of (status_code, body). status_code is None on connection error.
        body is a parsed dict on success, or an error string on failure.
    """
    global _in_audit
    start = time.time()

    host_key = _extract_host_key(url)
    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()

    body_bytes = None
    if data is not None:
        body_bytes = json.dumps(data).encode("utf-8")

    headers = {"Accept": "application/json"}
    if body_bytes is not None:
        headers["Content-Type"] = "application/json"

    # 1. Try with cached cookies first (skip Basic Auth overhead)
    cookie_header = _build_cookie_header(host_key)
    if cookie_header:
        headers["Cookie"] = cookie_header
        status, body, resp = _do_request(url, method, body_bytes, headers, timeout)

        if status is not None and status != 401:
            # Cache any new cookies from this response
            if resp and hasattr(resp, "getheaders"):
                _update_cookies(host_key, _parse_set_cookies(resp))
            _audit_request(url, method, status, start, request_data=data, response_body=body)
            return status, body

        # 401 — cookies expired, fall through to Basic Auth
        headers.pop("Cookie", None)

    # 2. Authenticate with Basic Auth
    headers["Authorization"] = f"Basic {credentials}"
    if cookie_header:
        headers["Cookie"] = cookie_header

    status, body, resp = _do_request(url, method, body_bytes, headers, timeout)

    # Cache cookies from successful auth
    if resp and hasattr(resp, "getheaders") and status is not None and status < 400:
        _update_cookies(host_key, _parse_set_cookies(resp))

    _audit_request(url, method, status, start, request_data=data, response_body=body)
    return status, body


def _audit_request(url, method, status, start_time, request_data=None, response_body=None):
    """Log an API call to the audit trail (best-effort, no recursion)."""
    global _in_audit
    if not _audit_context or _in_audit:
        return
    _in_audit = True
    try:
        from audit import log_event
        duration_ms = round((time.time() - start_time) * 1000, 1)
        kwargs = dict(
            server=_audit_context.get("server", ""),
            namespace=_audit_context.get("namespace", ""),
            url=url, method=method,
            status=status if status is not None else 0,
            duration_ms=duration_ms,
        )
        if request_data is not None:
            kwargs["request_body"] = json.dumps(request_data) if not isinstance(request_data, str) else request_data
        if response_body is not None:
            kwargs["response_body"] = json.dumps(response_body) if not isinstance(response_body, str) else response_body
        log_event("api_call", **kwargs)
    except Exception:
        pass
    finally:
        _in_audit = False


def _audit_interop_request(url, method, status, start_time, response_body=None):
    """Log an InteropEditors API call to the audit trail (best-effort, no recursion)."""
    global _in_audit
    if not _audit_context or _in_audit:
        return
    _in_audit = True
    try:
        from audit import log_event
        duration_ms = round((time.time() - start_time) * 1000, 1)
        kwargs = dict(
            server=_audit_context.get("server", ""),
            namespace=_audit_context.get("namespace", ""),
            url=url, method=method,
            status=status if status is not None else 0,
            duration_ms=duration_ms,
        )
        if response_body is not None:
            kwargs["response_body"] = json.dumps(response_body) if not isinstance(response_body, str) else response_body
        log_event("interop_api", **kwargs)
    except Exception:
        pass
    finally:
        _in_audit = False


def session_logout(server_config, username, password):
    """Send a logout request to end the server session.

    Calls HEAD /api/atelier/?CacheLogout=end to clean up the session.
    Pattern from intersystems-community/intersystems-servermanager.
    """
    base_url = build_base_url(server_config)
    url = f"{base_url}/?CacheLogout=end"
    host_key = _extract_host_key(url)

    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
    headers = {"Authorization": f"Basic {credentials}"}
    cookie_header = _build_cookie_header(host_key)
    if cookie_header:
        headers["Cookie"] = cookie_header

    try:
        _do_request(url, "HEAD", None, headers, timeout=5)
    except Exception:
        pass

    # Clear cached cookies for this host
    _cookie_cache.pop(host_key, None)


def parse_atelier_response(body):
    """Extract content from the standard Atelier API response envelope.

    The Atelier API wraps responses in:
        {"result": {"content": <data>}, "status": {"errors": [...]}}

    Args:
        body: Parsed JSON response dict.

    Returns:
        The content from result.content.

    Raises:
        AtelierError: If the response contains errors.
    """
    if not isinstance(body, dict):
        return body

    status = body.get("status", {})
    errors = status.get("errors", [])
    if errors:
        error_msgs = [e.get("error", str(e)) if isinstance(e, dict) else str(e) for e in errors]
        raise AtelierError(
            f"Atelier API error: {'; '.join(error_msgs)}",
            errors=errors
        )

    result = body.get("result", {})
    return result.get("content", result)


def get_local_config(config_path=None):
    """Build a localhost server config from the default entry in servers.json.

    Reads the "default" field from servers.json, takes that server's config,
    and overrides the host to localhost. This allows scripts to run without
    an explicit --server flag while preserving pathPrefix and credentials.

    Returns:
        Tuple of (server_config, server_name).
    """
    try:
        servers_data = load_servers(config_path)
    except Exception:
        # No servers.json at all: use bare defaults
        return {
            "webServer": {"scheme": "http", "host": "localhost", "port": 80, "pathPrefix": ""},
            "username": "superuser",
            "password": "SYS",
        }, "localhost"

    # Find the default server name from the raw JSON (load_servers strips it)
    if config_path is None:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
        config_path = os.path.join(project_root, "config", "servers.json")
    try:
        with open(config_path) as f:
            raw = json.load(f)
        default_name = raw.get("default", "")
    except Exception:
        default_name = ""

    if default_name and default_name in servers_data:
        server_config = servers_data[default_name]
    elif servers_data:
        default_name = next(iter(servers_data))
        server_config = servers_data[default_name]
    else:
        return {
            "webServer": {"scheme": "http", "host": "localhost", "port": 80, "pathPrefix": ""},
            "username": "superuser",
            "password": "SYS",
        }, "localhost"

    # Override host to localhost for local connections
    import copy
    server_config = copy.deepcopy(server_config)
    server_config["webServer"]["host"] = "localhost"

    return server_config, default_name


def get_server_and_creds(args):
    """Convenience function to resolve server config and credentials from CLI args.

    Args:
        args: argparse namespace with .server, .password (optional), .config (optional).

    Returns:
        Tuple of (server_config, base_url, username, password).

    Raises:
        SystemExit: If the server is not found in config.
    """
    server_name = getattr(args, "server", None)

    if server_name is None:
        # No --server specified: use localhost via IRIS globals
        server_config, server_name = get_local_config()
    else:
        # Explicit --server: resolve from servers.json (backward compat)
        servers = load_servers(getattr(args, "config", None))
        if server_name not in servers:
            print(f"ERROR: Server '{server_name}' not found in config/servers.json")
            print(f"Available servers: {', '.join(servers.keys())}")
            sys.exit(1)
        server_config = servers[server_name]

    base_url = build_base_url(server_config)
    username = resolve_username(server_config, getattr(args, "username", None))
    password = resolve_password(server_name, server_config, getattr(args, "password", None))

    # Auto-enable API audit logging for this process
    set_audit_context(server_name, getattr(args, "namespace", "") or "")

    return server_config, base_url, username, password


def common_arg_parser(description):
    """Create an ArgumentParser pre-loaded with standard Atelier API arguments.

    Includes: --server, --namespace, --password, --config

    Args:
        description: Parser description string.

    Returns:
        An ArgumentParser instance. Callers add script-specific args on top.
    """
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("--server", "-s", default=None,
                        help="Server name from config/servers.json (default: localhost)")
    parser.add_argument("--namespace", "-n",
                        help="IRIS namespace to work in")
    parser.add_argument("--username", "-u",
                        help="Username (overrides config and IRIS_USERNAME env var)")
    parser.add_argument("--password", "-p",
                        help="Password (overrides config and IRIS_PASSWORD env var)")
    parser.add_argument("--config", "-c",
                        help="Path to servers.json (default: config/servers.json)")
    return parser
