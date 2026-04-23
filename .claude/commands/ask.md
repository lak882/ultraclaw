---
allowed-tools: Bash
description: Send a prompt to a running InterClaw instance via HTTP and print the response.
---

Invoke the InterClaw chat pipeline on a remote server. This is the local-CLI gateway to the same tool layer (run_sql, put_class, get_doc, get_schema, test_dtl, etc.) the in-browser chatbot uses, so Claude Code running on your laptop can drive an InterClaw server without opening the UI.

Usage: `/ask <prompt>`

## Execution

Run the CLI at `.claude/scripts/interclaw_ask.py`:

```bash
python3 .claude/scripts/interclaw_ask.py "$ARGUMENTS"
```

Default target: the `default` entry in `config/servers.json`. Override with:

- `--server <name>` — pick a different entry from `config/servers.json`.
- `--conn http://user:pass@host:port/path-prefix` — full connection string. Also supports the `interclaw://` scheme alias.
- `INTERCLAW_CONN` env var — same format as `--conn`; picked up when `--server` is not given.

Other useful flags:
- `--namespace TESTING` — run the turn in a different namespace than the server default.
- `--model opus|sonnet|haiku` (default `opus`).
- `--effort low|medium|high|max`.
- `--session-id <id>` — continue an existing chat; without it every call is a fresh one-shot.
- `--json` — stream events as ndjson on stdout (tool calls, deltas, tool_results, done).
- `--quiet` — suppress thinking/tool chatter on stderr.
- `--no-stream` — wait for the final output before printing.
- `--stdin` — read the prompt from stdin instead of argv.

## Response

Print the CLI output verbatim so the user sees the server's answer. If the exit code is non-zero, show the stderr diagnostic line.

The server-side typed tools run under the namespace the instance is configured to; see `install/InterClaw/Tools/` for the full list (RunSQL, GetDoc, GetSchema, PutClass, TestDTL, Exec, SpawnAgent, EnterPlanMode).
