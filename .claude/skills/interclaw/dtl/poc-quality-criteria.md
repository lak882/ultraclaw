# POC Build Quality Criteria

Evaluate every POC agent run against these criteria. Score each as PASS/FAIL with notes.

## DTL Quality

| # | Criterion | What to Check |
|---|-----------|---------------|
| D1 | **Named field paths only** | Every `source.{...}` and `target.{...}` uses field names (e.g., `PID:PatientName.FamilyName`), never positional numbers (e.g., `PID:5.1`). Zero exceptions. |
| D2 | **DependsOn tuple** | `DependsOn = (SourceClass, TargetClass)` — never a single class. |
| D3 | **No `<comment>` tags in DTL XML** | Zero `<comment>` tags anywhere in the DTL — not just inside `<foreach>`. Use XML comments (`<!-- -->`) or `<annotation>` elements instead. |
| D4 | **Correct create mode** | `create='copy'` when all source segments should pass through and only specific fields are modified. `create='new'` when building a new message structure, filtering segments, or the target schema differs from source. See D10 for completeness check when using `create='new'`. |
| D5 | **Utility function shorthand** | Uses `..Lookup()`, `..ReplaceStr()`, `..Strip()`, `..Length()`, etc. Never `##class(...)`, `$ZSTRIP()`, `$REPLACE()`. |
| D6 | **Correct utility function names** | `..ReplaceStr()` not `..Replace()`. `..SubString()` not `..Truncate()`. `..Length()` not `$LENGTH()` in DTL assign context. |
| D7 | **Proper foreach syntax** | Named field in iterator (e.g., `PID:PatientIdentifierList()`), correct k1/k2 nesting for nested loops. Uses `<break/>` when searching for first match. |
| D8 | **Schema fetched first** | Agent ran ``get_schema` tool (mode=segment_fields)` BEFORE writing any DTL. |
| D9 | **DocType verified against schema** | The `sourceDocType` and `targetDocType` in the DTL match actual registered schemas. For custom Z-structures (e.g., `SH2.5:ADT_A01_Z`), the agent pulled the specific Z-structure with ``get_schema` tool (mode=message) <cat:Z_type>` and confirmed it exists — never assumed a Z-type matches the base message. |
| D10 | **Segment completeness for `create='new'`** | When `create='new'` is used, pull the schema structure (``get_schema` tool (mode=message)`) and verify EVERY group/segment is explicitly copied from source to target. For ORU_R01 this includes: MSH, SFT, DSC, PIDgrpgrp (PIDgrp with PID/PV1grp), ORCgrp (ORC, OBR, NTE, TQ1grp, CTD, FT1, CTI, SPMgrp, OBXgrp with NTE). Missing segments = silent data loss. |
| D11 | **Field repeat iteration** | When iterating over tilde-delimited field repeats (e.g., OBX:ObservationValue), uses DTL-native `<foreach property='...ObservationValue()' key='k1'>` syntax — not manual `$PIECE` splitting in `<code>` blocks. |
| D12 | **No `<code>` in DTL** | `<assign>` property paths support variables (`counter`, `k1`) and expressions (`counter+1`). There is NO reason to use `<code>` with `SetValueAt()`/`GetValueAt()` in a DTL. Any active `<code>` block (excluding `disabled='1'` debug `write` statements) is a FAIL. Counter management uses `<assign value='3' property='counter' action='set' />` and `<assign value='counter + 1' property='counter' action='set' />`. Dynamic-indexed targets use `target.{...OBXgrp(counter).OBX}`. |
| D13 | **Source metadata preserved in new segments** | When creating new segments from field repeats (e.g., exploding OBX:5 tilde-delimited values into individual OBX segments), metadata fields are copied from the **source** segment — not hardcoded from header/footer templates. Specifically: `OBX:ObservationResultStatus` must retain source value (e.g., `F` for Final), not reuse the header/footer pattern (`IP`). Also applies to `OBX:ValueType` and `OBX:ObservationIdentifier` — these describe the clinical data and must come from the source OBX. Header/footer OBX segments (static text like "Sanford Health" or "Page 1 of 1") may use hardcoded status values since they are not clinical results. |
| D14 | **100% DTL-native elements** | A well-formed DTL uses ONLY `<assign>`, `<foreach>`, `<if>`, `<break/>`, and utility functions (`..Length()`, `..SubString()`, `..Lookup()`, etc.). Zero active `<code>` blocks. Segment copies: `<assign value='source.{MSH}' property='target.{MSH}' action='set' />`. Repeating group copies: `source.{PIDgrpgrp().PIDgrp}` with `()` syntax. Counter indexing: `target.{...OBXgrp(counter).OBX}` in `<assign>` (variables work in property paths). Raw segment strings for headers/footers: `'"OBX|0|||0| Sanford Health ||||||IP"'`. Any `GetValueAt()`/`SetValueAt()` call in an active `<code>` block is a FAIL. |

