Class ElRio.POC.DTL.ORUToEpic Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EnsLib.HL7.Message) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.5.1:ORU_R01' targetDocType='2.5.1:ORU_R01' create='copy' language='objectscript' >
<annotation>
Transform ORU_R01 messages from EyePACS to Epic format.
- Pass through all segments using create='copy'
- Replace underscores with spaces in PV1-3.1 (Assigned Patient Location - Point of Care)
- For each OBX segment:
  - If OBX-2.1 = "TX", set OBX-3.1 = "&amp;GDT"
  - If OBX-8.1 = "H", set OBX-8.1 = "N"
</annotation>
<assign value='source' property='target' action='set' />
<assign value='..ReplaceStr(source.{PIDgrpgrp(1).PIDgrp.PV1grp.PV1:3.1},"_"," ")' property='target.{PIDgrpgrp(1).PIDgrp.PV1grp.PV1:3.1}' action='set' />
<foreach property='source.{PIDgrpgrp(1).ORCgrp()}' key='k1' >
<foreach property='source.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp()}' key='k2' >
<if condition='source.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(k2).OBX:2.1} = "TX"' >
<true>
<assign value='"&amp;GDT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(k2).OBX:3.1}' action='set' />
</true>
</if>
<if condition='source.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(k2).OBX:8.1} = "H"' >
<true>
<assign value='"N"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(k2).OBX:8.1}' action='set' />
</true>
</if>
</foreach>
</foreach>
</transform>
}

}
