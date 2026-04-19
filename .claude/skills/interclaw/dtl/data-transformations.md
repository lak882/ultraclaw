# Data Transformations (DTL) Reference

Data Transformations map fields between message formats. They're the primary tool for HL7-to-HL7, HL7-to-SDA3, and custom object mapping in HealthShare.

## Class Hierarchy

```
Ens.DataTransform
  └── Ens.DataTransformDTL
        ├── Your.CustomTransform (DTL XML)
        └── Your.CodeTransform (pure ObjectScript)
```

## Before Writing a DTL: Pull the Schemas

**Always pull the HL7 schemas from IRIS before creating a DTL.** This gives you the full segment/field structure so you know exactly what paths are available to map.

Use `get_schema.py` to explore schemas:

```bash
# List available HL7 versions
<python> .claude/skills/interclaw/scripts/hl7/get_schema.py \
  --server myserver --namespace HSLIB --list-categories

# List message structures in a version
<python> .claude/skills/interclaw/scripts/hl7/get_schema.py \
  --server myserver --namespace HSLIB --list-messages 2.5.1

# View segment fields (top-level only, numbered)
<python> .claude/skills/interclaw/scripts/hl7/get_schema.py \
  --server myserver --namespace HSLIB --segment 2.5.1:PID --fields

# View segment with all subcomponents
<python> .claude/skills/interclaw/scripts/hl7/get_schema.py \
  --server myserver --namespace HSLIB --segment 2.5.1:ORC

# View message structure info
<python> .claude/skills/interclaw/scripts/hl7/get_schema.py \
  --server myserver --namespace HSLIB --message 2.5.1:VXU_V04
```

For any DTL, pull the schemas for **both** the source and target segments you plan to map. For example, before writing a VXU facility lookup DTL:
```bash
# Pull ORC and RXA schemas to see available fields
<python> .claude/skills/interclaw/scripts/hl7/get_schema.py \
  --server myserver --namespace HSLIB --segment 2.5.1:ORC --fields
<python> .claude/skills/interclaw/scripts/hl7/get_schema.py \
  --server myserver --namespace HSLIB --segment 2.5.1:RXA --fields
```

This step is critical — never guess at field paths. The schema shows you every segment, field, component, and subcomponent available for mapping.

## Utility Functions

DTL transforms have access to InterSystems utility functions via the `Ens.Util.FunctionSet` class. These are available directly in DTL expressions.

Reference: https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=EBUS_utility_functions

### Commonly Used Functions

All utility functions come from `Ens.Util.FunctionSet` (inherited by `Ens.Rule.FunctionSet`).
Full reference: https://docs.intersystems.com/healthconnectlatest/csp/docbook/DocBook.UI.Page.cls?KEY=EBUS_utility_functions

#### String Functions

| Function | Signature | Example |
|----------|-----------|---------|
| `..ReplaceStr(val, find, repl)` | Replace all occurrences | `..ReplaceStr(source.{PV1:AssignedPatientLocation.PointofCare}, "_", " ")` |
| `..Contains(val, sub)` | Check string contains | `..Contains(source.{PID:PatientAddress.StateorProvince}, "AZ")` |
| `..DoesNotContain(val, sub)` | Negation of Contains | `..DoesNotContain(source.{MSH:SendingApplication.NamespaceID}, "TEST")` |
| `..StartsWith(val, prefix)` | Check string prefix | `..StartsWith(source.{MSH:SendingApplication.NamespaceID}, "EPIC")` |
| `..DoesNotStartWith(val, prefix)` | Negation of StartsWith | |
| `..Strip(val, action, remchar, keepchar)` | Strip characters (wraps $ZStrip) | `..Strip(source.{PID:PhoneNumberHome}, "<>W")` |
| `..Piece(val, delim, from, to)` | Extract delimited piece | `..Piece(source.{PID:PatientAccountNumber}, "-", 1)` |
| `..SubString(val, start, end)` | Extract substring by position | `..SubString(source.{OBR:UniversalServiceIdentifier.Identifier}, 1, 2)` |
| `..Pad(val, padpos, padchar)` | Pad string to length (negative=prepend) | `..Pad(source.{PV1:AttendingDoctor.IDNumber}, -4, "0")` |
| `..Translate(val, id, assoc)` | Character-by-character translation | `..Translate(source.{PID:PatientIdentifierList.IDNumber}, "-", "")` |
| `..ToUpper(val)` | Uppercase | `..ToUpper(source.{PID:PatientName.FamilyName})` |
| `..ToLower(val)` | Lowercase | `..ToLower(source.{MSH:SendingApplication.NamespaceID})` |
| `..Length(val, delim)` | String length or count of pieces | `..Length(source.{PID:PatientIdentifierList.IDNumber})` |

**IMPORTANT**: Use `..ReplaceStr()`, NOT `..Replace()`, `$REPLACE()`, or `..replace()`. The lowercase `..replace()` exists but is deprecated.

#### Lookup Functions

| Function | Signature | Example |
|----------|-----------|---------|
| `..Lookup(table, key, default, emptyFlag)` | Lookup table value | `..Lookup("FacilityMap", source.{ORC:EnterersLocation.Room})` |
| `..Exists(table, key)` | Check if key exists (returns 1/0) | `..Exists("FacilityMap", source.{MSH:SendingFacility.NamespaceID})` |

#### Pattern Matching / Comparison

| Function | Signature | Example |
|----------|-----------|---------|
| `..Matches(val, pattern)` | ObjectScript `?` pattern | `..Matches(source.{PID:PatientIdentifierList.IDNumber}, "1.N")` |
| `..Like(val, pattern)` | SQL LIKE (`%`=any, `_`=single) | `..Like(source.{MSH:SendingApplication.NamespaceID}, "EPIC%")` |
| `..In(val, items)` | Check membership (comma-delimited) | `..In(source.{MSH:MessageType.TriggerEvent}, "A01,A02,A03")` |
| `..NotIn(val, items)` | Negation of In | |
| `..RegexMatch(val, regex)` | Regular expression match | |

#### Date/Time Functions

| Function | Signature | Example |
|----------|-----------|---------|
| `..ConvertDateTime(val, inFmt, outFmt)` | Date format conversion — see [datetime-formats.md](datetime-formats.md) | `..ConvertDateTime(source.{PID:DateTimeofBirth}, "%Y%m%d", "%Y-%m-%d")` |
| `..CurrentDateTime(format)` | Current date/time | `..CurrentDateTime("%Q")` |

#### Numeric / Logic Functions

| Function | Signature | Example |
|----------|-----------|---------|
| `..Round(val, digits)` | Round to N decimal places | `..Round(source.{OBX:ObservationValue}, 2)` |
| `..Min(v1, v2, ...)` | Smallest of up to 8 values | |
| `..Max(v1, v2, ...)` | Largest of up to 8 values | |
| `..If(cond, trueVal, falseVal)` | Ternary expression | `..If(source.{PID:AdministrativeSex}="M", "Male", "Female")` |
| `..Not(val)` | Logical inversion | |

### Using in DTL XML

