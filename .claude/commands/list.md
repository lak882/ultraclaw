---
allowed-tools: Bash, Read
description: List documents (classes, routines, includes) in a namespace on an IRIS server.
---

List documents (classes, routines, includes) in a namespace on an IRIS server.

Usage: /list [type] [filter]

## Argument parsing

Parse "$ARGUMENTS": first word is type if it matches cls/mac/inc/csp, otherwise treat entire input as filter with default type cls.

| Arg pattern | Maps to |
|-------------|---------|
| First word = `cls`, `mac`, `inc`, or `csp` | `--type <word>` (remaining = filter) |
| Anything else | `--type cls --filter "<entire input>"` |
| `--json` | `--json` |

## Execution

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/documents/list_docs.py --server <server> --namespace <namespace> --type <type> [--filter "<pattern>"] --links
```

Always pass `--links` for cls type. This classifies each class (DTL, Rule, BPL, Production) and emits `PORTAL_URL:` lines that the frontend auto-links.

## Output

Display results and report total count. System classes (%-prefixed) are excluded by default when no filter is given. If no filter is provided and results exceed 50, just report the count and suggest the user add a filter.
