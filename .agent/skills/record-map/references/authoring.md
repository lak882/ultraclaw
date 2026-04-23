# Record Maps Reference

Record Maps define how to parse and create fixed-width or delimited flat files. They generate ObjectScript classes that map file records to objects.

## Class Hierarchy

```
EnsLib.RecordMap.RecordMap
  └── Your.Custom.RecordMap

Generated classes:
  EnsLib.RecordMap.Base
    └── Your.RecordMap.Record      (generated persistent class per record type)

Services/Operations:
  EnsLib.RecordMap.Service.Standard
    ├── EnsLib.RecordMap.Service.FileService       (read files)
    └── EnsLib.RecordMap.Service.FTPService         (read from FTP)
  EnsLib.RecordMap.Operation.Standard
    ├── EnsLib.RecordMap.Operation.FileOperation    (write files)
    └── EnsLib.RecordMap.Operation.FTPOperation     (write to FTP)
  EnsLib.RecordMap.Service.BatchFileService          (batch/multi-record)
  EnsLib.RecordMap.Operation.BatchFileOperation       (batch write)
```

## How Record Maps Work

1. Define a Record Map class that describes the file layout (field positions, delimiters).
2. IRIS generates a persistent class with properties matching each field.
3. A RecordMap Service reads files and creates record objects.
4. A RecordMap Operation writes record objects back to files.

## Delimited Record Map

```objectscript
Class MyApp.RecordMap.CSVPatient Extends EnsLib.RecordMap.RecordMap
{

XData RecordMap [ XMLNamespace = "http://www.intersystems.com/recordmap" ]
{
<Record name="MyApp.RecordMap.CSVPatient"
        targetClassname="MyApp.Record.CSVPatient"
        type="delimited" char_encoding="UTF-8"
        paddedRecords="0" recordTerminator="\x0d\x0a" allowEarlyTerminator="0">

  <Separators>
    <Separator>,</Separator>
  </Separators>

  <Field name="MRN" required="0" datatype="%String" index="1"/>
  <Field name="LastName" required="0" datatype="%String"/>
  <Field name="FirstName" required="0" datatype="%String"/>
  <Field name="DOB" required="0" datatype="%Date"/>
  <Field name="Gender" required="0" datatype="%String"/>
  <Field name="Address" required="0" datatype="%String"/>
  <Field name="City" required="0" datatype="%String"/>
  <Field name="State" required="0" datatype="%String"/>
  <Field name="Zip" required="0" datatype="%String"/>
  <Field name="Phone" required="0" datatype="%String"/>

</Record>
}

}
```

## Fixed-Width Record Map

```objectscript
Class MyApp.RecordMap.FixedPatient Extends EnsLib.RecordMap.RecordMap
{

XData RecordMap [ XMLNamespace = "http://www.intersystems.com/recordmap" ]
{
<Record name="MyApp.RecordMap.FixedPatient"
        targetClassname="MyApp.Record.FixedPatient"
        type="fixedwidth" char_encoding="UTF-8"
        paddedRecords="1" recordTerminator="\x0d\x0a" padFromLeft="0">

  <Field name="RecordType" required="1" datatype="%String" width="2"/>
  <Field name="MRN" required="1" datatype="%String" width="20"/>
  <Field name="LastName" required="0" datatype="%String" width="30"/>
  <Field name="FirstName" required="0" datatype="%String" width="30"/>
  <Field name="DOB" required="0" datatype="%String" width="8"/>
  <Field name="Gender" required="0" datatype="%String" width="1"/>

</Record>
}

}
```

## Field Attributes

| Attribute | Description |
|-----------|-------------|
| `name` | Property name in the generated class |
| `required` | Whether the field must have a value |
| `datatype` | ObjectScript data type (`%String`, `%Date`, `%Integer`, etc.) |
| `width` | Field width (fixed-width only) |
| `index` | Create an index on this field (1=yes) |

## Record Attributes

| Attribute | Description |
|-----------|-------------|
| `name` | The record-map classname itself, NOT the generated target. Must match the enclosing `Class` name. |
| `targetClassname` | Required. Dotted name of the persistent class IRIS generates. Must differ from `name`. |
| `type` | `delimited` or `fixedwidth` |
| `char_encoding` | Character encoding (`UTF-8`, `Latin1`, etc.) |
| `recordTerminator` | Line ending (`\x0d\x0a` = CRLF, `\x0a` = LF) |
| `paddedRecords` | Pad fixed-width records to full width |
| `padFromLeft` | Pad from left instead of right |
| `allowEarlyTerminator` | Allow the record terminator before all fields are read |