```xml
<!-- Lookup table -->
<assign value='..Lookup("FacilityMap", source.{ORC:EnterersLocation.Room})' property='target.{ORC:EnterersLocation.Facility.NamespaceID}' action='set'/>

<!-- String replacement — use ReplaceStr, NOT Replace -->
<assign value='..ReplaceStr(source.{PV1:AssignedPatientLocation.PointofCare}, "_", " ")' property='target.{PV1:AssignedPatientLocation.PointofCare}' action='set'/>

<!-- String manipulation -->
<assign value='..ToUpper(source.{PID:PatientName.FamilyName})' property='target.{PID:PatientName.FamilyName}' action='set'/>

<!-- Pad with leading zeros -->
<assign value='..Pad(source.{PV1:AttendingDoctor.IDNumber}, -4, "0")' property='target.{PV1:AttendingDoctor.IDNumber}' action='set'/>

<!-- Date conversion -->
<assign value='..ConvertDateTime(source.{PID:DateTimeofBirth}, "%Y%m%d", "%Y-%m-%d")' property='target.BirthDate' action='set'/>

<!-- Conditional with utility function -->
<if condition='..Contains(source.{PID:PatientAddress.StateorProvince}, "AZ")'>
  <true>
    <assign value='"Arizona"' property='target.State' action='set'/>
  </true>
</if>
```

**NEVER use `<code>` blocks in DTL.** Every operation — segment copies, counter management, dynamic-indexed targets, conditionals, string manipulation — can be expressed with `<assign>`, `<foreach>`, `<if>`, `<break/>`, and utility functions (`..Length()`, `..SubString()`, `..Lookup()`, `..ReplaceStr()`). Property paths in `<assign>` support variables (`counter`, `k1`) and arithmetic expressions (`counter+1`). Raw pipe-delimited segment strings work for static segments: `'"OBX|0|||0| Sanford Health ||||||IP"'`. The `()` syntax copies all repeats of a group: `source.{PIDgrpgrp().PIDgrp}`. The ONLY acceptable `<code>` is a `disabled='1'` debug `write` statement. Any active `<code>` block is a quality failure.

## DTL Class Structure

```objectscript
Class MyApp.Transform.HL7ToSDA3 Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, HS.SDA3.Container) ]
{

Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;
Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='HS.SDA3.Container'
           sourceDocType='2.5.1:ADT_A01' targetDocType=''
           create='new' language='objectscript' >

  <!-- Actions go here -->

</transform>
}

}
```

## Key Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `IGNOREMISSINGSOURCE` | 0 | Don't error when a source path doesn't exist |
| `REPORTERRORS` | 0 | Log errors to the event log |
| `TREATEMPTYREPEATINGFIELDASNULL` | 0 | Treat empty repeating fields as null |

## Transform Attributes

| Attribute | Description |
|-----------|-------------|
| `sourceClass` | Source message class |
| `targetClass` | Target message class |
| `sourceDocType` | Schema for virtual docs (e.g., `2.5.1:ADT_A01`) |
| `targetDocType` | Schema for target virtual docs |
| `create` | `new` (create new target), `copy` (clone source), `existing` (modify in-place) |
| `language` | `objectscript` |

## Choosing `create='new'` vs `create='copy'` (Segment Filtering)

The `create` attribute on the `<transform>` element controls how the target message is initialized, and the choice has a major impact on which segments appear in the output.

### `create='copy'` — Pass-through with modifications

Use `create='copy'` when you want **all source segments to pass through** and you only need to modify specific fields. The target starts as a full clone of the source, so any segment you don't explicitly touch remains unchanged in the output.

```xml
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.5.1:ADT_A01' targetDocType='2.5.1:ADT_A08'
           create='copy' language='objectscript' >
  <!-- Only override what changes — everything else passes through -->
  <assign value='"A08"' property='target.{MSH:MessageType.TriggerEvent}' action='set'/>
</transform>
```

### `create='new'` — Segment filtering (explicit output)

Use `create='new'` when you need to **output only specific segments**. The target starts empty, so you must explicitly copy or set every segment you want in the output. This prevents unwanted segments from leaking to downstream systems.

**When to use**: When the spec says something like "Only send MSH, EVN, PID, PV1, PD1, DRG, OBX" — that is a segment filtering requirement and you must use `create='new'`.

**CRITICAL: Copy ALL segments from the schema.** When using `create='new'`, pull the schema structure with `get_schema.py --message` and copy EVERY group and segment from source to target — not just the obvious ones. For example, ORU_R01 has: MSH, SFT, DSC, PIDgrpgrp (containing PIDgrp with PID/PV1grp), ORCgrp (containing ORC, OBR, NTE, TQ1grp, CTD, FT1, CTI, SPMgrp, OBXgrp with NTE). Missing segments are **silently lost** — the output will be valid HL7 but missing data.

```xml
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.5.1:ADT_A01' targetDocType='2.5.1:ADT_A01'
           create='new' language='objectscript' >
  <!-- Must explicitly copy each segment you want in the output -->
  <assign value='source.{MSH}' property='target.{MSH}' action='set'/>
  <assign value='source.{EVN}' property='target.{EVN}' action='set'/>
  <assign value='source.{PID}' property='target.{PID}' action='set'/>
  <assign value='source.{PV1}' property='target.{PV1}' action='set'/>
  <assign value='source.{PD1}' property='target.{PD1}' action='set'/>
  <assign value='source.{DRG}' property='target.{DRG}' action='set'/>

  <!-- Copy OBX segments in a loop -->
  <foreach property='source.{OBXgrp()}' key='k1'>
    <assign value='source.{OBXgrp(k1).OBX}' property='target.{OBXgrp(k1).OBX}' action='set'/>
  </foreach>

  <!-- Now modify specific fields as needed -->
  <assign value='"FILTERED"' property='target.{MSH:Security}' action='set'/>
</transform>
```

**Rule of thumb**: If the spec lists which segments to include (or exclude), use `create='new'`. If the spec only describes field-level changes, use `create='copy'`.

## DTL Actions

### set — Assign a value

```xml
<!-- Direct field copy -->
<assign value='source.{PID:PatientName.FamilyName}' property='target.{PID:PatientName.FamilyName}' action='set'/>

<!-- Literal value -->
<assign value='"PROCESSED"' property='target.{MSH:MessageType.TriggerEvent}' action='set'/>

<!-- Expression -->
<assign value='$ZDATE($HOROLOG, 3)' property='target.{MSH:DateTimeOfMessage}' action='set'/>

<!-- Concatenation -->
<assign value='source.{PID:PatientName.GivenName}_" "_source.{PID:PatientName.FamilyName}' property='target.FullName' action='set'/>
```

### if — Conditional logic

```xml
<if condition='source.{MSH:MessageType.TriggerEvent}="A01"'>
  <true>
    <assign value='"ADMIT"' property='target.EventType' action='set'/>
  </true>
  <false>
    <assign value='"OTHER"' property='target.EventType' action='set'/>
  </false>
</if>
```

#### Condition Precision: `=` vs `[` (Contains)

When checking modality codes, message types, or other coded values in conditions, use `=` (exact match) instead of `[` (contains). The contains operator can produce false matches.

```xml
<!-- CORRECT: exact match on procedure code -->
<if condition='source.{OBR:UniversalServiceIdentifier.Identifier}="MI12345"'>

<!-- WRONG: contains — would also match "ADMIN12345" or "XYZMI12345" -->
<if condition='source.{OBR:UniversalServiceIdentifier.Identifier}["MI"'>
```

