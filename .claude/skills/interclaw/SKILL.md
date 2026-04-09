---
name: interclaw
description: Interact with InterSystems IRIS/HealthShare servers via the Atelier REST API. Use this skill whenever the user wants to connect to an IRIS server, browse namespaces, list or read classes/routines/globals, compile code, run queries, manage server-side resources, scaffold production components, or work with HL7/SDA3/FHIR integrations through the Atelier API.
---

# Atelier REST API Skill

Connect to InterSystems IRIS servers and manage production components, source code, and server resources through the Atelier REST API.

## What Do You Want to Do?

| Task | Command | Script |
|------|---------|--------|
| Test server connectivity | `/connect <server> [namespace]` | `test_connection.py` |
| List classes/routines | `/list [type] [filter]` | `list_docs.py` |
| Pull a class from server | `/pull <classname>` | `get_doc.py` |
| Push and compile a class | `/push <classname>` | `put_doc.py` + `compile.py` |
| Run SQL queries | (use script directly) | `run_query.py` |
| Check message traces | `/trace [count]` | `trace.py` |
| Send HL7 messages via HTTP | `/send <file>` | `send_hl7.py` |
| Generate production components | `/scaffold <description>` | templates + references |
| Create JSON adapter classes | `/json-adapter <description>` | templates + references |
| Send JSON to HTTP service | (use script directly) | `send_json.py` |
| Reset/delete a package | `/reset <package>` | `reset_package.py` |
| Create a Foundation namespace | `/new-namespace <name>` | `manage_namespace.py` |
| Delete a namespace | `/delete-namespace <name>` | `manage_namespace.py` |
| Reset (delete + recreate) namespace | `/reset-namespace <name>` | `manage_namespace.py` |
| Create a REST API / WSGI app / CSP page | `/web-app <description>` | templates + references + `manage_webapp.py` |
| List/manage CSP web applications | `/web-app list` | `manage_webapp.py` |

## Server Configuration

Servers are defined in `config/servers.json`:

```json
{
    "intersystems.servers": {
        "server-name": {
            "webServer": {
                "scheme": "http",
                "host": "hostname",
                "port": 80,
                "pathPrefix": ""
            },
            "username": "superuser",
            "password": "optional"
        }
    }
}
```

## Base URL Pattern

```
{scheme}://{host}:{port}{pathPrefix}/api/atelier/
```

## Portal URL Construction

When generating clickable hyperlinks in responses, **always read `config/servers.json`** to get the `pathPrefix` value. NEVER omit it — most IRIS instances use a non-empty prefix (e.g., `/irishealth`).

```
portal_base = {scheme}://{host}:{port}{pathPrefix}/csp/healthshare/{namespace_lower}
```

Example for vmdev1 (pathPrefix = `/irishealth`), namespace CLAUDE:
- **WRONG** (missing pathPrefix): `http://vmdev1.iscinternal.com/csp/healthshare/claude/...`
- **RIGHT**: `http://vmdev1.iscinternal.com:80/irishealth/csp/healthshare/claude/...`

Alternatively, run `portal_urls.py` to auto-generate correct links.

## Scripts

All scripts are in `.claude/skills/interclaw/scripts/`.

| Script | Purpose | Key Args |
|--------|---------|----------|
| `iris_api.py` | Shared library for Atelier REST API (not run directly) | — |
| `iris_terminal.py` | Run ObjectScript via `iris session` batch mode | `--server`, `--namespace`, `--code`, `--file`, `--stdin`, `--raw` |
| `test_connection.py` | Test server connectivity | `--server`, `--namespace` |
| `list_docs.py` | List documents in a namespace | `--server`, `--namespace`, `--type`, `--filter` |
| `get_doc.py` | Pull a document | `--server`, `--namespace`, `--doc`, `--output` |
| `put_doc.py` | Push a document | `--server`, `--namespace`, `--doc`, `--input`, `--compile` |
| `compile.py` | Compile documents | `--server`, `--namespace`, `--docs`, `--flags` |
| `run_query.py` | Execute SQL | `--server`, `--namespace`, `--sql`, `--format` |
| `send_hl7.py` | Send HL7 via HTTP POST | `--server`, `--url`, `--input` |
| `send_json.py` | Send JSON via HTTP POST | `--server`, `--url`, `--input` |
| `get_schema.py` | Pull HL7 schema info | `--server`, `--namespace`, `--segment`, `--message`, `--list-categories`, `--list-messages` |
| `portal_urls.py` | Generate Management Portal links | `--server`, `--namespace`, `--production`, `--classes`, `--lookup`, `--all-from`, `--format` |
| `reset_package.py` | Delete a package from server + local | `--server`, `--namespace`, `--package`, `--lookup`, `--auto-lookup`, `--dry-run` |
| `manage_production.py` | Start/stop/status of productions | `--server`, `--namespace`, `--status`, `--start`, `--stop`, `--stop-first`, `--list` |
| `manage_namespace.py` | Create/delete/list/check namespaces | `--server`, `--create`, `--delete`, `--exists`, `--list`, `--dry-run` |
| `test_dtl.py` | Test a DTL against a sample message | `--server`, `--namespace`, `--dtl`, `--input`, `--generate`, `--show`, `--diff` |
| `get_settings.py` | Show Host vs Adapter settings for a class | `--server`, `--namespace`, `--class`, `--type`, `--filter`, `--format` |
| `manage_webapp.py` | Create/delete/list/enable/disable CSP web applications | `--server`, `--create`, `--delete`, `--list`, `--get`, `--type`, `--dispatch` |
| `trace.py` | Query message traces with Visual Trace links | `--server`, `--namespace`, `--component`, `--session`, `--count`, `--events` |
| `manage_lookup.py` | Lookup table CRUD (list/set/clear/count) | `--server`, `--namespace`, `--table`, `--list`, `--set`, `--clear` |
| `feedback.py` | Submit feedback to GitHub tracker | `--category`, `--comment`, `--rating` |

