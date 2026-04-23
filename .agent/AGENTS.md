---
description: Cross-cutting IRIS conventions that apply to all component types
---

# InterSystems IRIS Conventions

## Package Naming

```
<Pkg>.Production          <Pkg>.DTL.<Name>           <Pkg>.Rule.<Name>RoutingRule
<Pkg>.Msg.<Name>Request   <Pkg>.BP.<Name>Process     <Pkg>.BS.<Name>Service
<Pkg>.Msg.<Name>Response  <Pkg>.BPL.<Name>Process    <Pkg>.BO.<Name>Operation
```

**Multi-exercise POCs**: scope all components under a build number:
```
Sanford.Build1.DTL.ADTTransform    Sanford.Build1.BO.SystemA
Sanford.Build2.DTL.ORUTransform    Sanford.Build2.BO.ORUOutput
```
The production class itself remains `<Pkg>.Production`, shared across exercises.

**Default naming when no name is given**: package `Demo`. Derive the class name by concatenating source and target data types with `To`, stripping all special characters (dots, colons, underscores, hyphens, spaces). **If the resulting name starts with a digit, prepend `V`** — ObjectScript class names cannot begin with a number. If the resulting class already exists, append `2`.

| Source | Target | Name |
|--------|--------|------|
| `2.5.1:ADT_A01` | `2.5.1:ADT_A01` | `Demo.DTL.V251ADTA01ToV251ADTA01` |
| `2.5.1:ORM_O01` | `Custom:ORM_O01_Z` | `Demo.DTL.V251ORMO01ToCustomORMO01Z` |
| `2.5.1:ORU_R01` | `2.5.1:ORU_R01` | `Demo.Rule.V251ORUR01ToV251ORUR01RoutingRule` |

## Class Name Restrictions

- ObjectScript class names cannot begin with a digit. When generating from HL7 identifiers (e.g. `2.5.1:ORU_R01`), prepend `V` to produce `V251ORUR01`.
- Field names are case-sensitive. `NameOfCodingSystem` is correct; `NameofCodingSystem` compiles without error but silently drops the assignment.

## Skills Catalog

Skills live at `.agent/skills/<name>/SKILL.md` (or `<name>/<sub>/SKILL.md` for nested). Every turn's system prompt carries the `<available_skills>` block with each skill's name, one-line description, and absolute filesystem path. Load a skill by calling `read_file` on its `<path>` — not by name.

| Skill | Scope |
|---|---|
| `dtl` | Authoring and editing DTL transforms. HL7 schema lookup, named field paths, utility functions, foreach/conditionals/lookups, custom Z-structure handling, common compile-error gotchas. |
| `rule` | Authoring and editing HL7 routing rules. Constraint vs condition syntax, `<when>` expression operators, `RuleAssistClass` parameter, fan-out and catch-all patterns. |
| `record-map` | Parsing and creating fixed-width or delimited flat files. `name` vs `targetClassname`, delimited vs fixed-width attributes, File/FTP/Batch service and operation wiring. |
| `production` | Creating production classes, business services, processes, operations, and message classes. XData production format, adapter selection, BPL defaults, package naming. |
| `manage-production` | Running-production operations: start/stop/restart/update via `Ens.Director`, event-log error queries, message traces, lookup-table CRUD via `Ens.Util.LookupTable`. |
| `iris-sql` | The `run_sql` tool contract and IRIS SQL dialect. Call arguments and return shape, TOP vs LIMIT, `%STARTSWITH`/`%INLIST`/`%EXTERNAL`, `$Horolog`+DATEADD, class-to-table mapping, canonical system-table queries. |
| `test` | Testing workflows for IRIS Interoperability components. In-memory DTL testing via `Transform`, segment-level diff via `InterClaw.Script.Production.Test.DTL`. Future: end-to-end production testing. |
| `sample` | Generating realistic sample messages for testing and demos. Currently HL7 v2 (ADT, ORU, order-based). MSH template, segment patterns, minimum-viable ADT/ORU bodies, custom Z-structure handling. |
| `improving-skills` | Meta-skill for fixing a skill that repeatedly fails to trigger, gives bad guidance, or drifts out of date. Load when you notice a skill underperforming. |

