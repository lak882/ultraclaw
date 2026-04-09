Class EirSystems.Scenario11.DTL.ADTA01ToAdmitJSON Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EirSystems.Msg.AdmitRequest) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EirSystems.Msg.AdmitRequest' sourceDocType='2.5.1:ADT_A01' create='new' language='objectscript' >

<!-- MSH Segment -->
<assign value='source.{MSH:SendingApplication}' property='target.msh.sendingApplication' action='set' />
<assign value='source.{MSH:SendingFacility}' property='target.msh.sendingFacility' action='set' />
<assign value='source.{MSH:ReceivingApplication}' property='target.msh.receivingApplication' action='set' />
<assign value='source.{MSH:ReceivingFacility}' property='target.msh.receivingFacility' action='set' />
<assign value='source.{MSH:MessageType.MessageCode}' property='target.msh.messageType' action='set' />
<assign value='source.{MSH:MessageType.TriggerEvent}' property='target.msh.triggerEvent' action='set' />
<assign value='source.{MSH:MessageControlID}' property='target.msh.controlId' action='set' />

<!-- PID Segment -->
<assign value='source.{PID:AlternatePatientIDPID}' property='target.pid.id' action='set' />
<assign value='source.{PID:PatientName.FamilyName.Surname}' property='target.pid.patientName.lastName' action='set' />
<assign value='source.{PID:PatientName.GivenName}' property='target.pid.patientName.firstName' action='set' />
<assign value='source.{PID:PatientName.SecondandFurtherGivenNamesorInitialsThereof}' property='target.pid.patientName.middleInitial' action='set' />
<assign value='..ConvertDateTime(source.{PID:DateTimeofBirth.Time}, "%Y%m%d", "%Y-%m-%d")' property='target.pid.dateOfBirth' action='set' />
<assign value='source.{PID:AdministrativeSex}' property='target.pid.administrativeSex' action='set' />
<assign value='source.{PID:PatientAddress.StreetAddress.StreetorMailingAddress}' property='target.pid.address.street' action='set' />
<assign value='source.{PID:PatientAddress.City}' property='target.pid.address.city' action='set' />
<assign value='source.{PID:PatientAddress.StateorProvince}' property='target.pid.address.state' action='set' />
<assign value='source.{PID:PatientAddress.ZiporPostalCode}' property='target.pid.address.zipCode' action='set' />

<!-- AL1 Segment (repeating) -->
<foreach property='source.{AL1()}' key='k1'>
  <assign value='source.{AL1(k1):SetIDAL1}' property='target.al1.(k1).setId' action='set' />
  <assign value='source.{AL1(k1):AllergenTypeCode.Identifier}' property='target.al1.(k1).allergenType' action='set' />
  <assign value='source.{AL1(k1):3.1}' property='target.al1.(k1).allergen.code' action='set' />
  <assign value='source.{AL1(k1):3.2}' property='target.al1.(k1).allergen.description' action='set' />
  <assign value='source.{AL1(k1):AllergySeverityCode.Identifier}' property='target.al1.(k1).severity' action='set' />
</foreach>

</transform>
}

}
