# IRIS Interoperability Agent Orchestrator

An AI-powered agent that lives inside your InterSystems IRIS environment, enabling natural-language production building, HL7 transformation authoring, and end-to-end interoperability testing — directly from within IRIS.

## What This Does

This project provides an embedded agent skill set that connects to InterSystems IRIS and HealthShare servers via their native REST APIs (Atelier and InteropEditors). Rather than manually clicking through the Management Portal or writing ObjectScript by hand, you describe what you need in plain language and the agent builds, deploys, compiles, and tests it on your IRIS instance.

Key capabilities:

- **Build entire productions** from a requirements document (the `/poc` command)
- **Create HL7 Data Transformations (DTLs)** with automatic schema introspection and test verification
- **Author routing rules and BPL processes** using natural language descriptions
- **Manage production lifecycle** — start, stop, recover, and clean productions programmatically
- **Send test messages and inspect traces** without leaving the agent interface
- **Push and pull classes** between the local workspace and any connected IRIS namespace

## IRIS Integration Architecture

The agent communicates with IRIS through two REST API layers that are built into every IRIS installation. This project uses **Atelier API v8** (the latest version) and **InteropEditors API v3**.

- [Atelier REST API documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GATELIER)
- [Interoperability REST API documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GINTEROP)

```
+---------------------------+       +---------------------------+
|   CLI (Claude Code)       |       |   Browser (/cc frontend)  |
|   Terminal / IDE           |       |   Chatbot sidebar + SSE   |
+---------------------------+       +---------------------------+
          |                                   |
          |                          POST /api/message
          |                                   |
          |                         +-------------------+
          |                         | Chatbot Backend   |
          |                         | rest_server.py    |
          |                         | (localhost:8765)  |
          |                         +-------------------+
          |                                   |
          +-----------------------------------+
          |   claude --output-format stream-json
          v
+---------------------------+       +---------------------------+
|   Atelier REST API v8     |       |   InteropEditors REST API |
|   /api/atelier/v8/{ns}/   |       |   /api/interop-editors/   |
|                           |       |     v3/{ns}/              |
|   - Push/pull documents   |       |   - Production management |
|   - Compile classes       |       |   - Host configuration    |
|   - Run SQL queries       |       |   - DTL/Rule testing      |
|   - Schema introspection  |       |   - Lookup tables         |
+---------------------------+       +---------------------------+
          |                                   |
          +-----------------------------------+
          |
          v
+---------------------------+
|   InterSystems IRIS       |
|   HealthShare / IRIS for  |
|   Health                  |
|   - Productions           |
|   - Namespaces            |
|   - HL7 Schemas           |
|   - Lookup Tables         |
+---------------------------+
```

All communication uses Basic Auth over HTTP/HTTPS. No additional drivers, ODBC connections, or external dependencies are required beyond Python 3.10+ standard library.

## Prerequisites

- Python 3.10+ (standard library only, no pip packages needed)
- Network access to your IRIS server's web port (CSP gateway)
- A user account on the IRIS server with appropriate permissions
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated

## Connecting to Your IRIS Server

### 1. Configure Server Connections

Define your IRIS servers in `config/servers.json`:

```json
{
    "intersystems.servers": {
        "my-iris-server": {
            "webServer": {
                "scheme": "http",
                "host": "iris.example.com",
                "port": 80,
                "pathPrefix": "/irishealth"
            },
            "username": "superuser",
            "password": "SYS"
        }
    }
}
```

The `host` and `port` values are used to build all URLs (portal links, API calls, send targets). Use the externally-reachable hostname — never an internal IP. The `pathPrefix` field accommodates installations behind a reverse proxy or using a non-default CSP path (e.g., `/irishealth` for HealthShare deployments).

### 2. Test the Connection

```
/connect my-iris-server HSLIB
```

This verifies connectivity, authentication, and namespace access. The agent will confirm the server version and available namespaces.

### 3. Browse What Exists

```
/list cls HS.Hub*        -- list classes matching a pattern
/pull Some.Package.Name  -- pull a class to view its source
```

