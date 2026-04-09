Class Demo.HL7.Example.Rule.FileRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="Demo.HL7.Example.Rule.FileRoutingRule" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="Demo.HL7.Example.Production">
<ruleSet name="Main Routing" effectiveBegin="" effectiveEnd="">

  <rule name="Route to File" disabled="false">
    <constraint name="msgClass" value="EnsLib.HL7.Message"/>
    <when condition="1">
      <comment text="Route all HL7 messages to file operation"/>
      <send transform="" target="FileOperation"/>
      <return/>
    </when>
  </rule>

</ruleSet>
</ruleDefinition>
}

}
