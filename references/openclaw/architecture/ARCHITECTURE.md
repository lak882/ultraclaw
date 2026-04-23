# OpenClaw Architecture Deep Dive

**Version**: 1.0  
**Last Updated**: 2026-04-18  
**Analysis Date**: Based on main branch exploration

## Executive Summary

OpenClaw is a gateway-centric, multi-channel AI orchestration system that runs a personal AI assistant locally on user devices. The system integrates with messaging platforms (WhatsApp, Telegram, Slack, Discord, Signal) through a unified WebSocket gateway architecture with embedded Pi agent runtime for inference and tool execution.

**Core Statistics**:
- TypeScript/Node.js (ESM)
- 500+ gateway-related files
- 60+ bundled channel/provider plugins
- WebSocket-based control protocol
- Embedded Pi agent runtime
- Multi-platform support (CLI, web, macOS, iOS, Android)

---

## 1. OVERALL SYSTEM ARCHITECTURE

### High-Level Overview

OpenClaw is built around a **single Gateway daemon** per host that serves as the control plane for all interactions:

```
┌─────────────────────────────────────────────────────────┐
│                 CONTROL PLANE                            │
│         (Gateway WebSocket + HTTP Server)               │
├─────────────────────────────────────────────────────────┤
│  Auth System | Session Manager | Channel Runtime       │
│  Agent Executor | Queue Manager | Cron Service         │
├─────────────────────────────────────────────────────────┤
│                 AGENT RUNTIME                            │
│            (Embedded Pi Agent Core)                     │
├─────────────────────────────────────────────────────────┤
│  Tool System | Provider Transports | Context Mgmt      │
│  Streaming | Hook Integration | Compaction             │
├─────────────────────────────────────────────────────────┤
│              CHANNEL INTEGRATION                         │
│   WhatsApp | Telegram | Slack | Discord | Signal       │
├─────────────────────────────────────────────────────────┤
│                PLUGIN SYSTEM                             │
│  Provider Plugins | Channel Plugins | Tool Plugins     │
│  Memory Providers | Hook Handlers                       │
├─────────────────────────────────────────────────────────┤
│                NODE NETWORK                              │
│  macOS App | iOS App | Android App | Remote Devices    │
├─────────────────────────────────────────────────────────┤
│              STORAGE LAYER                               │
│  JSONL Sessions | Config | Credentials | Bootstrap      │
└─────────────────────────────────────────────────────────┘
```

### Gateway-Centric Design

The **Gateway daemon** is the architectural centerpiece:

- Maintains provider connections (messaging platforms)
- Exposes typed WebSocket API for control-plane clients
- Manages queue, session, and routing logic
- Orchestrates agent execution through Pi runtime
- Handles authentication and device pairing
- Broadcasts events (agent, chat, presence, health)

### Message Flow

```
[Inbound Message] → [Channel Plugin] → [Gateway Router] → 
[Queue Manager] → [Agent Runtime (Pi)] → [Tools/Skills] → 
[Model Provider] → [Response] → [Channel Plugin] → [Platform]
```

---

## 2. CORE COMPONENTS

### 2.1 Gateway (`src/gateway/`)

**Purpose**: Central control plane and orchestration hub

**Key Subsystems**:

1. **Protocol Handler** (`server.ts`, `net.ts`)
   - WebSocket handshake
   - Frame parsing
   - Request/response routing
   - Type-safe RPC

2. **Auth System** (`auth.ts`, `device-auth.ts`)
   - Device pairing
   - Token rotation
   - Rate limiting
   - Trust model

3. **Session Manager** (`session-*.ts`)
   - Session lifecycle
   - Transcript persistence (JSONL)
   - Compaction triggers

4. **Channel Runtime** (`server-channels.ts`)
   - Channel plugin loading
   - Account management
   - Inbound/outbound routing

5. **Agent Executor** (`server-chat.ts`, `call.ts`)
   - Agent invocation
   - Queue management
   - Streaming coordination

