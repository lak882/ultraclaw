Class Demo.Rule.FacilityRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="Facility Routing Rule" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="Demo.Production">

<ruleSet name="Route by Sending Facility" effectiveBegin="" effectiveEnd="">

<rule name="Facility A" disabled="false">
<constraint name="docCategory" value="2.5.1"/>
<when condition="HL7.{MSH:SendingFacility.NamespaceID}=&quot;FACILITY_A&quot;">
<comment text="Route messages from Facility A to Operation A"/>
<send transform="" target="Demo.BO.FacilityAOperation"/>
<return/>
</when>
</rule>

<rule name="Facility B" disabled="false">
<constraint name="docCategory" value="2.5.1"/>
<when condition="HL7.{MSH:SendingFacility.NamespaceID}=&quot;FACILITY_B&quot;">
<comment text="Route messages from Facility B to Operation B"/>
<send transform="" target="Demo.BO.FacilityBOperation"/>
<return/>
</when>
</rule>

<rule name="Facility C" disabled="false">
<constraint name="docCategory" value="2.5.1"/>
<when condition="HL7.{MSH:SendingFacility.NamespaceID}=&quot;FACILITY_C&quot;">
<comment text="Route messages from Facility C to Operation C"/>
<send transform="" target="Demo.BO.FacilityCOperation"/>
<return/>
</when>
</rule>

<rule name="Default" disabled="false">
<constraint name="docCategory" value="2.5.1"/>
<when condition="1">
<comment text="Default route for unmatched facility codes"/>
<send transform="" target="Demo.BO.DefaultOperation"/>
<return/>
</when>
</rule>

</ruleSet>

</ruleDefinition>
}

}
