Class AdmitToDischarge.DTL.ADTA01ToADTA03 Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EnsLib.HL7.Message) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.5.1:ADT_A01' targetDocType='2.5.1:ADT_A03' create='copy' language='objectscript' >
<annotation>Transforms ADT_A01 (admit) messages to ADT_A03 (discharge) messages. All segments pass through unchanged except for message type fields in MSH and EVN.</annotation>
<assign value='source' property='target' action='set' />
<assign value='"ADT^A03"' property='target.{MSH:9}' action='set' />
<assign value='"A03"' property='target.{MSH:9.2}' action='set' />
<assign value='"A03"' property='target.{EVN:1}' action='set' />
<assign value='##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S", $HOROLOG)' property='target.{MSH:7}' action='set' />
</transform>
}

}
