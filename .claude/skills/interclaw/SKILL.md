---
name: interclaw
description: Build and maintain InterSystems IRIS productions from inside the IRIS process. Call native typed tools (put_class, get_doc, run_sql, get_schema, test_dtl, etc.) to read and write classes, routines, schemas, lookup tables, and productions. Use the reference docs in this skill to generate correct ObjectScript, DTL, BPL, and routing-rule XML.
---

# InterClaw

You run **inside an IRIS process** in a healthcare-integration namespace. All work happens through typed tools; there is no subprocess, no REST client, no shell. The current namespace, origin, and (when present) active component are prepended to each prompt as `[Context: ...]`.

## Default Tool

Most tasks map to a single tool. Pick the most specific one; fall back to `exec` only when nothing else fits.

| Goal | Tool | Notes |
|---|---|---|
| Read a class or routine | `get_doc` | pass the `.cls` / `.mac` / `.inc` name |
| List classes by package | `list_docs` | optional `prefix` |
| Create or update a class | `put_class` | full UDL source; compiles by default |
| Compile an existing class | `compile_class` | comma-separated names ok |
| Run SQL (read-only) | `run_sql` | SELECT only; 100-row cap |
| Inspect an HL7 schema | `get_schema` | modes: `list_categories`, `list_messages`, `list_segments`, `message`, `segment_fields` |
| Test a DTL in memory | `test_dtl` | segment-level diff, no production needed |
| Check the running production | `production_status` | name + state |
| Read a skill file | `read_skill_file` | docs/templates/references |
| List skill files | `list_skill_files` | enumerate what's available |
| Fall-back ObjectScript / Python | `exec` | `iris` is preimported; bind `result` |
| Send an HL7 message | `send_hl7` | POST to a CSP HL7 HTTPService; returns HTTP status |
| Recent message traces | `trace` | filter by session_id or config_item |
| Recent errors/warnings | `get_errors` | Ensemble event log, last N hours |
| Start/stop/update production | `manage_production` | actions: start/stop/restart/update/status |
| Lookup table CRUD | `manage_lookup` | list_tables/list_keys/get/set/clear_key/clear_table |
| Namespace CRUD | `manage_namespace` | exists/list/create (HS Foundation)/delete |
| Web app CRUD | `manage_webapp` | list/get/create (csp/rest/wsgi)/delete |
| Delete a package | `reset_package` | dry-run by default; pass commit=true to delete |
| Batch-send HL7 fixtures | `test_suite` | POST every *.hl7 file in a dir, summarize |


### When to use `exec`

Use `exec` only when no typed tool covers the task — e.g. `%SYS` operations, `Config.*` / `Security.*`, namespace or webapp management, direct global access. **Never** call `iris.sql.*` from inside `exec`; use `run_sql`. Prefer ObjectScript via `iris.cls(...)._<Method>()` over raw `execute` strings — fewer quoting bugs, better errors.

## Reading vs. Writing Classes

- **Always `get_doc` before `put_class`** on an existing class. The model must see the current server state before overwriting it.
- Classes that already exist on-server need a complete UDL block in `put_class` — partial replacements are not supported.
- Compilation errors come back as structured status; treat a non-empty error list as a hard failure and fix before moving on.

## HL7 Workflow

| Step | Tool |
|---|---|
| See which categories/messages are registered | `get_schema` mode `list_categories` / `list_messages` |
| Inspect fields for a segment | `get_schema` mode `segment_fields` |
| Inspect a full message structure | `get_schema` mode `message` |
| Transform a message to verify a DTL | `test_dtl` with the DTL class + raw HL7 |

**Always pull the schema before writing DTL / routing-rule XML.** Never guess field paths or message-structure names. Custom Z-schemas must be registered in the namespace first — use `put_class` to write the `.HL7` doc, then compile.

## Productions

