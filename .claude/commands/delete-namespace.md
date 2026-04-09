---
allowed-tools: Bash, Read
description: Delete an IRIS namespace and its database configuration.
---

Delete an IRIS namespace and its database configuration. Physical database files are NOT deleted from disk.

Usage: /delete-namespace <name>

## Argument parsing

Parse "$ARGUMENTS": first word = namespace name. Uppercase it.

If the namespace matches the currently connected namespace, warn the user: "You are about to delete the active namespace. Are you sure?"

## Execution

### Step 1: Check permission mode

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/infrastructure/permissions.py --check delete
```

Exit 0 → skip confirmation. Exit 2 → require confirmation below.

### Step 2: Dry-run

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/infrastructure/manage_namespace.py --server <server> --delete <NAME> --dry-run
```

Display output. **Ask for confirmation**: "Proceed with deleting namespace <NAME>? This cannot be undone."

### Step 3: Execute delete

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/infrastructure/manage_namespace.py --server <server> --delete <NAME>
```

### Step 4: Report

Display script output. If the deleted namespace was the active one, remind user to `/connect` to a different namespace.