6. **HTTP Servers** (`server-http.ts`)
   - OpenAI-compatible endpoints
   - Web UI hosting
   - Canvas host

7. **Config Reloader** (`server-reload-*.ts`)
   - Live config updates
   - No restart required

8. **Cron Service** (`server-cron.ts`)
   - Scheduled automation

9. **Hook Runner** (`hooks.ts`)
   - Event-driven scripts
   - Plugin hook execution

**Key Files**:
- `src/gateway/server.impl.ts` - Gateway bootstrapping
- `src/gateway/server-chat.ts` - Agent execution
- `src/gateway/protocol/schema.ts` - Protocol types

---

### 2.2 Channels (`src/channels/`)

**Purpose**: Core channel implementation layer

**Responsibilities**:
- Shared `message` tool host (one tool for all channels)
- Session/thread bookkeeping
- Execution dispatch

**Plugin Responsibility** (in `extensions/`):
- Channel-specific discovery via `describeMessageTool()`
- Provider-specific session grammar
- Final action execution through adapter

**Bundled Channels** (as workspace plugins):
- WhatsApp (Baileys)
- Telegram (grammY)
- Discord
- Slack
- Signal
- iMessage
- SMS

---

### 2.3 Agents Runtime (`src/agents/`)

**Purpose**: Pi agent integration and execution

**Key Components**:

1. **Embedded Pi Core**
   - Single-session runtime
   - Model inference
   - Tool execution
   - Streaming

2. **Session Manager**
   - Per-session state
   - Workspace binding
   - Bootstrap injection (AGENTS.md, SOUL.md, etc.)

3. **Tool Wiring**
   - System tools: `read`, `write`, `exec`, `edit`
   - User tools
   - MCP tools
   - Channel `message` tool

4. **Provider Transports**
   - Anthropic
   - OpenAI
   - OpenRouter
   - Local models (Ollama, LM Studio)

5. **Streaming**
   - Block streaming
   - Reasoning streaming
   - Delta emission

6. **Compaction**
   - Auto-compression of history
   - Token budget management

7. **Hook Integration**
   - Plugin interception points
   - Before/after tool calls
   - Lifecycle hooks

**Key Files**:
- `src/agents/pi-embedded-runner/run/attempt.ts` - Main execution
- `src/agents/pi-embedded-runner/run/attempt.ts:2163` - LLM call
- `src/agents/pi-embedded-subscribe.ts` - Event streaming
- `src/agents/pi-tools.ts` - Tool definitions
- `src/agents/anthropic-transport-stream.ts` - Anthropic provider
- `src/agents/openai-transport-stream.ts` - OpenAI provider

---

### 2.4 Plugins System (`src/plugins/`)

**Purpose**: Extensible capability model

**Discovery Pipeline**:
1. Scan workspace, extension roots, bundled plugins
2. Find `openclaw.plugin.json` manifests
3. Schema validation
4. Compatibility checks
5. Lazy load via jiti
6. Invoke `register(api)` entrypoint
7. Assemble registry

**Plugin Registry Contains**:
- Provider registrations (Anthropic, OpenAI, local)
- Channel registrations (WhatsApp, Telegram, etc.)
- Tool registrations (custom tools)
- Hook registrations (lifecycle, message, tool)
- Memory providers (Honcho, QMD, built-in)
- Setup wizards and auth flows

**Plugin Types**:

| Type | Registration | Example |
|------|-------------|---------|
| Provider (text) | `api.registerProvider(...)` | openai, anthropic |
| Provider (speech) | `api.registerSpeechProvider(...)` | elevenlabs |
| Provider (vision) | `api.registerMediaUnderstandingProvider(...)` | openai |
| Provider (image gen) | `api.registerImageGenerationProvider(...)` | dall-e |
| Channel | `api.registerChannel(...)` | discord, telegram |
| Tool | Hooks system | custom tools |
| Skill | File-based (markdown) | bundled skills |
| Hook-only | `api.registerHook(...)` | lifecycle handlers |