## Mandatory Skill Loading

Before certain tool calls, always `read_file` the corresponding skill body at the `<path>` shown in `<available_skills>`. The skill carries dialect rules, return-shape expectations, and silent-failure gotchas that you cannot recover from without loading.

| Before calling... | Load this skill first |
|---|---|
| `run_sql` (any query) | `iris-sql` |
| `create_class` / `write_class` on a DTL | `dtl` |
| `create_class` / `write_class` on a routing rule | `rule` |
| `create_class` / `write_class` on a RecordMap | `record-map` |
| Any `Ens.Director` call (start/stop/restart/update) | `manage-production` |
| Building a production class, service, process, or operation | `production` |
| Running a DTL `Transform` for testing | `test` |
| Generating a sample HL7 message | `sample` |
| Auditing, editing, or rewriting an existing skill | `improving-skills` |

Skills are free to load — their bodies are small and the `<available_skills>` block gives you the absolute path. Do not guess field paths, column types, SQL dialect quirks, or workflow ordering without first loading the relevant skill.

## Pushed-File Links

After every response that creates or updates a class via `create_class` or `write_class`, end the response with a links section listing the legacy-ui URL for each file pushed. This lets the user click straight into the editor.

The system prompt carries a `<link_base>` element with the legacy-ui base URL, for example `http://vmdev1.iscinternal.com/interclaw-test/ui/interop/interclaw/legacy-ui/index.html`. Build editor URLs by appending `#/csp/healthshare/{namespace}/{zen-page}` where `{namespace}` is from the context line and `{zen-page}` comes from this table.

| Component | ZEN page suffix | Label |
|---|---|---|
| DTL | `EnsPortal.DTLEditor.zen?DT={class}.cls` | DTL Editor |
| Routing Rule | `EnsPortal.RuleEditor.zen?RULE={class}` | Rule Editor |
| BPL | `EnsPortal.BPLEditor.zen?BP={class}.cls` | BPL Editor |
| Production | `EnsPortal.ProductionConfig.zen?PRODUCTION={class}` | Production |
| HL7 Schema | `EnsPortal.HL7.SchemaDocumentStructure.zen?MS={category}:{structure}` | HL7 Schema |
| Lookup Table | `EnsPortal.LookupSettings.zen?LookupTable={name}.lut` | Lookup Table |
| BS / BO / BP / MSG (no native editor) | `EnsPortal.ProductionConfig.zen?PRODUCTION={production-class}` | Production Config |

Detect the component type from the class name's package segment: `Pkg.DTL.*` → DTL; `Pkg.Rule.*RoutingRule` or `Pkg.Rule.*` → Routing Rule; `Pkg.BPL.*` → BPL; `Pkg.Production` → Production; `.HL7` doc → HL7 Schema; `.lut` → Lookup Table; otherwise Production Config.

### Format

End the response with a horizontal rule, then one markdown link per pushed file:

```
---
[Demo.DTL.ADTToADT — DTL Editor]({link_base}#/csp/healthshare/ULTRACLAW/EnsPortal.DTLEditor.zen?DT=Demo.DTL.ADTToADT.cls)
[Demo.Rule.ADTRoutingRule — Rule Editor]({link_base}#/csp/healthshare/ULTRACLAW/EnsPortal.RuleEditor.zen?RULE=Demo.Rule.ADTRoutingRule)
```

Substitute the `{link_base}` value from the `<link_base>` element in the system prompt. Do not emit `/goto` text; the markdown links are the navigation mechanism. Do not include links for classes that were read but not written. Do not include links for message classes or utility classes that have no native editor — link to the Production Config page for those if anywhere.
