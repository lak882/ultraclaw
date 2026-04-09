Create, open, or manage an InterSystems Production.

Usage: /production <description | action> [arguments]

Actions:
- **(default) description** — Generate a full production from a natural language description
- **update** — Modify an existing production (add/change components, update wiring)
- **open** — Check status, start if needed, report component list
- **start** / **stop** / **status** — Production lifecycle

## Parsing

Parse "$ARGUMENTS". Determine the action:
- First word is `open`, `start`, `stop`, `status`, `update` → that action
- Otherwise → natural language description (generate production)

---

## Action: status / start / stop

Direct call to `manage_production.py`.

## Action: open

Check status, start if not running, report production status and component list.

---

## Action: Update Existing Production

1. Pull existing production. Understand all hosts, classes, settings.
2. Create/modify dependent components using `/dtl`, `/rule`, `/bpl` workflows.
3. Modify production class — preserve all existing `<Item>` elements, only change what's requested.
4. Push with `--force`, compile, restart with `--stop-first`.

---

## Action: Generate Production from Description

### Pre-check
Pull `<Pkg>.Production.cls` — if it exists, switch to **Update** flow above.

### Phase 1: Plan

Identify components from the description:

Inbound (Business Service):
- "CSV file" / "file drop" / "file polling" → `EnsLib.HL7.Service.FileService`
- "HL7 TCP" / "MLLP" → `EnsLib.HL7.Service.TCPService`
- "HL7 HTTP" → `EnsLib.HL7.Service.HTTPService` (EnableStandardRequests=1, PoolSize=0)
- "REST" / "HTTP" → `EnsLib.REST.Service`
- "FTP" → `EnsLib.FTP.InboundAdapter`
- "SQL" → `EnsLib.SQL.InboundAdapter`
- "FHIR" → `HS.FHIRServer.Interop.Service`
- When ambiguous, prefer file-based services (simpler to demo)

Routing/Processing:
- "route" → `EnsLib.HL7.MsgRouter.RoutingEngine` + rule class
- "process" / "validate" → Business Process (code or BPL)

Outbound (Business Operation):
- "TCP" / "MLLP" → `EnsLib.HL7.Operation.TCPOperation`
- "file" / "archive" → `EnsLib.HL7.Operation.FileOperation`
- "REST" / "HTTP" → `EnsLib.REST.Operation`
- "SQL" → `EnsLib.SQL.Operation.GenericOperation`
- "Hub" → `HS.Hub.HSWS.WebServices.Operations`
- "FHIR" → `HS.FHIRServer.Interop.Operation`

Fetch schemas and host settings in parallel. Create `src/` and FileDrop directories under `${cspdir}interclaw/filedrop/`.

### Phase 2: Build (parallel agents)

Launch agents in a **single message** for DTLs, rules, BPLs, messages, lookup tables, and custom BS/BO. Each agent pushes and compiles its classes.

### Phase 3: Assemble and test

Generate production class with correct settings (EnableStandardRequests=1 for HTTP, FilePath for file components). Push, compile, start with `--stop-first`. Send test messages and check traces.
