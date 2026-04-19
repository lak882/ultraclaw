---
allowed-tools: Bash, Read
description: Generate a Mermaid flowchart diagram of a production's message flow.
---

Generate a Mermaid flowchart diagram of a production's message flow.

Usage: /diagram <package> [--local]

## Argument parsing

Parse "$ARGUMENTS":
- First word = package name. Strip trailing `.Production` if included.
- `--local` flag = use local src/ files instead of server.

## Execution

```bash
<python> .claude/skills/interclaw/scripts/production/diagram_production.py --server <server> --namespace <ns> --package <package> [--local]
```

If the script fails (not found on server), retry with `--local`.

## Output

1. Display the script's stdout (Mermaid code) inside a fenced mermaid code block:
   ````
   ```mermaid
   <script stdout>
   ```
   ````
2. The script prints a summary line to stderr (e.g., "Summary: 3 services, 2 processes, 4 operations | 5 routing rule targets resolved | 1 disabled"). Display this summary after the diagram.
