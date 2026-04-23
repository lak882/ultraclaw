"""GitLab API utilities — shared by git-token, git-issue, git-push scripts."""

import json
import os
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError


def find_project_root():
    """Walk up from this script to find the directory containing CLAUDE.md."""
    cwd = os.path.dirname(os.path.abspath(__file__))
    while cwd != "/" and not os.path.exists(os.path.join(cwd, "CLAUDE.md")):
        cwd = os.path.dirname(cwd)
    return cwd


def load_gitlab_config(cwd=None):
    """Load GitLab config from orchestrator.json -> gitlab key."""
    cwd = cwd or find_project_root()
    config_path = os.path.join(cwd, "config", "orchestrator.json")
    try:
        with open(config_path) as f:
            config = json.load(f)
        return config.get("gitlab", {})
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def save_gitlab_config(gl_config, cwd=None):
    """Save GitLab config back to orchestrator.json -> gitlab key."""
    cwd = cwd or find_project_root()
    config_path = os.path.join(cwd, "config", "orchestrator.json")
    with open(config_path) as f:
        config = json.load(f)
    config["gitlab"] = gl_config
    with open(config_path, "w") as f:
        json.dump(config, f, indent=4)
        f.write("\n")


def gitlab_request(method, path, token, gitlab_url, data=None, timeout=15):
    """Make a GitLab API v4 request. Returns parsed JSON response."""
    url = f"{gitlab_url.rstrip('/')}/api/v4/{path.lstrip('/')}"
    body = json.dumps(data).encode() if data else None
    req = Request(url, data=body, method=method)
    req.add_header("PRIVATE-TOKEN", token)
    if data:
        req.add_header("Content-Type", "application/json")
    try:
        with urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read().decode())
    except HTTPError as e:
        error_body = e.read().decode("utf-8", errors="replace")[:500]
        raise RuntimeError(f"GitLab API {e.code}: {error_body}")
    except (URLError, OSError) as e:
        raise RuntimeError(f"Could not reach GitLab: {e}")


def validate_config(gl_config):
    """Check that required GitLab config fields are present. Raises on missing."""
    missing = []
    if not gl_config.get("url"):
        missing.append("url")
    if not gl_config.get("projectId"):
        missing.append("projectId")
    if not gl_config.get("token"):
        missing.append("token")
    if missing:
        raise RuntimeError(
            f"GitLab not configured. Missing: {', '.join(missing)}. "
            f"Run /git-token to configure."
        )


def mask_token(token):
    """Mask a token for safe display: glpat-xx...xxxx."""
    if not token:
        return "(none)"
    if len(token) > 8:
        return token[:8] + "..." + token[-4:]
    return "****"
