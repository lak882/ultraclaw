# Custom Z-Segments and Custom HL7 Schemas Reference

Custom Z-segments extend standard HL7 message schemas with organization-specific segments.

## XML Format (.HL7 files)

Custom schemas are defined in XML files with a `.HL7` extension:

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Category name="MyCustom" description="Custom schema with Z-segments" base="2.5.1">

  <!-- Message Types: map trigger event to message structure -->
  <MessageType name='ADT_A01' structure='ADT_A01_Z' returntype='ACK'/>

  <!-- Message Structures: define segment layout -->
  <!-- CRITICAL: Tildes must wrap EVERY bracket/brace, not just separate segments -->
  <MessageStructure name='ADT_A01_Z' 
    definition='MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]~[~ZPN~]~[~ZIN~]'/>

  <!-- Segment Structures: define fields -->
  <SegmentStructure name='ZPN' description='Custom Provider/Notes'>
    <SegmentSubStructure piece='1' description='Set ID' datatype='SI' max_length='4' required='O'/>
    <SegmentSubStructure piece='2' description='Field 2' datatype='ST' max_length='200' required='O'/>
  </SegmentStructure>

</Category>
```

### Key Attributes

**Category**: `name` = schema name, `base` = parent schema to inherit from (e.g., "2.5.1")

**MessageStructure definition syntax**:
| Syntax | Meaning |
|--------|---------|
| `SEG` | Required segment |
| `[SEG]` | Optional segment |
| `{SEG}` | Repeating segment |
| `[{SEG}]` | Optional and repeating |
| `~` | Segment separator |

**SegmentSubStructure attributes**:
| Attribute | Description |
|-----------|-------------|
| `piece` | Field position (1-based) |
| `description` | Human-readable field name |
| `datatype` | HL7 data type (ST, CX, SI, TS, NM, CE, etc.) |
| `repeatcount` | `*` = unlimited, number = fixed, empty = non-repeating |
| `max_length` | Maximum field length |
| `required` | `R` = required, `O` = optional |

## CRITICAL: Definition Syntax

The `definition` attribute in `<MessageStructure>` uses tildes (`~`) around **every** bracket, brace, and segment name. This is NOT the same as just separating segments with tildes.

**WRONG** (will silently fail — PUT returns 200 but schema doesn't persist):
```
definition='MSH~EVN~PID~[PD1]~[{NK1}]~PV1'
```

**CORRECT** (tildes wrap every bracket/brace):
```
definition='MSH~EVN~PID~[~PD1~]~[~{~NK1~}~]~PV1'
```

To get the correct syntax, export an existing standard schema (e.g., `GET /api/atelier/v1/{ns}/doc/2.5.1.HL7`) and copy the definition format from there.

## DTL DocType

When referencing a custom schema in DTL, use the **message structure name** (not the message type name):
```xml
sourceDocType='StClairCustom:ADT_A01_Z'   <!-- CORRECT: structure name -->
sourceDocType='StClairCustom:ADT_A01'      <!-- WRONG: message type name -->
```

## Importing/Pushing Schemas

Push .HL7 files via the Atelier API just like .cls files. Schema files live on the server, not in the repo.

```bash
<python> .claude/skills/interclaw/scripts/documents/put_doc.py \
  --server myserver --namespace TESTING \
  --doc MyCustom.HL7 \
  --input /tmp/MyCustom.HL7 \
  --force --compile
```

## Viewing Schemas

Registered schemas can be viewed in the browser at:
```
{pathPrefix}/ui/interop/interclaw/legacy-ui/index.html#/csp/healthshare/{namespace}/EnsPortal.HL7.SchemaDocumentStructure.zen?MS=MS:{category}:{structure}
```
Example: `MS=MS:SH2.5:ADT_A01_Z` shows the SH2.5 custom schema's ADT_A01_Z message structure.

## Using Custom Schemas

1. Set **MessageSchemaCategory** on the Business Service to the custom schema name
2. Reference in DTL: `sourceDocType='StClairCustom:ADT_A01_Z'`
3. Access Z-segment fields in DTL: `source.{ZPN:15}`, `target.{ZIN:4}`

## DTL with Z-Segments

```xml
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='StClairCustom:ADT_A01_Z' targetDocType='StClairCustom:ADT_A01_Z'
           create='copy' language='objectscript' >

  <!-- Read from ZPN-15 -->
  <assign value='source.{ZPN:15}' property='target.{ZIN:4}' action='set'/>

</transform>
```

## Production Configuration

Update the HTTP Service to use the custom schema:
```xml
<Setting Target="Host" Name="MessageSchemaCategory">StClairCustom</Setting>
```
