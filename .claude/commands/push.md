---
allowed-tools: Bash, Read
description: Push a local class file to the IRIS server and compile it.
---

Push a local class file to the IRIS server and compile it.

Usage: /push <classname or filepath>

## Argument parsing

Parse "$ARGUMENTS":
- If it contains `/` or `\` → treat as file path. Read the file, derive class name from `Class <name>` in content.
- Otherwise → treat as class name. Find at `src/<Namespace>/<Package>/<ClassName>.cls`.

Ensure the document name ends with .cls (or appropriate extension).

## Execution

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/documents/put_doc.py --server <server> --namespace <namespace> --doc <name>.cls --input <filepath> --compile
```

## Output

Report success or show compilation errors and offer to fix.

## Auto-test after push

- **DTL classes** (name contains `.DTL.`): run `test_dtl.py --dtl <class> --generate <MSG_TYPE> --diff`
- **Production classes** (name ends `.Production`): start with `manage_production.py --start <name> --stop-first`, send test message if HTTP service exists, check trace.
