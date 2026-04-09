Class AlertDemo.POC.DTL.ADTA01Copy Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

/// Copy ADT_A01, strip whitespace from PID-5 (Patient Name), lookup PV1-3.1 in Facility_Codes table.
Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;
Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.5.1:ADT_A01' targetDocType='2.5.1:ADT_A01'
           create='copy' language='objectscript' >

  <!-- Strip leading/trailing whitespace from Patient Name components -->
  <assign value='..Strip(source.{PID:PatientName.FamilyName.Surname}, "&lt;&gt;W")' property='target.{PID:PatientName.FamilyName.Surname}' action='set'/>
  <assign value='..Strip(source.{PID:PatientName.GivenName}, "&lt;&gt;W")' property='target.{PID:PatientName.GivenName}' action='set'/>
  <assign value='..Strip(source.{PID:5.3}, "&lt;&gt;W")' property='target.{PID:5.3}' action='set'/>

  <!-- Lookup PV1-3.1 (Point of Care) in Facility_Codes table -->
  <assign value='..Lookup("Facility_Codes", source.{PV1:AssignedPatientLocation.PointOfCare})' property='target.{PV1:AssignedPatientLocation.PointOfCare}' action='set'/>

</transform>
}

}