## Test Message Quality

| # | Criterion | What to Check |
|---|-----------|---------------|
| T1 | **Segment order matches schema** | Segments appear in schema-defined order (verified against ``get_schema` tool (mode=message)` output). |
| T2 | **Multiple repeating groups** | At least 2 instances of any repeating segment/group the DTL iterates over. |
| T3 | **No pre-populated targets** | Fields the DTL writes to are empty or have different values in the test message — diff must show actual changes. |
| T4 | **Exercises all DTL branches** | Test data triggers every conditional path (if/else), every lookup key, every foreach body. |
| T5 | **Field alignment verified** | Agent confirmed field positions (pipe count) are correct before running DTL test. |
| T6 | **Message type in test matches DocType** | The MSH:9 message type in the test message matches the DTL's sourceDocType. If the DTL expects `SH2.5:ADT_A01_Z`, the test message's MSH:9 must produce an ADT^A01 that parses under that schema. |

## Production & Routing Quality

| # | Criterion | What to Check |
|---|-----------|---------------|
| P1 | **Trace clean** | All messages Status=Completed, zero errors in event log. |
| P2 | **Routing correct** | Messages routed to correct targets per spec (including filtered messages). |
| P3 | **Transform applied correctly** | Output files show expected transformations (verified via diff or manual check). |
| P4 | **Standard production template** | Production includes: `Ens.Alert` handler (routing engine or `Ens.Alerting.NotificationOperation`), `BadMessageHandler` (disabled `EnsLib.HL7.Operation.FileOperation` referenced in MsgRouter). MsgRouter has `BadMessageHandler` setting configured. |
| P5 | **MessageSchemaCategory correct** | File service `MessageSchemaCategory` matches the HL7 version used by the DTL's DocType (e.g., `SH2.5` for custom Sanford schemas, `2.5.1` for standard ORU, `2.3.1` for ORM). Mismatch causes silent parsing failures. |
| P6 | **Routing rule uses constraints** | Routing rules MUST use `<constraint name="docName" value="ADT_A01"/>` to filter by message type — not `HL7.{MSH:MessageType.MessageCode}` conditions. Constraints are declarative, efficient, and the standard pattern. The `<when>` condition should only contain business logic checks (e.g., SendingFacility). `condition="1"` is acceptable when the constraint already filters to the exact message type needed. |
| P7 | **Package naming convention** | All components for an exercise follow `<Pkg>.<BuildN>.<Type>.<Name>` convention. For multi-exercise POCs, each exercise scopes its classes under its build number: `Sanford.Build1.DTL.ADTTransform`, `Sanford.Build1.BO.SystemA`, `Sanford.Build1.BS.ADTFileService`, `Sanford.Build1.Rule.ADTRoutingRule`. Never mix scoped and unscoped names (e.g., `Sanford.BO.SystemA` alongside `Sanford.Build1.DTL.ADTTransform`) — that breaks the organizational hierarchy and makes package reset unreliable. Production config item `Name` attributes must match the class paths. |

## BPL / Business Process Quality

