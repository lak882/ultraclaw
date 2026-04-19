#!/usr/bin/env python3
"""Create a GitLab issue via the API."""
import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import argparse
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from gitlab_api import load_gitlab_config, validate_config, gitlab_request


def main():
    parser = argparse.ArgumentParser(description="Create a GitLab issue")
    parser.add_argument("--title", required=True, help="Issue title")
    parser.add_argument("--description", default="", help="Issue description (Markdown)")
    parser.add_argument("--labels", default="", help="Comma-separated labels")
    parser.add_argument("--confidential", action="store_true", help="Make issue confidential")
    parser.add_argument("--assignee", default="", help="Assignee username")
    args = parser.parse_args()

    gl = load_gitlab_config()
    try:
        validate_config(gl)
    except RuntimeError as e:
        print(json.dumps({"status": "error", "message": str(e)}))
        sys.exit(1)

    # Merge user labels with defaults
    labels = [l.strip() for l in args.labels.split(",") if l.strip()] if args.labels else []
    for dl in gl.get("defaultLabels", []):
        if dl not in labels:
            labels.append(dl)

    issue_data = {
        "title": args.title,
        "description": args.description or "",
        "labels": ",".join(labels),
    }
    if args.confidential:
        issue_data["confidential"] = True

    try:
        result = gitlab_request(
            "POST",
            f"projects/{gl['projectId']}/issues",
            gl["token"], gl["url"],
            data=issue_data,
        )
        print(json.dumps({
            "status": "ok",
            "issue_url": result.get("web_url", ""),
            "issue_id": result.get("iid"),
            "title": result.get("title", ""),
            "labels": result.get("labels", []),
        }))
    except RuntimeError as e:
        print(json.dumps({"status": "error", "message": str(e)}))
        sys.exit(1)


if __name__ == "__main__":
    main()
