Class ElRio.POC.Rule.EyepacsRouter Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="ElRio.POC.Production">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="RouteORUToEpic" disabled="false">
<constraint name="docName" value="ORU_R01"></constraint>
<when condition='Document.{MSH:MessageType.1}!="ACK"'>
<send transform="ElRio.POC.DTL.ORUToEpic" target="To_Epic"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