| # | Criterion | What to Check |
|---|-----------|---------------|
| B1 | **Request immutability** | Never calls `SetValueAt()` directly on `request`. Uses `%ConstructClone(1)` (deep clone) and stores in context property before modification. Calls `%Save()` after `SetValueAt()`. |
| B2 | **Context properties declared** | All intermediate values stored in BPL context properties (not local ObjectScript variables) so they survive async call suspension/resume. |
| B3 | **Alert routing correct** | BPL `<alert>` elements target `Ens.Alert` config item. Production has matching `Ens.Alert` host enabled. |
| B4 | **SQL table naming** | `%Persistent` class global names under 31 characters. Uses `SqlTableName` and explicit short `DataLocation` values. |
| B5 | **OBRunion path resolution** | For ORM_O01 with OBRunion, uses full group path (`ORCgrp(1).OBRuniongrp.OBRunion.OBR:FieldName`) as primary approach. Falls back to segment-level access only if full path returns empty. |
| B6 | **BPL mandate** | Every business process MUST extend `Ens.BusinessProcessBPL` with an `XData BPL` block — never code-based `Ens.BusinessProcess` with `OnRequest()`/`OnResponse()` methods. BPLs provide visual traceability, easier debugging, and better demo value. The ONLY exception is if the user's spec explicitly requests a code-based process. If any class `Extends Ens.BusinessProcess` (without the `BPL` suffix), this criterion FAILS. |
| B7 | **BPL-native elements over `<code>`** | BPL `<code>` blocks should be minimized. Use `<sql>` for SQL operations (INSERT, SELECT, DELETE) instead of `<code>` wrapping a utility class. Use `<assign>` for extracting values from request/context. Use `<call>` with `<transform>` for DTL-based enrichment instead of `<code>` doing `%ConstructClone`+`SetValueAt`. `<code>` is only acceptable when no BPL-native element can express the logic (e.g., complex multi-step ObjectScript, dynamic variable manipulation). If `<sql>` fails to compile on the target IRIS version, log it as a platform bug and fall back to utility class + `<code>` — but this should be the exception, not the default pattern. |
| B8 | **`<call>` uses `<assign>` pattern** | For HL7 messages (`EnsLib.HL7.Message`), `<call>` MUST use `<assign property="callrequest" value="request" action="set" />` inside `<request>` — NOT `value=` on the `<request>` element. The `value=` attribute causes "Invalid BPL" compile errors. Similarly, `<response>` should omit `value=`. |
| B9 | **`<switch>` for multi-way branching** | When a BPL branches on message type (e.g., ORM vs SIU vs ADT), it should use `<switch>` with `<case>` elements — not nested `<if>` chains. `<switch>` is cleaner, evaluates top-to-bottom, and reads naturally. Nested `<if>` creates deeply indented XML. |
| B10 | **Spec field numbers verified against schema** | When the spec references fields by positional number (e.g., "PV1:18", "SCH:7.2", "OBR:4"), the agent must have pulled the segment schema (``get_schema` tool (mode=segment_fields, segment=<SEG>)`) and confirmed the positional number maps to the correct named path. Common mistakes: PV1:18=PatientType not PreadmitNumber(PV1:5); SCH:7.2=AppointmentReason.Text not Identifier(SCH:7.1). If the BPL uses a named path that doesn't match what the spec's positional number maps to, this FAILS. |
| B11 | **`<sequence>` elements named** | Every `<sequence>` must have a `name` attribute. Unnamed sequences appear as blank nodes in Visual Trace and the BPL editor. |
| B12 | **No unnecessary `<sequence>` nesting** | The top-level `<sequence>` inside `<process>` is sufficient for simple linear BPLs. Nested `<sequence>` wrappers are only justified inside `<flow>` branches, `<scope>` blocks, `<if>`/`<switch>` branches with multiple activities, or BPLs exceeding ~10 activities where logical grouping aids readability. |

## Process Efficiency

| # | Criterion | What to Check |
|---|-----------|---------------|
| E1 | **No `exec` tool** | Never used `exec` tool for any operation. |
| E2 | **Single compile pass** | All classes compiled on first push (no recompile needed due to errors). |
| E3 | **No test message rewrites** | Test message correct on first attempt (no field realignment needed). |
| E4 | **DTL compiled first try** | No DTL compile errors requiring XML fixes. |
| E5 | **Total tool calls** | Lower is better — measures agent efficiency. |

## Scoring

- **Perfect**: All D/T/P/B criteria PASS (D1-D14, T1-T6, P1-P7, B1-B12), E1-E4 all PASS
- **Clean**: All D/T/P/B criteria PASS, some E criteria FAIL (self-corrected issues)
- **Needs work**: Any D/T/P/B criteria FAIL (skill gap found — update skills)

## Checklist by Create Mode

### When to use `create='copy'`

Use when the spec describes **field-level modifications** to an existing message:
- Change MSH:SendingApplication
- Strip dashes from SSN
- Truncate a date field
- Filter PID repeats by AssigningAuthority
- Lookup and replace a coded value
- Copy a field from one segment to another

**Key property**: All source segments pass through unchanged unless explicitly overridden. You only write `<assign>` for fields you want to change.

### When to use `create='new'`

Use when the spec requires **building a different message structure**:
- Source and target are different message types (ORU_R01 → MDM_T02)
- Spec says "only include segments X, Y, Z" (segment filtering)
- Restructuring OBX segments (exploding repeats into individual segments)
- Target has segments that don't exist in source (constructed from scratch)

**Key property**: Target starts empty. You must explicitly copy EVERY segment you want in the output. Pull the schema and work through the full group hierarchy — don't just copy the obvious segments.

### Quick Decision

| Question | Answer → Mode |
|----------|---------------|
| Same message type, modifying specific fields? | `create='copy'` |
| Different source/target message types? | `create='new'` |
| Spec lists which segments to include/exclude? | `create='new'` |
| Restructuring repeating segments? | `create='new'` |
| All segments should pass through? | `create='copy'` |
