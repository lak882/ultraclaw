---
name: iris-sql
description: Run SQL against IRIS using the `run_sql` tool. Covers the exact call contract (arguments, return shape, limits), the IRIS SQL dialect (TOP vs LIMIT, %STARTSWITH, %INLIST, %EXTERNAL, class-to-table mapping, $Horolog+DATEADD), and the canonical system-table queries. Load before writing any SQL statement, before calling `run_sql`, and before answering any question that needs data from IRIS. Triggers on "query", "run SQL", "SELECT", "count", "list classes", "how many", "show me rows from", "find classes that", "what's in Ens_Util.Log", "check event log", "inspect dictionary", "message headers", "traces", "messages in", "errors in", "when did", "who sent", "show recent", "event log", "lookup table", "production hosts", "property types", "class definitions", "disabled items", "warnings", "last hour", "last day", "count messages", "sample rows", "first N", "top N", "most recent", "oldest", "group by", "join on". Also load for any question that implies aggregating, filtering, or enumerating IRIS-resident data.
---

# iris-sql

Every SQL query against IRIS goes through the `run_sql` tool. This skill explains exactly how to call it and how to write the query.

## Calling the `run_sql` tool

### Arguments

| Arg | Type | Required | Default | Description |
|---|---|---|---|---|
| `sql` | string | yes | — | One SQL statement. No trailing semicolon. |
| `limit` | integer | no | 100 | Max rows for SELECT. Ignored for DML/DDL. Hard cap 1000 regardless of value. |

Minimal call: `{"sql": "SELECT TOP 5 Name FROM %Dictionary.ClassDefinition"}`.

Call with custom row limit: `{"sql": "SELECT Name FROM %Dictionary.ClassDefinition", "limit": 500}`.

### Return shape

SELECT queries return:
```json
{
  "kind": "select",
  "rows": [ {"col1": value, "col2": value}, ... ],
  "row_count": 23,
  "truncated": false
}
```

`truncated: true` means more rows existed than `limit` returned; re-run with a tighter `WHERE`, a higher `limit`, or aggregate with `COUNT(*)` first.

INSERT / UPDATE / DELETE / DDL return:
```json
{
  "kind": "exec",
  "sqlcode": 0,
  "row_count": 3,
  "message": "OK"
}
```

`sqlcode < 0` means failure; the error text surfaces directly as a plain string (not JSON) prefixed with `SQL error`.

### When NOT to use `run_sql`

Use `run_sql` for anything SQL-shaped. Fall back to `xecute` only when:
- the operation requires cursor iteration with per-row ObjectScript,
- the call is a class method, not a query,
- you need to switch namespace mid-operation with `ZN`.

## IRIS SQL dialect essentials

### Row limiting

IRIS uses `TOP n`, not `LIMIT n`:

```sql
SELECT TOP 10 Name FROM %Dictionary.ClassDefinition
```

`LIMIT` is not supported. The tool's `limit` parameter is separate; `TOP n` constrains the query itself and is the idiomatic form.

### Row identity

Every persistent row has an internal id exposed as `%ID`:

```sql
SELECT %ID AS id, Name FROM Ens.MessageHeader
```

### Date and time

`$Horolog` is the canonical internal current-time reference:

```sql
WHERE TimeCreated >= DATEADD('minute', -5, $Horolog)
```

`DATEADD(unit, n, ref)` and `DATEDIFF(unit, a, b)` take lowercase string units: `'minute'`, `'hour'`, `'day'`, `'week'`, `'month'`, `'year'`.

Display dates in human-readable form by wrapping with `%EXTERNAL`:

```sql
SELECT %EXTERNAL(TimeCreated) FROM Ens.MessageHeader
```

### Class-to-table mapping

A class `A.B.C` becomes table `A_B.C` — every dot except the last becomes an underscore.

