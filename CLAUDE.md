# InterClaw — IRIS Atelier API Skill

Interact with InterSystems IRIS/HealthShare servers via the Atelier REST API v8 and InteropEditors REST API v3. Build, deploy, and test productions from the command line.

## Project Structure

- `config/servers.json` — server connection definitions (host, port, credentials)
- `.claude/skills/interclaw/` — skill (SKILL.md + scripts + references + templates)
- `.claude/commands/` — slash commands
- `src/<Namespace>/` — locally generated/pulled class files
- `tests/` — test messages and scaffold prompts
- `docs/extending-interclaw.md` — guide for adding scripts, commands, domains, templates

## Quick Start

Use `/connect <server-name> [namespace]` to test a connection. Server names come from `config/servers.json`.

## Tool Selection Priority

**MANDATORY: Always use the highest-level tool available.**

| Priority | Tool | When to use |
|----------|------|-------------|
| **1. Slash commands** | `/production`, `/dtl`, `/push`, `/trace`, etc. | Always try first |
| **2. Dedicated scripts** | `put_doc.py`, `manage_production.py`, etc. | When no command covers the task |
| **3. SQL queries** | `run_query.py --sql "..."` | Data retrieval not covered by scripts |
| **4. Terminal** | `iris_terminal.py --code '...'` | **Last resort only — %SYS/Config.*/Security.* ops with no dedicated script** |

**NEVER call `iris_terminal.py` directly** unless the operation requires `%SYS` namespace or `Config.*`/`Security.*` classes AND no dedicated script exists. Production management, SQL queries, class CRUD, schema lookup, traces, lookups — all have dedicated scripts. Never construct raw HTTP calls — always use scripts.

## Commands

| Command | Use when... |
|---------|-------------|
| `/connect` | connecting to a server, switching namespace |
| `/list` | browsing classes/routines/includes |
| `/pull` | reading a class from the server |
| `/push` | deploying and compiling a local class |
| `/production` | creating/starting/stopping a production |
| `/build-poc` | building from a requirements document (.md/.docx/.pdf) |
| `/poc` | alias for `/build-poc` |
| `/interview` | gathering requirements before `/build-poc` |
| `/host` | adding/removing/updating individual hosts |
| `/dtl` | creating/updating a data transformation |
| `/rule` | creating/updating routing rules |
| `/bpl` | creating/updating a visual business process |
| `/lookup` | creating/updating a lookup table |
| `/json-adapter` | creating JSON message classes from a payload structure |
| `/web-app` | creating REST API, Flask/FastAPI app, or CSP page |
| `/send` | sending HL7/JSON messages (HTTP, TCP/MLLP, file drop) |
| `/trace` | debugging message flow, routing decisions |
| `/errors` | event log errors, suspended/errored messages |
| `/test-suite` | batch-testing all messages for a package |
| `/validate` | static analysis before pushing |
| `/diagram` | Mermaid flowchart of production message flow |
| `/reset` | deleting a package (dry-run first) |
| `/reset-force` | force-deleting a package (no confirmation) |
| `/new-namespace` | creating a HealthShare Foundation namespace |
| `/delete-namespace` | deleting a namespace |
| `/reset-namespace` | wiping and recreating a namespace |
| `/ipm` | building/updating an IPM package |
| `/ipm-install` | installing/verifying/uninstalling IPM packages |
| `/pip` | managing Python packages in IRIS embedded Python |
| `/docx-to-md` | converting Word to Markdown |
| `/pull-docs` | pulling InterSystems documentation as Markdown |
| `/cost` | checking token usage for current session |
| `/goto` | navigating to a component in the chatbot sidebar |
| `/feedback` | submitting feedback to the InterClaw GitHub tracker |

**Disambiguation:** `/trace` = message flow; `/errors` = event log. `/production` = from description; `/build-poc` = from requirements doc (splits exercises, delegates to `/production`). `/reset` = dry-run first; `/reset-force` = immediate. `/host` = single host via API; `/production update` = XDATA for multi-component changes.

## Scripts

Scripts live in `.claude/skills/interclaw/scripts/` organized by domain. Run with `irispython` from project root.

