/// Routing rule for AdmitToDischarge production
/// Routes ADT_A01 messages - transforms to ADT_A03 discharge if patient name contains "nicholai", otherwise passes through
Class AdmitToDischarge.Rule.AdmitRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="AdmitToDischarge.Rule.AdmitRoutingRule" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="AdmitToDischarge.Production">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="docCategory" value="2.5.1"></constraint>
<constraint name="docName" value="ADT_A01"></constraint>
<when condition="source.{PID:5} [ &quot;icholai&quot;">
<comment text="Convert admit to discharge for patient nicholai"/>
<send transform="AdmitToDischarge.DTL.ADTA01ToADTA03" target="DischargeFileOperation"></send>
<return></return>
</when>
<otherwise>
<comment text="Pass through unchanged"/>
<send transform="" target="DischargeFileOperation"></send>
</otherwise>
</rule>
</ruleSet>
</ruleDefinition>
}

}
