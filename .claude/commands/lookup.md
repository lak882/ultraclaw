---
allowed-tools: Bash, Read
description: Create or update a lookup table on the IRIS server.
---

Create or update a lookup table on the IRIS server.

Usage:
- `/lookup list` — list all table names
- `/lookup <TableName>` — show entries in a table
- `/lookup <TableName> key1=val1 key2=val2 ...` — set entries (upsert)
- `/lookup <TableName> --clear` — delete all entries
- `/lookup <TableName> key1=val1 key2=val2 --clear-first` — replace all entries

## Argument parsing

Parse "$ARGUMENTS" into these patterns:

| Input pattern | Script call |
|---------------|-------------|
| `list` | `--list-tables` |
| `<TableName>` (no key=val) | `--table <TableName> --list` |
| `<TableName> k=v k=v ...` | `--table <TableName> --set k=v k=v` |
| `<TableName> k=v ... --clear-first` | `--table <TableName> --set k=v --clear-first` |
| `<TableName> --clear` | `--table <TableName> --clear` |
| `<TableName> --count` | `--table <TableName> --count` |
| `<TableName> --json` | `--table <TableName> --list --format json` |

The first non-flag word is the table name. Remaining `key=value` pairs (containing `=`) are entries to set.

## Execution

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/documents/manage_lookup.py --server <server> --namespace <ns> [flags from table above]
```

## Output

Display the script output verbatim. The script handles formatting (aligned table or JSON).