| Domain | Scripts | Purpose |
|--------|---------|---------|
| `connection/` | test_connection, get_settings | Server connectivity, settings introspection |
| `documents/` | list_docs, get_doc, put_doc, compile, run_query, search_code, class_inspect, manage_lookup | Class/routine CRUD, SQL, code search, lookup tables |
| `production/` | manage_production, diagram_production, validate_package | Production lifecycle |
| `hl7/` | send_hl7, send_json, get_schema, register_schema, test_dtl, test_suite | HL7 messaging, schemas, testing |
| `diagnostics/` | get_errors, audit, changelog, trace, feedback | Errors, audit trail, change tracking, message traces, feedback |
| `infrastructure/` | manage_namespace, manage_webapp, reset_package, permissions | Namespaces, web apps, permissions |
| `git/` | git_issue, git_push, git_token | GitLab integration |
| `docs/` | pull_docs, docx_to_md, open_portal | Documentation tools |
| `lib/` | iris_api, iris_http, iris_terminal, portal_urls, gitlab_api | Shared libraries (imported, not run directly) |

All scripts accept `--server`, `--namespace`, `--password`, `--config`. Run any script with `--help` for full usage.

```bash
# Pattern: cd to project root, use irispython
cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/<domain>/<script>.py --server vmdev1 --namespace HSLIB [args]
```

## Conventions

- **Always cd to project root** before running scripts. Every Bash command: `cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/...`
- **Use `irispython`** (not `python3`): `/usr/local/InterSystems/IRISHealth/bin/irispython`
- Generated class files: `src/<Namespace>/<Package>/<ClassName>.cls`
- **Never pass undocumented flags** — only use flags from `CLAUDE.md` or `--help`
- Base URL: `{scheme}://{host}:{port}{pathPrefix}/api/atelier/v8/`
- Standard library only (urllib) for HTTP, no external dependencies

### Command Conventions

All slash commands implicitly inherit these rules:

- **Server context**: Requires active server/namespace. If not established, tell user to run `/connect`.
- **Create-or-update**: Pull existing class first with `get_doc.py`. Pull succeeds → update mode. Pull fails → create mode.
- **Auto-open on mention**: Print `/goto <classname>` to navigate sidebar to the class being edited.
- **No code dumps**: Do NOT display full source in chat. Briefly describe changes (1-3 sentences), then push directly.
- **Push**: `put_doc.py --server <s> --namespace <ns> --doc <Name>.cls --input <path> --compile`. Add `--force` for updates.
- **Navigation**: `put_doc.py` emits `/goto` on stdout — backend navigates automatically. Never output `/goto` text, portal URLs, or `[View in Portal]` links.
- **Auto-test after push**: DTLs → `test_dtl.py --diff`. Productions → start + send + trace. Rules/BPL → send + trace.
- **Schema fetch**: Always `get_schema.py` before writing DTLs. Never guess field paths.

### File Directories

File-based components use the deployed `filedrop/` directory inside the InterClaw CSP application:

```
${cspdir}interclaw/filedrop/<Package>/<Component>/In    — services read
${cspdir}interclaw/filedrop/<Package>/<Component>/Out   — operations write
${cspdir}interclaw/filedrop/<Package>/<Component>/Files — samples/archive
```

IPM deploys as `irisusr` with `775` permissions — no ownership fix needed. Create subdirectories with `os.makedirs()` — they inherit irisusr ownership.
Trigger classes: `EnsLib.HL7.Service.FileService`, `EnsLib.File.PassthroughService`, `EnsLib.HL7.Operation.FileOperation`, `EnsLib.File.PassthroughOperation`, and variants

### Package Naming

```
<Pkg>.Production          <Pkg>.DTL.<Name>           <Pkg>.Rule.<Name>RoutingRule
<Pkg>.Msg.<Name>Request   <Pkg>.BP.<Name>Process     <Pkg>.BS.<Name>Service
<Pkg>.Msg.<Name>Response  <Pkg>.BPL.<Name>Process    <Pkg>.BO.<Name>Operation
```

### Permission Modes

Run `permissions.py --check <operation>` before destructive ops. Exit 0 = no confirmation needed, exit 2 = ask user first. Modes: `strict`, `normal` (default), `permissive`, `dangerously-skip-permissions`. Guardrails (always enforced): stop production before deleting, backup before deploy, max 3 packages per reset, namespace match required.