**Key Files**:
- `src/plugins/loader.ts` - Plugin loading
- `src/plugins/registry.ts` - Central registry
- `src/plugins/manifest.ts` - Manifest parsing

---

### 2.5 Plugin SDK (`src/plugin-sdk/`)

**Purpose**: Public contract for third-party plugins

**Exports**:
- `core.ts` - Basic types, registration APIs
- `provider-entry.ts` - Model provider API
- `channel-contract.ts` - Channel integration API
- `runtime.ts` - Runtime helpers (lazy-loaded)
- Subpaths for specific capabilities

**Design Principle**: Plugin authors only import from `openclaw/plugin-sdk/*`

---

### 2.6 UI & Control Plane (`ui/`)

**Purpose**: Web-based control interface

**Features**:
- Session history browser
- Agent configuration
- Model selection
- Skills browsing
- Settings management

**Deployment**:
- Served by Gateway HTTP (same port)
- Mounted at `/__openclaw__/ui`
- Communicates via WebSocket (same protocol as CLI)

---

### 2.7 Apps (Mobile & Desktop)

**macOS** (`apps/macos/`):
- SwiftUI app
- launchd gateway integration
- Canvas host
- Voice wake

**iOS** (`apps/ios/`):
- Swift app
- Local WebSocket pairing
- Remote access over Tailscale

**Android** (`apps/android/`):
- Kotlin app

**Shared** (`apps/shared/`):
- Protocol models
- Pairing logic
- Credential storage

---

## 3. GATEWAY PROTOCOL

### WebSocket Frame Structure

**Connection Handshake**:

```json
// 1. Gateway sends challenge
{
  "type": "event",
  "event": "connect.challenge",
  "payload": { "nonce": "...", "ts": 1737264000000 }
}

// 2. Client responds with connect request
{
  "type": "req",
  "id": "unique-id",
  "method": "connect",
  "params": {
    "minProtocol": 3,
    "maxProtocol": 3,
    "client": { "id": "cli", "version": "1.2.3" },
    "role": "operator",
    "scopes": ["operator.read", "operator.write"],
    "auth": { "token": "..." },
    "device": {
      "id": "device_fingerprint",
      "publicKey": "...",
      "signature": "...",
      "nonce": "..."
    }
  }
}

// 3. Gateway responds with hello
{
  "type": "res",
  "id": "unique-id",
  "ok": true,
  "payload": {
    "type": "hello-ok",
    "protocol": 3,
    "features": { "methods": [...], "events": [...] },
    "auth": { "deviceToken": "...", "role": "operator" }
  }
}
```

**Request/Response Pattern**:
```json
// Request
{ "type": "req", "id": "uuid", "method": "health", "params": {} }

// Response
{ "type": "res", "id": "uuid", "ok": true, "payload": {...} }
// or
{ "type": "res", "id": "uuid", "ok": false, "error": "..." }
```

**Server-Push Events**:
```json
{ "type": "event", "event": "tick", "payload": {...} }
```

### Device Pairing & Authentication

**Trust Model**:
1. First connection requires explicit approval
2. Device signs challenge nonce with private key
3. Gateway issues device token
4. Subsequent connections use token
5. Device metadata pinned (changes require re-pair)

**Auth Modes**:
- `"token"` (default) - shared secret bearer token
- `"password"` - shared secret password
- `"trusted-proxy"` - Tailscale/proxy identity headers
- `"none"` - loopback only (no auth)

### Event Types

- `tick` - Heartbeat (15s default)
- `agent` - Agent run lifecycle + streaming
- `presence` - Online status
- `health` - Gateway health
- `chat` - Inbound messages
- `cron` - Scheduled automation
- `connect.challenge` - Auth challenge

---

## 4. AGENT RUNTIME (Pi)

### Session Lifecycle