This is especially important for:
- **Modality codes** (e.g., `"MI"` would match `"ADMIN"` with contains)
- **Message trigger events** (e.g., `"A01"` would match `"BA01X"` with contains)
- **Facility codes** and **namespace identifiers**

Use `..In()` when you need to check membership in a set: `..In(source.{MSH:MessageType.TriggerEvent}, "A01,A02,A03")`.

### for each — Loop over repeating elements

```xml
<foreach property='source.{PID:PatientIdentifierList()}' key='k1'>
  <assign value='source.{PID:PatientIdentifierList(k1).IDNumber}' property='target.Identifiers.(k1).Value' action='set'/>
  <assign value='source.{PID:PatientIdentifierList(k1).AssigningAuthority.NamespaceID}' property='target.Identifiers.(k1).Authority' action='set'/>
</foreach>
```

**CRITICAL: No `<comment>` tags in DTL XML.** `<comment>` elements cause DTL compile errors (`ERROR <Ens>ErrInvalidDTL`) in IRIS 2026.1 — even outside `<foreach>`. Use XML comments (`<!-- ... -->`) instead. The `<annotation>` element inside other DTL elements (e.g., inside `<if>`, `<assign>`) IS safe for inline notes.

**`<break/>` for early exit.** Use `<break/>` inside `<foreach>` to stop iterating after finding the first match:

```xml
<foreach property='source.{PID:PatientIdentifierList()}' key='k1'>
  <if condition='source.{PID:PatientIdentifierList(k1).AssigningAuthority.NamespaceID}="USDMC"'>
    <true>
      <assign value='source.{PID:PatientIdentifierList(k1)}' property='target.{PID:PatientIdentifierList(1)}' action='set'/>
      <break/>
    </true>
  </if>
</foreach>
```

**Field-level repeat iteration.** The `()` syntax in `<foreach>` works on tilde-delimited field repeats, not just segment groups. This is the DTL-native way to iterate subfield values:

```xml
<!-- Iterates each tilde-separated value in OBX:ObservationValue -->
<foreach property='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationValue()}' key='k1'>
  <!-- k1 indexes each repeat (1, 2, 3...) -->
  <assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationValue(k1)}'
    property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(k1).OBX:ObservationValue(1)}' action='set'/>
</foreach>
```

No need to manually split with `$PIECE` — the virtual document handles tilde-delimited repeats natively.

**Preserve source field values when creating new segments from repeats.** When exploding field repeats into individual OBX segments (or similar), copy metadata fields from the **source** segment — not from header/footer templates. Header/footer OBX segments (static text like "Sanford Health" or "Page 1 of 1") use hardcoded values because they are synthetic. But data OBX segments represent clinical results and their metadata must come from the source.

Fields to copy from source for each data OBX:
- `OBX:ObservationResultStatus` — retain source value (e.g., `F` for Final), not header pattern (`IP`)
- `OBX:ValueType` — e.g., `TX`, `NM`, `CE` from the source OBX
- `OBX:ObservationIdentifier` — the LOINC/local code from the source OBX

```xml
<!-- WRONG: hardcodes IP status for clinical data -->
<assign value='"IP"' property='target.{...OBXgrp(k1).OBX:ObservationResultStatus}' action='set' />

<!-- RIGHT: copies source status (F, P, C, etc.) for clinical data -->
<assign value='source.{...OBXgrp(1).OBX:ObservationResultStatus}'
  property='target.{...OBXgrp(k1).OBX:ObservationResultStatus}' action='set' />
```

**`disabled='1'` attribute.** Any DTL element can be disabled without deleting by adding `disabled='1'`. Useful for keeping debug code:

```xml
<code disabled='1'>
<![CDATA[ write "debug: k1="_k1]]>
</code>
```

**ZERO `<code>` blocks in DTL — no exceptions.** `<assign>` handles everything: segment copies, counter arithmetic, dynamic-indexed paths, raw segment strings. `<foreach>` handles iteration. `<if>` handles conditionals. Utility functions handle string ops. The ONLY `<code>` allowed is `disabled='1'` debug writes. Any active `<code>` block using `GetValueAt()`/`SetValueAt()` is ALWAYS wrong — rewrite it with `<assign>`.

```xml
<!-- WRONG: field-by-field copy loop in <code> -->
<code>
<![CDATA[
 for i=1:1:source.GetValueAt("MSH:*") {
   do target.SetValueAt(source.GetValueAt("MSH:"_i),"MSH:"_i)
 }
]]>
</code>

<!-- RIGHT: whole-segment assign -->
<assign value='source.{MSH}' property='target.{MSH}' action='set' />

<!-- RIGHT: whole repeating group copy -->
<assign value='source.{PIDgrpgrp().PIDgrp}' property='target.{PIDgrpgrp().PIDgrp}' action='set' />

<!-- RIGHT: <assign> works with counter variables in property paths -->
<assign value='3' property='counter' action='set' />
<foreach property='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationValue()}' key='k1' >
  <assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(counter).OBX}' action='set' key='k1' />
  <assign value='counter + 1' property='counter' action='set' />
</foreach>
```

**Complex `create='new'` DTL pattern (OBX restructuring, counter-based indexing).** When a `create='new'` DTL explodes tilde-delimited field repeats into individual OBX segments with header/footer rows:

**Key insight: `<assign>` property paths support variables and expressions.** Counter variables (`counter`), foreach keys (`k1`), and arithmetic (`counter+1`) all work in `<assign>` — there is NO need for `<code>` blocks with `SetValueAt()`.

