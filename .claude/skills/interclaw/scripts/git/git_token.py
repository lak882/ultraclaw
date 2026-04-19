#!/usr/bin/env python3
"""Configure GitLab token and project settings for /git-issue and /git-push."""
import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import argparse
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from gitlab_api import load_gitlab_config, save_gitlab_config, gitlab_request, mask_token


def main():
    parser = argparse.ArgumentParser(description="Configure GitLab integration")
    parser.add_argument("--token", help="GitLab Personal or Project Access Token")
    parser.add_argument("--url", help="GitLab instance URL (e.g., https://gitlab.example.com)")
    parser.add_argument("--project-id", help="GitLab project ID (numeric or URL-encoded path)")
    parser.add_argument("--branch-prefix", help="Branch prefix for /git-push (default: skills/)")
    parser.add_argument("--show", action="store_true", help="Show current config (token masked)")
    parser.add_argument("--test", action="store_true", help="Test the connection")
    parser.add_argument("--clear", action="store_true", help="Remove stored token")
    args = parser.parse_args()

    gl = load_gitlab_config()

    if args.show:
        if not gl.get("token"):
            print(json.dumps({"configured": False, "message": "No GitLab token configured. Run /git-token to set up."}))
        else:
            print(json.dumps({
                "configured": True,
                "url": gl.get("url", ""),
                "projectId": gl.get("projectId", ""),
                "token": mask_token(gl.get("token", "")),
                "branchPrefix": gl.get("branchPrefix", "skills/"),
                "defaultLabels": gl.get("defaultLabels", []),
            }))
        return

    if args.clear:
        gl["token"] = ""
        save_gitlab_config(gl)
        print(json.dumps({"status": "ok", "message": "GitLab token cleared."}))
        return

    if args.test:
        if not gl.get("token") or not gl.get("url") or not gl.get("projectId"):
            print(json.dumps({"status": "error", "message": "Not fully configured. Run /git-token with --token, --url, and --project-id first."}))
            sys.exit(1)
        try:
            project = gitlab_request("GET", f"projects/{gl['projectId']}", gl["token"], gl["url"])
            print(json.dumps({
                "status": "ok",
                "project": project.get("path_with_namespace", ""),
                "default_branch": project.get("default_branch", ""),
                "web_url": project.get("web_url", ""),
                "visibility": project.get("visibility", ""),
            }))
        except RuntimeError as e:
            print(json.dumps({"status": "error", "message": str(e)}))
            sys.exit(1)
        return

    # Update config fields
    updated = False
    if args.token:
        gl["token"] = args.token
        updated = True
    if args.url:
        gl["url"] = args.url.rstrip("/")
        updated = True
    if args.project_id:
        gl["projectId"] = args.project_id
        updated = True
    if args.branch_prefix:
        gl["branchPrefix"] = args.branch_prefix
        updated = True

    if not updated:
        print(json.dumps({"status": "error", "message": "No arguments provided. Use --token, --url, --project-id, or --show."}))
        sys.exit(1)

    # Set defaults for new config
    gl.setdefault("branchPrefix", "skills/")
    gl.setdefault("defaultLabels", ["interclaw"])

    save_gitlab_config(gl)

    result = {
        "status": "ok",
        "url": gl.get("url", ""),
        "projectId": gl.get("projectId", ""),
        "token": mask_token(gl.get("token", "")),
        "branchPrefix": gl.get("branchPrefix", "skills/"),
    }

    # Auto-test if all required fields are present
    if gl.get("token") and gl.get("url") and gl.get("projectId"):
        try:
            project = gitlab_request("GET", f"projects/{gl['projectId']}", gl["token"], gl["url"])
            result["test"] = {
                "status": "ok",
                "project": project.get("path_with_namespace", ""),
                "web_url": project.get("web_url", ""),
            }
        except RuntimeError as e:
            result["test"] = {"status": "error", "message": str(e)}

    print(json.dumps(result))


if __name__ == "__main__":
    main()
