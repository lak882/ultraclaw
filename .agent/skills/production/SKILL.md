---
name: production
description: Create and structure IRIS Interoperability productions. Use when authoring a production class, business services, processes, operations, or message classes. Triggers on "create production", "new service", "new process", "new operation", "add business host".
tools: [read_class, create_class, write_class, run_sql, xecute]
---

# production

Create an IRIS Interoperability production and its component classes.

## When to use

- Authoring a new production class from scratch.
- Adding a new business service, process, or operation.
- Creating request/response message classes.

For starting, stopping, checking state, or debugging a running production, use the `manage-production` skill instead.

## Tool reference

| Goal | How |
|---|---|
| Read an existing class | `read_class` � pass `classname` |
| Create a new class | `create_class` � pass full UDL body; compiles by default |
| Update an existing class | `write_class` � pass full UDL body; compiles by default |
| List classes in a package | `run_sql`: `SELECT Name FROM %Dictionary.ClassDefinition WHERE Name %STARTSWITH 'Pkg.' ORDER BY Name` |
| Reload production config after edits | `exec:` `Set sc=##class(Ens.Director).UpdateProduction() Set %result=$System.Status.GetErrorText(sc)` |

## References

| Asset | When to load |
|---|---|
| `references/production-class.md` | Production class structure, package naming, XDATA format, Item/Setting attributes |
| `references/services.md` | Business service hierarchy, OnProcessInput, adapters, SendRequest patterns |
| `references/operations.md` | Business operation hierarchy, MessageMap XDATA, retry/error handling |
| `references/processes.md` | Business process and BPL reference, BPL vs code-based decision |
| `references/messages.md` | Request/response message class structure, property types, HL7 virtual document paths |
| `references/pitfalls.md` | Production-specific gotchas � load during review |

Load via `read_file` with the absolute path: `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/production/references/<name>.md`.

## Templates

| Asset | Purpose |
|---|---|
| `templates/production.cls.template` | Starter production class with XDATA shell |
| `templates/service.cls.template` | Custom business service stub |
| `templates/operation.cls.template` | Custom business operation stub with MessageMap |
| `templates/process.cls.template` | Code-based business process stub (rare � prefer BPL) |
| `templates/message-request.cls.template` | Request message class stub |
| `templates/message-response.cls.template` | Response message class stub |

## Authoring checklist

1. Load `references/production-class.md` for structure and naming.
2. Identify built-in vs custom components.
3. For each custom service, load `references/services.md`; pick adapter.
4. For orchestration, load `references/processes.md`; default to BPL.
5. For custom operations, load `references/operations.md`.
6. For custom message classes, load `references/messages.md`.
7. Load `references/pitfalls.md` before pushing.
8. After pushing, reload config with the `UpdateProduction` xecute above.