| Class | Table |
|---|---|
| `Ens.MessageHeader` | `Ens.MessageHeader` |
| `Ens.Config.Item` | `Ens_Config.Item` |
| `Ens.Util.Log` | `Ens_Util.Log` |
| `InterClaw.ToolKit.Tool.RunSQL` | `InterClaw_ToolKit_Tool.RunSQL` |

When in doubt, look up with: `SELECT Name FROM %Dictionary.ClassDefinition WHERE Name LIKE 'Pkg.%'`.

### IRIS-specific operators

- `field %STARTSWITH 'foo'` — indexed prefix match. Prefer over `LIKE 'foo%'`.
- `field %PATTERN '3N1"-"3N1"-"4N'` — IRIS pattern match (N=numeric, A=alpha, U=upper, L=lower).
- `field %INLIST $LISTBUILD('a','b','c')` — `IN` for a %List value.
- `field %MATCHES 'pattern'` — case-insensitive glob.

### Case sensitivity

Identifiers are case-insensitive. String values and `LIKE` patterns are case-sensitive. Use `UPPER()` or `%MATCHES` for case-insensitive text matching:

```sql
WHERE UPPER(Name) = 'FOO'
WHERE Name %MATCHES 'foo*'
```

### Reserved-word columns

When a column name collides with a SQL keyword, prefix with underscore (the canonical IRIS convention) or wrap in double quotes:

```sql
-- %Dictionary.ParameterDefinition has a "Default" column; reserved word
SELECT parent, _Default AS Val FROM %Dictionary.ParameterDefinition
```

`%Dictionary` tables use a lowercase `parent` column, not `Parent`.

### Quoting

Escape a single quote inside a string literal by doubling it:

```sql
WHERE Name = 'O''Brien'
```

Double quotes wrap identifiers, not strings.

## System metadata tables

| Table | Key columns | Use for |
|---|---|---|
| `%Dictionary.ClassDefinition` | `Name`, `Super`, `Abstract`, `System`, `TimeChanged` | Class source definitions. Filter user code with `System = 0`. |
| `%Dictionary.CompiledClass` | `Name`, `Super` | Classes that compiled successfully. |
| `%Dictionary.PropertyDefinition` | `parent`, `Name`, `Type`, `Relationship` | Property metadata per class. |
| `%Dictionary.MethodDefinition` | `parent`, `Name`, `FormalSpec`, `ReturnType` | Method metadata per class. |
| `%Dictionary.ParameterDefinition` | `parent`, `Name`, `_Default`, `Type` | Parameter metadata per class. `Default` is reserved; use `_Default`. |
| `Ens_Config.Item` | `ClassName`, `Name`, `Enabled`, `PoolSize` | Hosts in a production (BS/BP/BO rows). |
| `Ens.MessageHeader` | `%ID`, `SessionId`, `SourceConfigName`, `TargetConfigName`, `MessageBodyClassName`, `Status`, `TimeCreated` | Every interop message. |
| `Ens.MessageBody` | `%ID` | Linked to `Ens.MessageHeader.MessageBodyId`. |
| `Ens_Util.Log` | `ID`, `TimeLogged`, `Type`, `ConfigName`, `SessionId`, `Text` | Event log. **`Type` is INTEGER**: 2=Error, 3=Warning, 4=Info, 5=Assert, 6=Alert. |
| `Ens_Util.LookupTable` | `TableName`, `KeyName`, `DataValue` | All lookup-table entries, all tables. |

## Canonical query recipes

### Production inspection

```sql
-- Every host in the running production
SELECT Name, ClassName, Enabled, PoolSize FROM Ens_Config.Item ORDER BY Name

-- Count disabled hosts
SELECT COUNT(*) AS DisabledCount FROM Ens_Config.Item WHERE Enabled = 0
```

### Message tracing

