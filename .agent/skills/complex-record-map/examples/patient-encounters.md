# Example: Patient + Encounters ComplexMap

Minimum-viable ComplexMap showing the header/body/trailer pattern with a repeating parent-child group.

## Input file shape

```
HDR|20260423|POC|test-batch-001
PAT|MRN001|Doe|John|19800101|M
ENC|E001|MRN001|20260401|Routine
ENC|E002|MRN001|20260415|FollowUp
PAT|MRN002|Smith|Jane|19900515|F
ENC|E003|MRN002|20260410|Urgent
TRL|3|2
```

One header. Repeated Patient groups, each with N Encounter lines. One trailer.

## Prerequisite sub-RecordMaps

Each record type gets its own RecordMap with `RecordInComplexMap = 1` and `LeadingData`. Skeleton for one:

```objectscript
Class Demo.RecordMap.PATLine Extends EnsLib.RecordMap.RecordMap
{

Parameter RecordInComplexMap = 1;

XData RecordMap [ XMLNamespace = "http://www.intersystems.com/Ensemble/RecordMap" ]
{
<Record name="Demo.RecordMap.PATLine"
        targetClassname="Demo.Record.PATLine"
        type="delimited" char_encoding="UTF-8"
        LeadingData="PAT|">
  <Separators>
    <Separator>|</Separator>
  </Separators>
  <Field name="Tag"       required="1" datatype="%String"/>
  <Field name="MRN"       required="1" datatype="%String"/>
  <Field name="LastName"  required="0" datatype="%String"/>
  <Field name="FirstName" required="0" datatype="%String"/>
  <Field name="DOB"       required="0" datatype="%String"/>
  <Field name="Gender"    required="0" datatype="%String"/>
</Record>
}

}
```

Repeat for `HDRLine` (`LeadingData="HDR|"`), `ENCLine` (`LeadingData="ENC|"`), `TRLLine` (`LeadingData="TRL|"`).

## ComplexMap class

```objectscript
Class Demo.RecordMap.ComplexMap.PatientEncounters Extends EnsLib.RecordMap.ComplexMap
{

Parameter BATCHCLASS = "Demo.RecordMap.ComplexMap.PatientEncountersBatch";
Parameter RECORDMAPGENERATED = 1;

XData ComplexBatch [ XMLNamespace = "http://www.intersystems.com/Ensemble/RecordMap" ]
{
<ComplexBatch xmlns="http://www.intersystems.com/Ensemble/RecordMap"
              name="Demo.RecordMap.ComplexMap.PatientEncounters"
              char_encoding="UTF-8"
              targetClassname="Demo.RecordMap.ComplexMap.PatientEncountersBatch">

  <Header>
    <RecordReference name="FileHeader" required="1" repeating="0"
                     recordMap="Demo.RecordMap.HDRLine"/>
  </Header>

  <RecordSequence name="Patients" required="1" repeating="1">
    <RecordReference name="Patient" required="1" repeating="0"
                     recordMap="Demo.RecordMap.PATLine"/>
    <RecordReference name="Encounter" required="0" repeating="1"
                     recordMap="Demo.RecordMap.ENCLine"/>
  </RecordSequence>

  <Trailer>
    <RecordReference name="FileTrailer" required="1" repeating="0"
                     recordMap="Demo.RecordMap.TRLLine"/>
  </Trailer>
</ComplexBatch>
}

}
```

## Generate the batch class

After pushing the ComplexMap source:

```
exec: Set sc = ##class(EnsLib.RecordMap.ComplexGenerator).Generate("Demo.RecordMap.ComplexMap.PatientEncounters") Set %result = $System.Status.GetErrorText(sc)
```

Verify the batch class got properties:

```
exec: Set %result = ##class(%Dictionary.CompiledClass).%OpenId("Demo.RecordMap.ComplexMap.PatientEncountersBatch").Properties.Count()
```

Expect at least 3 user properties: `FileHeader`, `Patients` (a list of sequence helpers), `FileTrailer`.

## Production wiring

```xml
<Item Name="PatientFileService" Category="Inbound"
      ClassName="EnsLib.RecordMap.ComplexMap.FileService"
      PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="FilePath">/data/patients/in/</Setting>
  <Setting Target="Adapter" Name="FileSpec">*.dat</Setting>
  <Setting Target="Host" Name="ComplexMap">Demo.RecordMap.ComplexMap.PatientEncounters</Setting>
  <Setting Target="Host" Name="TargetConfigNames">PatientProcessor</Setting>
</Item>
```

Each file becomes one message of type `Demo.RecordMap.ComplexMap.PatientEncountersBatch`.
