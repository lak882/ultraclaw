Class Demo.Nicholai.Rule.DischargeRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="Demo.Nicholai">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="NicholaiDischarge" disabled="false">
<constraint name="source" value="HL7_File_Service"></constraint>
<constraint name="docType" value="2.5.1:ADT_A01"></constraint>
<when condition="Contains(Document.{PID:5.1},&quot;Nicholai&quot;)">
<send transform="Demo.Nicholai.DTL.ADTA01ToADTA03" target="HL7_File_Operation"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
