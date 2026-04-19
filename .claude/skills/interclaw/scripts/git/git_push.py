#!/usr/bin/env python3
"""Push local files to a GitLab branch via the Commits API."""
import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import argparse
import json
import os
import sys
from urllib.parse import quote as url_quote

sys.path.insert(0, os.path.dirname(__file__))
from gitlab_api import (
    find_project_root, load_gitlab_config, validate_config, gitlab_request,
)


def collect_files(paths, cwd):
    """Collect files from paths (files or directories). Returns list of {path, content}."""
    files = []
    for p in paths:
        abs_path = os.path.join(cwd, p) if not os.path.isabs(p) else p
        if os.path.isdir(abs_path):
            for root, dirs, filenames in os.walk(abs_path):
                dirs[:] = [d for d in dirs if not d.startswith(".")]
                for fname in filenames:
                    if fname.startswith("."):
                        continue
                    full = os.path.join(root, fname)
                    rel = os.path.relpath(full, cwd)
                    with open(full, "r", errors="replace") as f:
                        content = f.read()
                    files.append({"path": rel, "content": content})
        elif os.path.isfile(abs_path):
            rel = os.path.relpath(abs_path, cwd)
            with open(abs_path, "r", errors="replace") as f:
                content = f.read()
            files.append({"path": rel, "content": content})
        else:
            print(json.dumps({"status": "error", "message": f"Path not found: {p}"}))
            sys.exit(1)
    return files


def branch_exists(gl, branch_name):
    """Check if a branch exists on GitLab."""
    try:
        gitlab_request(
            "GET",
            f"projects/{gl['projectId']}/repository/branches/{url_quote(branch_name, safe='')}",
            gl["token"], gl["url"],
        )
        return True
    except RuntimeError:
        return False


def create_branch(gl, branch_name, ref="main"):
    """Create a new branch from ref."""
    return gitlab_request(
        "POST",
        f"projects/{gl['projectId']}/repository/branches",
        gl["token"], gl["url"],
        data={"branch": branch_name, "ref": ref},
    )


def file_exists_on_remote(gl, branch_name, file_path):
    """Check if a file already exists on the remote branch."""
    try:
        gitlab_request(
            "GET",
            f"projects/{gl['projectId']}/repository/files/{url_quote(file_path, safe='')}"
            f"?ref={url_quote(branch_name, safe='')}",
            gl["token"], gl["url"],
        )
        return True
    except RuntimeError:
        return False


def main():
    parser = argparse.ArgumentParser(description="Push files to a GitLab branch")
    parser.add_argument("paths", nargs="+", help="Files or directories to push")
    parser.add_argument("--branch", help="Branch name (auto-prefixed if no / in name)")
    parser.add_argument("--message", "-m", default="", help="Commit message")
    parser.add_argument("--ref", default="main", help="Base branch for new branches (default: main)")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be pushed")
    args = parser.parse_args()

    gl = load_gitlab_config()
    try:
        validate_config(gl)
    except RuntimeError as e:
        print(json.dumps({"status": "error", "message": str(e)}))
        sys.exit(1)

    cwd = find_project_root()
    files = collect_files(args.paths, cwd)
    if not files:
        print(json.dumps({"status": "error", "message": "No files found to push"}))
        sys.exit(1)

    # Determine branch name
    prefix = gl.get("branchPrefix", "skills/")
    if args.branch:
        branch_name = args.branch if "/" in args.branch else f"{prefix}{args.branch}"
    else:
        slug = args.paths[0].replace("/", "-").replace("\\", "-").replace(".", "-").strip("-")
        branch_name = f"{prefix}{slug}"

    if args.dry_run:
        print(json.dumps({
            "status": "dry-run",
            "branch": branch_name,
            "files": [f["path"] for f in files],
            "file_count": len(files),
        }))
        return

    # Create branch if needed
    is_new_branch = not branch_exists(gl, branch_name)
    if is_new_branch:
        try:
            create_branch(gl, branch_name, args.ref)
        except RuntimeError as e:
            print(json.dumps({"status": "error", "message": f"Failed to create branch: {e}"}))
            sys.exit(1)

    # Build commit actions — check each file to decide create vs update
    actions = []
    for f in files:
        exists = file_exists_on_remote(gl, branch_name, f["path"])
        actions.append({
            "action": "update" if exists else "create",
            "file_path": f["path"],
            "content": f["content"],
        })

    # Commit message
    file_names = ", ".join(f["path"].split("/")[-1] for f in files[:5])
    if len(files) > 5:
        file_names += f" (+{len(files) - 5} more)"
    commit_message = args.message or f"Update {file_names}"

    try:
        result = gitlab_request(
            "POST",
            f"projects/{gl['projectId']}/repository/commits",
            gl["token"], gl["url"],
            data={
                "branch": branch_name,
                "commit_message": commit_message,
                "actions": actions,
            },
        )

        print(json.dumps({
            "status": "ok",
            "branch": branch_name,
            "new_branch": is_new_branch,
            "commit_id": result.get("id", "")[:12],
            "commit_url": result.get("web_url", ""),
            "files_pushed": len(files),
            "message": commit_message,
        }))
    except RuntimeError as e:
        print(json.dumps({"status": "error", "message": f"Commit failed: {e}"}))
        sys.exit(1)


if __name__ == "__main__":
    main()
