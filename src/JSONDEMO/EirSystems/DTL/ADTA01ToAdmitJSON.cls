Class EirSystems.DTL.ADTA01ToAdmitJSON Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EirSystems.Msg.AdmitRequest) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EirSystems.Msg.AdmitRequest'
           sourceDocType='2.5.1:ADT_A01' targetDocType=''
           create='new' language='objectscript' >

  <!-- MSH Segment -->
  <assign value='source.{MSH:3}' property='target.msh.sendingApplication' action='set'/>
  <assign value='source.{MSH:4}' property='target.msh.sendingFacility' action='set'/>
  <assign value='source.{MSH:5}' property='target.msh.receivingApplication' action='set'/>
  <assign value='source.{MSH:6}' property='target.msh.receivingFacility' action='set'/>
  <assign value='source.{MSH:9.1}' property='target.msh.messageType' action='set'/>
  <assign value='source.{MSH:9.2}' property='target.msh.triggerEvent' action='set'/>
  <assign value='source.{MSH:10}' property='target.msh.controlId' action='set'/>

  <!-- PID Segment -->
  <assign value='source.{PID:4}' property='target.pid.id' action='set'/>
  <assign value='source.{PID:5.1}' property='target.pid.patientName.lastName' action='set'/>
  <assign value='source.{PID:5.2}' property='target.pid.patientName.firstName' action='set'/>
  <assign value='source.{PID:5.3}' property='target.pid.patientName.middleInitial' action='set'/>
  <assign value='..ConvertDateTime(source.{PID:7}, "%Y%m%d", "%Y-%m-%d")' property='target.pid.dateOfBirth' action='set'/>
  <assign value='source.{PID:8}' property='target.pid.administrativeSex' action='set'/>
  <assign value='source.{PID:11.1}' property='target.pid.address.street' action='set'/>
  <assign value='source.{PID:11.3}' property='target.pid.address.city' action='set'/>
  <assign value='source.{PID:11.4}' property='target.pid.address.state' action='set'/>
  <assign value='source.{PID:11.5}' property='target.pid.address.zipCode' action='set'/>

  <!-- AL1 Segments (repeating) -->
  <foreach property='source.{AL1()}' key='k1'>
    <assign value='source.{AL1(k1):1}' property='target.al1.(k1).setId' action='set'/>
    <assign value='source.{AL1(k1):2}' property='target.al1.(k1).allergenType' action='set'/>
    <assign value='source.{AL1(k1):3.1}' property='target.al1.(k1).allergen.code' action='set'/>
    <assign value='source.{AL1(k1):3.2}' property='target.al1.(k1).allergen.description' action='set'/>
    <assign value='source.{AL1(k1):4}' property='target.al1.(k1).severity' action='set'/>
  </foreach>

</transform>
}

}
