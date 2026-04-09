Class StClair.POC.DTL.ADTToAmbulatoryBilling Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='StClairCustom:ADT_A01_Z' targetDocType='StClairCustom:ADT_A01_Z'
           create='new' language='objectscript' >

  <!-- Copy allowed segments: MSH, EVN, PID, PV1, PD1, NK1, GT1, IN1, IN2, IN3, ZIN -->
  <assign value='source.{MSH}' property='target.{MSH}' action='set'/>
  <assign value='source.{EVN}' property='target.{EVN}' action='set'/>
  <assign value='source.{PID}' property='target.{PID}' action='set'/>
  <assign value='source.{PV1}' property='target.{PV1}' action='set'/>
  <assign value='source.{PD1}' property='target.{PD1}' action='set'/>

  <!-- Copy NK1 segments (repeating) -->
  <foreach property='source.{NK1()}' key='k1'>
    <assign value='source.{NK1(k1)}' property='target.{NK1(k1)}' action='set'/>
  </foreach>

  <!-- Copy GT1 segments (repeating) -->
  <foreach property='source.{GT1()}' key='k1'>
    <assign value='source.{GT1(k1)}' property='target.{GT1(k1)}' action='set'/>
  </foreach>

  <!-- Copy IN1/IN2/IN3 from insurance group (repeating) -->
  <foreach property='source.{IN1grp()}' key='k1'>
    <assign value='source.{IN1grp(k1).IN1}' property='target.{IN1grp(k1).IN1}' action='set'/>
    <assign value='source.{IN1grp(k1).IN2}' property='target.{IN1grp(k1).IN2}' action='set'/>
    <foreach property='source.{IN1grp(k1).IN3()}' key='k2'>
      <assign value='source.{IN1grp(k1).IN3(k2)}' property='target.{IN1grp(k1).IN3(k2)}' action='set'/>
    </foreach>
  </foreach>

  <!-- PID-3.1: concatenate PV1-3.1 (Point of Care) with PID-3.1 using "-" separator -->
  <!-- Example: PV1-3.1="FNA", PID-3.1="123456" => "FNA-123456" -->
  <assign value='source.{PV1:3.1}_"-"_source.{PID:3.1}' property='target.{PID:3.1}' action='set'/>

  <!-- Create ZIN segment: ZIN-4 = ZPN-15 (Notes) -->
  <assign value='"1"' property='target.{ZIN:1}' action='set'/>
  <assign value='source.{ZPN:15}' property='target.{ZIN:4}' action='set'/>

</transform>
}

}