## API Version Compatibility

**Use the lowest InteropEditors API version that supports the operation.**

| API | Min IRIS | Key additions |
|-----|----------|---------------|
| v1  | ~2019.1  | Rules CRUD, compile, test. Productions list. Lookup tables. |
| v2  | ~2022.1  | +GetPropertyList, +GetContextTypes |
| v3  | **2025.1** | +Production management. +DTL editor. |
| v4  | 2025.3   | +BPL editor. +PostProduction. +TestProductionTarget. |
| v5  | 2025.3   | +GetProductionHost. +Host queue/log/jobs/messages. |
| v6  | 2026.1   | +Message viewer/search/trace. +DTL Explainer. |

## Important Gotchas

### Sending Messages
- **Always use the CSP web gateway path**: `/{pathPrefix}/csp/healthshare/{namespace}/EnsLib.HL7.Service.HTTPService.cls?CfgItem=<name>`
- **Always include `?CfgItem=<configItemName>`** — without it IRIS returns "no service configured"
- **Always check `/trace` after sending** — errors only show up in the trace

### HTTP Service Settings
- `EnableStandardRequests` is a **HOST** setting, not Adapter. Using `Target="Adapter"` causes silent HTTP 500. Always `Target="Host"`, default `EnableStandardRequests=1` with `PoolSize=0`.

### Code Display and Push Workflow
- **Do NOT display full source code.** Briefly describe changes, push directly. User reviews in editor via `/goto`.
- **Do NOT output `/goto` as visible text.** `put_doc.py` emits it on stdout; backend detects automatically.
- **Do NOT output portal URLs or `[View in Portal]` links.** Frontend auto-links class names.
- **Auto-test after push is MANDATORY.** DTLs → `test_dtl.py --diff`. Productions → start + send + trace.
- **Always pull trace after sending.** Never assume success without checking.

### Production Management
- **Single production per POC**: All exercises share ONE production class (`<Pkg>.Production`). Use the `Category` attribute on each `<Item>` to group hosts by exercise (e.g., `Category="Build 1 - VXU to ASIIS"`). Never create separate productions per exercise.
- **Standard production template components**: Productions should include `Ens.Alert` (as `EnsLib.MsgRouter.RoutingEngine` or `Ens.Alerting.NotificationOperation`), a `BadMessageHandler` (`EnsLib.HL7.Operation.FileOperation`, disabled), and optionally `EMailAlert`/`PagerAlert` (`EnsLib.EMail.AlertOperation`, disabled). Reference `BadMessageHandler` in the MsgRouter's `BadMessageHandler` setting.
- **Always start production after building**: `manage_production.py --start <Pkg>.Production --stop-first`
- **Always stop before deleting classes.** Running deletion → Suspended state.
- Stuck in Suspended → `--recover` then `--stop`, or `--clean` as last resort.
- Use `put_doc.py --force --compile` for 409 timestamp conflicts.

### DTL Authoring
- **Always pull HL7 schema first** with `get_schema.py --message <cat:msg>`. Never guess field paths. For **custom Z-structures** (e.g., `SH2.5:ADT_A01_Z`), always pull the specific Z-structure schema — don't assume it matches the base message type. The Z-structure may have different segments, groups, or field definitions.
- **Use `..` shorthand** for utility functions: `..Lookup()`, `..Strip()`, `..ConvertDateTime()`, `..ReplaceStr()`, `..Piece()`, `..ToUpper()`, `..ToLower()`, `..Coalesce()`, `..Pad()`, `..SubString()`, `..Length()`
  - **Wrong**: `##class(Ens.Util.FunctionSet).Fn()`, `$ZSTRIP()`, `$REPLACE()`
