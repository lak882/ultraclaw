Class ElRio.POC.DTL.VXUToASIIS Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.5.1:VXU_V04' targetDocType='2.5.1:VXU_V04' create='copy' language='objectscript' >
<annotation>
Transform VXU_V04 messages for ASIIS submission.
Maps facility names to SIIS client IDs using Facility_To_SIIS lookup table.
- ORC-13.2 (Enterer's Location - ID Number) mapped to ORC-13.4 (Alternate Identifier)
- RXA-11.2 (Administered-at Location - Organizational Unit Type) mapped to RXA-11.4 (Facility)
</annotation>
<assign value='source' property='target' action='set' />
<foreach property='source.{ORCgrp()}' key='k1' >
<assign value='..Lookup("Facility_To_SIIS", source.{ORCgrp(k1).ORC:13.2})' property='target.{ORCgrp(k1).ORC:13.4}' action='set' />
<assign value='..Lookup("Facility_To_SIIS", source.{ORCgrp(k1).RXA:11.2})' property='target.{ORCgrp(k1).RXA:11.4}' action='set' />
</foreach>
</transform>
}

}