```
1. Accept Phase
   ├─ Message arrives at Gateway
   ├─ Route to session (DM/group/cron)
   ├─ Create session if needed
   └─ Queue into session lane

2. Dispatch Phase
   ├─ Dequeue when lane available
   ├─ Load workspace + bootstrap
   ├─ Acquire session lock
   └─ Prepare system prompt

3. Execution Phase
   ├─ Build Pi session (model + auth)
   ├─ Invoke Pi agent loop
   ├─ Stream: tool/assistant deltas
   ├─ Enforce timeout
   └─ Return usage metadata

4. Completion Phase
   ├─ Serialize run results
   ├─ Emit lifecycle events
   ├─ Send channel replies
   └─ Update session history
```

### System Prompt Assembly

```
Base Prompt (OpenClaw)
+ Skills Prompt (loaded .md files)
+ Bootstrap Context (AGENTS.md, SOUL.md, etc.)
+ Session History (compacted if needed)
+ Per-Run Overrides
```

**Bootstrap Files** (in workspace):
- `AGENTS.md` - Operating instructions + memory
- `SOUL.md` - Persona, boundaries, tone
- `TOOLS.md` - Tool conventions
- `BOOTSTRAP.md` - First-run ritual
- `IDENTITY.md` - Agent name/vibe
- `USER.md` - User profile

### Tool Execution Flow

```
1. Model emits tool_use block
2. Validate params against schema
3. Hook: before_tool_call (plugins can block)
4. Execute tool (system/user/plugin)
5. Sanitize result (size limits)
6. Hook: after_tool_call
7. Persist to session
8. Next LLM invocation with result
```

**System Tools**:
- `read` - Read files (workspace-scoped)
- `write` - Create files
- `exec` - Run commands (approval gates)
- `edit` - Patch files
- `apply_patch` - Apply unified diff
- `message` - Send to channels (shared core tool)

**Approval System**:
- Owner-only tools require explicit approval
- Auto-approve for trusted patterns
- ACP (Automatic Capability Provisioning)

### Provider Transport Abstraction

**Supported Providers**:
- Anthropic (direct SDK)
- OpenAI (direct SDK)
- OpenRouter (HTTP bridge)
- Mistral, Groq, Perplexity (plugins)
- Local models (LM Studio, Ollama)
- Custom (self-hosted)

**Model Resolution**:
1. Parse model ref: `provider/model-id`
2. Resolve auth profile
3. Instantiate provider runtime
4. Stream inference with hooks
5. Normalize output (tools, stop, usage)

### LLM Invocation Point

**The actual LLM call happens at**:
- File: `src/agents/pi-embedded-runner/run/attempt.ts`
- Line: `2163`
- Code: `await activeSession.prompt(effectivePrompt, { images: imageResult.images })`

**Provider Transports**:
- `src/agents/anthropic-transport-stream.ts` - Anthropic SDK
- `src/agents/openai-transport-stream.ts` - OpenAI SDK
- Uses `@anthropic-ai/sdk` and `openai` packages

**Streaming Flow**:
```
activeSession.prompt()
    ↓
Provider Transport (anthropic/openai)
    ↓
HTTP Request to API
    ↓
Streaming Response (SSE)
    ↓
subscribeEmbeddedPiSession()
    ↓
Parse Events (text, tool_call, reasoning)
    ↓
Execute Tools
    ↓
activeSession.steer(toolResult)
    ↓
Loop until done
```

---

## 5. CHANNEL INTEGRATION

### Channel Plugin Loading

```
Discovery: openclaw.plugin.json manifest
    ↓
Manifest Validation
    ↓
Plugin Runtime Load: jiti import
    ↓
Register Channel: api.registerChannel(...)
    ↓
Inbound Routing: message → session
    ↓
Outbound: message.send() → channel adapter
```

### Message Ingestion

**Each Channel Implements**:
- Connection/Auth (OAuth, tokens)
- Polling/Webhooks (inbound delivery)
- Normalization (platform → OpenClaw format)
- Threading (bind to sessions)
- Media Handling (upload/download)

