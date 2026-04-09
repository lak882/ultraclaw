Class ElRio.POC.Rule.FromImagingOrdersRouter Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="ElRio.POC.Production">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Route ORM to Rad Ltd" disabled="false">
<constraint name="docName" value="ORM_O01"></constraint>
<when condition='Document.{MSH:MessageType.1}!="ORU"'>
<send transform="ElRio.POC.DTL.ORMToRadLtd" target="To_RadLtd"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
