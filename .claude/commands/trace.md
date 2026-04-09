---
allowed-tools: Bash, Read
description: Check recent message traces and event logs on the IRIS server.
---

Check recent message traces and event logs on the IRIS server.

Usage: /trace [--component <name>] [--session <id>] [count]

## Argument parsing

Parse "$ARGUMENTS" into these flags:

| Arg pattern | Maps to |
|-------------|---------|
| `--component <name>` or `-C <name>` | `--component <name>` |
| `--session <id>` or `-S <id>` | `--session <id>` |
| bare number (e.g. `50`) | `--count <number>` |
| `--events` | `--events` (requires --session) |
| `--json` | `--format json` |

Defaults: count = 20, format = table.

## Execution

Run exactly one command:

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/diagnostics/trace.py --server <server> --namespace <ns> [--component <name>] [--session <id>] [--count <N>] [--events] [--format <fmt>]
```

## Output

Display the script output verbatim. The script handles:
- Formatted table with aligned columns
- Visual Trace portal links for each session
- Status code translation (1=Created, 5=Error, 6=Suspended, etc.)
- Summary counts (N messages: X Completed, Y Error, etc.)
- Event log entries when --session + --events is used