**Inbound Flow**:
1. Channel receives message
2. Normalize to ChatMessage type
3. Route by session binding
4. Queue with debounce/collect/steer
5. Trigger agent execution

### Response Delivery

**Outbound Flow**:
1. Agent completes
2. Build reply payloads
3. Apply channel formatting
4. De-duplicate tool sends
5. Send via channel adapter
6. Track delivery status

**Queue Modes**:
- `collect` - Hold until run completes
- `steer` - Inject during run
- `followup` - Start new run

### Multi-Channel Routing

**Session Binding**:

| Source | Binding |
|--------|---------|
| DM | Per-peer |
| Group | Per-group across channels |
| Cron | Fresh per-run |
| Webhook | Per-endpoint |

---

## 6. PLUGIN SYSTEM

### Plugin Manifest

```json5
{
  "id": "my-custom-tool",
  "name": "My Tool",
  "version": "1.0.0",
  "openclaw": {
    "plugin": {
      "kind": "tool",
      "capabilities": ["tools"],
      "entrypoint": "./dist/index.js"
    }
  }
}
```

### Plugin Loading

**Control Plane** (manifest-first):
1. Discover plugins
2. Read `openclaw.plugin.json`
3. Validate schema
4. Extract metadata
5. Activation planning

**Runtime** (lazy):
1. Import plugin module
2. Invoke `register(api)`
3. Register capabilities
4. Update registry

### Plugin Hooks

**Lifecycle**:
- `gateway_start` / `gateway_stop`
- `session_start` / `session_end`
- `agent_end`

**Model/Prompt**:
- `before_model_resolve`
- `before_prompt_build`
- `before_agent_reply`

**Execution**:
- `before_tool_call` / `after_tool_call`
- `tool_result_persist`

**Message**:
- `message_received`
- `message_sending`
- `message_sent`

---

## 7. SECURITY MODEL

### Trust Boundaries

**Trusted Operator Model**:
- One user per gateway
- Authenticated callers = trusted
- Loopback = full access
- No per-operator isolation

**Multi-User**: Separate VPS/user/gateway per person

### Pairing & Authentication

**Device Pairing**:
- Store: `~/.openclaw/pairing.jsonl`
- Track device IDs, public keys
- Detect metadata changes
- Revoke/supersede entries

**Challenge-Response**:
1. Client connects
2. Gateway sends nonce
3. Client signs with private key
4. Gateway verifies
5. Issue device token
6. Reuse token or re-auth

### Sandbox Execution

**Exec Tool Gating**:
- `tools.exec.policy` - Approval policy
- `agents.defaults.sandbox.mode` - Runtime mode
- Pattern matching for safe commands

**Sandbox Runtimes**:
- Docker containerization
- Host execution (fallback)
- Per-session workspace isolation

### Tool Permissions

**Owner-Only Tools**:
- System exec
- Canvas evaluation
- Direct node.invoke
- Host file operations

**Allowlist Control**:
- `channels.whatsapp.allowFrom`
- `tools.*.allowFrom`
- Message context filtering

---

## 8. DATA STORAGE

### Session Logs (JSONL)

**Location**: `~/.openclaw/agents/<agentId>/sessions/<sessionId>.jsonl`

**Format**:
```json
{"role":"user","content":"Hello","ts":1737264000000}
{"role":"assistant","content":"Hi!","ts":1737264001000}
{"role":"tool","toolName":"read","input":{...},"ts":...}
{"role":"tool","toolName":"read","output":"...","ts":...}
```

### Configuration Storage

**Gateway Config**: `~/.openclaw/openclaw.json`

```json5
{
  "gateway": { "port": 18789 },
  "agents": { "defaults": { "workspace": "..." } },
  "channels": { "whatsapp": { "allowFrom": [...] } },
  "plugins": { "enabled": [...] }
}
```

**Hot Reload**: Config changes trigger reload without restart

### Credential Management

**Location**: `~/.openclaw/credentials/`

- Channel credentials
- Provider API keys
- OAuth tokens

