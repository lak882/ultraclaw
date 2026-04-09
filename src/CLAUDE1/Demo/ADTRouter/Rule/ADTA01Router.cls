Class Demo.ADTRouter.Rule.ADTA01Router Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="Demo.ADTRouter.Rule.ADTA01Router" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="Demo.ADTRouter.Production">
<ruleSet name="ADT A01 Rules" effectiveBegin="" effectiveEnd="">
<rule name="Route ADT A01">
<constraint name="docCategory" value="2.5.1"/>
<constraint name="docName" value="ADT_A01"/>
<when condition="1">
<comment text="Route ADT A01 messages to target"/>
<send transform="" target="UndefinedTarget"/>
<return/>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
