# Routing Rules Reference

Routing Rules provide declarative if/then logic for message dispatch. They're used with routing engine business processes to direct messages to different targets based on message content.

## Class Hierarchy

```
Ens.Rule.Definition
  └── Your.Custom.RoutingRule
```

Routing rules are used with:
```
EnsLib.MsgRouter.RoutingEngine          (generic)
EnsLib.HL7.MsgRouter.RoutingEngine      (HL7-specific)
EnsLib.MsgRouter.VDocRoutingEngine      (virtual document)
```

## Rule Best Practices (from reference implementations)

1. **Always set `alias`** on `<ruleDefinition>` — this is the display name in the Management Portal rule editor
2. **Use `Parameter RuleAssistClass`** (not `RuleAssist`) — the correct parameter name
3. **Add `<comment text="...">` inside every `<when>` block** — these show in the visual rule editor and document intent
4. **Use named field paths** like `OBR:UniversalServiceIdentifier.Identifier` instead of numeric `OBR:4.1` — self-documenting
5. **Use `<constraint>` for message type filtering** instead of long `||`-chained conditions:
   - `<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03"/>` (declarative, efficient)
   - NOT: `condition="HL7.{MSH:MessageType.TriggerEvent}=&quot;A01&quot;||HL7.{MSH:MessageType.TriggerEvent}=&quot;A02&quot;||..."` (verbose, slow)
6. **`<return/>` means exclusive routing** — use it when only ONE target should receive the message. **Omit** `<return/>` when a message should go to MULTIPLE targets (fan-out).
7. **OBR-4.1 must be exact match** in test messages — if the rule checks `= "MI"`, the test message must have `OBR-4.1 = "MI"`, not `"MI12345"`

## Rule Class Structure

```objectscript
Class MyApp.HL7RoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="MyApp.Rule.MainRouter" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="MyApp.Production">

<ruleSet name="Main Routing" effectiveBegin="" effectiveEnd="">

  <rule name="ADT Messages" disabled="false">
    <constraint name="docCategory" value="2.5.1"/>
    <constraint name="docName" value="ADT_A01,ADT_A04,ADT_A08"/>
    <when condition="1">
      <comment text="Route all ADT messages through the ADT transform"/>
      <send transform="MyApp.Transform.ADTTransform" target="ADTProcessor"/>
      <return/>
    </when>
  </rule>

  <rule name="ORM Messages" disabled="false">
    <constraint name="docCategory" value="2.5.1"/>
    <constraint name="docName" value="ORM_O01"/>
    <when condition="1">
      <comment text="Pass ORM messages through to order processor"/>
      <send transform="" target="ORMProcessor"/>
      <return/>
    </when>
  </rule>

  <rule name="ORU Results" disabled="false">
    <constraint name="docCategory" value="2.5.1"/>
    <constraint name="docName" value="ORU_R01"/>
    <when condition="1">
      <comment text="Transform and route lab results"/>
      <send transform="MyApp.Transform.ORUTransform" target="LabResultsOp"/>
      <return/>
    </when>
  </rule>

  <rule name="Default" disabled="false">
    <when condition="1">
      <send transform="" target="UnhandledMessages"/>
    </when>
  </rule>

</ruleSet>

</ruleDefinition>
}

}
```

## RuleDefinition Attributes

| Attribute | Description |
|-----------|-------------|
| `context` | The routing engine class this rule works with |
| `production` | The production this rule is associated with |
| `alias` | Optional alias name |

## RuleSet Attributes

| Attribute | Description |
|-----------|-------------|
| `name` | Rule set name |
| `effectiveBegin` | Start date/time when this rule set is active |
| `effectiveEnd` | End date/time when this rule set expires |

## Rule Elements

### `<rule>` — A named rule

```xml
<rule name="Rule Name" disabled="false">
  <constraint name="msgClass" value="EnsLib.HL7.Message"/>
  <when condition="...">
    <send transform="..." target="..."/>
  </when>
</rule>
```

### `<constraint>` — Filter which messages this rule applies to

```xml
<constraint name="msgClass" value="EnsLib.HL7.Message"/>
<constraint name="docCategory" value="2.5.1"/>
<constraint name="docName" value="ADT_A01"/>
```

### `<when>` — Conditional test

```xml
<when condition="HL7.{MSH:MessageType.MessageCode}=&quot;ADT&quot;">
  <!-- actions if true -->
</when>
```

### `<send>` — Route to a target

```xml
<send transform="MyApp.SomeTransform" target="TargetConfigName"/>
```

- `transform` — optional DTL to apply before sending
- `target` — the production config name to send to

### `<return>` — Stop processing

```xml
<return/>
```

### `<delegate>` — Hand off to another rule

```xml
<delegate target="AnotherRuleClass"/>
```

## Condition Syntax

### HL7 Field Comparisons

```xml
<!-- Equals -->
condition="HL7.{MSH:MessageType.MessageCode}=&quot;ADT&quot;"

<!-- Not equals — use != (NOT '= which is ObjectScript syntax) -->
condition="HL7.{MSH:MessageType.MessageCode}!=&quot;SIU&quot;"

<!-- Contains -->
condition="HL7.{MSH:SendingApplication.NamespaceID}[&quot;EPIC&quot;"

<!-- Does not contain -->
condition="HL7.{MSH:SendingApplication.NamespaceID}'[&quot;TEST&quot;"

<!-- Multiple conditions (AND) -->
condition="HL7.{MSH:MessageType.MessageCode}=&quot;ADT&quot;&amp;&amp;HL7.{MSH:MessageType.TriggerEvent}=&quot;A01&quot;"

<!-- OR -->
condition="HL7.{MSH:MessageType.TriggerEvent}=&quot;A01&quot;||HL7.{MSH:MessageType.TriggerEvent}=&quot;A04&quot;"
```

