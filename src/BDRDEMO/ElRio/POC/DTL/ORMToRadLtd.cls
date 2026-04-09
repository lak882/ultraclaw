Class ElRio.POC.DTL.ORMToRadLtd Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.5.1:ORM_O01' targetDocType='2.5.1:ORM_O01' create='copy' language='objectscript' >
<annotation>
Transform ORM_O01 messages for Rad Ltd.
Conditionally modifies ORC fields based on sending application.
If MSH:3.1 (Sending Application) = "IMG_SCHEDULE_APPT", set ORC:OrderControl = 'NW' and ORC:OrderStatus = 'SC'.
</annotation>
<if condition='source.{MSH:3.1}="IMG_SCHEDULE_APPT"' >
<true>
<foreach property='source.{ORCgrp()}' key='k1' >
<assign value='"NW"' property='target.{ORCgrp(k1).ORC:1}' action='set' />
<assign value='"SC"' property='target.{ORCgrp(k1).ORC:5}' action='set' />
</foreach>
</true>
</if>
</transform>
}

}