- `production_status` returns `{name, state, running}` for the currently installed production.
- To start, stop, or update a production, emit an `exec` block that calls `##class(Ens.Director).StartProduction(...)` / `StopProduction(...)` / `UpdateProduction(...)` in ObjectScript. A dedicated tool is planned.
- Single production per POC — all exercises share one `<Pkg>.Production` class, grouped via the `Category="..."` attribute on each `<Item>`.

## File-based Components

File-drop components use the deployed `filedrop/` tree inside the InterClaw CSP app:

```
${cspdir}interclaw/filedrop/<Package>/<Component>/In     -- services read
${cspdir}interclaw/filedrop/<Package>/<Component>/Out    -- operations write
${cspdir}interclaw/filedrop/<Package>/<Component>/Files  -- sample / archive
```

IPM deploys this tree as the IRIS process user at `775`, so no chown/chmod is needed. Create subdirectories with `os.makedirs(...)` inside an `exec` call.

## Package Naming

```
<Pkg>.Production           <Pkg>.DTL.<Name>              <Pkg>.Rule.<Name>RoutingRule
<Pkg>.Msg.<Name>Request    <Pkg>.BP.<Name>Process        <Pkg>.BS.<Name>Service
<Pkg>.Msg.<Name>Response   <Pkg>.BPL.<Name>Process       <Pkg>.BO.<Name>Operation
```

Multi-exercise POCs scope every non-production class under the build number:
```
Sanford.Build1.DTL.ADTTransform   Sanford.Build1.BO.SystemA
Sanford.Build2.DTL.ORUTransform   Sanford.Build2.BO.ORUOutput
```
The production class stays `<Pkg>.Production`.

When the user gives no name, use `Demo` as the package and derive the class name from source+target data types: `Demo.DTL.V251ADTA01ToV251ADTA01`. Names cannot start with a digit — prepend `V` if they would.

## Reference Docs (read before writing)

Load only the docs you need for the task — `read_skill_file` is cheap but context isn't.

| Domain | File | Read when |
|---|---|---|
| Production XML | `production/production-class.md` | scaffolding a production |
| Business services | `production/services/business-services.md` | creating a BS |
| Business processes | `production/processes/business-processes.md` | creating a code-based BP |
| BPL | `bpl/bpl-reference.md` | creating / editing any BPL — **always** |
| Routing rules | `rules/routing-rules.md` | creating a rule class |
| DTL | `dtl/data-transformations.md` | creating / editing any DTL — **always** |
| DTL datetime helpers | `dtl/datetime-formats.md` | format conversions |
| DTL quality checklist | `dtl/poc-quality-criteria.md` | reviewing a finished DTL |
| Business operations | `production/operations/business-operations.md` | creating a BO |
| Messages | `production/messages/messages.md` | request/response class design |
| Record maps | `data/record-maps.md` | flat-file parsing |
| Lookup tables | `data/lookup-tables.md` | code translation tables |
| JSON adapter | `data/json-adaptor.md` | JSON-over-HTTP messages |
| Z-segments | `data/custom-z-segments.md` | custom HL7 schema design |
| Utility fns | `data/custom-utility-functions.md` | DTL/BPL helper reference |
| REST apps | `web/rest-applications.md` | `%CSP.REST` dispatchers |
| WSGI apps | `web/wsgi-applications.md` | Flask/FastAPI inside IRIS |
| CSP/Zen | `web/csp-zen-applications.md` | CSP pages / Zen apps |
| Webapp config | `web/web-application-config.md` | auth, CORS, static files |
| IPM module.xml | `infra/module-xml-reference.md` | packaging |
| Goto DOM logic | `infra/goto-dom-logic.md` | navigation wiring |

## Templates

Class templates carry `{{PLACEHOLDER}}` markers; fill them, then pipe the result into `put_class`.

