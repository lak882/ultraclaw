Class Demo.VaccineToASIIS.DTL.VXUFacilityLookup Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EnsLib.HL7.Message) ]
{

/// VXU_V04 copy transform with facility lookup on ORC-13
Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;
Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.5.1:VXU_V04' targetDocType='2.5.1:VXU_V04'
           create='copy' language='objectscript' >

<foreach property='source.{ORCgrp()}' key='k1'>
  <assign value='source.{ORCgrp(k1).ORC:EnterersLocation.Room}' property='target.{ORCgrp(k1).ORC:EnterersLocation.Room}' action='set' />
  <assign value='..Lookup("FacilityToSII", source.{ORCgrp(k1).ORC:EnterersLocation.Room})' property='target.{ORCgrp(k1).ORC:EnterersLocation.Facility}' action='set' />
</foreach>

</transform>
}

}