- Use `..ReplaceStr()` not `..Replace()`.
- **Not-equals operators differ by context**: In **routing rule XML** conditions, use `!=`. In **DTL XML** `<if condition>` (ObjectScript), use `'=` XML-escaped as `&apos;=`, or use `]""` to test non-empty. Never use `!=` in DTL conditions — it causes compile errors.
- Nested same-name groups: outer gets doubled (`PIDgrpgrp(1).PIDgrp...`)
- Custom schemas: use **structure name** (`StClairCustom:ADT_A01_Z`), not message type name.
- **ALWAYS use named field paths.** Every field reference in DTL source/target properties MUST use the field name from `get_schema.py --segment`, never a positional number.
  - **RIGHT**: `PID:PatientIdentifierList.IDNumber`, `ORC:EnterersLocation.Room`, `EVN:RecordedDateTime`, `PV1:VisitNumber`, `OBX:ValueType`
  - **WRONG**: `PID:3.1`, `ORC:13.2`, `EVN:2`, `PV1:19`, `OBX:2` — positional numbers are NEVER acceptable
  - See `references/data/DTL/data-transformations.md` Common Named Path Reference for lookup table.
- **No `<comment>` tags in DTL XML.** They cause compile errors (`ERROR <Ens>ErrInvalidDTL`) in IRIS 2026.1 — even outside `<foreach>`. Use XML comments (`<!-- ... -->`) instead. The `<annotation>` element inside other DTL elements (e.g., `<if>`, `<assign>`) IS safe and can be used for inline notes.
- **`disabled='1'` attribute**: Any DTL/BPL element can be disabled without deleting it by adding `disabled='1'`. Useful for keeping debug `<code>` blocks (e.g., `write` statements) without executing them.
- **Do not mix `<assign>` and `<code>` blocks.** DTL transforms with virtual document `<assign>` elements alongside `<code>` blocks fail to compile. Use one approach or the other — not both.
- **`DependsOn` must be a tuple** — `DependsOn = (EnsLib.HL7.Message, EnsLib.HL7.Message)`, not a single class.
- **`create='new'` requires copying ALL segments.** When using `create='new'`, the target starts empty. You must explicitly copy EVERY segment and group from the source schema — not just the obvious ones. Pull the schema structure and copy all groups (e.g., for ORU_R01: MSH, SFT, DSC, PIDgrp, ORCgrp with NTE, TQ1grp, CTD, FT1, CTI, SPMgrp, OBXgrp NTEs). Missing segments are silently lost.
- **`<break/>` for early exit in foreach.** Use `<break/>` inside `<foreach>` to stop iterating after finding the first match (e.g., finding a specific PID:PatientIdentifierList entry by AssigningAuthority).
- **Foreach on field-level repeats.** The `()` syntax works on tilde-delimited field repeats, not just segment groups. `source.{OBX:ObservationValue()}` iterates each tilde-separated repeat of OBX-5 natively — no need to manually split with `$PIECE`.

### Test Messages
- **Must exercise DTL logic.** Include values that will be actively changed (lookups, conditionals, loops, string ops).
- **Multiple repeating segments** for for-each loops — don't just include one.
- **Segment order must match schema exactly.** Check the schema structure output — segments must appear in the order the schema defines them (e.g., VXU_V04: PID, NK1, PV1grp, ORCgrp; ADT_A01: NK1 before PV1). Out-of-order segments cause group parsing to fail silently (ORCgrp count = 0).
- **Count field positions carefully using pipe separators.** The field number minus 1 gives the pipe count from the segment name. PID-19 (SSN) needs 18 pipes after `PID`; PV1-19 (Visit Number) needs 18 pipes after `PV1`. Common mistake: counting from the last populated field instead of from the segment name. Always verify by importing the message and checking with `GetValueAt()`.
- **Never pre-populate target fields.** If the DTL writes to `ORC:EnterersLocation.Facility.NamespaceID` via lookup, the test message must NOT already have a value in that subcomponent — otherwise the diff shows no change and you can't tell if the DTL worked.
- **Verify field alignment after writing test messages**: Import the message with DocType set and use `GetValueAt()` to confirm fields land at expected positions before running the DTL test.

### JSON Adapter Classes
- Must extend `%XML.Adaptor` in addition to `%SerialObject/%Persistent` — without it, ERROR #6249 on trace display.

### Navigation
- Never output `/goto` text, `/interclaw` URLs, or `[View in Portal]` links in responses.
- For manual navigation: `/goto <name>` (auto-detects editor type). Traces: `/trace-view [sessionID]`.
