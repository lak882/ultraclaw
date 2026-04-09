Class ElRio.POC.Rule.FromEyePACSRouter Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="ElRio.POC.Production">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="RouteORUToEpic" disabled="false">
<constraint name="docName" value="ORU_R01"></constraint>
<constraint name="source" value="From_EyePACS"></constraint>
<when condition="1">
<send transform="ElRio.POC.DTL.ORUToEpic" target="To_Epic"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
