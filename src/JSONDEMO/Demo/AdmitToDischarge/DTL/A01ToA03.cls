Class Demo.AdmitToDischarge.DTL.A01ToA03 Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EnsLib.HL7.Message) ]
{

/// Converts ADT_A01 (admission) messages to ADT_A03 (discharge) messages by changing message type and event code
Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;
Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.5.1:ADT_A01' targetDocType='2.5.1:ADT_A03'
           create='copy' language='objectscript' >

<assign value='&quot;A03&quot;' property='target.{MSH:9.2}' action='set'/>
<assign value='&quot;ADT^A03&quot;' property='target.{MSH:9}' action='set'/>
<assign value='&quot;A03&quot;' property='target.{EVN:1}' action='set'/>

</transform>
}

}