## Production Building Workflow

The core workflow for building interoperability solutions inside IRIS:

### From a Requirements Document (Recommended)

The `/poc` command reads a requirements document and builds the entire production automatically:

```
/poc poc-examples/ElRio_POC.md ElRio.POC HSLIB
```

This will:
1. Parse the document and extract each use case
2. Plan the full production structure (services, operations, DTLs, rules, lookup tables)
3. Build all components in parallel, pushing and compiling each on the IRIS server
4. Start the production and send test messages
5. Verify routing and transformations by inspecting message traces

### Step-by-Step Building

For more control, build components individually:

```
/production "Create a production for HL7 ADT routing"
/dtl "Transform ADT_A01 to SDA3, mapping PID and PV1 fields"
/rule "Route ADT messages: A01 to FileOp, A08 to UpdateOp"
/host add "Add an HTTP HL7 service listening for ADT messages"
/lookup "Create a facility code translation table"
/bpl "Create a process that enriches ADT messages with a SQL lookup"
```

Each command handles the full lifecycle: generate the class, display it for review, push it to IRIS, compile it, and run verification tests.

### Testing Inside IRIS

After building, test the production without leaving the agent:

```
/send tests/adt_a01_test.hl7   -- send a test message via HTTP
/trace 5                        -- check the last 5 message traces
```

The agent checks traces automatically after sends to catch errors that only surface in the IRIS event log (serialization failures, routing mismatches, transform errors).

## IRIS-Specific Integration Points

### Namespace Isolation

Every command targets a specific IRIS namespace. Switch namespaces with `/connect`:

```
/connect my-server HSLIB     -- work in HSLIB
/connect my-server CLAUDE    -- switch to CLAUDE namespace
```

Classes are organized locally under `src/<Namespace>/` to mirror the server layout.

### HL7 Schema Introspection

The agent queries IRIS's built-in HL7 schema repository before writing any transformation. This ensures field paths, segment structures, and group names are correct:

```python
# Automatically called before DTL authoring
python .claude/skills/interclaw/scripts/hl7/get_schema.py \
    --server my-server --namespace HSLIB --message 2.5.1:ADT_A01 --fields
```

### Production Lifecycle Management

Full control over production state through the InteropEditors API:

| Action | What happens on the IRIS server |
|--------|--------------------------------|
| Start | `Ens.Director.StartProduction()` via REST |
| Stop | Graceful shutdown of all hosts |
| Recover | Recover from Suspended state |
| Clean | `Ens.Director.CleanProduction()` for stuck states |

The agent always starts the production after building and always stops it before deleting classes, preventing the Suspended state that can be difficult to recover from manually.

### Lookup Tables

Lookup tables are created directly on the IRIS server via SQL, not as class files:

```
/lookup "Create facility code mappings: HOSP1=Hospital One, HOSP2=Hospital Two"
```

### Custom HL7 Schemas (Z-Segments)

Push custom `.HL7` schema files to IRIS via the Atelier API for Z-segment support:

```python
python .claude/skills/interclaw/scripts/hl7/register_schema.py \
    --server my-server --namespace HSLIB --input schema.HL7
```

### File-Based Components

For file-based services and operations, the agent creates standard directory structures on the IRIS server filesystem:

```
/isc/FileDrop/<Namespace>/<Package>/<Component>/In    -- inbound files
/isc/FileDrop/<Namespace>/<Package>/<Component>/Out   -- outbound files
/isc/FileDrop/<Namespace>/<Package>/<Component>/Files -- reference/test files
```

## Supported IRIS Component Types

| Component | How the agent creates it |
|-----------|------------------------|
| Productions | XML class pushed via Atelier API |
| Business Services | Built-in adapters (HTTP, File, TCP) configured in production XML |
| Business Operations | Built-in adapters configured in production XML |
| Business Processes (BPL) | XML-based visual processes pushed as `.cls` files |
| Data Transformations (DTL) | XML-based transforms with schema-validated field paths |
| Routing Rules | XML rule definitions with constraints and conditions |
| Lookup Tables | Created via SQL INSERT through the Atelier query endpoint |
| Custom Schemas | `.HL7` files pushed via the Atelier document API |
| Custom BS/BO/BP | ObjectScript classes generated only when built-in components are insufficient |
| JSON Adapters | Message and serial classes extending `%XML.Adaptor` for REST integrations |

