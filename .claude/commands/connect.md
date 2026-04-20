---
allowed-tools: Bash, Read
description: Connect to an InterSystems IRIS server and test connectivity.
---

Connect to an InterSystems IRIS server using the Atelier REST API.

Usage: /connect <server-name> [namespace]

## Argument parsing

Parse "$ARGUMENTS": first word = server name, second word (optional) = namespace.

If no password in `config/servers.json` for this server, ask the user before proceeding.

## Execution

### Step 1: Test connection

```bash
<python> .claude/skills/interclaw/scripts/connection/test_connection.py --server <server-name> [--namespace <namespace>]
```

Display output verbatim (connection status, IRIS version, available namespaces).

### Step 2: Query instance identity

```bash
<python> .claude/skills/interclaw/scripts/connection/instance_id.py --server <server-name> --config config/servers.json
```

Display `instanceId` and `uniqueInstanceName`. If `status` is `"created"`, note that a new instance ID was generated.

### Step 3: Report

If connection succeeded: "Ready to work in {NAMESPACE} on {server} (instance: {uniqueInstanceName}, ID: {instanceId})."

### Step 4: Notify the frontend of the active namespace

If the user specified a namespace (or you derived one from the instance), emit a directive line on its own row so the shell can update the top-right namespace label and reload the Portal / Skills iframes under the new namespace:

```
/namespace {NAMESPACE}
```

The frontend scans assistant output for `/namespace <NS>` (line must start with `/namespace ` and be otherwise empty apart from the NS token and a trailing punctuation like a period). When detected, it dispatches `interclaw-namespace-change` so the header, tab hrefs, sessionStorage, and iframes all follow. Skip this step if you did not switch namespace.
