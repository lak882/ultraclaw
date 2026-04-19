Class Demo.DTL.ORUTransform Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EnsLib.HL7.Message) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.5.1:ORU_R01' targetDocType='2.5.1:ORU_R01' create='copy' language='objectscript' >
<annotation>Truncate lab order names longer than 20 characters and standardize coding system to LN.</annotation>
<foreach property='source.{PIDgrpgrp()}' key='k1' >
<annotation>Iterate over patient groups.</annotation>
<foreach property='source.{PIDgrpgrp(k1).ORCgrp()}' key='k2' >
<annotation>Iterate over order groups to process OBR segments.</annotation>
<if condition='..Length(source.{PIDgrpgrp(k1).ORCgrp(k2).OBR:UniversalServiceIdentifier.Text}) > 20' >
<annotation>Truncate OBR order name if longer than 20 characters.</annotation>
<true>
<assign value='..SubString(source.{PIDgrpgrp(k1).ORCgrp(k2).OBR:UniversalServiceIdentifier.Text},1,20)' property='target.{PIDgrpgrp(k1).ORCgrp(k2).OBR:UniversalServiceIdentifier.Text}' action='set' />
</true>
</if>
<assign value='"LN"' property='target.{PIDgrpgrp(k1).ORCgrp(k2).OBR:UniversalServiceIdentifier.NameOfCodingSystem}' action='set' >
<annotation>Standardize OBR coding system to LN for LOINC.</annotation>
</assign>
<foreach property='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp()}' key='k3' >
<annotation>Iterate over observation groups to process OBX segments.</annotation>
<if condition='..Length(source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:ObservationIdentifier.Text}) > 20' >
<annotation>Truncate OBX observation name if longer than 20 characters.</annotation>
<true>
<assign value='..SubString(source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:ObservationIdentifier.Text},1,20)' property='target.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:ObservationIdentifier.Text}' action='set' />
</true>
</if>
<assign value='"LN"' property='target.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:ObservationIdentifier.NameOfCodingSystem}' action='set' >
<annotation>Standardize OBX coding system to LN for LOINC.</annotation>
</assign>
</foreach>
</foreach>
</foreach>
</transform>
}

}