All scripts accept `--server` (required), `--namespace`, `--password`, and `--config`.

## API Endpoints

All endpoints use Basic Auth and return JSON.

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/atelier/` | GET | Server info (connection test) |
| `/api/atelier/v1/` | GET | List namespaces |
| `/api/atelier/v1/{ns}/doc/{name}` | GET | Get document |
| `/api/atelier/v1/{ns}/doc/{name}` | PUT | Save document |
| `/api/atelier/v1/{ns}/action/compile` | POST | Compile documents |
| `/api/atelier/v1/{ns}/action/query` | POST | Execute SQL |
| `/api/atelier/v1/{ns}/docnames/{type}` | GET | List documents by type |

### InteropEditors API (v3)

Used for production management, DTL testing, and editor integrations.

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/interop-editors/v3/{ns}/productions` | GET | List all productions |
| `/api/interop-editors/v3/{ns}/productions/status` | GET | Get running production + state |
| `/api/interop-editors/v3/{ns}/productions/state/{class}` | POST | Start/stop (`?state=start&hostID=0`) |
| `/api/interop-editors/v3/{ns}/dtl/test/{class}` | POST | Test DTL (`?inputMessage=...`) |
| `/api/interop-editors/v3/{ns}/dtl/test/{class}` | GET | Get DTL test info |
| `/api/interop-editors/v3/{ns}/dtl/{class}` | GET | Get DTL definition as JSON |
| `/api/interop-editors/v3/{ns}/rules/{class}` | GET | Get rule definition as JSON |

### Frontend (Interop Editor)

The IRIS interop editor frontend is deployed at:
```
<iris-instance>/ui/interop/interop-editor/index.html
```
For this installation: `/usr/local/InterSystems/IRISHealth/ui/interop/interop-editor/index.html`

### FileDrop Directory Pattern

File-based production components use the deployed `filedrop/` directory inside the InterClaw CSP application:

```
${cspdir}interclaw/filedrop/<Package>/<Component>/In    — services read from here
${cspdir}interclaw/filedrop/<Package>/<Component>/Out   — operations write here
${cspdir}interclaw/filedrop/<Package>/<Component>/Files — sample/reference files
```

IPM deploys as `irisusr` with `775` permissions, so `filedrop/` is writable immediately after install. Create subdirectories with `os.makedirs()` — they inherit irisusr ownership. Set adapter `FilePath` settings to these paths.

File-based adapter classes that trigger directory creation:
- **Services** (`/In` + `/Files`): `EnsLib.HL7.Service.FileService`, `EnsLib.File.PassthroughService`, `EnsLib.RecordMap.Service.FileService`, `EnsLib.EDI.XML.Service.FileService`, custom BS with `EnsLib.File.InboundAdapter`
- **Operations** (`/Out`): `EnsLib.HL7.Operation.FileOperation`, `EnsLib.File.PassthroughOperation`, `EnsLib.RecordMap.Operation.FileOperation`, `EnsLib.EDI.XML.Operation.FileOperation`, custom BO with `EnsLib.File.OutboundAdapter`

### HTTP Service URL Pattern

To send HL7 messages to an HTTP service via the CSP Web Gateway:
```
{pathPrefix}/csp/healthshare/{namespace}/EnsLib.HL7.Service.HTTPService.cls?CfgItem={configItemName}
```
- `.cls` extension is required in the URL
- Service must have `EnableStandardRequests=1` (Host setting) and `PoolSize=0`
- `?CfgItem=` identifies the config item when multiple services share the same class

