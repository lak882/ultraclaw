Class Demo.DTL.ORUR01ToORUR01 Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EnsLib.HL7.Message) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.5.1:ORU_R01' targetDocType='2.5.1:ORU_R01' create='copy' language='objectscript' >
<foreach property='source.{PIDgrpgrp()}' key='k1' >
<foreach property='source.{PIDgrpgrp(k1).ORCgrp()}' key='k2' >
<if condition='..Length(target.{PIDgrpgrp(k1).ORCgrp(k2).OBR:UniversalServiceIdentifier.Text}) &gt; 20' >
<true>
<assign value='..SubString(target.{PIDgrpgrp(k1).ORCgrp(k2).OBR:UniversalServiceIdentifier.Text},1,20)' property='target.{PIDgrpgrp(k1).ORCgrp(k2).OBR:UniversalServiceIdentifier.Text}' action='set' />
</true>
</if>
<assign value='"LN"' property='target.{PIDgrpgrp(k1).ORCgrp(k2).OBR:UniversalServiceIdentifier.NameOfCodingSystem}' action='set' />
<foreach property='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp()}' key='k3' >
<if condition='..Length(target.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:ObservationIdentifier.Text}) &gt; 20' >
<true>
<assign value='..SubString(target.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:ObservationIdentifier.Text},1,20)' property='target.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:ObservationIdentifier.Text}' action='set' />
</true>
</if>
<assign value='"LN"' property='target.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:ObservationIdentifier.NameOfCodingSystem}' action='set' />
</foreach>
</foreach>
</foreach>
</transform>
}

}
