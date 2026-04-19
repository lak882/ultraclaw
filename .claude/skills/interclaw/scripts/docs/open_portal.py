#!/usr/bin/env python3
"""Open an IRIS Management Portal page in Chrome via Playwright.

First call: launches Chrome with --remote-debugging-port and logs in.
Subsequent calls: connects to the already-running Chrome via CDP and opens a new tab.

Usage:
  open_portal.py --url <portal-url>
  open_portal.py --url <portal-url> --server vmdev1
  open_portal.py --url <portal-url> --wait 5000
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import argparse
import json
import os
import subprocess
import sys
import time
import urllib.request
import urllib.error

# Suppress Node.js deprecation warnings from Playwright's internal server
os.environ["NODE_OPTIONS"] = "--no-deprecation"

try:
    from playwright.sync_api import sync_playwright
except ImportError:
    print("ERROR: playwright is not installed.", file=sys.stderr)
    print("Install it with: pip install playwright && playwright install chromium", file=sys.stderr)
    sys.exit(1)


def load_playwright_config(config_path=None):
    """Load browser and auth config from config/playwright.json."""
    if config_path is None:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
        config_path = os.path.join(project_root, "config", "playwright.json")

    if not os.path.exists(config_path):
        print(f"ERROR: Playwright config not found at {config_path}", file=sys.stderr)
        print("Create config/playwright.json with browser.executablePath and auth credentials.", file=sys.stderr)
        sys.exit(1)

    with open(config_path) as f:
        return json.load(f)


def load_server_auth(server_name, config_path=None):
    """Load auth credentials from config/servers.json for a specific server."""
    if config_path is None:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
        config_path = os.path.join(project_root, "config", "servers.json")

    with open(config_path) as f:
        data = json.load(f)

    servers = data.get("intersystems.servers", {})
    if server_name not in servers:
        return None, None

    server = servers[server_name]
    return server.get("username", "superuser"), server.get("password", "")


def handle_login(page, username, password, target_url):
    """Detect and handle the IRIS CSP login page."""
    try:
        login_form = page.locator("input[name='IRISUsername']")
        if login_form.count() > 0 and login_form.is_visible(timeout=2000):
            print("Login page detected, authenticating...", file=sys.stderr)
            page.fill("input[name='IRISUsername']", username)
            page.fill("input[name='IRISPassword']", password)
            page.click("input[type='submit']")
            page.wait_for_load_state("networkidle", timeout=10000)
            return True
    except Exception:
        pass

    try:
        login_form = page.locator("input[name='CacheUsername']")
        if login_form.count() > 0 and login_form.is_visible(timeout=2000):
            print("Login page detected (legacy), authenticating...", file=sys.stderr)
            page.fill("input[name='CacheUsername']", username)
            page.fill("input[name='CachePassword']", password)
            page.click("input[type='submit']")
            page.wait_for_load_state("networkidle", timeout=10000)
            return True
    except Exception:
        pass

    return False


def get_user_data_dir():
    """Get a persistent user data directory for the Playwright Chrome profile."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
    data_dir = os.path.join(project_root, ".playwright-profile")
    os.makedirs(data_dir, exist_ok=True)
    return data_dir


def is_chrome_running(cdp_port):
    """Check if Chrome is already running with remote debugging on the given port."""
    try:
        req = urllib.request.Request(f"http://127.0.0.1:{cdp_port}/json/version")
        resp = urllib.request.urlopen(req, timeout=2)
        resp.read()
        return True
    except (urllib.error.URLError, OSError):
        return False


def open_in_existing_chrome(p, cdp_port, url, username, password, wait_ms):
    """Connect to an already-running Chrome via CDP and open a new tab."""
    browser = p.chromium.connect_over_cdp(f"http://127.0.0.1:{cdp_port}")
    context = browser.contexts[0] if browser.contexts else browser.new_context()
    page = context.new_page()
    print(f"Opening: {url}", file=sys.stderr)
    page.goto(url, wait_until="networkidle", timeout=30000)
    handle_login(page, username, password, url)
    if wait_ms > 0:
        time.sleep(wait_ms / 1000)
    title = page.title()
    print(f"OK: Page loaded — {title}", file=sys.stderr)
    # Disconnect without closing — browser stays open
    browser.close()


