Class EirSystems.Rule.InboundRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="EirSystems.Rule.InboundRoutingRule" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="EirSystems.Production">

<ruleSet name="Inbound Routing" effectiveBegin="" effectiveEnd="">

  <rule name="ADT A01 - Admit" disabled="false">
    <constraint name="docCategory" value="2.5.1"/>
    <constraint name="docName" value="ADT_A01"/>
    <when condition="1">
      <comment text="Route ADT^A01 to BPL process for HL7-to-JSON transformation"/>
      <send transform="" target="ADT_AdmitProcess"/>
      <return/>
    </when>
  </rule>

</ruleSet>

</ruleDefinition>
}

}
