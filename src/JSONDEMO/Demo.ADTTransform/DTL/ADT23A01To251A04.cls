Class Demo.ADTTransform.DTL.ADT23A01To251A04 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

/// Transform HL7 2.3 ADT_A01 to HL7 2.5.1 ADT_A04
Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;
Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.3:ADT_A01' targetDocType='2.5.1:ADT_A01'
           create='copy' language='objectscript' >

  <!-- Change trigger event from A01 to A04 -->
  <assign value='"A04"' property='target.{MSH:9.2}' action='set'/>
  <assign value='"ADT^A04^ADT_A01"' property='target.{MSH:9}' action='set'/>

  <!-- Update version from 2.3 to 2.5.1 -->
  <assign value='"2.5.1"' property='target.{MSH:12}' action='set'/>

  <!-- Update timestamp to current time -->
  <assign value='##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S", $HOROLOG)' property='target.{MSH:7}' action='set'/>

  <!-- All other segments pass through unchanged via create='copy' -->

</transform>
}

}
