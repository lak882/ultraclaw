---
allowed-tools: Bash, Read
description: Force-reset a production package — no dry run, no confirmation.
---

Force-reset a production package — no dry run, no confirmation. Immediately delete all classes, clear lookup tables, purge package messages, remove local files.

Usage: /reset-force <package-name> [--keep-local]

**Do NOT pull or inspect classes.** Just delete them.

## Argument parsing

Parse "$ARGUMENTS":
- First word = package name
- `--keep-local` = keep local src/ files

## Execution

### Step 1: Stop the production (avoids Suspended state)

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/production/manage_production.py --server <server> --namespace <ns> --stop
```

### Step 2: Execute reset immediately (with auto-lookup)

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/infrastructure/reset_package.py --server <server> --namespace <ns> --package <package> --auto-lookup [--keep-local]
```

### Step 3: Delete local files (unless --keep-local)

```bash
rm -rf src/<Namespace>/<Package>/
```

### Step 4: Report

Display script output verbatim. Output `/reload` on its own line as the last line.
