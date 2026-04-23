---
name: sample-hl7
description: Generate a realistic sample HL7 v2 message from a schema. Use to create test messages for DTLs, routing rules, or production smoke tests. Outputs pipe-delimited v2 text. Triggers on "sample HL7", "generate ADT", "generate ORU", "example HL7 message".
---

# sample/hl7

Generate a sample HL7 v2 message by pulling the schema for the target message type and populating realistic values for every required segment.

## Tool reference

| Goal | How |
|---|---|
| Pull message structure | `exec:` `Set %result = ##class(InterClaw.Script.HL7.GetSchema).MessageStructure("2.5.1","ADT_A01")` |
| Pull segment fields | `exec:` `Set %result = ##class(InterClaw.Script.HL7.GetSchema).SegmentFields("2.5.1","PID")` |
| List available messages | `exec:` `Set %result = ##class(InterClaw.Script.HL7.GetSchema).ListMessages("2.5.1")` |

## Procedure

1. Pull the message structure to see required segments and groups.
2. For each required segment, pull its field list to see what populates.
3. Fill in realistic values using the patterns below.
4. Emit the final message as pipe-delimited v2 text with `|` field separators, `^~\&` encoding chars, and `\r` (carriage return) line endings.

## MSH template

The first segment is always MSH with exactly this shape:

```
MSH|^~\&|<SendingApp>|<SendingFacility>|<ReceivingApp>|<ReceivingFacility>|<YYYYMMDDHHMMSS>||<MessageType>^<TriggerEvent>^<Structure>|<MessageControlID>|P|<Version>
```

Example for an ADT^A01^ADT_A01 v2.5.1 message:
```
MSH|^~\&|HIS|ST_JOHNS|LAB|ST_JOHNS|20260422140000||ADT^A01^ADT_A01|MSG00001|P|2.5.1
```

## Common segment patterns

### PID (patient identification)

Minimum realistic fields: `PID-1` set_id, `PID-3` patient ID list, `PID-5` name, `PID-7` DOB, `PID-8` sex.

```
PID|1||MRN12345^^^ST_JOHNS^MR||DOE^JOHN^A||19800101|M|||123 MAIN ST^^ANYTOWN^NY^12345||555-1234
```

### PV1 (visit)

```
PV1|1|I|ICU^BED1^A||||1234^SMITH^JANE^^DR|||MED||||||||V12345
```

### ORC (order common)

```
ORC|NW|ORD12345||FIL12345|CM||||20260422140000|1234^SMITH^JANE
```

### OBR (observation request)

```
OBR|1|ORD12345|FIL12345|GLUC^GLUCOSE^LN|||20260422140000
```

### OBX (observation value)

Repeat for each result:

```
OBX|1|NM|GLUC^GLUCOSE^LN||95|mg/dL|70-110|N|||F
```

## Gotchas

- Use **carriage return `\r`** (`$Char(13)`), not LF or CRLF, between segments. IRIS parses CR-delimited.
- Subcomponent separator is `&`, not `,`. Never put a literal `,` inside a field.
- Component count per field must match the schema exactly — don't pad extras.
- For custom schema categories, use the structure name (e.g. `ST_JOHNS_2.5:ADT_A01_Z`), not the base message type.
- Message Control ID (MSH-10) must be unique per send; use a timestamp or sequence number.

## Small sample messages for common types

### ADT_A01 (admission)

```
MSH|^~\&|HIS|ST_JOHNS|LAB|ST_JOHNS|20260422140000||ADT^A01^ADT_A01|MSG00001|P|2.5.1
EVN|A01|20260422140000
PID|1||MRN12345^^^ST_JOHNS^MR||DOE^JOHN^A||19800101|M
PV1|1|I|ICU^BED1^A|||||||MED||||||||V12345
```

### ORU_R01 (lab result)

```
MSH|^~\&|LAB|ST_JOHNS|HIS|ST_JOHNS|20260422140000||ORU^R01^ORU_R01|MSG00002|P|2.5.1
PID|1||MRN12345^^^ST_JOHNS^MR||DOE^JOHN^A||19800101|M
OBR|1|ORD12345|FIL12345|GLUC^GLUCOSE^LN|||20260422140000
OBX|1|NM|GLUC^GLUCOSE^LN||95|mg/dL|70-110|N|||F
```

Substitute realistic values for your scenario (patient name, MRN, dates, result values).
