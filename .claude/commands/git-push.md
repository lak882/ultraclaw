---
allowed-tools: Bash, Read
description: Push local files to a GitLab branch.
---

Push local files to a GitLab branch via the GitLab Commits API.

Usage: /git-push <files or directories> [--branch name] [--message "commit message"]

## Argument parsing

Parse "$ARGUMENTS":
- File/directory paths (relative to project root)
- `--branch <name>` — target branch (auto-generated if omitted)
- `--message "msg"` — commit message
- `--dry-run` — preview without pushing

If no paths specified and user says "push my skills" or similar, default to `.claude/commands/` and `.claude/skills/`.

## Execution

### Step 1: Check GitLab config

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/git/git_token.py --show
```

If not configured, tell the user to run `/git-token` first. Stop.

### Step 2: Dry-run

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/git/git_push.py --dry-run <paths> [--branch <name>]
```

Display output (branch name, file list). **Ask for confirmation** before pushing.

### Step 3: Push

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/git/git_push.py <paths> [--branch <name>] [--message "msg"]
```

### Step 4: Report

Display script output verbatim (branch name, commit URL, file count, whether branch was newly created).
