Class EirSystems.Scenario11.Rule.ADTRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="EirSystems.Scenario11.Rule.ADTRoutingRule" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="EirSystems.Scenario11.Production">
<ruleSet name="" effectiveBegin="" effectiveEnd="">

<rule name="ADT A01 to JSON" disabled="false">
<constraint name="source" value="HL7_File_Service"></constraint>
<constraint name="docCategory" value="2.5.1"></constraint>
<constraint name="docName" value="ADT_A01"></constraint>
<when condition="1">
<comment text="Transform ADT^A01 to Admit JSON"></comment>
<send transform="EirSystems.Scenario11.DTL.ADTA01ToAdmitJSON" target="JSON_File_Operation"></send>
<return></return>
</when>
</rule>

</ruleSet>
</ruleDefinition>
}

}
