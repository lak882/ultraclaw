# local-dev — Standalone Atelier REST scripts for local development

**Scope:** this directory is a **local development helper**. The scripts here talk to a running IRIS instance from a developer laptop/shell over the Atelier REST API, without going through the in-IRIS `InterClaw` chat pipeline. They are **not** loaded by the production chatbot, **not** part of the shipped skill, and **not** invoked by server-side tools.

If you are reading this from inside the InterClaw server-side agent (the one running under the IRIS process), you should **not** be here — you have typed tools (`put_class`, `run_sql`, `get_doc`, `get_schema`, `test_dtl`, etc.) that do these jobs faster and more safely. See `install/InterClaw/Tools/` for that surface.

## When to use `local-dev/`

- Quickly bouncing off a server for exploration, debugging, or bulk operations from a shell (`bash`, your editor, CI, etc.).
- Automating repetitive tasks across multiple instances.
- Running ad-hoc SQL / class pulls / log checks against a server you don't have the UI open for.
- Prototyping a feature before it gets folded into the server-side skill.

## When NOT to use `local-dev/`

- Inside a chat session on the running InterClaw chatbot UI. Use the typed tools in the chat instead — they run in-process, return typed results, and compose with planning/permissions.
- From the InterClaw server itself (the BP + BO pipeline under `install/InterClaw/`). Those run in the IRIS namespace and can call tools natively.
- As a production deployment path. `put_class` via the server-side typed tool (or the Atelier compile through the skill's native path) is the shipping mechanism; these scripts are a convenience fallback.

## Structure

```
local-dev/
├── CLAUDE.md           (this file)
└── scripts/
    ├── connection/     test_connection, get_settings, instance_id
    ├── diagnostics/    audit, changelog, feedback, get_errors, trace
    ├── docs/           catalog_portal_urls, docx_to_md, open_portal, pull_docs
    ├── documents/      list_docs, get_doc, put_doc, compile, run_query,
    │                   search_code, class_inspect, manage_lookup
    ├── git/            git_issue, git_push, git_token
    ├── hl7/            send_hl7, send_json, get_schema, register_schema,
    │                   test_dtl, test_suite, route_test
    ├── infrastructure/ manage_namespace, manage_webapp, permissions,
    │                   reset_package, setup_interclaw, setup_interclaw_portal
    ├── lib/            iris_api, iris_http, iris_terminal, iris_terminal_pool,
    │                   portal_urls, interclaw_platform, gitlab_api, iris
    └── production/     manage_production, diagram_production, samples,
                        validate_package
```

All scripts are standalone and use the Python standard library only (no external deps) except for IRIS Python / Atelier auth. `lib/` holds shared helpers imported via a relative `sys.path` poke at the top of each script.

## Connection

All scripts read `config/servers.json` at the repo root — same file the in-browser chatbot, the `/ask` CLI, and the installer use. Invocation:

```bash
<python> local-dev/scripts/<domain>/<script>.py --namespace HSLIB [--server <name>] [other flags]
```

Where `<python>` = `../../bin/irispython` (relative to repo root). `--server <name>` picks an entry from `config/servers.json`; omitted → uses the `default` entry with host overridden to localhost. Every script accepts `--server`, `--namespace`, `--password`, `--config`. Run any script with `--help` for full flag list.

## Relationship to `/ask` and the server-side tools

| Task | Local-dev script | In-chat equivalent | Notes |
|------|------------------|-------------------|-------|
| Run SQL | `documents/run_query.py --sql "..."` | `run_sql` tool in chat | Chat tool is typed + returns JSON; this prints to stdout |
| Get a class source | `documents/get_doc.py --doc Pkg.Class.cls` | `get_doc` tool | |
| Push + compile a class | `documents/put_doc.py --doc ... --input ... --compile` | `put_class` tool | Chat tool enforces plan-mode / approval; script is raw |
| Browse docs | `documents/list_docs.py` | Inline in chat | |
| Trace messages | `diagnostics/trace.py` | `/trace` in chat | |
| HL7 schema lookup | `hl7/get_schema.py` | `get_schema` tool | |
| Send HL7 | `hl7/send_hl7.py` | `/send` in chat | |
| Manage production | `production/manage_production.py` | `/production` in chat | |
| Namespace CRUD | `infrastructure/manage_namespace.py` | `%SYS` via chat | Script path is faster for batch ops |

Prefer the chat path when you're already in a chat session. Prefer a local-dev script when you're in a terminal and don't want to open a browser.

## Safety

- `infrastructure/reset_package.py` and `manage_namespace.py --delete` are destructive; always dry-run first (most scripts accept `--dry-run`).
- Scripts run with whatever credentials `config/servers.json` supplies — usually superuser. Treat them accordingly in multi-tenant setups.
- Nothing here writes to `^InterClaw.Config` or the chat event globals. The server-side agent won't see script-initiated changes in its session state until it next polls the affected object.
