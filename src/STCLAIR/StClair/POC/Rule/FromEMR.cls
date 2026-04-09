///
Class StClair.POC.Rule.FromEMR Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="StClair.POC.Rule.From_EMR" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="StClair.POC.Production">
<ruleSet name="One-To-Many ADT Feed" effectiveBegin="" effectiveEnd="">
<rule name="ADT To RIS Message Rule">
<constraint name="docCategory" value="2.5.1"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A05,ADT_A06,ADT_A07,ADT_A08,ADT_A11,ADT_A13,ADT_A28,ADT_A36"></constraint>
<when condition="1" comment="">
<comment text="Sends to RIS, pads provider IDs, removes hyphens from MRNs, filters out unnecessary fields, and outputs only specific segments. "></comment>
<send transform="StClair.POC.DTL.ADTToRIS" target="To_RIS"></send>
<return></return>
</when>
</rule>
<rule name="ADT To Ambulatory Billing Message Rule" disabled="false">
<constraint name="docCategory" value="2.5.1"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A04,ADT_A08,ADT_A31"></constraint>
<when condition="1" comment="">
<comment text="Sends to Ambulatory Billing, concatenates patient and visit IDs into PID-3 and generates a custom ZIN segment from custom ZPN segment."></comment>
<send transform="StClair.POC.DTL.ADTToAmbulatoryBilling" target="To_Ambulatory_Billing"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
</rule>
</ruleSet>
</ruleDefinition>
}

}