## Package Naming Convention

All components follow a consistent structure under a root package:

```
<Pkg>.Production                          -- the production class
<Pkg>.DTL.<SourceFormat>To<TargetFormat>  -- data transformations
<Pkg>.Rule.<Name>RoutingRule              -- routing rules
<Pkg>.BP.<Name>Process                    -- code-based business processes
<Pkg>.BPL.<Name>Process                   -- BPL visual processes
<Pkg>.BS.<Name>Service                    -- custom business services
<Pkg>.BO.<Name>Operation                  -- custom business operations
<Pkg>.Msg.<Name>Request / Response        -- message classes
<Pkg>.RecordMap.<Name>                    -- record map definitions
```

## Project Structure

```
config/
  servers.json                 -- IRIS server connection definitions
  poc.json                     -- POC mode settings (HTTP inbound, file outbound)
.claude/
  skills/interclaw/          -- core skill: scripts, references, templates
    scripts/                   -- Python scripts for all IRIS API interactions
    references/                -- DTL, Rule, Z-segment, utility function docs
    templates/                 -- .cls file templates for code generation
  chatbot-backend/             -- FastAPI SSE backend (rest_server.py)
  commands/                    -- slash command definitions
backup/
  ui/interop/                  -- source of truth for the custom /cc frontend
    interop-editor/            -- chatbot-modified production config editor
    dtl-editor/                -- DTL editor
    rule-editor/               -- routing rule editor
    bpl-editor/                -- BPL process editor
    message-viewer/            -- message trace viewer
src/<Namespace>/               -- local copies of classes, organized by namespace
tests/                         -- test HL7 messages
poc-examples/                  -- POC requirements documents
devlogs/                       -- development session logs
research/                      -- research investigations
architecture/                  -- design decisions (ADRs)
CLAUDE.md                      -- agent instructions (auto-loaded)
```

## Command Reference

### High-Level Orchestration

| Command | Parameters | Purpose |
|---------|-----------|---------|
| `/poc <file> [package] [namespace]` | **Required:** path to requirements doc (.md, .docx, .pdf). **Optional:** package name, namespace | Build a complete POC from a requirements document — generates all DTLs, rules, productions, lookup tables, sends test messages, and verifies traces |
| `/interview [package-name]` | **Optional:** package name to pre-populate | Interactive questionnaire that walks through integration requirements and generates a markdown document for `/poc` |
| `/production <description>` | **Required:** description or action (open, start, stop, status, update) | Generate a new production from a description, or manage an existing production's lifecycle |

### Component Authoring

| Command | Parameters | Purpose |
|---------|-----------|---------|
| `/dtl <description>` | **Required:** transformation description (source/target types, field mappings). **Optional:** `--test-message <file>` | Create or update an HL7 Data Transformation (DTL) with automatic schema introspection and test verification |
| `/rule <description>` | **Required:** routing description (conditions and targets) | Create or update a routing rule with conditions based on HL7 field values |
| `/bpl <description>` | **Required:** process flow description (calls, transforms, conditionals) | Create or update a BPL (visual/XML) business process |
| `/json-adapter <description>` | **Required:** JSON structure and package name. **Optional:** `--portal` | Generate ObjectScript message classes from a JSON payload structure with HTTP service and file operation wiring |
| `/host <action>` | **Required:** action (add, update, remove, list, settings) + arguments per action | Add, update, remove, or list hosts (services, processes, operations) in a production |
| `/lookup <description>` | **Required:** table name and key-value pairs | Create or update lookup tables on the server for use in DTL transforms |

### Document Management

