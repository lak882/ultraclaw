# Condition Expression Reference

Condition expression syntax, HL7 field comparisons, logical operators, XML entity encoding, and built-in functions. Load when writing `<when>` conditions.

## HL7 Field Path Syntax in Conditions

```xml
HL7.{SegmentName:FieldName.ComponentName}
HL7.{GroupPath.SegmentName:FieldName.ComponentName}
```

Always use named field paths, never positional numbers. Pull the segment schema with `get_schema` (`{"mode":"segment_fields","category":"2.5.1","segment":"OBR"}`) to verify names.

## Comparison Operators

| Operator | Meaning | XML form |
|----------|---------|----------|
| `=` | equals | `=` |
| `!=` | not equals | `!=` |
| `[` | contains | `[` |
| `'[` | does not contain | `'[` |
| `>` | greater than | `&gt;` |
| `<` | less than | `&lt;` |

Use `!=` for not-equals. Never use `'=` — that is ObjectScript syntax and will not work in the rule expression parser.

## XML Entity Encoding

String literals in condition attributes must be XML-entity-encoded:

| Character | Encoded form |
|-----------|-------------|
| `"` | `&quot;` |
| `&` | `&amp;` |
| `<` | `&lt;` |
| `>` | `&gt;` |

## Logical Operators

| Operator | Meaning |
|----------|---------|
| `&&` | AND |
| `\|\|` | OR |

## Common Condition Examples

```xml
<!-- Equals -->
condition="HL7.{MSH:MessageType.MessageCode}=&quot;ADT&quot;"

<!-- Not equals -->
condition="HL7.{MSH:MessageType.TriggerEvent}!=&quot;A03&quot;"

<!-- Contains -->
condition="HL7.{MSH:SendingApplication.NamespaceID}[&quot;EPIC&quot;"

<!-- Does not contain -->
condition="HL7.{MSH:SendingApplication.NamespaceID}'[&quot;TEST&quot;"

<!-- AND -->
condition="HL7.{MSH:MessageType.MessageCode}=&quot;ADT&quot;&amp;&amp;HL7.{MSH:MessageType.TriggerEvent}=&quot;A01&quot;"

<!-- OR -->
condition="HL7.{MSH:MessageType.TriggerEvent}=&quot;A01&quot;||HL7.{MSH:MessageType.TriggerEvent}=&quot;A04&quot;"

<!-- Non-empty check -->
condition="HL7.{PID:PatientIdentifierList.IDNumber}'=&quot;&quot;"

<!-- Always true (constraint already filtered) -->
condition="1"
```

## Built-in Functions

```xml
<!-- String length -->
condition="$LENGTH(HL7.{PID:PatientIdentifierList.IDNumber})&gt;0"

<!-- Lookup table: value exists in table -->
condition="..Lookup(&quot;AcceptedFacilities&quot;,HL7.{MSH:SendingFacility.NamespaceID})'=&quot;&quot;"

<!-- Lookup table: value matches expected -->
condition="..Lookup(&quot;FacilityRoutes&quot;,HL7.{MSH:SendingFacility.NamespaceID})=&quot;HUB&quot;"
```

## Nested Group Paths

For fields inside repeating groups, use the full group path:

```xml
condition="HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:UniversalServiceIdentifier.Identifier}=&quot;MI&quot;"
```

Use exact match (`=`) on coded field values, not contains (`[`). `OBR:4.1 = "MI"` will not match `"MI12345"` — which is correct. Using `[` would cause false matches.