**Security**: Plaintext in `~/.openclaw` (OS-level security)

---

## 9. KEY DESIGN PATTERNS

### Error Handling

**Result-Based** (Zod validation):
```typescript
type Result<T, E> = 
  | { ok: true; data: T } 
  | { ok: false; error: E }
```

**Error Codes** (closed unions):
```typescript
type ToolError = 
  | { code: "permission_denied" }
  | { code: "file_not_found" }
  | { code: "timeout" }
```

### Async Patterns

**Queue System**:
- Per-session lanes (serialize runs)
- Global lane option
- Collect/steer/followup modes

**Event Streams** (RxJS-style):
```typescript
subscribeEmbeddedPiSession(session) 
  → Observable<Event>
```

### Event-Driven Architecture

**Hook System**:
1. Plugin registers handler
2. Gateway invokes at lifecycle point
3. Handler blocks, modifies, or chains
4. First to block wins

### Streaming Responses

**Block Streaming**:
- Emit text blocks as complete
- `text_end` or `message_end`
- Client-side chunking
- Coalescing to reduce spam

**Transport**:
```json
{ "type": "event", "event": "agent", 
  "payload": { "stream": "assistant", "delta": "Hello " } }
```

### Idempotency

**Side-Effecting Methods**:
- Require `idempotency_key`
- Gateway maintains dedupe cache
- Safe to retry

### State Management

**Immutable Config + Mutable Runtime**:
- Config read once, broadcast on change
- Runtime state mutable
- Incremental change notifications
- State versioning for staleness detection

---

## 10. FILE STRUCTURE

```
/src/
  /gateway/             - WebSocket server, orchestration
  /agents/              - Agent runtime, Pi integration
  /channels/            - Core channel implementation
  /plugins/             - Plugin loader, registry
  /plugin-sdk/          - Public plugin contract
  /config/              - Configuration loading
  /sessions/            - Session persistence
  /terminal/            - CLI UI components
  /utils/               - Shared helpers

/ui/                    - Web control UI
/apps/
  /macos/               - SwiftUI desktop app
  /ios/                 - Swift iOS app
  /android/             - Kotlin Android app
/docs/                  - Documentation
/extensions/            - Bundled plugins (60+)
/skills/                - Bundled skills
```

---

## KEY INSIGHTS

1. **Single Gateway Pattern**: One daemon per host controls all messaging and agent execution

2. **Plugin-First Extension**: 90% capabilities are plugins, core stays lean

3. **Manifest-First Discovery**: Plugin discovery from metadata without code execution

4. **Gateway Protocol as Contract**: WebSocket typed protocol = API stability

5. **Embedded Agent + Queue**: Single Pi runtime per session, queue prevents concurrency

6. **Channel Plugin Ownership**: Core has one shared `message` tool, channels own discovery

7. **Sandbox Opt-In**: Configurable per-session, host execution is default

8. **Credential Boundary**: Agent never sees credentials, gateway manages connections

9. **Lazy Plugin Loading**: Control plane on metadata, runtime on-demand

10. **Workspace = Chroot**: Agent workspace acts as container boundary

---

## SUMMARY

OpenClaw is a sophisticated gateway-centric AI orchestration system that provides:

1. **Multi-Channel Integration**: WhatsApp, Telegram, Slack, Discord, Signal, etc.
2. **Embedded Agent Runtime**: Pi core with tool execution
3. **Plugin Extensibility**: 60+ bundled plugins
4. **WebSocket Control Protocol**: Type-safe RPC
5. **Multi-Platform**: CLI, web, macOS, iOS, Android
6. **Local-First**: Runs on user devices
7. **Privacy-Focused**: Credentials isolated, sandbox support

The architecture prioritizes:
- **Reliability**: Gateway-centric control
- **Security**: Trust boundaries, device pairing
- **Extensibility**: Plugin system
- **Performance**: Lazy loading, hot reload
- **User Control**: Local execution, explicit approvals