```xml
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.5:ORU_R01' targetDocType='2.5:ORU_R01'
           create='new' language='objectscript' >

<!-- 1. Copy ALL non-OBX segments using <assign> with () for repeating groups -->
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{SFT()}' property='target.{SFT()}' action='set' />
<assign value='source.{DSC}' property='target.{DSC}' action='set' />
<assign value='source.{PIDgrpgrp().PIDgrp}' property='target.{PIDgrpgrp().PIDgrp}' action='set' />
<assign value='source.{PIDgrpgrp().ORCgrp().ORC}' property='target.{PIDgrpgrp().ORCgrp().ORC}' action='set' />
<assign value='source.{PIDgrpgrp().ORCgrp().OBR}' property='target.{PIDgrpgrp().ORCgrp().OBR}' action='set' />
<assign value='source.{PIDgrpgrp().ORCgrp().NTE()}' property='target.{PIDgrpgrp().ORCgrp().NTE()}' action='set' />
<assign value='source.{PIDgrpgrp().ORCgrp().TQ1grp()}' property='target.{PIDgrpgrp().ORCgrp().TQ1grp()}' action='set' />
<assign value='source.{PIDgrpgrp().ORCgrp().CTD}' property='target.{PIDgrpgrp().ORCgrp().CTD}' action='set' />
<assign value='source.{PIDgrpgrp().ORCgrp().FT1()}' property='target.{PIDgrpgrp().ORCgrp().FT1()}' action='set' />
<assign value='source.{PIDgrpgrp().ORCgrp().CTI()}' property='target.{PIDgrpgrp().ORCgrp().CTI()}' action='set' />
<assign value='source.{PIDgrpgrp().ORCgrp().SPMgrp()}' property='target.{PIDgrpgrp().ORCgrp().SPMgrp()}' action='set' />
<assign value='source.{PIDgrpgrp().ORCgrp().OBXgrp().NTE()}' property='target.{PIDgrpgrp().ORCgrp().OBXgrp().NTE()}' action='set' />

<!-- 2. Header OBX rows as raw segment strings -->
<assign value='"OBX|0|||0| Sanford Health ||||||IP"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX}' action='set' />
<assign value='"OBX|1|||0| Sanford USD Medical Center ||||||IP"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(2).OBX}' action='set' />

<!-- 3. Initialize counter (data OBX starts at position 3) -->
<assign value='3' property='counter' action='set' />

<!-- 4. Foreach over tilde-delimited OBX:ObservationValue repeats -->
<foreach property='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationValue()}' key='k1' >
  <!-- Copy full source OBX to target at counter position, then override fields -->
  <assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(counter).OBX}' action='set' key='k1' />
  <assign value='counter-1' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(counter).OBX:SetIDOBX}' action='set' />
  <assign value='""' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(counter).OBX:ObservationValue}' action='set' />

  <!-- Split long values: first 80 chars in OBX, full text in NTE -->
  <if condition='..Length(source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationValue(k1)}) &gt; 80' >
    <true>
      <assign value='..SubString(source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationValue(k1)},1,80)' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(counter).OBX:ObservationValue(1)}' action='set' />
      <assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationValue(k1)}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(counter).NTE(1):Comment}' action='set' />
    </true>
    <false>
      <assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationValue(k1)}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(counter).OBX:ObservationValue(1)}' action='set' />
    </false>
  </if>

  <assign value='counter + 1' property='counter' action='set' />
</foreach>

<!-- 5. Footer OBX — counter is now one past last data row -->
<assign value='counter - 1' property='counter' action='set' />
<assign value='"OBX|"_counter_"|||0| Page 1 of 1 ||||||IP"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(counter+1).OBX}' action='set' />

</transform>
```

**Key rules for this pattern:**
- **Zero `<code>` blocks needed.** `<assign>` property paths support variables (`counter`, `k1`) and expressions (`counter+1`, `counter-1`). Never use `SetValueAt()`/`GetValueAt()` in `<code>` when `<assign>` can do the job.
- **Use `()` for repeating group copies** — `source.{PIDgrpgrp().PIDgrp}` copies ALL repeats in one `<assign>`.
- **Raw segment strings for headers/footers** — `'"OBX|0|||0| Sanford Health ||||||IP"'` sets the entire OBX segment.
- **Copy whole source OBX, then override** — `<assign value='source.{...OBXgrp(1).OBX}' property='target.{...OBXgrp(counter).OBX}' action='set' key='k1' />` copies all metadata (ValueType, ObservationIdentifier, ObservationResultStatus), then individual fields are overridden.
- Copy ALL optional segments from the schema for completeness, even if typically empty.

### subtransform — Call another DTL

```xml
<subtransform class='MyApp.Transform.PIDToPatient' targetObj='target.Patient' sourceObj='source'/>
```

### code — Inline ObjectScript

```xml
<code>
<![CDATA[
  Set tMRN = source.GetValueAt("PID:3.1")
  If tMRN '= "" {
    Set target.PatientMRN = $ZSTRIP(tMRN, "<>W")
  }
]]>
</code>
```

### lookup — Table lookup

```xml
<assign value='..Lookup("GenderMap", source.{PID:AdministrativeSex})' property='target.Gender' action='set'/>
```

### trace — Debug output

```xml
<trace value='"Processing patient: "_source.{PID:PatientName}'/>
```

## HL7 Virtual Document Paths

Used in DTL when source/target is `EnsLib.HL7.Message`:

```
source.{SegmentName:Field.Component.SubComponent}
source.{SegmentName(repeat):Field(repeat).Component}
source.{GroupName(index).SegmentName:Field}
```

### Field Path Notation: Always Use Named Paths

**MANDATORY: Use named property paths, not GetValueAt() or numeric paths.** Named paths are self-documenting, type-safe, and consistent across DTLs and routing rules.

#### Why Named Paths Matter

**BAD (GetValueAt - never use this):**
```xml
<assign value='source.GetValueAt("PIDgrp.PID:3.1")' property='target.PatientID' action='set' />
<assign value='source.GetValueAt("PIDgrp.PID:5.1")' property='target.LastName' action='set' />
<assign value='source.GetValueAt("PIDgrp.PV1:2")' property='target.PatientClass' action='set' />
```
Problems: Unreadable, fragile (string typos), no autocomplete, hard to debug.

**BETTER (Numeric paths - valid but not preferred):**
```xml
<assign value='source.{PIDgrp.PID:3.1}' property='target.PatientID' action='set' />
<assign value='source.{PIDgrp.PID:5.1}' property='target.LastName' action='set' />
<assign value='source.{PIDgrp.PV1:2}' property='target.PatientClass' action='set' />
```
Improvement: Direct property access, but field numbers require documentation lookup.

**BEST (Named paths - always use this):**
```xml
<assign value='source.{PIDgrp.PID:PatientIdentifierList.IDNumber}' property='target.PatientID' action='set' />
<assign value='source.{PIDgrp.PID:PatientName.FamilyName}' property='target.LastName' action='set' />
<assign value='source.{PIDgrp.PV1:PatientClass}' property='target.PatientClass' action='set' />
```
✓ Self-documenting
✓ Maintainable
✓ Type-safe
✓ Matches HL7 specification names

#### Benefits of Named Property Paths

1. **Self-Documentation** - Code reads like plain English, no need to lookup "what is PID:3.1?"
2. **Type Safety** - IRIS validates named paths at compile time, catches errors early
3. **Consistency** - Same syntax used in DTLs, routing rules, and schema documentation
4. **Maintainability** - Future developers understand intent without HL7 specification lookup
5. **Debugger Friendly** - Named paths visible in trace viewer, numeric paths show as indexes
6. **Refactor Proof** - Named paths survive schema updates better than numeric positions

#### When to Use Each Approach

| Scenario | Use | Reason |
|----------|-----|--------|
| Static field access | Named path: `source.{PID:PatientName.FamilyName}` | Best readability |
| Repeating segment loop | Named path: `source.{OBX(k1):ObservationValue}` | k1 is standard iterator variable |
| Dynamic path construction | `GetValueAt()` | Only when path is computed at runtime |
| Field count | Named path: `source.{OBX(*)}` | Counts occurrences |

**Key Rule:** Use **k1, k2, k3, etc.** to indicate nesting level. After a loop ends, keys can be reused for the next sequential loop at the same level.

#### Discovering Named Paths

Use `get_schema.py` to find named field paths:

```bash
# Get all fields for a segment
<python> .claude/skills/interclaw/scripts/hl7/get_schema.py --server myserver --namespace HSLIB --segment 2.5.1:PID --fields

# Get full message structure with groups
<python> .claude/skills/interclaw/scripts/hl7/get_schema.py --server myserver --namespace HSLIB --message 2.5.1:VXU_V04
```

Output shows: `PID:3 PatientIdentifierList` → Use `PID:PatientIdentifierList`

#### Common Named Path Reference

