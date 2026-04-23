# Routing Rule Pitfalls

Gotchas to verify before pushing a routing rule. Load during review.

## RuleAssistClass, Not RuleAssist

The correct parameter name is `RuleAssistClass`. Using `RuleAssist` compiles without error but produces incorrect behavior in the rule editor — the assist class is silently ignored.

```objectscript
// Correct
Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

// Wrong — compiles, but rule editor assist does not work
Parameter RuleAssist = "EnsLib.HL7.MsgRouter.RuleAssist";
```

## != Not '= for Not-Equals

In routing rule `<when condition>` expressions, not-equals is `!=`. The ObjectScript operator `'=` is not valid in the rule expression parser and will cause a runtime evaluation error.

```xml
<!-- Correct -->
condition="HL7.{MSH:MessageType.TriggerEvent}!=&quot;A03&quot;"

<!-- Wrong — ObjectScript syntax, not valid in rule conditions -->
condition="HL7.{MSH:MessageType.TriggerEvent}'=&quot;A03&quot;"
```

## Use Constraints for Message Type, Not Conditions

Filtering message types inside `<when condition>` is verbose and evaluated later than constraints. Use `<constraint name="docName">` instead.

```xml
<!-- Correct -->
<constraint name="docName" value="ADT_A01"/>
<when condition="1">...</when>

<!-- Wrong — filtering inside condition -->
<when condition="HL7.{MSH:MessageType.MessageCode}=&quot;ADT&quot;&amp;&amp;HL7.{MSH:MessageType.TriggerEvent}=&quot;A01&quot;">...</when>
```

## Exact Match, Not Contains, for Coded Values

When matching coded field values like `OBR:UniversalServiceIdentifier.Identifier`, use `=` not `[`. The contains operator matches substrings: `OBR:4.1 [ "MI"` would match both `"MI"` and `"MICRO"`.

```xml
<!-- Correct -->
condition="HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:UniversalServiceIdentifier.Identifier}=&quot;MI&quot;"

<!-- Wrong — will false-match "MICRO", "MRI", etc. -->
condition="HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:UniversalServiceIdentifier.Identifier}[&quot;MI&quot;"
```

## Always Set the alias Attribute

The `alias` attribute on `<ruleDefinition>` is the display name in the Management Portal rule editor. If left empty, the rule appears with no label. Set it to the class name.

```xml
<!-- Correct -->
<ruleDefinition alias="MyApp.Rule.MainRoutingRule" context="..." production="...">

<!-- Wrong — blank label in editor -->
<ruleDefinition alias="" context="..." production="...">
```

## Test Messages Must Match Rule Conditions Exactly

If a rule checks `OBR:UniversalServiceIdentifier.Identifier = "MI"`, the test message must have exactly `"MI"` in that field — not `"MI12345"` or `"mi"`. Rules are case-sensitive. Mismatched test data produces passing traces that do not exercise the condition.