```sql
-- 20 newest messages
SELECT TOP 20 %ID AS Id, SessionId, %EXTERNAL(TimeCreated) AS When,
       SourceConfigName AS Src, TargetConfigName AS Tgt, MessageBodyClassName AS Body
  FROM Ens.MessageHeader ORDER BY ID DESC

-- Everything in one session
SELECT %ID AS Id, %EXTERNAL(TimeCreated) AS When, SourceConfigName, TargetConfigName
  FROM Ens.MessageHeader
 WHERE SessionId = '1234' ORDER BY ID

-- Messages touching one config item
SELECT TOP 30 %ID, SessionId, %EXTERNAL(TimeCreated), SourceConfigName, TargetConfigName
  FROM Ens.MessageHeader
 WHERE SourceConfigName = 'MyService' OR TargetConfigName = 'MyService'
 ORDER BY ID DESC
```

### Event log

```sql
-- Recent errors + warnings (24h)
SELECT TOP 25 %EXTERNAL(TimeLogged) AS When, Type, ConfigName, Text
  FROM Ens_Util.Log
 WHERE Type IN (2,3,6)
   AND TimeLogged >= DATEADD('hour', -24, $Horolog)
 ORDER BY ID DESC

-- Errors from a specific config item
SELECT TOP 25 %EXTERNAL(TimeLogged), Type, Text
  FROM Ens_Util.Log
 WHERE Type IN (2,3,6) AND ConfigName = 'MyService'
 ORDER BY ID DESC
```

### Class introspection

```sql
-- Classes in a package
SELECT Name FROM %Dictionary.ClassDefinition
 WHERE Name %STARTSWITH 'Demo.' AND System = 0
 ORDER BY Name

-- Properties of a class
SELECT Name, Type, Collection FROM %Dictionary.PropertyDefinition
 WHERE parent = 'Demo.Msg.PatientRequest'
 ORDER BY SequenceNumber

-- Methods of a class
SELECT Name, ReturnType, FormalSpec FROM %Dictionary.MethodDefinition
 WHERE parent = 'Demo.BP.Orchestrator'
 ORDER BY Name

-- Parameter values (note _Default, not Default)
SELECT parent AS ClassName, Name, _Default AS Val
  FROM %Dictionary.ParameterDefinition
 WHERE parent %STARTSWITH 'InterClaw.' ORDER BY parent, Name
```

### Lookup tables

```sql
-- List all tables
SELECT DISTINCT TableName FROM Ens_Util.LookupTable ORDER BY TableName

-- All keys in a table
SELECT KeyName, DataValue FROM Ens_Util.LookupTable
 WHERE TableName = 'MyTab' ORDER BY KeyName

-- One value
SELECT DataValue FROM Ens_Util.LookupTable
 WHERE TableName = 'MyTab' AND KeyName = 'k1'
```

## Critical constraints

- **No read-only guard.** DELETE, DROP, TRUNCATE execute immediately. `run_sql` does not sandbox destructive statements.
- **Row cap is 1000.** Regardless of `limit`, the tool will never return more than 1000 rows. Aggregate with `COUNT(*)` to confirm totals before paginating.
- **Streams/BLOBs error.** SELECTing a stream column fails with "Stream fields are not supported". Use `SUBSTRING(col, 1, N)` to get a prefix.
- **`Ens_Util.Log.Type` is INTEGER.** Query with `Type IN (2, 3)`, not `Type IN ('Error', 'Warning')`. Writing the query with strings silently returns zero rows.
- **Parameterizing table/column names is not possible.** Build those via string concatenation in the query itself; only values can be bind parameters.
- **One statement per call.** No semicolon-separated batches.

## Things to avoid

- `LIMIT n` — not supported. Use `TOP n`.
- `NOW()` inside `DATEADD` — use `$Horolog` instead.
- `SELECT *` on `Ens.MessageHeader` without `TOP` — the table is huge on busy systems.
- Matching `Status` or `Type` fields with string values when they are integers. When unsure, first run `SELECT DISTINCT Status FROM ...` and look at the values.