| Command | Parameters | Purpose |
|---------|-----------|---------|
| `/connect <server> [namespace]` | **Required:** server name (from servers.json). **Optional:** namespace | Connect to an IRIS server and set the active namespace |
| `/list [type] [filter]` | **Optional:** type (cls, mac, inc), filter pattern (e.g. `HS.Hub*`) | List documents in the current namespace |
| `/pull <classname>` | **Required:** class name (with or without .cls) | Pull a class from the server and display source code |
| `/push <classname>` | **Required:** class name or file path | Push a local class to the server and compile it |

### Testing and Debugging

| Command | Parameters | Purpose |
|---------|-----------|---------|
| `/send <file>` | **Required:** path to .hl7 file or message description. **Optional:** `--to <configItemName>` | Send HL7 or JSON test messages to IRIS via HTTP |
| `/test-suite <package>` | **Required:** package prefix. **Optional:** `--to <service>`, `--wait <seconds>` | Batch-send all test messages for a package and report pass/fail results |
| `/trace [count]` | **Optional:** number of recent messages (default 20) | Inspect recent message traces and event logs |
| `/errors [package]` | **Optional:** package, `--count N`, `--since HH:MM` | Pull error events from the event log |
| `/validate <package>` | **Required:** package name | Static analysis — checks routing targets, DTL DocTypes, lookup tables, syntax |
| `/diagram <package>` | **Required:** package name | Generate a Mermaid flowchart of a production's message flow |

### Navigation

| Command | Parameters | Purpose |
|---------|-----------|---------|
| `/goto [--dtl\|--rule\|--bpl\|--production\|--trace] <name>` | **Optional:** editor flag, component name | Navigate to a component in the interop editor sidebar (auto-detects editor type from class name) |
| `/trace-view [sessionID]` | **Optional:** message session ID | Open a specific message trace in the trace viewer |

### Utilities and Maintenance

| Command | Parameters | Purpose |
|---------|-----------|---------|
| `/cost` | None | Show token usage and cost estimates for the preceding command |
| `/docx-to-md <path>` | **Required:** path to .docx file | Convert a Word document to Markdown for use with `/poc` |
| `/reset <package>` | **Required:** package name. **Optional:** `--dry-run`, `--keep-local` | Delete a package from the server with dry-run confirmation |
| `/reset-force <package>` | **Required:** package name. **Optional:** `--keep-local` | Force-delete package immediately without confirmation |

## Custom Frontend (`/cc`)

The stock IRIS Interop Editor UI is left completely unmodified. All customizations live in a separate copy at `/ui/interop/cc/`, served alongside the originals without conflict.

- **Stock UI**: `http://{host}:{port}/ui/interop/interop-editor/index.html` — untouched IRIS Angular app
- **Custom UI**: `http://{host}:{port}/ui/interop/cc/interop-editor/index.html` — our fork with chatbot sidebar

The custom frontend adds a chatbot sidebar (docked right, resizable), model selector, auth gate (sidebar hidden on login page), namespace change detection, and `/goto` navigation. The Angular `<app-root>` is untouched — all changes are external CSS overrides and vanilla JS injected into `index.html`. See `architecture/2026-04-03_2340_cc-frontend-modifications.md` for a full breakdown.

The source of truth for the custom frontend is `backup/ui/interop/` in this repo. On deployment (via IPM package), these files are copied to `/ui/interop/cc/` on the IRIS server.

## Chatbot Streaming Architecture

The embedded chatbot sidebar is a reskin of Claude Code. It wraps the `claude` CLI with `--output-format stream-json` and pipes structured output through a FastAPI backend to the browser via Server-Sent Events (SSE).

### Data Flow

```
User Input (chatbot textbox)
  |
  v
POST /api/message { session_id, text, model }
  |
  v
Backend (rest_server.py)
  |-- Spawns: claude --output-format stream-json --resume SESSION_ID -p
  |-- Pipes prompt via stdin (avoids OS arg length limits)
  |-- Reads stdout line-by-line as JSON
  |-- Transforms each message into SSE events
  |-- Accumulates text for /goto detection
  |
  v
SSE Stream (text/event-stream)
  |
  v
Frontend (backup/ui/interop/interop-editor/index.html, served at /ui/interop/cc)
  |-- Reads stream via fetch() + response.body.getReader()
  |-- Parses "data: {json}" lines
  |-- Dispatches by event type to render UI
```

