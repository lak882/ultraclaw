# Messages Reference

Request and response message class structure, property types, HL7 virtual document path syntax. Load when creating message classes.

## Class Hierarchy

```
%Library.Persistent
  └── Ens.MessageBody
        ├── Ens.Request
        │     ├── Ens.StringRequest
        │     ├── Ens.StreamContainer
        │     ├── EnsLib.HL7.Message                 (HL7 virtual doc — also a response)
        │     ├── EnsLib.EDI.X12.Document            (X12)
        │     ├── HS.Message.PatientSearchRequest    (HealthShare MPI)
        │     └── Your.Custom.Request
        └── Ens.Response
              ├── Ens.StringResponse
              ├── HS.Message.PatientSearchResponse   (HealthShare MPI)
              └── Your.Custom.Response
```

## Persistent vs Serial

| Type | Stored In | Use When |
|------|-----------|----------|
| `Extends Ens.Request` | Own table in DB | Default for top-level messages — has its own ID, queryable, visible in message viewer |
| `Extends %SerialObject` | Embedded in parent | Sub-objects within a message — no own ID, not independently queryable |

## Property Types

### Scalar

| Type | Example | Notes |
|------|---------|-------|
| `%String` | `Property Name As %String;` | Default MAXLEN=50 — increase when needed |
| `%String(MAXLEN=1000)` | | Longer text |
| `%String(MAXLEN="")` | | Unlimited length |
| `%Integer` | `Property Count As %Integer;` | |
| `%Numeric` | `Property Amount As %Numeric(SCALE=2);` | Decimal |
| `%Boolean` | `Property Active As %Boolean;` | 0 or 1 |
| `%Date` | `Property DOB As %Date;` | Internal date format |
| `%TimeStamp` | `Property Created As %TimeStamp;` | YYYY-MM-DD HH:MM:SS |

### Collections

```objectscript
Property Codes As list Of %String;
Property Metadata As array Of %String;
Property LineItems As list Of MyApp.Msg.LineItem;
```

### Streams

```objectscript
Property Document As %Stream.GlobalCharacter;
```

## Property Parameters

```objectscript
Property Name As %String(MAXLEN = 200, TRUNCATE = 1);
Property Code As %String(VALUELIST = ",A,B,C");
Property Email As %String(MAXLEN = 254) [ Required ];
Property Status As %String [ InitialExpression = "NEW" ];
```

## Example: Request/Response Pair

```objectscript
Class MyApp.Msg.PatientLookupRequest Extends Ens.Request
{

Property MRN As %String(MAXLEN = 50) [ Required ];
Property Facility As %String(MAXLEN = 100);
Property IncludeDemographics As %Boolean [ InitialExpression = 1 ];

}
```

```objectscript
Class MyApp.Msg.PatientLookupResponse Extends Ens.Response
{

Property Found As %Boolean;
Property PatientId As %String(MAXLEN = 50);
Property FirstName As %String(MAXLEN = 100);
Property LastName As %String(MAXLEN = 100);
Property DOB As %Date;
Property Gender As %String(VALUELIST = ",M,F,U");
Property Identifiers As list Of MyApp.Msg.PatientIdentifier;

}
```

```objectscript
Class MyApp.Msg.PatientIdentifier Extends %SerialObject
{

Property Type As %String(MAXLEN = 20);
Property Value As %String(MAXLEN = 100);
Property AssigningAuthority As %String(MAXLEN = 100);

}
```

## HL7 Virtual Document (EnsLib.HL7.Message)

Segments are stored compressed and accessed via path syntax.

```objectscript
Set tMsgType  = msg.GetValueAt("MSH:9.1")      // "ADT"
Set tEvent    = msg.GetValueAt("MSH:9.2")       // "A01"
Set tMRN      = msg.GetValueAt("PID:3.1")
Set tLastName = msg.GetValueAt("PID:5.1")
Set tFirstName = msg.GetValueAt("PID:5.2")
Do msg.SetValueAt("NewValue", "PID:8")
Set tCount    = msg.GetValueAt("PID:3(*)")      // count of repeats
Set tId       = msg.GetValueAt("PID:3(2).1")    // 2nd repeat, component 1
```

### HL7 Path Syntax

```
SegmentName:FieldNumber.ComponentNumber.SubComponentNumber
SegmentName(RepeatIndex):FieldNumber(RepeatIndex).Component.SubComponent
```

Always use named field paths in DTLs — never positional numbers. Use `get_schema` (`{"mode":"segment_fields","category":"2.5.1","segment":"PID"}`) to verify names.

## Message Flow Pattern

```
[Service] --Request--> [Process] --Request--> [Operation]
                          |                        |
                          <--------Response---------+
     <--------Response---+
```
