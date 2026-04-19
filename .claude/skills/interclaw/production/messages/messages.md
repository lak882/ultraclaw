# Messages Reference

Messages are the contracts between production components. Every request sent through a production is an `Ens.Request` subclass; every response is an `Ens.Response` subclass.

## Class Hierarchy

```
%Library.Persistent
  └── Ens.MessageBody
        ├── Ens.Request                              (base request)
        │     ├── Ens.StringRequest                  (single string)
        │     ├── Ens.StreamContainer                (stream wrapper)
        │     ├── EnsLib.HL7.Message                 (HL7 virtual doc)
        │     ├── EnsLib.EDI.X12.Document            (X12)
        │     ├── HS.Message.PatientSearchRequest    (HealthShare MPI)
        │     └── Your.Custom.Request
        └── Ens.Response                             (base response)
              ├── Ens.StringResponse                 (single string)
              ├── EnsLib.HL7.Message                 (HL7 — also a response)
              ├── HS.Message.PatientSearchResponse   (HealthShare MPI)
              └── Your.Custom.Response
```

## Persistent vs Serial

| Type | Stored In | Use When |
|------|-----------|----------|
| `Extends Ens.Request` (Persistent) | Own table in DB | Default for messages — has its own ID, queryable, appears in message viewer |
| `Extends %SerialObject` | Embedded in parent | Sub-objects within a message — no own ID, not independently queryable |

**Rule of thumb:** Top-level messages are always Persistent (Ens.Request/Ens.Response). Nested structures within a message can be Serial.

## Property Types

### Scalar Types

| Type | ObjectScript | Description |
|------|-------------|-------------|
| `%String` | `Property Name As %String;` | Text (default MAXLEN=50) |
| `%String(MAXLEN=1000)` | | Longer text |
| `%String(MAXLEN="")` | | Unlimited length |
| `%Integer` | `Property Count As %Integer;` | Integer |
| `%Numeric` | `Property Amount As %Numeric(SCALE=2);` | Decimal |
| `%Boolean` | `Property Active As %Boolean;` | 0 or 1 |
| `%Date` | `Property DOB As %Date;` | Internal date format |
| `%TimeStamp` | `Property Created As %TimeStamp;` | YYYY-MM-DD HH:MM:SS |
| `%Status` | `Property Result As %Status;` | Status code |

### Collection Types

```objectscript
// List of strings
Property Codes As list Of %String;

// Array (key-value)
Property Metadata As array Of %String;

// List of objects
Property LineItems As list Of MyApp.LineItem;
```

### Object References

```objectscript
// Reference to another persistent object
Property Patient As MyApp.Patient;

// Embedded serial object
Property Address As MyApp.Address;  // where Address Extends %SerialObject

// Stream for large content
Property Document As %Stream.GlobalCharacter;
```

## Property Parameters

```objectscript
Property Name As %String(MAXLEN = 200, TRUNCATE = 1);
Property Code As %String(VALUELIST = ",A,B,C");
Property Email As %String(MAXLEN = 254) [ Required ];
Property Status As %String [ InitialExpression = "NEW" ];
Property InternalId As %String [ Calculated, SqlComputeCode = { Set {*} = {PatientId} }, SqlComputed ];
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
/// Serial sub-object for patient identifiers
Class MyApp.Msg.PatientIdentifier Extends %SerialObject
{

Property Type As %String(MAXLEN = 20);   // MRN, SSN, etc.
Property Value As %String(MAXLEN = 100);
Property AssigningAuthority As %String(MAXLEN = 100);

}
```

## Built-in HL7 Message (EnsLib.HL7.Message)

The most common message type in HealthShare. It's a "virtual document" — segments are stored compressed, accessed via path syntax.

```objectscript
// Access HL7 fields by path
Set tMsgType = msg.GetValueAt("MSH:9.1")           // "ADT"
Set tEvent = msg.GetValueAt("MSH:9.2")              // "A01"
Set tPatientMRN = msg.GetValueAt("PID:3.1")         // MRN
Set tPatientName = msg.GetValueAt("PID:5")           // Full name
Set tLastName = msg.GetValueAt("PID:5.1")            // Last name
Set tFirstName = msg.GetValueAt("PID:5.2")           // First name

// Set a field
Do msg.SetValueAt("NewValue", "PID:8")

// Count repeating segments
Set tCount = msg.GetValueAt("PID:3(*)")

// Access repeating fields
Set tId = msg.GetValueAt("PID:3(2).1")              // 2nd repeat, component 1
```

### HL7 Path Syntax

```
SegmentName:FieldNumber.ComponentNumber.SubComponentNumber
SegmentName(RepeatIndex):FieldNumber(RepeatIndex).Component.SubComponent
```

Examples:
- `MSH:9` — Message type field
- `MSH:9.1` — Message type component 1
- `PID:3(1).1` — First patient ID, first component
- `PID:3(*)` — Count of patient ID repeats
- `OBX(2):5` — Second OBX segment, field 5

## HealthShare SDA3 Messages

SDA3 (Summary Document Architecture) is HealthShare's internal clinical data model:

```objectscript
// SDA3 container
Property SDA As HS.SDA3.Container;

// Common SDA3 types
// HS.SDA3.Patient — demographics
// HS.SDA3.Encounter — visit/encounter
// HS.SDA3.Diagnosis — diagnosis
// HS.SDA3.Medication — medication
// HS.SDA3.LabOrder — lab order
// HS.SDA3.Observation — observation/result
```

## Message Flow Pattern

```
[Service] --Request--> [Process] --Request--> [Operation]
                         |                       |
                         <-------Response--------+
    <--------Response---+
```

1. Service creates a Request, sends it
2. Process receives the Request, may transform, sends new Request(s)
3. Operation receives the Request, sends to external system, returns Response
4. Response flows back through the chain