def launch_fresh_chrome(p, executable, cdp_port, user_data_dir, headless, url, username, password, wait_ms):
    """Launch a new Chrome instance with remote debugging and navigate to url."""
    # Launch Chrome with about:blank so only one tab opens
    chrome_args = [
        executable,
        f"--user-data-dir={user_data_dir}",
        f"--remote-debugging-port={cdp_port}",
        "--no-first-run",
        "--no-default-browser-check",
        "about:blank",
    ]
    subprocess.Popen(
        chrome_args,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    # Wait for Chrome to start and CDP to become available
    for _ in range(15):
        if is_chrome_running(cdp_port):
            break
        time.sleep(1)
    else:
        print("ERROR: Chrome did not start in time", file=sys.stderr)
        sys.exit(1)

    # Connect via CDP and navigate the existing tab to our URL
    time.sleep(1)  # give Chrome a moment to settle
    browser = p.chromium.connect_over_cdp(f"http://127.0.0.1:{cdp_port}")
    context = browser.contexts[0] if browser.contexts else browser.new_context()

    # Reuse the blank tab that Chrome opened
    page = context.pages[0] if context.pages else context.new_page()
    print(f"Opening: {url}", file=sys.stderr)
    page.goto(url, wait_until="networkidle", timeout=30000)
    handle_login(page, username, password, url)

    if wait_ms > 0:
        time.sleep(wait_ms / 1000)

    title = page.title()
    print(f"OK: Page loaded — {title}", file=sys.stderr)

    # Disconnect without closing the browser
    browser.close()
    print("Browser opened (detached).", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(description="Open an IRIS portal page in Chrome")
    parser.add_argument("--url", "-u", required=True,
                        help="Portal URL to open")
    parser.add_argument("--server", "-s",
                        help="Server name from servers.json (for auth credentials)")
    parser.add_argument("--wait", "-w", type=int, default=2000,
                        help="Extra wait time in ms after page load (default: 2000)")
    parser.add_argument("--config", "-c",
                        help="Path to playwright.json config")
    args = parser.parse_args()

    # Load config
    config = load_playwright_config(args.config)
    browser_config = config.get("browser", {})
    auth_config = config.get("auth", {})
    cdp_port = config.get("cdpPort", 9222)

    # Resolve auth credentials
    if args.server:
        username, password = load_server_auth(args.server)
        if username is None:
            print(f"WARNING: Server '{args.server}' not found in servers.json, using playwright.json auth",
                  file=sys.stderr)
            username = auth_config.get("username", "superuser")
            password = auth_config.get("password", "")
    else:
        username = auth_config.get("username", "superuser")
        password = auth_config.get("password", "")

    # Resolve relative URLs to full URLs using server config
    url = args.url

    # Fix MSYS/Git Bash path mangling on Windows (e.g., /irishealth/... → C:/Program Files/Git/irishealth/...)
    if not url.startswith("http") and sys.platform == "win32":
        # Look for known path prefixes from server config to recover the intended path
        script_dir_fix = os.path.dirname(os.path.abspath(__file__))
        project_root_fix = os.path.abspath(os.path.join(script_dir_fix, "..", "..", "..", ".."))
        servers_path_fix = os.path.join(project_root_fix, "config", "servers.json")
        if os.path.exists(servers_path_fix):
            with open(servers_path_fix) as f:
                sdata = json.load(f)
            for srv in sdata.get("intersystems.servers", {}).values():
                prefix = srv.get("webServer", {}).get("pathPrefix", "")
                if prefix:
                    # Strip leading slash for matching
                    prefix_bare = prefix.lstrip("/")
                    idx = url.find(prefix_bare)
                    if idx > 0:
                        url = "/" + url[idx:]
                        break

    if not url.startswith("http"):
        server_name = args.server
        # If no server specified, use the first one in servers.json
        if not server_name:
            script_dir = os.path.dirname(os.path.abspath(__file__))
            project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
            servers_path = os.path.join(project_root, "config", "servers.json")
            if os.path.exists(servers_path):
                with open(servers_path) as f:
                    servers_data = json.load(f)
                server_names = list(servers_data.get("intersystems.servers", {}).keys())
                if server_names:
                    server_name = server_names[0]

        if server_name:
            script_dir = os.path.dirname(os.path.abspath(__file__))
            project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
            servers_path = os.path.join(project_root, "config", "servers.json")
            with open(servers_path) as f:
                servers_data = json.load(f)
            server = servers_data.get("intersystems.servers", {}).get(server_name, {})
            web = server.get("webServer", {})
            scheme = web.get("scheme", "http")
            host = web.get("host", "localhost")
            port = web.get("port", 80)
            # Strip leading slash from url to avoid double slash
            path = url.lstrip("/")
            url = f"{scheme}://{host}:{port}/{path}"
        else:
            print("ERROR: Relative URL provided but no server available to resolve it.", file=sys.stderr)
            sys.exit(1)
    args.url = url

    executable = browser_config.get("executablePath")
    headless = browser_config.get("headless", False)

    if not executable:
        print("ERROR: browser.executablePath not set in playwright.json", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(executable):
        print(f"ERROR: Chrome not found at {executable}", file=sys.stderr)
        sys.exit(1)

    user_data_dir = get_user_data_dir()

    with sync_playwright() as p:
        if is_chrome_running(cdp_port):
            # Chrome is already running — just open a new tab
            open_in_existing_chrome(p, cdp_port, args.url, username, password, args.wait)
        else:
            # First launch — start Chrome with remote debugging
            launch_fresh_chrome(p, executable, cdp_port, user_data_dir, headless,
                                args.url, username, password, args.wait)


if __name__ == "__main__":
    main()
