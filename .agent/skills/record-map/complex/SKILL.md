---
name: record-map/complex
description: Author Complex Record Maps in IRIS. Use when a flat file contains multiple record types in one file (header + detail + trailer, or nested groups), not a single record type repeated. Builds on existing RecordMap classes. Triggers on "complex record map", "batch file with header", "multi-record file", "ComplexMap", "header and trailer record", "nested record groups".
---

# record-map/complex

A Complex Record Map assembles several existing RecordMap classes into one batch structure: an optional header record, a sequence of body records (some required, some optional, some repeating), and an optional trailer. Use it when one file contains more than one record type. Use a plain RecordMap (parent `record-map` skill) when the file is one record type repeated.

## Prerequisite

Every record type that will appear in the batch must already exist as its own `EnsLib.RecordMap.RecordMap` class. The Complex Map references those classes by name in `recordMap="..."` attributes. Author the child RecordMaps first (see parent `record-map` skill), then assemble them here.

## Class shape

```
Class MyApp.RecordMap.OrderBatch Extends EnsLib.RecordMap.ComplexMap
{
Parameter BATCHCLASS = "MyApp.Record.OrderBatch";

XData ComplexBatch [ XMLNamespace = "http://www.intersystems.com/Ensemble/RecordMap" ]
{
<ComplexBatch name="MyApp.RecordMap.OrderBatch"
              targetClassname="MyApp.Record.OrderBatch"
              char_encoding="UTF-8">
  <Header name="Hdr" recordMap="MyApp.RecordMap.OrderHeader"/>
  <RecordSequence name="Orders" required="true" repeating="true" minRepeats="1" maxRepeats="0">
    <RecordReference name="Order" recordMap="MyApp.RecordMap.OrderLine" required="true"/>
    <RecordReference name="Discount" recordMap="MyApp.RecordMap.OrderDiscount" required="false" repeating="true"/>
  </RecordSequence>
  <Trailer name="Tlr" recordMap="MyApp.RecordMap.OrderTrailer"/>
</ComplexBatch>
}
}
```

Two things differ from a plain RecordMap:

| Plain RecordMap | Complex Map |
|---|---|
| Extends `EnsLib.RecordMap.RecordMap` | Extends `EnsLib.RecordMap.ComplexMap` |
| XData block named `RecordMap` | XData block named `ComplexBatch` |
| Root element `<Record>` with `<Field>` children | Root element `<ComplexBatch>` with `<Header>`, `<RecordSequence>`, `<RecordReference>`, `<Trailer>` children |
| XML namespace `http://www.intersystems.com/recordmap` | XML namespace `http://www.intersystems.com/Ensemble/RecordMap` (note the `Ensemble/` segment) |

Also set the `BATCHCLASS` parameter to the same value as `targetClassname`. IRIS reads it during generation and delete.

## ComplexBatch attributes

| Attribute | Required | Notes |
|---|---|---|
| `name` | yes | The Complex Map classname itself. Must match the enclosing `Class` declaration. |
| `targetClassname` | yes | Distinct persistent class IRIS generates as a subclass of `EnsLib.RecordMap.ComplexBatch`. |
| `char_encoding` | no | Defaults to `UTF-8`. |
| `annotation` | no | Free-text description, appears as class comment. |

## Child elements

| Element | Purpose | Key attributes |
|---|---|---|
| `<Header>` | Optional single record at the start of the file | `name`, `recordMap` |
| `<Trailer>` | Optional single record at the end of the file | `name`, `recordMap` |
| `<RecordReference>` | One record type in the body | `name`, `recordMap`, `required`, `repeating`, `minRepeats`, `maxRepeats` |
| `<RecordSequence>` | A group of records that occur together; can nest | `name`, `required`, `repeating`, `minRepeats`, `maxRepeats`; contains `<RecordReference>` and/or nested `<RecordSequence>` |

`required`, `repeating` are `"true"`/`"false"`. `minRepeats="0" maxRepeats="0"` on a repeating element means unbounded. A non-repeating element must have both `minRepeats` and `maxRepeats` omitted (or zero).

## Identifier requirement