**MSH (Message Header):**
```
source.{MSH:MessageType.MessageCode}              MSH-9.1: ADT, ORM, ORU, VXU, etc.
source.{MSH:MessageType.TriggerEvent}             MSH-9.2: A01, A02, R01, V04, etc.
source.{MSH:SendingApplication.NamespaceID}       MSH-3.1: Sending system ID
source.{MSH:SendingFacility.NamespaceID}          MSH-4.1: Sending facility
source.{MSH:ReceivingApplication.NamespaceID}     MSH-5.1: Receiving system
source.{MSH:DateTimeOfMessage}                    MSH-7: Timestamp
```

**EVN (Event Type):**
```
source.{EVN:EventTypeCode}                        EVN-1: Event type (A01, A02, etc.)
source.{EVN:RecordedDateTime}                     EVN-2: Recorded date/time (full TS)
source.{EVN:RecordedDateTime.Time}                EVN-2.1: Date/time value
source.{EVN:DateTimePlannedEvent}                  EVN-3: Planned event date/time
source.{EVN:EventReasonCode}                      EVN-4: Reason code
source.{EVN:EventOccurred}                        EVN-6: Event occurred date/time
```

**PID (Patient Identification):**
```
source.{PID:PatientIdentifierList.IDNumber}       PID-3.1: MRN/Patient ID
source.{PID:PatientIdentifierList.AssigningAuthority}  PID-3.4: Issuing facility
source.{PID:PatientName.FamilyName}               PID-5.1: Last name
source.{PID:PatientName.GivenName}                PID-5.2: First name
source.{PID:DateTimeofBirth}                      PID-7: DOB
source.{PID:AdministrativeSex}                    PID-8: Gender
source.{PID:PatientAddress.StreetAddress}         PID-11.1: Address line 1
source.{PID:PatientAddress.City}                  PID-11.3: City
source.{PID:PatientAddress.StateorProvince}       PID-11.4: State
source.{PID:PatientAddress.ZipOrPostalCode}       PID-11.5: Zip
source.{PID:PhoneNumberHome}                      PID-13: Phone
source.{PID:PatientAccountNumber}                 PID-18: Account number (CX type)
source.{PID:PatientAccountNumber.IDNumber}        PID-18.1: Account number value
source.{PID:SSNNumberPatient}                     PID-19: SSN
```

**PV1 (Patient Visit):**
```
source.{PV1:SetIDPV1}                             PV1-1: Sequence number
source.{PV1:PatientClass}                         PV1-2: I, O, E (Inpatient/Outpatient/Emergency)
source.{PV1:AssignedPatientLocation.PointofCare}  PV1-3.1: Ward/Unit
source.{PV1:AssignedPatientLocation.Room}         PV1-3.2: Room number
source.{PV1:AssignedPatientLocation.Bed}          PV1-3.3: Bed number
source.{PV1:AttendingDoctor.IDNumber}             PV1-7.1: Attending physician ID
source.{PV1:AttendingDoctor.FamilyName}           PV1-7.2: Attending last name
source.{PV1:PatientType}                          PV1-18: Patient type
source.{PV1:VisitNumber}                          PV1-19: Visit number (CX type)
source.{PV1:VisitNumber.IDNumber}                 PV1-19.1: Visit number value
source.{PV1:AdmitDateTime}                        PV1-44: Admission date/time
source.{PV1:DischargeDateTime}                    PV1-45: Discharge date/time
```

**AL1 (Allergy Information):**
```
source.{AL1:SetIDAL1}                             AL1-1: Sequence number
source.{AL1:AllergenTypeCode}                     AL1-2: DA (Drug), FA (Food), etc.
source.{AL1:AllergenCodeMnemonicDescription.Identifier}  AL1-3.1: Allergen code
source.{AL1:AllergenCodeMnemonicDescription.Text}        AL1-3.2: Allergen name
source.{AL1:AllergySeverityCode}                  AL1-4: SV (Severe), MO (Moderate), etc.
source.{AL1:AllergyReactionCode}                  AL1-5: Reaction description
```

**ORC (Common Order):**
```
source.{ORC:OrderControl}                         ORC-1: NW, CA, RE, etc.
source.{ORC:PlacerOrderNumber.EntityIdentifier}   ORC-2.1: Placer order ID
source.{ORC:FillerOrderNumber.EntityIdentifier}   ORC-3.1: Filler order ID
source.{ORC:OrderStatus}                          ORC-5: Order status
source.{ORC:OrderingProvider.IDNumber}            ORC-12.1: Ordering physician ID
source.{ORC:EnterersLocation.PointofCare}         ORC-13.1: Point of care
source.{ORC:EnterersLocation.Room}                ORC-13.2: Room / department name
source.{ORC:EnterersLocation.Facility.NamespaceID}  ORC-13.4.1: Facility namespace ID
source.{ORC:OrderingFacilityName}                 ORC-21: Facility name
```

**RXA (Pharmacy/Treatment Administration):**
```
source.{RXA:GiveSubIDCounter}                     RXA-1: Sub-ID counter
source.{RXA:DateTimeStartofAdministration}        RXA-3: Administration start
source.{RXA:AdministeredCode.Identifier}          RXA-5.1: Administered drug/vaccine code
source.{RXA:AdministeredCode.Text}                RXA-5.2: Drug/vaccine name
source.{RXA:AdministeredAmount}                   RXA-6: Amount administered
source.{RXA:AdministeredatLocation.PointofCare}   RXA-11.1: Point of care
source.{RXA:AdministeredatLocation.Room}          RXA-11.2: Room / department name
source.{RXA:AdministeredatLocation.Facility.NamespaceID}  RXA-11.4.1: Facility namespace ID
```

**TQ1 (Timing/Quantity - Pharmacy Orders):**
```
source.{TQ1:Quantity.Quantity}                    TQ1-2.1: Quantity value
source.{TQ1:RepeatPattern}                        TQ1-3: Frequency (e.g., QID, BID)
source.{TQ1:StartDateTime}                        TQ1-7: Start date/time
source.{TQ1:EndDateTime}                          TQ1-8: End date/time
```

**RXO (Pharmacy Order):**
```
source.{RXO:RequestedGiveCode.Identifier}         RXO-1.1: Drug code
source.{RXO:RequestedGiveCode.Text}               RXO-1.2: Drug name
source.{RXO:RequestedGiveAmountMinimum}           RXO-2: Dose amount
source.{RXO:RequestedGiveUnits.Identifier}        RXO-4.1: Dose units (mg, mL, etc.)
source.{RXO:RequestedGiveRateAmount}              RXO-17: Infusion rate
```

**RXE (Pharmacy Encoded Order):**
```
source.{RXE:QuantityTiming.Quantity.Quantity}     RXE-1.1.1: Quantity to dispense
source.{RXE:GiveCode.Identifier}                  RXE-2.1: Drug code
source.{RXE:GiveCode.Text}                        RXE-2.2: Drug name
source.{RXE:GiveAmountMinimum}                    RXE-3: Dose amount
source.{RXE:GiveUnits.Identifier}                 RXE-5.1: Dose units
source.{RXE:PharmacyTreatmentSuppliersSpecialDispensingInstructions}  RXE-9: SIG (directions)
```

