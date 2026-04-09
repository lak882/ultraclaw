Class StClair.POC.DTL.ADTToRIS Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='StClairCustom:ADT_A01_Z' targetDocType='2.5.1:ADT_A01'
           create='new' language='objectscript' >

  <!-- Copy only allowed segments: MSH, EVN, PID, PV1, PD1, DRG, OBX -->
  <assign value='source.{MSH}' property='target.{MSH}' action='set'/>
  <assign value='source.{EVN}' property='target.{EVN}' action='set'/>
  <assign value='source.{PID}' property='target.{PID}' action='set'/>
  <assign value='source.{PV1}' property='target.{PV1}' action='set'/>
  <assign value='source.{PD1}' property='target.{PD1}' action='set'/>
  <assign value='source.{DRG}' property='target.{DRG}' action='set'/>

  <!-- Copy OBX segments (repeating) -->
  <foreach property='source.{OBX()}' key='k1'>
    <assign value='source.{OBX(k1)}' property='target.{OBX(k1)}' action='set'/>
  </foreach>

  <!-- Pad PV1-7.1 (Attending Doctor ID) with leading zeros to 4 digits -->
  <assign value='..Pad(source.{PV1:7.1}, -4, "0")' property='target.{PV1:7.1}' action='set'/>

  <!-- Remove all hyphens from MRN (PID-3.1) -->
  <assign value='..Translate(source.{PID:3.1}, "-", "")' property='target.{PID:3.1}' action='set'/>

  <!-- PID-3: only send PID-3.1 (clear extra subcomponents) -->
  <assign value='""' property='target.{PID:3.2}' action='set'/>
  <assign value='""' property='target.{PID:3.3}' action='set'/>
  <assign value='""' property='target.{PID:3.4}' action='set'/>
  <assign value='""' property='target.{PID:3.5}' action='set'/>

  <!-- PID-18: only send PID-18.1 (clear extra subcomponents) -->
  <assign value='""' property='target.{PID:18.2}' action='set'/>
  <assign value='""' property='target.{PID:18.3}' action='set'/>
  <assign value='""' property='target.{PID:18.4}' action='set'/>

  <!-- Remove PV1-19 (Visit Number) -->
  <assign value='""' property='target.{PV1:19}' action='set'/>

</transform>
}

}