The parser tells one record type from another by a leading identifier (a fixed literal at the start of the record, defined via `<RecordIdentifier>` in the child RecordMap's `<Record>` block). A Complex Map will fail validation if:

- Any non-required or repeating `<RecordReference>` points at a RecordMap with no identifier. The parser needs the identifier to decide whether the next line belongs to this element or the next one.
- Two adjacent elements have the same identifier (a collision; the parser cannot distinguish them).

If validation complains about missing identifiers, add a `<RecordIdentifier>` to the child RecordMap before re-pushing the Complex Map.

## Tool reference

| Goal | How |
|---|---|
| Read existing Complex Map | `read_class` on the Complex Map classname |
| Create | `create_class` with the full UDL body |
| Update | `write_class` with the full UDL body |
| Force target-class generation | `exec:` `Set tSC = ##class(EnsLib.RecordMap.ComplexGenerator).Generate("MyApp.RecordMap.OrderBatch") Set %result = $System.Status.GetErrorText(tSC)` |
| Inspect generated target class | `read_class` on the `targetClassname` (generated subclass of `EnsLib.RecordMap.ComplexBatch`) |
| Delete cleanly | `exec:` `Set tSC = ##class(EnsLib.RecordMap.ComplexMap).DeleteComplexMap("MyApp.RecordMap.OrderBatch",1,1) Set %result = $System.Status.GetErrorText(tSC)` (removes target class and extent too) |

## Authoring checklist

1. Confirm every referenced child RecordMap exists and, if it will be optional or repeating, has a `<RecordIdentifier>`.
2. Pick a `targetClassname` distinct from the Complex Map classname (convention: `Pkg.RecordMap.Foo` and `Pkg.Record.Foo`).
3. Set the `BATCHCLASS` parameter equal to `targetClassname`.
4. Assemble the `<ComplexBatch>` XData with `<Header>`, body elements, `<Trailer>`.
5. For each body element, decide `required` and `repeating`, set `minRepeats`/`maxRepeats` only when `repeating="true"`.
6. Push with `create_class` / `write_class`.
7. If wiring into a production, use the `ComplexBatch` service and operation variants (see below).

## Production wiring

Complex Maps use their own service and operation classes, not the plain-RecordMap ones:

| Direction | Class |
|---|---|
| Inbound file | `EnsLib.RecordMap.Service.ComplexBatchFileService` |
| Inbound FTP | `EnsLib.RecordMap.Service.ComplexBatchFTPService` |
| Outbound file | `EnsLib.RecordMap.Operation.ComplexBatchFileOperation` |
| Outbound FTP | `EnsLib.RecordMap.Operation.ComplexBatchFTPOperation` |

The host setting is `ComplexMap` (not `RecordMap`). Set it to the Complex Map classname, not the target.

```xml
<Item Name="OrderBatchService" Category="Inbound"
      ClassName="EnsLib.RecordMap.Service.ComplexBatchFileService"
      PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="FilePath">/data/inbound/</Setting>
  <Setting Target="Adapter" Name="FileSpec">*.dat</Setting>
  <Setting Target="Host" Name="ComplexMap">MyApp.RecordMap.OrderBatch</Setting>
  <Setting Target="Host" Name="TargetConfigNames">OrderProcessor</Setting>
</Item>
```

The service sends one message per file: an instance of the generated `BATCHCLASS`, carrying the header, all body records, and the trailer as typed properties.

## Key gotchas

- XData block is `ComplexBatch`, not `RecordMap`. XML namespace is `http://www.intersystems.com/Ensemble/RecordMap`, not the plain-RecordMap namespace. Using the wrong namespace causes silent XData parse failure with no properties generated.
- Set `BATCHCLASS` parameter. Without it, `DeleteComplexMap` cannot find the target to clean up, and some generator paths skip target creation.
- Identifiers are a hard requirement for optional or repeating children. The error message names the offending child RecordMap; fix that RecordMap's `<RecordIdentifier>`, then re-push.
- Production host setting is `ComplexMap`, not `RecordMap`. Using the wrong setting name fails with a host-startup error.