**OBR (Observation Request):**
```
source.{OBR:SetIDOBR}                             OBR-1: Sequence number
source.{OBR:PlacerOrderNumber.EntityIdentifier}   OBR-2.1: Placer order ID
source.{OBR:FillerOrderNumber.EntityIdentifier}   OBR-3.1: Filler order ID
source.{OBR:UniversalServiceIdentifier.Identifier}  OBR-4.1: Test code
source.{OBR:UniversalServiceIdentifier.Text}      OBR-4.2: Test name
source.{OBR:ObservationDateTime}                  OBR-7: Observation date/time
source.{OBR:ResultsRptStatusChgsDateTime}         OBR-22: Result status date
source.{OBR:ResultStatus}                         OBR-25: F (Final), P (Preliminary)
```

**OBX (Observation Result):**
```
source.{OBX(k1):SetIDOBX}                         OBX-1: Sequence number
source.{OBX(k1):ValueType}                        OBX-2: NM, ST, TX, CE, etc.
source.{OBX(k1):ObservationIdentifier.Identifier}  OBX-3.1: Result code
source.{OBX(k1):ObservationIdentifier.Text}       OBX-3.2: Result name
source.{OBX(k1):ObservationValue}                 OBX-5: Result value
source.{OBX(k1):Units.Identifier}                 OBX-6.1: Units of measure
source.{OBX(k1):ReferencesRange}                  OBX-7: Normal range
source.{OBX(k1):AbnormalFlags}                    OBX-8: H (High), L (Low), N (Normal)
source.{OBX(k1):ObservationResultStatus}          OBX-11: F, P, etc.
```

#### Examples: Repeating Groups with Named Paths

**Before (numeric paths in loop):**
```xml
<foreach property='source.{OBXgrp()}' key='k1'>
  <assign value='source.{OBXgrp(k1).OBX:1}' property='target.{OBXgrp(k1).OBX:SetIDOBX}' action='set' />
  <assign value='source.{OBXgrp(k1).OBX:3.1}' property='target.{OBXgrp(k1).OBX:ObservationIdentifier.Identifier}' action='set' />
  <assign value='source.{OBXgrp(k1).OBX:5}' property='target.{OBXgrp(k1).OBX:ObservationValue}' action='set' />
</foreach>
```

**After (named paths with k1):**
```xml
<foreach property='source.{OBXgrp()}' key='k1'>
  <assign value='source.{OBXgrp(k1).OBX:SetIDOBX}' property='target.{OBXgrp(k1).OBX:SetIDOBX}' action='set' />
  <assign value='source.{OBXgrp(k1).OBX:ObservationIdentifier.Identifier}' property='target.{OBXgrp(k1).OBX:ObservationIdentifier.Identifier}' action='set' />
  <assign value='source.{OBXgrp(k1).OBX:ObservationValue}' property='target.{OBXgrp(k1).OBX:ObservationValue}' action='set' />
</foreach>
```

**Sequential loops (k1 can be reused after first loop ends):**
```xml
<foreach property='source.{OBXgrp()}' key='k1'>
  <assign value='source.{OBXgrp(k1).OBX:ObservationValue}' property='target.{OBXgrp(k1).OBX:ObservationValue}' action='set' />
</foreach>

<!-- After loop ends, k1 is available for reuse -->
<foreach property='source.{NK1()}' key='k1'>
  <assign value='source.{NK1(k1):Name.FamilyName}' property='target.{NK1(k1):Name.FamilyName}' action='set' />
</foreach>
```

**Nested repeating groups (key number indicates nesting level):**
```xml
<foreach property='source.{ORDERgrp()}' key='k1'>
  <assign value='source.{ORDERgrp(k1).ORC:OrderControl}' property='target.{ORDERgrp(k1).ORC:OrderControl}' action='set' />

  <!-- Nested loop uses k2, not k1 -->
  <foreach property='source.{ORDERgrp(k1).OBXgrp()}' key='k2'>
    <assign value='source.{ORDERgrp(k1).OBXgrp(k2).OBX:ObservationValue}' property='target.{ORDERgrp(k1).OBXgrp(k2).OBX:ObservationValue}' action='set' />
  </foreach>
</foreach>
```

**Triple-nested example (k1, k2, k3 for three levels):**
```xml
<foreach property='source.{ORDERgrp()}' key='k1'>
  <foreach property='source.{ORDERgrp(k1).OBXgrp()}' key='k2'>
    <foreach property='source.{ORDERgrp(k1).OBXgrp(k2).NTEgrp()}' key='k3'>
      <assign value='source.{ORDERgrp(k1).OBXgrp(k2).NTEgrp(k3).NTE:Comment}' property='target.{ORDERgrp(k1).OBXgrp(k2).NTEgrp(k3).NTE:Comment}' action='set' />
    </foreach>
  </foreach>
</foreach>
```

**Key insight:** Key number (k1, k2, k3) always indicates nesting depth. Keys can be reused after a loop ends for the next sequential loop at the same level.

#### Best Practices Summary

**DO:**
- ✓ Always use named property paths: `source.{PID:PatientName.FamilyName}`
- ✓ Use k1, k2, k3 to indicate nesting level (k1 = first level, k2 = nested in k1, etc.)
- ✓ Reuse keys after loops end: After `</foreach>` with k1, you can start a new `<foreach key='k1'>`
- ✓ Run `get_schema.py --fields` to discover correct named paths
- ✓ Use `source.{OBX(*)}` to count repeating segments
- ✓ Keep DTL assign statements simple (no code blocks unless explicitly required)

**DON'T:**
- ✗ Never use GetValueAt() for static field access
- ✗ Never use numeric paths when named paths are available
- ✗ Never use the same key for nested loops (k1 inside k1 causes confusion)
- ✗ Never add code blocks for simple field assignments (DTL syntax handles it)

### Messages with Groups (e.g., VXU_V04, ORM_O01)
```xml
source.{ORCgrp(1).ORC:13.2}       <!-- ORC-13.2 in first ORCgrp (VXU_V04) -->
source.{ORCgrp(k1).RXA:11.2}      <!-- RXA-11.2 in iterated ORCgrp -->
source.{ORCgrp(1).ORC:1.1}        <!-- ORC-1.1 in ORM_O01 -->
```

### Nested Same-Name Groups (CRITICAL)

When a group contains a child group with the **same name**, the OUTER repeating group gets its name doubled with "grp" appended. This is how IRIS resolves the ambiguity.

**Example: ORU_R01** has `PIDgrp` containing another `PIDgrp`:
```
PIDgrp (repeating, outer)  →  path name: PIDgrpgrp
  PIDgrp (optional, inner) →  path name: PIDgrp
  ORCgrp (repeating)       →  path name: ORCgrp
```

Correct paths for ORU_R01 (always use named field paths):
```xml
source.{PIDgrpgrp(1).PIDgrp.PV1grp.PV1:AssignedPatientLocation.PointofCare}   <!-- PV1-3.1 -->
source.{PIDgrpgrp(1).PIDgrp.PID:PatientIdentifierList.IDNumber}               <!-- PID-3.1 -->
source.{PIDgrpgrp(1).ORCgrp(1).OBR:UniversalServiceIdentifier.Identifier}     <!-- OBR-4.1 -->
source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(k1).OBX:ValueType}                     <!-- OBX-2 in loop -->
```

**WRONG** (will error "not mapped in schema"):
```xml
source.{PIDgrp(1).PIDgrp.PV1grp.PV1:3.1}     <!-- WRONG: inner name used for outer -->
source.{PIDgrp(1).PIDgrpgrp.PV1grp.PV1:3.1}   <!-- WRONG: doubled name on inner -->
```