## IRIS Terminal — Internal Library Only

**DO NOT call `iris_terminal.py` directly.** It is a shared library used internally by `manage_namespace.py`, `manage_webapp.py`, and `instance_id.py` for system-level operations that cannot go through the Atelier REST API (`%SYS`, `Config.*`, `Security.*`).

For any task that has a dedicated script or slash command, use that instead:

| Instead of terminal... | Use |
|----------------------|-----|
| Production start/stop | `manage_production.py` |
| Namespace create/delete | `manage_namespace.py` |
| Web app create/delete | `manage_webapp.py` |
| SQL queries | `run_query.py` |
| Class CRUD | `get_doc.py` / `put_doc.py` |
| Schema lookup | `get_schema.py` |

Only use `iris_terminal.py` directly when **all** of these are true:
1. No dedicated script or slash command covers the operation
2. The operation requires `%SYS` namespace or `Config.*`/`Security.*` classes
3. The Atelier REST API cannot perform the operation

## Reference Documentation

Detailed HealthShare-focused reference docs for building production components:

| Reference | Content |
|-----------|---------|
| **Interop Components** (`references/interop/`) | |
| `interop/Production/production-class.md` | Production XML structure, Item elements, settings |
| `interop/Service/business-services.md` | BS patterns, adapter catalog, OnProcessInput |
| `interop/Process/business-processes.md` | BPL vs code-based, routing engines |
| `interop/BPL/bpl-reference.md` | Complete BPL XML reference, all activities, patterns |
| `interop/Operation/business-operations.md` | BO patterns, MessageMap, adapter catalog |
| `interop/Rule/routing-rules.md` | Rule class structure, conditions, HL7 routing |
| `interop/Msg/messages.md` | Request/Response classes, HL7 message paths |
| **Data & Transforms** (`references/data/`) | |
| `data/DTL/data-transformations.md` | DTL structure, HL7/SDA3 transform patterns |
| `data/RecordMap/record-maps.md` | Flat file parsing, delimited/fixed-width |
| `data/LookupTable/lookup-tables.md` | Key-value tables, code translation |
| `data/JSONAdapter/json-adaptor.md` | %JSON.Adaptor, JSON HTTP service pattern |
| `data/ZSegment/custom-z-segments.md` | Custom HL7 Z-segment definitions |
| `data/UtilityFunctions/custom-utility-functions.md` | Utility function reference |
| **Web Applications** (`references/web/`) | |
| `web/WebApp/rest-applications.md` | REST API development with %CSP.REST, UrlMap, handlers |
| `web/WebApp/wsgi-applications.md` | Python WSGI/ASGI apps (Flask/Django/FastAPI) in IRIS |
| `web/WebApp/csp-zen-applications.md` | CSP pages (%CSP.Page) and Zen component pages |
| `web/WebApp/web-application-config.md` | Security.Applications config, auth, static files, CORS |
| **Infrastructure** (`references/infra/`) | |
| `infra/IPM/module-xml-reference.md` | IPM package module.xml reference |
| `infra/Navigation/goto-dom-logic.md` | Goto DOM logic reference |
| **IDE Tools** (`references/ide/`) | |
| `ide/LanguageServer/` | ObjectScript LSP implementation |
| `ide/ServerManager/` | VS Code IRIS server management extension |
| `ide/VSCodeObjectScript/` | ObjectScript language extension for VS Code |
| `ide/WebTerminal/` | Web-based IRIS terminal interface |

Read the relevant reference docs before generating ObjectScript code to ensure accurate class hierarchies, method signatures, and adapter class names.

## Templates

Class templates with `{{PLACEHOLDER}}` markers in `.claude/skills/interclaw/templates/`:

**Interop** (`templates/interop/`):
- `business-service.cls.template`
- `business-process.cls.template`
- `business-operation.cls.template`
- `message-request.cls.template`
- `message-response.cls.template`
- `dtl.cls.template`

**Web** (`templates/web/`):
- `rest-dispatch.cls.template`
- `rest-handler-method.template`
- `csp-page.cls.template`
- `zen-page.cls.template`
- `zen-app.cls.template`
- `openapi-spec.json.template`

**Python** (`templates/python/`):
- `flask-app.py.template`
- `fastapi-app.py.template`

## Standard Workflow

1. `/connect <server> <namespace>` — establish connection
2. `/list` — see what exists
3. `/pull <class>` — examine existing code
4. Edit or `/scaffold` — create new components
5. `/push <class>` — deploy and compile
6. `/trace` — verify message flow
