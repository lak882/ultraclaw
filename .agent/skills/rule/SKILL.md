---
name: rule
description: Create and maintain HL7 Routing Rules for IRIS Interoperability. Use when authoring or editing a routing rule class. Triggers on "create rule", "routing rule", "add a when", "constraint", "route messages".
tools: [read_class, create_class, write_class, run_sql, xecute]
---

# rule

Create and maintain Routing Rule classes for IRIS Interoperability productions.

## Tool reference

| Goal | How |
|---|---|
| Read an existing rule | `read_class` — pass `classname` |
| Create a new rule | `create_class` — pass full UDL body |
| Update an existing rule | `write_class` — pass full UDL body |
| Verify HL7 field paths | `exec:` `Set %result = ##class(InterClaw.Script.HL7.GetSchema).SegmentFields("2.5.1","MSH")` |
| View full message structure | `exec:` `Set %result = ##class(InterClaw.Script.HL7.GetSchema).MessageStructure("2.5.1","ADT_A01")` |
| Check routing outcome | `run_sql`: `SELECT ID, SessionId, TimeCreated, SourceConfigName, TargetConfigName FROM Ens.MessageHeader WHERE SessionId='1234' ORDER BY ID` |
| Check event log errors | `run_sql`: `SELECT TOP 25 TimeLogged, Type, ConfigName, Text FROM Ens_Util.Log WHERE Type IN (2,3,6) AND TimeLogged >= DATEADD('hour',-1,$Horolog) ORDER BY ID DESC` |

## Sending a test message

HL7 send requires the `InterClaw.Script.Test.SendHTTP` method (created in a follow-up session). Until then, use the `manage-production` skill's HTTP send pattern.

## References

All current references are HL7-routing-specific:

| Asset | When to load |
|---|---|
| `hl7/references/overview.md` | Class hierarchy, `Ens.Rule.Definition` structure, `RuleAssistClass` parameter. Load when starting a new rule from scratch. |
| `hl7/references/elements.md` | `<rule>`, `<constraint>`, `<when>`, `<send>`, `<return>`, `<delegate>` reference. Load when writing the body of a rule. |
| `hl7/references/conditions.md` | Condition expression syntax, HL7 field comparisons, logical operators, XML entity encoding. Load when writing `<when>` conditions. |
| `hl7/references/patterns.md` | Best practices, constraint-first filtering, modality-based routing, fan-out, catch-all rules. Load when deciding structure. |
| `hl7/references/pitfalls.md` | `RuleAssistClass` vs `RuleAssist`, `!=` vs `'=`, constraint vs condition for message type. Load during review. |

Base path: `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/rule/hl7/references/`.

## Templates

| Asset | Purpose |
|---|---|
| `hl7/templates/routing-rule.cls.template` | Starter HL7 routing rule class with XDATA shell. |

## Examples

HL7 routing examples live in `hl7/examples/`. Load for concrete worked patterns.

## Authoring checklist

1. Load `references/overview.md` for class structure and `RuleAssistClass` parameter.
2. Load `references/elements.md` for `<constraint>`, `<when>`, `<send>` reference.
3. Verify HL7 field names via `InterClaw.Script.HL7.GetSchema.SegmentFields` before writing conditions.
4. Load `references/conditions.md` when writing non-trivial `<when>` expressions.
5. Load `references/patterns.md` to choose the right structural approach.
6. Load `references/pitfalls.md` before pushing.
