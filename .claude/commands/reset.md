---
allowed-tools: Bash, Read
description: Reset a production package — dry-run first, then confirm before deleting.
---

Reset a production package — dry-run first, then confirm before deleting. Use `/reset-force` to skip confirmation.

Usage: /reset <package-name> [--keep-local]

**Do NOT pull or inspect classes.** Just identify what to delete and delete it.

## Argument parsing

Parse "$ARGUMENTS":
- First word = package name
- `--keep-local` = keep local src/ files

## Execution

### Step 1: Check permission mode

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/infrastructure/permissions.py --check reset
```

Exit 0 → skip confirmation. Exit 2 → require confirmation below.

### Step 2: Dry-run (includes auto-lookup detection)

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/infrastructure/reset_package.py --server <server> --namespace <ns> --package <package> --auto-lookup --dry-run [--keep-local]
```

Display the dry-run output. **Stop and ask the user to confirm** (unless permissions.py said exit 0).

### Step 3: Execute reset

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/infrastructure/reset_package.py --server <server> --namespace <ns> --package <package> --auto-lookup [--keep-local]
```

### Step 4: Report

Display script output verbatim. Output `/reload` on its own line as the last line.
