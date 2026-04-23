# Production Pitfalls

Production-specific gotchas to verify before and after pushing. Load during review.

## Single Production Per POC

All exercises in a multi-exercise POC share one production class (`<Pkg>.Production`). Never create separate productions per exercise. Use the `Category` attribute on each `<Item>` to group hosts by exercise:

```xml
<Item Name="Build1.ADTService" Category="Build 1 - ADT to SDA3" ...>
<Item Name="Build2.ORUService" Category="Build 2 - ORU to Lab" ...>
```

## HL7 Routing Engine Class

For HL7 productions, always use `EnsLib.HL7.MsgRouter.RoutingEngine`, not the generic `EnsLib.MsgRouter.RoutingEngine`. The generic class does not understand HL7 virtual document paths in routing rule conditions.

```xml
<!-- Correct -->
<Item ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" ...>

<!-- Wrong — will not evaluate HL7 field conditions correctly -->
<Item ClassName="EnsLib.MsgRouter.RoutingEngine" ...>
```

## HTTP Service: EnableStandardRequests Is a Host Setting

`EnableStandardRequests` is a `Target="Host"` setting, not `Target="Adapter"`. Using `Target="Adapter"` causes a silent HTTP 500 with no meaningful error.

```xml
<!-- Correct -->
<Setting Target="Host" Name="EnableStandardRequests">1</Setting>

<!-- Wrong — silent HTTP 500 -->
<Setting Target="Adapter" Name="EnableStandardRequests">1</Setting>
```

Also use `PoolSize=0` for HTTP services.

## Stop Production Before Deleting Classes

Deleting classes while the production is running causes components to enter Suspended state. Always stop the production before deleting or replacing classes that are referenced by active items.

## BPL Is the Default

Never create a code-based BP (`Ens.BusinessProcess`) for orchestration when BPL (`Ens.BusinessProcessBPL`) will do the job. BPL activities appear as named steps in Visual Trace; code-based BPs show as a single opaque block. See the `processes` reference for the full decision guide.

## Verify Wiring Before Starting

After pushing all classes and before starting the production, verify that every referenced class and item name resolves. Read the production XDATA first with `run_sql` (`SELECT Source FROM %Dictionary.ClassDefinition WHERE Name='MyPkg.Production'`), then verify references with these queries:

```sql
-- Confirm every ClassName in the production is compiled
SELECT Name, Compiled
FROM %Dictionary.CompiledClass
WHERE Name IN ('MyPkg.BS.ADTService', 'EnsLib.HL7.MsgRouter.RoutingEngine', ...)
```

```sql
-- Inspect all configured items and their class names
SELECT Name, ClassName, Enabled
FROM Ens_Config.Item
WHERE Production = 'MyPkg.Production'
```

Cross-reference `TargetConfigNames` and `BusinessRuleName` values from the production XDATA (read with `get_doc`) against the `Name` column of the second query. Any value that does not appear as an existing item name is a dangling reference that will cause a runtime error.

## Always Start Production After Building

After verifying wiring, start the production using `manage_production`:

```json
{"action":"start","production":"MyPkg.Production"}
```

Verify it is running with `production_status`, then send a test message with `send_hl7` and confirm routing with `trace`. Check `get_errors` if anything looks wrong.

## Routing Rule Constraints vs Conditions

Use `<constraint>` for message type filtering in routing rules, not `HL7.{MSH:MessageType.MessageCode}` conditions. Constraints are evaluated before the rule engine processes conditions and are more efficient.

```xml
<!-- Correct: filter by message type via constraint -->
<constraint name="docName" value="ADT_A01"/>
<when condition="1">...</when>

<!-- Wrong: filtering by message type in a condition -->
<when condition='HL7.{MSH:MessageType.MessageCode}="ADT"'>...</when>
```

## POC Productions: Business Logic Only

Do not add infrastructure components (alerting, error handlers, dead-letter queues) to a POC production unless the spec explicitly requires them. Keep it to services, processes, operations, routing, and transforms.
