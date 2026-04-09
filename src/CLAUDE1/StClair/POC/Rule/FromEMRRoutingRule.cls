Class StClair.POC.Rule.FromEMRRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="StClair.POC.Rule.From_EMR_Router" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="StClair.POC.Production">

<ruleSet name="" effectiveBegin="" effectiveEnd="">

  <!-- Rule 1: Route constrained ADT types to RIS -->
  <rule name="ADT to RIS">
    <constraint name="docCategory" value="StClairCustom"/>
    <when condition='HL7.{MSH:9.2}=&quot;A01&quot;||HL7.{MSH:9.2}=&quot;A02&quot;||HL7.{MSH:9.2}=&quot;A03&quot;||HL7.{MSH:9.2}=&quot;A04&quot;||HL7.{MSH:9.2}=&quot;A05&quot;||HL7.{MSH:9.2}=&quot;A06&quot;||HL7.{MSH:9.2}=&quot;A07&quot;||HL7.{MSH:9.2}=&quot;A08&quot;||HL7.{MSH:9.2}=&quot;A11&quot;||HL7.{MSH:9.2}=&quot;A13&quot;||HL7.{MSH:9.2}=&quot;A28&quot;||HL7.{MSH:9.2}=&quot;A31&quot;||HL7.{MSH:9.2}=&quot;A36&quot;'>
      <comment text="Send ADT A01,A02,A03,A04,A05,A06,A07,A08,A11,A13,A28,A31,A36 to RIS with transformation"/>
      <send transform="StClair.POC.DTL.ADTToRIS" target="To_RIS"/>
    </when>
  </rule>

  <!-- Rule 2: Route specific ADT types with facility SCH to Ambulatory Billing -->
  <rule name="ADT to Ambulatory Billing">
    <constraint name="docCategory" value="StClairCustom"/>
    <when condition='(HL7.{MSH:9.2}=&quot;A01&quot;||HL7.{MSH:9.2}=&quot;A04&quot;||HL7.{MSH:9.2}=&quot;A08&quot;||HL7.{MSH:9.2}=&quot;A31&quot;)&amp;&amp;HL7.{PV1:3.4}=&quot;SCH&quot;'>
      <comment text="Send ADT A01,A04,A08,A31 with facility SCH to Ambulatory Billing with ZPN-to-ZIN transformation"/>
      <send transform="StClair.POC.DTL.ADTToAmbulatoryBilling" target="To_Ambulatory_Billing"/>
      <return/>
    </when>
  </rule>

</ruleSet>

</ruleDefinition>
}

}
