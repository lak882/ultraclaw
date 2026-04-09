Class Demo.ADTConvert.DTL.ADTA01ToADTA02 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

/// Transform ADT_A01 (Admit) to ADT_A02 (Transfer)
Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;
Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.5.1:ADT_A01' targetDocType='2.5.1:ADT_A02'
           create='copy' language='objectscript' >

  <!-- Change trigger event from A01 (Admit) to A02 (Transfer) -->
  <assign value='"A02"' property='target.{MSH:MessageType.TriggerEvent}' action='set'/>
  <assign value='"ADT^A02"' property='target.{MSH:MessageType}' action='set'/>

  <!-- Update message timestamp -->
  <assign value='..CurrentDateTime("%Y%m%d%H%M%S")' property='target.{MSH:DateTimeOfMessage}' action='set'/>

</transform>
}

}
