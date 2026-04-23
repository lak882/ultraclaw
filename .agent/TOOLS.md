---
description: Catalog of tools registered under InterClaw.ToolKit.Tool on the ULTRACLAW namespace.
---

# TOOLS

Tools registered under the `InterClaw.ToolKit.Tool` package on the `interclaw-test` instance, `ULTRACLAW` namespace. Each tool extends `InterClaw.ToolKit.Base` and declares a `ToolName`, `ToolDescription`, and an `XData ToolInputSchema` block that Claude sees at every turn. Invocation flows through `InterClaw.BO.ToolOperation`, which dispatches by `ToolName` and returns the result string as a `tool_result` block.

## Catalog

| Tool Name | Class | Purpose |
|-----------|-------|---------|
| `echo` | `InterClaw.ToolKit.Tool.Echo` | Return the input text verbatim. Used to verify the tool pipeline is reachable. |
| `run_sql` | `InterClaw.ToolKit.Tool.RunSQL` | Execute any SQL statement in the current namespace. SELECT returns up to `limit` rows as JSON; DML and DDL return a status object. No read-only guard. |
| `xecute` | `InterClaw.ToolKit.Tool.Xecute` | Execute arbitrary ObjectScript via the `XECUTE` command. Assign to `result` inside the snippet to return a value. |
| `read_class` | `InterClaw.ToolKit.Tool.Class.Read` | Return the UDL source of an existing IRIS class. Same format that `create_class` and `write_class` accept. |
| `create_class` | `InterClaw.ToolKit.Tool.Class.Create` | Create a brand-new IRIS class from a UDL body. Fails if the class already exists or if the body declares a different class name. |
| `write_class` | `InterClaw.ToolKit.Tool.Class.Write` | Replace the full body of an existing IRIS class. Refuses to create new classes. |
| `delete_class` | `InterClaw.ToolKit.Tool.Class.Delete` | Permanently delete an IRIS class. Definition and compiled code both go. Irreversible. |
| `read_file` | `InterClaw.ToolKit.Tool.File.Read` | Read a text file by absolute path. Capped at 256 KB; larger files are truncated. |
| `create_file` | `InterClaw.ToolKit.Tool.File.Create` | Create a new file at an absolute path. Fails if the file already exists. Parent directory must already exist. |
| `write_file` | `InterClaw.ToolKit.Tool.File.Write` | Replace the contents of an existing file. Refuses to create new files. |
| `delete_file` | `InterClaw.ToolKit.Tool.File.Delete` | Delete a file at the given absolute path. Refuses to delete directories. Irreversible. |

## Input Schemas

### echo

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `text` | string | yes | String to echo back. |

### run_sql

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sql` | string | yes | A single SQL statement. No trailing semicolon required. |
| `limit` | integer | no | Maximum rows returned for SELECT. Default 100, hard cap 1000. |

### xecute

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `code` | string | yes | ObjectScript source to execute. Assign to `result` inside the snippet to return a value. |

### read_class

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `classname` | string | yes | Dotted class name to read. |

### create_class

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `classname` | string | yes | Dotted class name. Must match the `Class <name>` line in `body`. |
| `body` | string | yes | Full UDL class body. Must start with `Class <name> Extends ...`. |
| `compile` | boolean | no | Compile after load. Default true. |

### write_class

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `classname` | string | yes | Dotted class name. Must already exist and match `Class <name>` in `body`. |
| `body` | string | yes | Full replacement UDL body. |
| `compile` | boolean | no | Compile after load. Default true. |

### delete_class

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `classname` | string | yes | Dotted class name to delete. |

### read_file

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | yes | Absolute file path. |

### create_file

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | yes | Absolute file path. Must not already exist. |
| `body` | string | yes | Initial file contents. Empty string is valid. |

### write_file

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | yes | Absolute file path. Must already exist. |
| `body` | string | yes | Full replacement contents. |

### delete_file

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | yes | Absolute path to the file to delete. Must be a file, not a directory. |

## Notes

- All tools return plain strings. When a tool needs to return structured data, it returns a JSON string the caller is expected to parse.
- Tools are namespace-aware: `InterClaw.ToolKit.Base.Run()` can switch namespaces before invoking `Execute()` and reverts afterwards.
- The file tools and class tools run as the IRIS process user; there is no path or namespace allow-list. Callers are trusted.
- `run_sql` and `xecute` both execute arbitrary code paths. Use the most specific tool available before falling back to either.
