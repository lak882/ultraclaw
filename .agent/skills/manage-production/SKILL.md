---
name: manage-production
description: Operate a running IRIS Interoperability production. Use for starting, stopping, restarting, checking state, inspecting errors/traces, and managing lookup tables. Triggers on "start production", "stop production", "restart", "status", "errors", "trace", "lookup".
tools: [run_sql, xecute]
---

# manage-production

Lifecycle and operational inspection of a running production. For authoring production classes and business hosts, use the `production` skill.

## When to use

- Starting, stopping, or restarting a production.
- Checking which production is running and its state.
- Reloading config after editing a production class (`UpdateProduction`).
- Reading errors from `Ens_Util.Log`.
- Inspecting message traces.
- Reading or modifying lookup tables.

## Tool reference — production lifecycle

`Ens.Director` is the native API. Every snippet below runs through `xecute` (tool name `xecute`, prefix `exec:` for readability in this skill).

| Goal | How |
|---|---|
| Check state | `exec:` `Set sc=##class(Ens.Director).GetProductionStatus(.name,.state) Set stateStr=$Case(state,1:"Running",2:"Stopped",3:"Suspended",4:"Troubled",5:"NetworkStopped",:"-") Set %result=name_" | "_stateStr` |
| Start | `exec:` `Set sc=##class(Ens.Director).StartProduction("Demo.Production") Set %result=$Select($$$ISOK(sc):"Started",1:"Error: "_$System.Status.GetErrorText(sc))` |
| Stop | `exec:` `Set sc=##class(Ens.Director).StopProduction(30) Set %result=$Select($$$ISOK(sc):"Stopped",1:"Error: "_$System.Status.GetErrorText(sc))` |
| Restart | `exec:` `Set sc=##class(Ens.Director).RestartProduction(30) Set %result=$Select($$$ISOK(sc):"Restarted",1:"Error: "_$System.Status.GetErrorText(sc))` |
| Reload config (no stop) | `exec:` `Set sc=##class(Ens.Director).UpdateProduction() Set %result=$Select($$$ISOK(sc):"Updated",1:"Error: "_$System.Status.GetErrorText(sc))` |
| Stop + start (force) | `exec:` `Do ##class(Ens.Director).StopProduction(30,1) Set sc=##class(Ens.Director).StartProduction("Demo.Production") Set %result=$System.Status.GetErrorText(sc)` |

Increase the timeout (second arg to `StopProduction`) for productions with slow shutdowns. A `Troubled` production must be stopped before starting a new one.

## Tool reference — errors

`Ens_Util.Log.Type` is an integer: `2`=Error, `3`=Warning, `4`=Info, `6`=Alert.

| Goal | How |
|---|---|
| Recent errors (24h) | `run_sql`: `SELECT TOP 25 TimeLogged, Type, ConfigName, SessionId, Text FROM Ens_Util.Log WHERE Type IN (2,3,6) AND TimeLogged >= DATEADD('hour', -24, $Horolog) ORDER BY ID DESC` |
| Errors for one config item | `run_sql`: `SELECT TOP 25 TimeLogged, Type, Text FROM Ens_Util.Log WHERE Type IN (2,3,6) AND ConfigName = 'MyService' ORDER BY ID DESC` |
| Everything in last hour | `run_sql`: `SELECT ID, TimeLogged, Type, ConfigName, Text FROM Ens_Util.Log WHERE TimeLogged >= DATEADD('hour', -1, $Horolog) ORDER BY ID DESC` |

## Tool reference — traces

| Goal | How |
|---|---|
| 20 most recent | `run_sql`: `SELECT TOP 20 ID, SessionId, TimeCreated, SourceConfigName, TargetConfigName, MessageBodyClassName FROM Ens.MessageHeader ORDER BY ID DESC` |
| Filter by config item | `run_sql`: `SELECT TOP 20 ID, SessionId, TimeCreated, SourceConfigName, TargetConfigName FROM Ens.MessageHeader WHERE SourceConfigName = 'MyService' OR TargetConfigName = 'MyService' ORDER BY ID DESC` |
| Filter by session | `run_sql`: `SELECT ID, TimeCreated, SourceConfigName, TargetConfigName, MessageBodyClassName FROM Ens.MessageHeader WHERE SessionId = '1234' ORDER BY ID` |

## Tool reference — lookup tables

`Ens.Util.LookupTable` is the native API. Every operation has a native one-liner.

| Goal | How |
|---|---|
| List tables | `run_sql`: `SELECT DISTINCT TableName FROM Ens_Util.LookupTable ORDER BY TableName` |
| List keys in a table | `run_sql`: `SELECT KeyName, DataValue FROM Ens_Util.LookupTable WHERE TableName = 'MyTab' ORDER BY KeyName` |
| Get one key | `exec:` `Set %result = ##class(Ens.Util.LookupTable).GetValueAt("MyTab", "k1")` (native one-liner; returns "" on miss) |
| Set a key | `exec:` `Set lu=##class(Ens.Util.LookupTable).%New() Set lu.TableName="MyTab",lu.KeyName="k1",lu.DataValue="v1" Set sc=lu.%Save() Set %result=$System.Status.GetErrorText(sc)` |
| Clear a table | `exec:` `Do ##class(Ens.Util.LookupTable).%ClearTable("MyTab") Set %result="cleared"` |
| Import XML | `exec:` `Do ##class(Ens.Util.LookupTable).%Import("/path/to/file.xml") Set %result="imported"` |
| Export XML | `exec:` `Do ##class(Ens.Util.LookupTable).%Export("/path/to/file.xml","MyTab") Set %result="exported"` |

## Gotchas

- `GetProductionStatus` returns state codes (1-5), not strings. Translate with `$Case`.
- Always include `stateStr` or you'll log raw integers.
- `StopProduction` second arg is `pForce` (0 or 1). Use force only when a normal stop times out.
- Lookup table `%Save` on duplicate key errors with SQLCODE -119. Use `%DeleteId` on `TableName||KeyName` first if replacing.
- Event log timestamps use `$Horolog` (IRIS internal form). `DATEADD('hour', -N, $Horolog)` does the right thing in SQL.
- `Ens.MessageHeader.SessionId` is a string, quote it in SQL.
