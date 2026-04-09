Class Demo.Nicholai.DTL.VXU23To251 Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EnsLib.HL7.Message) ]
{

/// VXU_V04 version upgrade: 2.3 to 2.5.1
Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;
Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.3:VXU_V04' targetDocType='2.5.1:VXU_V04'
           create='copy' language='objectscript' >

<assign value='"VXU_V04"' property='target.{MSH:MessageType.MessageStructure}' action='set' />
<assign value='"2.5.1"' property='target.{MSH:VersionID.VersionID}' action='set' />

</transform>
}

}
