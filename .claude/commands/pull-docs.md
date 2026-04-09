---
allowed-tools: Bash, Read
description: Pull InterSystems documentation pages as Markdown.
---

Pull InterSystems documentation pages and convert them to Markdown.

Usage:
- /pull-docs <KEY>                          — Fetch a doc page by key
- /pull-docs <KEY> --version 2024.1         — Fetch for a specific IRIS version
- /pull-docs <KEY> --product iris            — Fetch for a specific product (default: irisforhealth)
- /pull-docs search <query>                 — Search for doc keys matching a query
- /pull-docs list-keys <KEY>                — List all doc keys referenced on a page
- /pull-docs <URL>                          — Fetch a page by full URL

## Argument parsing

Parse "$ARGUMENTS" to determine the mode:

| Input pattern | Script flags |
|---------------|-------------|
| `search <query>` | `--search "<query>"` |
| `list-keys <KEY>` | `--key <KEY> --list-keys` |
| `http...` (URL) | `--url "<URL>"` |
| `<KEY>` (anything else) | `--key <KEY>` |

Additional options passed through: `--version <ver>`, `--product <name>`, `--save`/`--output <path>`, `--server <name>`.

If user has an active server connection, add `--server <server>` to fetch from local DocBook.

## Execution

### Step 1: Run pull_docs.py

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/docs/pull_docs.py <flags from table above> [--server <server>] [--version <ver>] [--product <name>] [--output <path>]
```

### Step 2: Display output

Display the Markdown output verbatim. If `--save` was specified, confirm the file was saved to `docs/<KEY>.md`.

## Common doc keys

- `GINTEROP` — Interoperability main TOC (good for searching)
- `GCRN_new20261` — New features in 2026.1
- `GATELIER` — Atelier REST API documentation
- `EGIN_basics` — Interoperability basics tutorial
- `GREST_intro` — REST API development guide
- `GEPYTHON_productions` — Embedded Python in productions
