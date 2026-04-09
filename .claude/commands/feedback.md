---
allowed-tools: Bash, Read
description: Submit feedback to the InterClaw GitHub issue tracker.
---

Submit feedback to the InterClaw GitHub issue tracker.

Usage:
- `/feedback bug <comment>` — report a bug
- `/feedback feature-request <comment>` — request a feature
- `/feedback praise <comment>` — share positive feedback
- `/feedback general <comment>` — general feedback
- `/feedback` — interactive mode (prompt for category, rating, comment)

## Argument parsing

Parse "$ARGUMENTS":

| Input pattern | Maps to |
|---------------|---------|
| `bug <comment>` | `--category bug --comment "<comment>"` |
| `feature-request <comment>` | `--category feature-request --comment "<comment>"` |
| `praise <comment>` | `--category praise --comment "<comment>"` |
| `general <comment>` | `--category general --comment "<comment>"` |
| (no args) | Interactive: ask category (bug/feature-request/general/praise), rating (1-5, optional), comment |

First word is category if it matches one of: `bug`, `feature-request`, `general`, `praise`. Everything after is the comment.

## Execution

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/diagnostics/feedback.py --category <category> --comment "<comment>" [--rating <1-5>] [--namespace <ns>]
```

## Output

Display the script output verbatim (success with issue URL, or error message).
