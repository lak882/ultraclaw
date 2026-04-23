# Routing Rule Patterns

Best practices, structural patterns, fan-out, catch-all rules, and rule logging. Load when deciding how to structure a rule set.

## Constraint-First Filtering

Always use `<constraint>` to filter by message type before writing condition logic. Constraints are evaluated before the rule expression parser and are more efficient.

```xml
<!-- Good: constraint filters, condition handles business logic -->
<rule name="ADT Admissions">
  <constraint name="docCategory" value="2.5.1"/>
  <constraint name="docName" value="ADT_A01"/>
  <when condition="HL7.{MSH:SendingFacility.NamespaceID}=&quot;USDMC&quot;">
    <comment text="Route USDMC admissions to the hub"/>
    <send transform="MyApp.DTL.ADTTransform" target="HubOperation"/>
    <return/>
  </when>
</rule>

<!-- Bad: filtering by message type inside the condition -->
<rule name="ADT Admissions">
  <when condition="HL7.{MSH:MessageType.MessageCode}=&quot;ADT&quot;&amp;&amp;HL7.{MSH:MessageType.TriggerEvent}=&quot;A01&quot;">
    ...
  </when>
</rule>
```

When the constraint already isolates the message type exactly, use `condition="1"`:

```xml
<constraint name="docName" value="ADT_A01"/>
<when condition="1">
  <comment text="All A01 admissions go to the hub"/>
  <send transform="" target="HubOperation"/>
  <return/>
</when>
```

## return vs No return: Exclusive vs Fan-Out

`<return/>` stops rule evaluation after the first matching `<when>`. Omit it to allow subsequent rules to also match the same message.

```xml
<!-- Exclusive routing: only one target receives the message -->
<when condition="1">
  <send transform="" target="PrimarySystem"/>
  <return/>
</when>

<!-- Fan-out: message continues to next rules after this send -->
<when condition="1">
  <send transform="" target="PrimarySystem"/>
  <send transform="" target="AuditArchive"/>
</when>
```

## Modality-Based Routing Pattern

When routing by a coded field value (e.g., imaging modality, order type), group rules by message type using `docName` constraints and use exact match conditions:

```xml
<ruleSet name="Main Routing" effectiveBegin="" effectiveEnd="">

  <rule name="ORU Results">
    <constraint name="docCategory" value="2.5.1"/>
    <constraint name="docName" value="ORU_R01"/>
    <when condition="HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:UniversalServiceIdentifier.Identifier}=&quot;MI&quot;">
      <comment text="X-ray results to radiology system"/>
      <send transform="MyApp.DTL.XrayTransform" target="RadiologyOp"/>
      <return/>
    </when>
    <when condition="HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:UniversalServiceIdentifier.Identifier}=&quot;MC&quot;">
      <comment text="CT results to radiology system"/>
      <send transform="MyApp.DTL.CTTransform" target="RadiologyOp"/>
      <return/>
    </when>
    <when condition="1">
      <comment text="All other ORU results to default handler"/>
      <send transform="" target="DefaultResultsOp"/>
      <return/>
    </when>
  </rule>

  <rule name="ORM Orders">
    <constraint name="docCategory" value="2.5.1"/>
    <constraint name="docName" value="ORM_O01"/>
    <when condition="1">
      <comment text="All orders to order processor"/>
      <send transform="" target="OrderProcessor"/>
      <return/>
    </when>
  </rule>

</ruleSet>
```

## Catch-All Rule

Always include a catch-all at the end of the rule set to handle unmatched messages explicitly:

```xml
<rule name="Unhandled Messages" disabled="false">
  <when condition="1">
    <comment text="Log unrecognized messages to file for review"/>
    <send transform="" target="UnhandledMessageFileOp"/>
  </when>
</rule>
```

## Multiple Sends (Fan-Out)

A single `<when>` block can send to multiple targets. Omit `<return/>` to also allow subsequent rules to match:

```xml
<when condition="HL7.{MSH:MessageType.MessageCode}=&quot;ADT&quot;">
  <comment text="Route ADT to hub and archive"/>
  <send transform="MyApp.DTL.ADTToSDA3" target="HS.Hub.WebServices"/>
  <send transform="" target="ADTArchiveFileOp"/>
  <send transform="MyApp.DTL.ADTToFHIR" target="FHIRRepository"/>
</when>
```

## Rule Logging

Configure on the routing engine item in the production:

```xml
<Setting Target="Host" Name="RuleLogging">a</Setting>
```

| Value | Logs |
|-------|------|
| `a` | All rule evaluations |
| `e` | Errors only |
| `d` | Delegates |
| `` (empty) | Nothing |

Rule logs are viewable in Management Portal under Interoperability > Message Viewer > Rule Log.
