Class Demo.AdmitToDischarge.Rule.CheckNicholaiRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="Demo.AdmitToDischarge.Production">
<ruleSet name="" effectiveBegin="" effectiveEnd="">

<rule name="Route Nicholai patients with transform" disabled="false">
<constraint name="docCategory" value="2.5.1"></constraint>
<constraint name="docName" value="ADT_A01"></constraint>
<when condition="HL7.{PID:5}[&quot;Nicholai&quot;">
<comment text="Patient name contains Nicholai - transform A01 to A03 and send to File_Out"></comment>
<send transform="Demo.AdmitToDischarge.DTL.A01ToA03" target="File_Out"></send>
<return/>
</when>
</rule>

<rule name="Default - pass through" disabled="false">
<constraint name="docCategory" value="2.5.1"></constraint>
<constraint name="docName" value="ADT_A01"></constraint>
<when condition="1">
<comment text="All other patients - pass through without transform"></comment>
<send transform="" target="File_Out"></send>
<return/>
</when>
</rule>

</ruleSet>
</ruleDefinition>
}

}
