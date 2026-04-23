# Routing Rule Overview

Class hierarchy, `Ens.Rule.Definition` structure, and top-level attributes. Load when starting a new rule from scratch.

## Class Hierarchy

```
Ens.Rule.Definition
  └── Your.Custom.RoutingRule
```

Routing rules are consumed by routing engine business processes:

```
EnsLib.HL7.MsgRouter.RoutingEngine      HL7-specific — use this for HL7 productions
EnsLib.MsgRouter.RoutingEngine          generic
EnsLib.MsgRouter.VDocRoutingEngine      virtual document
```

Always use `EnsLib.HL7.MsgRouter.RoutingEngine` in HL7 productions. The generic class does not understand HL7 virtual document path expressions in `<when>` conditions.

## Class Structure

```objectscript
Class MyApp.Rule.MainRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="MyApp.Rule.MainRoutingRule" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="MyApp.Production">

<ruleSet name="Main Routing" effectiveBegin="" effectiveEnd="">

  <!-- rules go here -->

</ruleSet>

</ruleDefinition>
}

}
```

## RuleAssistClass Parameter

```objectscript
Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";
```

This is the correct parameter name. `RuleAssist` (without "Class") is wrong and will compile without error but produce incorrect behavior in the rule editor.

## ruleDefinition Attributes

| Attribute | Description |
|-----------|-------------|
| `alias` | Display name in the Management Portal rule editor — always set this to the class name |
| `context` | The routing engine class this rule works with |
| `production` | The production this rule is associated with |

## ruleSet Attributes

| Attribute | Description |
|-----------|-------------|
| `name` | Rule set name shown in the editor |
| `effectiveBegin` | ISO datetime when this rule set becomes active (leave empty for always) |
| `effectiveEnd` | ISO datetime when this rule set expires (leave empty for no expiry) |
