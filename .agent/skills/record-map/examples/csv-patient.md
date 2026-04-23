# Example: CSV patient RecordMap

A simple delimited RecordMap for a patient CSV file with 10 comma-separated fields.

## Input sample

```
12345,Doe,John,19800101,M,123 MAIN ST,ANYTOWN,NY,12345,555-1234
12346,Smith,Jane,19900515,F,456 OAK AVE,METROPOLIS,NY,12346,555-5678
```

## RecordMap class

```objectscript
Class Demo.RecordMap.CSVPatient Extends EnsLib.RecordMap.RecordMap
{

XData RecordMap [ XMLNamespace = "http://www.intersystems.com/Ensemble/RecordMap" ]
{
<Record name="Demo.RecordMap.CSVPatient"
        targetClassname="Demo.Record.CSVPatient"
        type="delimited" char_encoding="UTF-8"
        paddedRecords="0" recordTerminator="\x0d\x0a">

  <Separators>
    <Separator>,</Separator>
  </Separators>

  <Field name="MRN"       required="1" datatype="%String" index="1"/>
  <Field name="LastName"  required="0" datatype="%String"/>
  <Field name="FirstName" required="0" datatype="%String"/>
  <Field name="DOB"       required="0" datatype="%String"/>
  <Field name="Gender"    required="0" datatype="%String"/>
  <Field name="Address"   required="0" datatype="%String"/>
  <Field name="City"      required="0" datatype="%String"/>
  <Field name="State"     required="0" datatype="%String"/>
  <Field name="Zip"       required="0" datatype="%String"/>
  <Field name="Phone"     required="0" datatype="%String"/>

</Record>
}

}
```

## Expected generated target class

After compile, `Demo.Record.CSVPatient` should have one property per field (`MRN`, `LastName`, etc.) and an index on `MRN`.

Verify:

```
exec: Set %result = ##class(%Dictionary.CompiledClass).%OpenId("Demo.Record.CSVPatient").Properties.Count()
```

Expect roughly 10 user properties (plus %-prefixed framework properties).

## Production wiring

```xml
<Item Name="CSVFileService" Category="Inbound"
      ClassName="EnsLib.RecordMap.Service.FileService"
      PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="FilePath">/data/patients/in/</Setting>
  <Setting Target="Adapter" Name="FileSpec">*.csv</Setting>
  <Setting Target="Adapter" Name="ArchivePath">/data/patients/archive/</Setting>
  <Setting Target="Host" Name="RecordMap">Demo.RecordMap.CSVPatient</Setting>
  <Setting Target="Host" Name="TargetConfigNames">CSVProcessor</Setting>
  <Setting Target="Host" Name="HeaderCount">1</Setting>
</Item>
```

The service emits one `Demo.Record.CSVPatient` message per line.
