Class ElRio.POC.Rule.FromVaccineRouter Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="ElRio.POC.Production">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Route VXU to ASIIS" disabled="false">
<constraint name="docName" value="VXU_V04"></constraint>
<when condition="1">
<send transform="ElRio.POC.DTL.VXUToASIIS" target="To_ASIIS"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