**Rule**: When schema shows `GroupName > GroupName` (same name nested), use `GroupNamegrp()` for the outer one, `GroupName` for the inner one.

Use `get_schema.py --message <cat:msg>` to see the group structure and determine correct paths.

## Example: HL7 ADT A01 to A08 Transform

```objectscript
Class MyApp.Transform.ADTA01toA08 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.5.1:ADT_A01' targetDocType='2.5.1:ADT_A08'
           create='copy' language='objectscript' >

  <!-- Change trigger event to A08 (Update Patient Information) -->
  <assign value='"A08"' property='target.{MSH:MessageType.TriggerEvent}' action='set'/>
  <assign value='"ADT^A08"' property='target.{MSH:MessageType}' action='set'/>

  <!-- Update message control ID -->
  <assign value='source.{MSH:MessageControlID}_"_A08"' property='target.{MSH:MessageControlID}' action='set'/>

  <!-- Update timestamp -->
  <assign value='##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S", $HOROLOG)' property='target.{MSH:DateTimeOfMessage}' action='set'/>

  <!-- Copy all PID, PV1 segments as-is (create='copy' handles this) -->

</transform>
}

}
```

## Example: HL7 PID to SDA3 Patient

```objectscript
Class MyApp.Transform.PIDToSDA3Patient Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, HS.SDA3.Container) ]
{

Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='HS.SDA3.Container'
           sourceDocType='2.5.1:ADT_A01' create='new' language='objectscript' >

  <!-- Patient demographics -->
  <assign value='source.{PID:PatientName.FamilyName}' property='target.Patient.Name.FamilyName' action='set'/>
  <assign value='source.{PID:PatientName.GivenName}' property='target.Patient.Name.GivenName' action='set'/>
  <assign value='source.{PID:DateTimeofBirth}' property='target.Patient.BirthTime' action='set'/>

  <!-- Gender mapping via lookup table -->
  <assign value='..Lookup("GenderMap", source.{PID:AdministrativeSex})' property='target.Patient.Gender.Code' action='set'/>

  <!-- Patient identifiers -->
  <foreach property='source.{PID:PatientIdentifierList()}' key='k1'>
    <assign value='source.{PID:PatientIdentifierList(k1).IDNumber}' property='target.Patient.PatientNumbers.(k1).Number' action='set'/>
    <assign value='source.{PID:PatientIdentifierList(k1).AssigningAuthority.NamespaceID}' property='target.Patient.PatientNumbers.(k1).Organization.Code' action='set'/>
    <assign value='source.{PID:PatientIdentifierList(k1).IdentifierTypeCode}' property='target.Patient.PatientNumbers.(k1).NumberType' action='set'/>
  </foreach>

  <!-- Address -->
  <assign value='source.{PID:PatientAddress.StreetAddress}' property='target.Patient.Addresses.(1).Street' action='set'/>
  <assign value='source.{PID:PatientAddress.City}' property='target.Patient.Addresses.(1).City.Code' action='set'/>
  <assign value='source.{PID:PatientAddress.StateorProvince}' property='target.Patient.Addresses.(1).State.Code' action='set'/>
  <assign value='source.{PID:PatientAddress.ZipOrPostalCode}' property='target.Patient.Addresses.(1).Zip.Code' action='set'/>

</transform>
}

}
```

## Example: ORU_R01 to MDM_T02 Conversion

When a downstream EMR expects document-style results (MDM) rather than lab-style results (ORU), convert ORU_R01 to MDM_T02. This is common when radiology or pathology results need to appear as clinical documents.

**Key points:**
- Use `create='new'` because you are building a different message structure — segments must be mapped individually
- Update MSH:9 to `MDM^T02^MDM_T02` so the receiver recognizes the message type
- MDM_T02 requires these segments: MSH, EVN, PID, PV1, TXA, ORC, OBR, OBX
- The TXA (Transcription Document Header) segment does not exist in ORU and must be constructed from scratch

### TXA Segment Construction

| Field | Value | Notes |
|-------|-------|-------|
| TXA-1 | Set ID (e.g., `"1"`) | Sequential counter |
| TXA-2 | Document type | Use a lookup table to map OBR:4 procedure codes to document types (e.g., `"RAD"`, `"PATH"`) |
| TXA-12 | Unique document ID | Often derived from OBR:3 (Filler Order Number) or a generated value |

```objectscript
Class MyApp.DTL.ORUToMDM Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.5.1:ORU_R01' targetDocType='2.5.1:MDM_T02'
           create='new' language='objectscript' >

  <!-- MSH: copy and update message type -->
  <assign value='source.{MSH}' property='target.{MSH}' action='set'/>
  <assign value='"MDM"' property='target.{MSH:MessageType.MessageCode}' action='set'/>
  <assign value='"T02"' property='target.{MSH:MessageType.TriggerEvent}' action='set'/>
  <assign value='"MDM_T02"' property='target.{MSH:MessageType.MessageStructure}' action='set'/>

  <!-- EVN -->
  <assign value='"T02"' property='target.{EVN:EventTypeCode}' action='set'/>
  <assign value='source.{MSH:DateTimeOfMessage}' property='target.{EVN:RecordedDateTime}' action='set'/>

  <!-- PID and PV1: copy from ORU nested groups -->
  <assign value='source.{PIDgrpgrp(1).PIDgrp.PID}' property='target.{PID}' action='set'/>
  <assign value='source.{PIDgrpgrp(1).PIDgrp.PV1grp.PV1}' property='target.{PV1}' action='set'/>

  <!-- TXA: construct from scratch -->
  <assign value='"1"' property='target.{TXA:SetIDTXA}' action='set'/>
  <assign value='..Lookup("DocumentTypeMap", source.{PIDgrpgrp(1).ORCgrp(1).OBR:UniversalServiceIdentifier.Identifier})' property='target.{TXA:DocumentType}' action='set'/>
  <assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:FillerOrderNumber.EntityIdentifier}' property='target.{TXA:UniqueDocumentNumber.EntityIdentifier}' action='set'/>

  <!-- ORC, OBR -->
  <assign value='source.{PIDgrpgrp(1).ORCgrp(1).ORC}' property='target.{OBXgrp(1).ORC}' action='set'/>
  <assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR}' property='target.{OBXgrp(1).OBR}' action='set'/>

  <!-- OBX segments -->
  <foreach property='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp()}' key='k1'>
    <assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(k1).OBX}' property='target.{OBXgrp(1).OBXgrp(k1).OBX}' action='set'/>
  </foreach>

</transform>
}

}
```

## OBX Removal After NTE Concatenation

When concatenating multiple OBX-5 values into an NTE-3 field (e.g., combining report lines into a single comment), use `action='remove'` on the source OBX entries to avoid duplicate data in the output. Without removal, the same content appears in both the OBX segments and the NTE segment.

```xml
<!-- First, concatenate OBX-5 values into NTE-3 -->
<foreach property='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp()}' key='k1'>
  <assign value='target.{OBXgrp(1).OBXgrp(1).NTE(1):3}_source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(k1).OBX:5}_"\.br\"'
    property='target.{OBXgrp(1).OBXgrp(1).NTE(1):3}' action='set'/>
</foreach>

<!-- Then remove the original OBX segments so data is not duplicated -->
<assign value='""' property='target.{OBXgrp(1).OBXgrp(1).OBX}' action='remove'/>
```