```
bpl/bpl-process.cls.template                  -- default for orchestration
dtl/dtl.cls.template
production/services/business-service.cls.template
production/operations/business-operation.cls.template
production/processes/business-process.cls.template   (rare; prefer BPL)
production/messages/message-request.cls.template
production/messages/message-response.cls.template
web/rest-dispatch.cls.template
web/rest-handler-method.template
web/csp-page.cls.template
web/zen-page.cls.template
web/zen-app.cls.template
web/openapi-spec.json.template
web/flask-app.py.template                     -- user-facing WSGI target
web/fastapi-app.py.template                   -- user-facing WSGI target
```

## Conventions

- **Pull existing before overwriting.** Default to `get_doc` first.
- **Always BPL for processes.** Code-based BPs only when the user explicitly asks or BPL genuinely cannot express the logic.
- **Always HL7 schema first for DTLs.** Never guess field paths.
- **Named field paths only.** `PID:PatientIdentifierList.IDNumber` — never `PID:3.1`.
- **Test everything after push.** DTLs via `test_dtl`; productions by sending a message and reading the trace (see the trace section below).
- **Portal URLs go at the end of the response only.** Use the ZEN editor table in the project `CLAUDE.md`.
- **No code dumps.** Describe the change in prose; the user sees the diff through the UI.

## Gotchas

- **Class names cannot start with a digit.** Prepend `V` when deriving from schema names.
- **Field names are case-sensitive.** `NameOfCodingSystem` — capital `O` in `Of`.
- **DTL not-equals differs by context.** Routing rule XML uses `!=`; DTL `<if condition>` uses `&apos;=` (escaped `'=`) or `]""`.
- **Never mix `<assign>` and `<code>` blocks** in a single DTL — they do not coexist cleanly.
- **`DependsOn` is a tuple**: `DependsOn = (EnsLib.HL7.Message, EnsLib.HL7.Message)`, not a single class.
- **`<comment>` tags break DTL compile in IRIS 2026.1.** Use XML comments (`<!-- ... -->`) instead.
- **HL7 routing rules need `<constraint name="docName" value="ADT_A01"/>`**, not a `{MSH:MessageType.MessageCode}` condition in `<when>`.
- **Custom HL7 schemas must be pushed as `.HL7` documents via `put_class`** (raw XML source), then compiled. The `register_schema` path is unreliable.
- **`^Ens.Util.Log` `Type` is an int**: 2=Error, 3=Warning, 4=Info, 6=Alert. Query with `Type IN (2,3)`.

## Trace and Errors (no typed tool yet)

For direct SQL access (when you need columns the `trace` / `get_errors` tools don't expose):

- Recent messages with session links: `run_sql` with
  `SELECT TOP 20 SessionId, %Id AS MsgId, TimeCreated, SourceConfigName, TargetConfigName, MessageBodyClassName FROM Ens.MessageHeader ORDER BY %Id DESC`
- Recent errors from the event log: `run_sql` with
  `SELECT TOP 20 ID, TimeLogged, Type, ConfigName, Text FROM Ens_Util.Log WHERE Type IN (2,3) ORDER BY ID DESC`
- Full visual-trace render: build the legacy-ui URL from `${origin}${pathPrefix}/ui/interop/interclaw/legacy-ui/index.html#/csp/healthshare/{ns}/EnsPortal.VisualTrace.zen?SESSIONID={sessionId}`.

## Sending HL7 via HTTP

Send a test message by POSTing to the CSP gateway URL for the HL7 HTTP service:
```
{pathPrefix}/csp/healthshare/{namespace}/EnsLib.HL7.Service.HTTPService.cls?CfgItem={configItemName}
```
Rules:
- `.cls` extension required.
- The service must have `EnableStandardRequests=1` (Host setting), `PoolSize=0`.
- `?CfgItem=` disambiguates when several services share the same class.

Drive the POST from `exec` (embedded Python `urllib.request`) or from a shell harness outside IRIS; always pull the trace immediately afterwards — HTTP 200 does not prove the message reached the target.