**IMPORTANT**: Use `!=` for not-equals in rule conditions, NOT `'=` (ObjectScript syntax won't work in the rule expression parser).

**Note:** XML requires entity encoding: `"` → `&quot;`, `&` → `&amp;`, `<` → `&lt;`

### Built-in Functions

```xml
<!-- String length -->
condition="$LENGTH(HL7.{PID:PatientIdentifierList.IDNumber})>0"

<!-- Lookup table -->
condition="..Lookup(&quot;AcceptedFacilities&quot;, HL7.{MSH:SendingFacility.NamespaceID})'=&quot;&quot;"

<!-- Exists check -->
condition="HL7.{PID:PatientIdentifierList.IDNumber}'=&quot;&quot;"
```

## Example: HealthShare HL7 Routing Rule

Routes HL7 messages by type to appropriate processors:

```objectscript
Class MyApp.Rules.MainHL7Router Extends Ens.Rule.Definition
{

Parameter RuleAssist = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="MyApp.Production">
<ruleSet name="Main Routing" effectiveBegin="" effectiveEnd="">

  <!-- ADT: Admit/Discharge/Transfer -->
  <rule name="ADT to Hub" disabled="false">
    <constraint name="msgClass" value="EnsLib.HL7.Message"/>
    <constraint name="docCategory" value="2.5.1"/>
    <when condition="HL7.{MSH:MessageType.MessageCode}=&quot;ADT&quot;">
      <send transform="MyApp.Transform.ADTToSDA3" target="HS.Hub.WebServices"/>
    </when>
  </rule>

  <!-- ORU: Lab Results -->
  <rule name="Lab Results" disabled="false">
    <constraint name="msgClass" value="EnsLib.HL7.Message"/>
    <when condition="HL7.{MSH:MessageType.MessageCode}=&quot;ORU&quot;&amp;&amp;HL7.{MSH:MessageType.TriggerEvent}=&quot;R01&quot;">
      <send transform="MyApp.Transform.ORUToSDA3" target="HS.Hub.WebServices"/>
      <send transform="" target="LabArchiveFileOp"/>
    </when>
  </rule>

  <!-- ORM: Orders -->
  <rule name="Orders" disabled="false">
    <when condition="HL7.{MSH:MessageType.MessageCode}=&quot;ORM&quot;">
      <send transform="MyApp.Transform.ORMToSDA3" target="HS.Hub.WebServices"/>
    </when>
  </rule>

  <!-- SIU: Scheduling -->
  <rule name="Scheduling" disabled="false">
    <when condition="HL7.{MSH:MessageType.MessageCode}=&quot;SIU&quot;">
      <send transform="" target="SchedulingProcessor"/>
    </when>
  </rule>

  <!-- Catch-all: log unrecognized messages -->
  <rule name="Unhandled" disabled="false">
    <when condition="1">
      <send transform="" target="UnhandledMessageFileOp"/>
    </when>
  </rule>

</ruleSet>
</ruleDefinition>
}

}
```

## Modality-Based Routing Pattern (Best Practice)

When routing by message content (e.g., imaging modality), use `docName` constraints to separate message types into distinct rule blocks, and `<return>` after each `<send>` to stop processing:

```xml
<ruleSet name="" effectiveBegin="" effectiveEnd="">

  <!-- ORU rules block -->
  <rule name="ORU Message Rules">
    <constraint name="docCategory" value="2.5.1"/>
    <constraint name="docName" value="ORU_R01"/>
    <when condition="HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:4.1}=&quot;MI&quot;">
      <send transform="MyApp.DTL.XrayTransform" target="To_EMR"/>
      <return/>
    </when>
    <when condition="HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:4.1}=&quot;MC&quot;">
      <send transform="MyApp.DTL.CTTransform" target="To_EMR"/>
      <return/>
    </when>
  </rule>

  <!-- ORM rules block -->
  <rule name="ORM Message Rules">
    <constraint name="docCategory" value="2.5.1"/>
    <constraint name="docName" value="ORM_O01"/>
    <when condition="HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:4.1}=&quot;MU&quot;">
      <send transform="MyApp.DTL.UltrasoundTransform" target="To_EMR"/>
      <return/>
    </when>
    <when condition="1">
      <send transform="" target="To_EMR"/>
      <return/>
    </when>
  </rule>

</ruleSet>
```

**Key patterns:**
- Use **`docName` constraints** to separate ORU vs ORM into distinct rule blocks (not separate rules per modality)
- Use **`=` exact match** on field values like `OBR:4.1`, NOT `[` (contains) which could cause false matches
- Use **`<return/>`** after `<send>` to stop processing after first match
- Use a **catch-all** `<when condition="1">` at the end of each block for unmatched messages

## Multiple Targets (Fan-Out)

A single rule can send to multiple targets:

```xml
<when condition="HL7.{MSH:MessageType.MessageCode}=&quot;ADT&quot;">
  <send transform="MyApp.ADTToSDA3" target="HS.Hub.WebServices"/>
  <send transform="" target="ADTArchiveFileOp"/>
  <send transform="MyApp.ADTToFHIR" target="FHIRRepository"/>
</when>
```

## Rule Logging

Configure on the routing engine:
- `RuleLogging = "a"` — log all rule evaluations
- `RuleLogging = "e"` — log errors only
- `RuleLogging = "d"` — log delegates
- `RuleLogging = ""` — no logging

Rule logs are viewable in Management Portal under Interoperability > Message Viewer > Rule Log.
