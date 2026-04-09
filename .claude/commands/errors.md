---
allowed-tools: Bash, Read
description: Pull error-level events from the IRIS event log and check for errored/suspended messages.
---

Pull error-level events from the IRIS event log and check for errored/suspended messages.

Usage: /errors [package] [--count N] [--since HH:MM|YYYY-MM-DD] [--json]

## Argument parsing

Parse "$ARGUMENTS":

| Arg pattern | Maps to |
|-------------|---------|
| First non-flag word | `--package <name>` |
| `--count N` or bare number | `--count <N>` (default: 20) |
| `--since HH:MM` or `--since YYYY-MM-DD` | `--since <value>` |
| `--json` | `--format json` |

## Execution

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/diagnostics/get_errors.py --server <server> --namespace <ns> [--package <pkg>] [--count <N>] [--since <value>] [--format <fmt>]
```

## Output

Display the script output verbatim. The script handles:
- Event Log Errors/Warnings table
- Errored/Suspended Messages table
- "System is clean" message when no errors (exit 0)
- Suggestion line with next `/trace` command when errors found (exit 1)
