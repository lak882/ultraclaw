---
name: dtl
description: Create and maintain InterSystems IRIS Data Transformation Language (DTL) classes: field mappings, utility functions, foreach loops, conditionals, and lookup tables. Use when writing or editing a DTL class. Triggers on "create DTL", "transform", "map HL7", "field path".
tools: [read_class, create_class, write_class, run_sql, xecute]
---

# dtl

Create and maintain IRIS DTL classes that transform HL7 and other messages between formats.

## Tool reference

| Goal | How |
|---|---|
| Read an existing DTL | `read_class` — pass `classname` |
| Create a new DTL | `create_class` — pass full UDL body; compiles by default |
| Update an existing DTL | `write_class` — pass full UDL body; compiles by default |
| Test a DTL in-memory | `exec:` `Set sc = ##class(MyDtl).Transform(hl7In, .out) Set %result = out` |
| Look up a lookup table value | `run_sql`: `SELECT DataValue FROM Ens_Util.LookupTable WHERE TableName='Tab' AND KeyName='K'` |

## Schema lookup before every DTL

Always pull the schema first. Never guess field paths. The existing `InterClaw.Script.HL7.GetSchema` utility class is the native one-liner.

| Task | Call |
|---|---|
| List categories | `exec:` `Set %result = ##class(InterClaw.Script.HL7.GetSchema).ListCategories()` |
| Messages in a version | `exec:` `Set %result = ##class(InterClaw.Script.HL7.GetSchema).ListMessages("2.5.1")` |
| Segment fields | `exec:` `Set %result = ##class(InterClaw.Script.HL7.GetSchema).SegmentFields("2.5.1","PID")` |
| Full message structure | `exec:` `Set %result = ##class(InterClaw.Script.HL7.GetSchema).MessageStructure("2.5.1","ADT_A01")` |
| List segments | `exec:` `Set %result = ##class(InterClaw.Script.HL7.GetSchema).ListSegments("2.5.1")` |

## References

General DTL references (format-agnostic):

| Asset | When to load |
|---|---|
| `references/data-transformations.md` | Full DTL language reference (assigns, foreach, conditionals, functions). Load when creating or editing any DTL. |
| `references/datetime-formats.md` | DateTime conversion patterns. Load when mapping date/time fields. |

HL7-specific references:

| Asset | When to load |
|---|---|
| `hl7/references/poc-quality-criteria.md` | Quality checklist for HL7 POC DTLs — named field paths, Z-structure handling, nested-group gotchas. Load during review before pushing. |

Base paths:
- General: `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/dtl/references/`
- HL7: `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/dtl/hl7/references/`

Load each via `read_file`.

## Templates

| Asset | Purpose |
|---|---|
| `templates/dtl.cls.template` | Format-agnostic DTL class shell. Works for HL7, JSON, XML, or custom message types. |

## Examples

HL7 transform examples live in `hl7/examples/`. Load when you want a concrete worked pattern for a message-type pairing.

## Authoring checklist

1. Pull source and target schemas via `InterClaw.Script.HL7.GetSchema.SegmentFields` — never guess field paths.
2. Load `references/data-transformations.md` for utility functions and gotchas.
3. Load `templates/dtl.cls.template` for class structure.
4. Use named field paths only (`PID:PatientIdentifierList.IDNumber`, never `PID:3.1`).
5. If mapping date/time, load `references/datetime-formats.md`.
6. After pushing, test via the `Transform` xecute above and verify the output.
7. Load `references/poc-quality-criteria.md` before marking complete.
