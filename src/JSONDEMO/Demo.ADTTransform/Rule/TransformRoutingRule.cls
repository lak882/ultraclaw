Class Demo.ADTTransform.Rule.TransformRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="Demo.ADTTransform.Production">
<ruleSet name="" effectiveBegin="" effectiveEnd="">

<rule name="Transform ADT_A01 to ADT_A04" disabled="false">
<constraint name="source" value="HL7FileService"></constraint>
<when condition="1">
<send transform="Demo.ADTTransform.DTL.ADT23A01To251A04" target="HL7FileOperation"></send>
</when>
</rule>

</ruleSet>
</ruleDefinition>
}

}