**Tip**: Always check `/trace` after this pattern to verify the output contains the NTE but not the removed OBX segments.

## Using DTL in a Business Process

### In BPL:
```xml
<transform name='Transform' class='MyApp.Transform.PIDToSDA3Patient'
  source='request' target='context.sdaContainer'/>
```

### In Code:
```objectscript
Set tSC = $ClassMethod("MyApp.Transform.PIDToSDA3Patient", "Transform", pRequest, .tOutput)
```

## Common Pitfalls and Testing Best Practices

Hard-won lessons from building transforms in production. Each pitfall below has caused silent failures where the DTL appeared to work but produced incorrect output.

### Class Name Restrictions

ObjectScript class names cannot begin with a digit. A class like `Demo.DTL.251ORUR01ToORUR01` will fail with a cryptic "Save failed with status 400" error on push. The error gives no indication that the class name is the problem.

This matters because the default naming convention derives class names from HL7 schema identifiers (e.g., `2.5.1:ORU_R01`), and stripping special characters produces a name starting with `2`. The fix is to prepend `V` (for "version") when the generated name starts with a digit: `Demo.DTL.V251ORUR01ToV251ORUR01`.

**Debugging approach that isolated this**: Building test DTLs with incrementally complex logic (basic assign, single foreach, nested loops, conditionals) all succeeded. Only the original class with the numeric-prefix name failed. Renaming the class with identical logic succeeded immediately. This confirmed the issue was the name, not the transformation logic.

| Test | Purpose | Result |
|------|---------|--------|
| `TestMinimal` | Verify basic assign works | Success |
| `TestLoop` | Add single foreach | Success |
| `TestNestedLoop` | Add nested loops with field access | Success |
| `TestWithIf` | Add conditional logic and utility functions | Success |
| `251ORUR01...` (numeric prefix) | Full logic with bad name | Failure (400) |
| `ORUToORU` (valid name) | Full logic, same transforms | Success |

### Field Name Casing

HL7 field names in IRIS schemas are case-sensitive. A single wrong letter -- uppercase where lowercase is expected, or vice versa -- causes the field to be silently ignored. The DTL compiles without error, but the value never appears in the output.

**Example**: OBX-3.3 (Name of Coding System)

| Wrong | Right |
|-------|-------|
| `NameofCodingSystem` | `NameOfCodingSystem` |

The difference is the capital "O" in "Of". The schema output from `get_schema.py` shows the exact casing. Copy field names character-for-character from the schema output -- never type them from memory.

Other commonly miscased fields:

| Segment | Wrong | Right |
|---------|-------|-------|
| PID | `DateTimeofBirth` | `DateTimeofBirth` (lowercase "of" -- this one IS lowercase) |
| PV1 | `AssignedpatientLocation` | `AssignedPatientLocation` |
| OBR | `UniversalserviceIdentifier` | `UniversalServiceIdentifier` |
| OBX | `ObservationIdentifier.nameOfCodingSystem` | `ObservationIdentifier.NameOfCodingSystem` |

**Rule**: Never assume casing. Always pull the schema and copy the exact field name.

### Test Message Requirements

A test message must exercise the transformation logic. If the DTL truncates strings longer than 20 characters, the test message must contain strings longer than 20 characters. If the DTL standardizes a code system value, the test message must contain a non-standard value that needs correction.

**Bad test message** (does not reveal whether the DTL works):
```
OBX|1|ST|2951-2^Sodium^LN||140|mmol/L
```
This has a short order name ("Sodium") and the correct code system ("LN"). The DTL would pass it through unchanged. You cannot tell if truncation or code system standardization is working.

**Good test message** (exercises every transformation rule):
```
OBX|1|ST|2951-2^Sodium, Serum or Plasma Level^LOINC||140|mmol/L
OBX|2|ST|2823-3^Potassium, Serum or Plasma Level^loinc||4.2|mmol/L
OBX|3|NM|2160-0^Creatinine, Enzymatic Method Result^LN||1.1|mg/dL
```

This exercises:
- Truncation: "Sodium, Serum or Plasma Level" (30 chars) and "Potassium, Serum or Plasma Level" (32 chars) exceed 20 characters
- Code system standardization: "LOINC" and "loinc" both need correction to "LN"
- Pass-through: "LN" is already correct and should not be changed
- Multiple OBX segments: verifies the foreach loop processes all repetitions

**After the DTL runs**, the diff should show:
```
OBX-3.2: "Sodium, Serum or Plasma Level" -> "Sodium, Serum or Pla" (truncated to 20)
OBX-3.3: "LOINC" -> "LN" (standardized)
OBX-3.2: "Potassium, Serum or Plasma Level" -> "Potassium, Serum or " (truncated to 20)
OBX-3.3: "loinc" -> "LN" (standardized)
OBX-3.2: "Creatinine, Enzymatic Method Result" -> "Creatinine, Enzymati" (truncated to 20)
OBX-3.3: "LN" -> "LN" (unchanged -- already correct)
```

If the diff shows no changes, the test message did not exercise the DTL. Fix the test data.

### Schema Verification Process

Before writing any DTL, follow this exact workflow:

1. **Pull the segment schema with field names:**
   ```bash
   <python> .claude/skills/interclaw/scripts/hl7/get_schema.py \
     --server myserver --namespace HSLIB --segment 2.5.1:OBX --fields
   ```

2. **Locate the field you need in the output.** For example, the schema shows:
   ```
   3  ObservationIdentifier (CE)
      1  Identifier
      2  Text
      3  NameOfCodingSystem
      4  AlternateIdentifier
      5  AlternateText
      6  NameOfAlternateCodingSystem
   ```

3. **Copy the field name exactly as shown.** Do not retype it. The schema says `NameOfCodingSystem` -- use exactly that. Not `NameofCodingSystem`, not `nameOfCodingSystem`, not `CodingSystem`.

4. **Build the full path:** `OBX:ObservationIdentifier.NameOfCodingSystem`

5. **Verify with test_dtl.py --diff after pushing.** If the field does not appear in the diff output, the path is wrong -- re-check casing against the schema.

### Positional Number Validation

When a specification references fields by positional number (e.g., "set OBX-3.3 to LN"), always verify the number maps to the field you expect:

1. Pull the segment schema with `--fields`
2. Find the positional number in the output
3. Confirm the field name matches the spec's intent

**Example**: A spec says "truncate OBX-3.2 to 20 characters."

Schema output for OBX:
```
3  ObservationIdentifier (CE)
   1  Identifier
   2  Text               <-- OBX-3.2 = ObservationIdentifier.Text
   3  NameOfCodingSystem  <-- OBX-3.3 = ObservationIdentifier.NameOfCodingSystem
```

OBX-3.2 is `ObservationIdentifier.Text` (the order/result name). The DTL should use:
```xml
<assign value='..SubString(source.{OBX:ObservationIdentifier.Text}, 1, 20)'
  property='target.{OBX:ObservationIdentifier.Text}' action='set'/>
```

Never write `OBX:3.2` in the DTL. Always translate the positional number to the named path using the schema.