### Claude CLI Stream-JSON Message Types

The `claude` CLI emits one JSON object per line. The backend receives these types:

| CLI Message Type | Description |
|-----------------|-------------|
| `system` | Session metadata (`session_id`), sub-agent progress (`subtype: "task_progress"`) |
| `content_block_delta` | Real-time incremental output — `text_delta` for text, `thinking_delta` for reasoning |
| `content_block_start` | Signals a new content block beginning (text, thinking, or tool_use) |
| `assistant` | Complete assistant message with all content blocks (text, thinking, tool_use) and usage stats |
| `user` | Tool results — content blocks with `type: "tool_result"` |
| `tool_use` | Legacy standalone tool invocation event |
| `tool_result` | Legacy standalone tool result event |
| `result` | Final usage statistics for the complete response |

### SSE Event Types (Backend to Frontend)

The backend transforms CLI messages into simplified SSE events:

| SSE Type | Source | Data Fields | Frontend Rendering |
|----------|--------|-------------|-------------------|
| `delta` | `content_block_delta` (text_delta) | `text` | Accumulated and rendered as markdown (debounced 80ms) |
| `thinking` | `content_block_delta` (thinking_delta) or `assistant` thinking block | `text` | Collapsible reasoning section with full thinking text |
| `output` | `assistant` text block (fallback when no deltas) | `text` | Animated text reveal |
| `tool_use` | `assistant` tool_use block | `tool`, `input` (JSON, truncated 2000 chars) | Reasoning step: `Bash(command)`, `Read(path)`, `Grep(pattern)`, etc. |
| `tool_result` | `user` tool_result block | `text` (truncated 8000 chars) | Updates tool step to success, shows result preview |
| `usage` | `assistant`/`result`/`system` usage fields | `input_tokens`, `output_tokens` | Token counter: `12.3k in · 4.5k out · 3.2s · $0.19` |
| `status` | Backend lifecycle or `system` task_progress | `text` | Header status bar: "Connecting...", "Ready" |
| `goto` | Inferred from response text or command | `target`, `editor` | Auto-navigates sidebar to DTL/Rule/BPL/Production editor |
| `reload` | `/reload`, `/refresh`, `/reset` commands | — | `window.location.reload()` preserving chat state |
| `done` | Stream complete | `session_id` | Finalizes tool steps, triggers post-processing, stores session for `--resume` |
| `session` | Init complete | `session_id` | Enables input, processes queued messages |

### Session Management

- Sessions use `--resume SESSION_ID` for multi-turn conversations
- Frontend stores session ID in `sessionStorage` for persistence across reloads
- Backend maintains `sessions` dict mapping frontend session IDs to Claude CLI session IDs

### Navigation Inference

After each response, the backend scans accumulated text and infers navigation from the command:

| Command | Inferred Navigation |
|---------|-------------------|
| `/dtl` | `goto` with `editor: "dtl"` (from `OK: Created` output) |
| `/rule` | `goto` with `editor: "rule"` |
| `/bpl` | `goto` with `editor: "bpl"` |
| `/production` | `goto` with `editor: "production"` (triggers reload for new productions) |
| `/push` | `goto` with auto-detected editor type from class name |
| `/send` | `goto` with `editor: "trace"` (opens trace viewer) |
| `/poc` | `goto` targeting `<package>.Production` |
| `/reset` | `reload` |

## Adding a New IRIS Server

1. Add an entry to `config/servers.json` with the server's web gateway host, port, and credentials
2. Run `/connect <name> <namespace>` to verify access
3. Use `/list` to browse existing components in the namespace

Multiple servers can be configured simultaneously, allowing the agent to work across development, test, and production IRIS instances from a single workspace.