## Gotchas when the target class does not generate

Compiling a Record Map class does NOT always surface generation problems. The record-map class can compile clean while the persistent target class is never produced. Watch for these:

1. **`name` vs `targetClassname` confusion.** `<Record name="...">` is the record-map classname. If you omit `targetClassname` or point both at the same class, the generator aborts with `ERROR #5768: Class 'MyApp.RecordMap.Foo' already exists`. Fix: always set `targetClassname` to a distinct class.

2. **Missing `targetClassname` triggers error #5659** at generation time, not during normal compile. If the target class does not appear, force generation and inspect the status.

3. **Force target-class generation**:
   ```
   exec: Set tSC=##class(EnsLib.RecordMap.Generator).GenerateObject("MyApp.RecordMap.Foo", .tTarget) Set %result=$System.Status.GetErrorText(tSC)
   ```
   Use `GenerateObject` (resolves target from the XData). Do not call `generateClass` directly; it expects an already-resolved target classname.

4. **Verify the target class actually has properties** (zero-property target means generation silently skipped fields):
   ```sql
   SELECT Name, Type FROM %Dictionary.CompiledProperty
   WHERE parent = 'MyApp.Record.Foo' AND Name NOT %STARTSWITH '%'
   ```

## Generated Class

When you compile a Record Map, IRIS generates a persistent class (named by `targetClassname`) with:
- A property for each `<Field>`
- An index for each field with `index="1"`
- `%OnNew()` and related methods for object creation
- `GetObject()` and `PutObject()` for serialization

## Using in a Production

### File Service (read files)

```xml
<Item Name="CSVFileService" Category="Inbound" ClassName="EnsLib.RecordMap.Service.FileService" PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="FilePath">/data/inbound/</Setting>
  <Setting Target="Adapter" Name="FileSpec">*.csv</Setting>
  <Setting Target="Adapter" Name="ArchivePath">/data/archive/</Setting>
  <Setting Target="Host" Name="RecordMap">MyApp.RecordMap.CSVPatient</Setting>
  <Setting Target="Host" Name="TargetConfigNames">CSVProcessor</Setting>
  <Setting Target="Host" Name="HeaderCount">1</Setting>
</Item>
```

### File Operation (write files)

```xml
<Item Name="CSVFileWriter" Category="Outbound" ClassName="EnsLib.RecordMap.Operation.FileOperation" PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="FilePath">/data/outbound/</Setting>
  <Setting Target="Host" Name="RecordMap">MyApp.RecordMap.CSVPatient</Setting>
  <Setting Target="Host" Name="Filename">output_%Q.csv</Setting>
</Item>
```

### Batch Processing

For files with multiple records, use batch services:

```xml
<Item Name="BatchCSVService" Category="Inbound" ClassName="EnsLib.RecordMap.Service.BatchFileService" PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="FilePath">/data/inbound/</Setting>
  <Setting Target="Adapter" Name="FileSpec">*.csv</Setting>
  <Setting Target="Host" Name="RecordMap">MyApp.RecordMap.CSVPatient</Setting>
  <Setting Target="Host" Name="TargetConfigNames">BatchProcessor</Setting>
  <Setting Target="Host" Name="HeaderCount">1</Setting>
</Item>
```

The batch service sends an `EnsLib.RecordMap.BatchRequest` containing all records from one file.

## Accessing Record Data in a Process

The process receives the target class (the generated one), not the record-map class:

```objectscript
Method OnRequest(pRequest As MyApp.Record.CSVPatient, Output pResponse As Ens.Response) As %Status
{
    Set tSC = $$$OK
    Set tMRN = pRequest.MRN
    Set tName = pRequest.LastName _ ", " _ pRequest.FirstName
    // build HL7 or other output
    Return tSC
}
```

## HealthShare Use Case

Common pattern: receive CSV/flat files from facilities, parse via RecordMap, transform to SDA3 or HL7, push to the Hub.

```
[CSV File Drop] -> [RecordMap Service] -> [Transform Process (RecordMap -> HL7/SDA3)] -> [Hub Operation]
```
