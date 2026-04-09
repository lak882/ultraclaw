Class Demo.Rule.MainRouter2 Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="Demo.Rule.MainRouter2" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="Demo.Production">

<ruleSet name="Main Routing" effectiveBegin="" effectiveEnd="">

  <rule name="Default" disabled="false">
    <when condition="1">
      <comment text="Catch-all — add rules above this one"/>
      <return/>
    </when>
  </rule>

</ruleSet>

</ruleDefinition>
}

}
