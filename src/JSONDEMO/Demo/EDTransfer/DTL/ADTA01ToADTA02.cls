Class Demo.EDTransfer.DTL.ADTA01ToADTA02 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

/// Transforms an ADT_A01 (Admit) into an ADT_A02 (Transfer) message.
/// Maps ED location to inpatient unit via ED_To_Inpatient lookup table,
/// preserves the original ED location as Prior Patient Location,
/// updates Patient Class from E (Emergency) to I (Inpatient),
/// and constructs the EVN segment for the A02 event.
Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;
Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message'
           sourceDocType='2.5.1:ADT_A01' targetDocType='2.5.1:ADT_A02'
           create='new' language='objectscript' >

  <!-- ===== MSH: Copy and update message type to ADT^A02 ===== -->
  <assign value='source.{MSH}' property='target.{MSH}' action='set'/>
  <assign value='"A02"' property='target.{MSH:MessageType.TriggerEvent}' action='set'/>
  <assign value='"ADT_A02"' property='target.{MSH:MessageType.MessageStructure}' action='set'/>
  <assign value='..CurrentDateTime("%Q(1)")' property='target.{MSH:DateTimeOfMessage.Time}' action='set'/>

  <!-- ===== EVN: Construct transfer event segment ===== -->
  <assign value='"A02"' property='target.{EVN:EventTypeCode}' action='set'/>
  <assign value='..CurrentDateTime("%Q(1)")' property='target.{EVN:RecordedDateTime.Time}' action='set'/>
  <assign value='..CurrentDateTime("%Q(1)")' property='target.{EVN:EventOccurred.Time}' action='set'/>

  <!-- ===== PID: Copy patient demographics as-is ===== -->
  <assign value='source.{PID}' property='target.{PID}' action='set'/>

  <!-- ===== PD1: Copy if present ===== -->
  <assign value='source.{PD1}' property='target.{PD1}' action='set'/>

  <!-- ===== PV1: Copy and transform location/class fields ===== -->
  <assign value='source.{PV1}' property='target.{PV1}' action='set'/>

  <!-- Set Prior Patient Location (PV1-6) to original ED location from PV1-3 -->
  <assign value='source.{PV1:AssignedPatientLocation}' property='target.{PV1:PriorPatientLocation}' action='set'/>

  <!-- Map ED location to inpatient unit via lookup table -->
  <assign value='..Lookup("ED_To_Inpatient", source.{PV1:AssignedPatientLocation.PointOfCare}, source.{PV1:AssignedPatientLocation.PointOfCare})' property='target.{PV1:AssignedPatientLocation.PointOfCare}' action='set'/>

  <!-- Update Patient Class from E (Emergency) to I (Inpatient) -->
  <assign value='"I"' property='target.{PV1:PatientClass}' action='set'/>

  <!-- ===== PV2: Copy if present ===== -->
  <assign value='source.{PV2}' property='target.{PV2}' action='set'/>

  <!-- ===== OBX: Copy non-triage OBX segments (filter out triage acuity) ===== -->
  <foreach property='source.{OBX()}' key='k1'>
    <if condition='..DoesNotContain(source.{OBX(k1):ObservationIdentifier.Identifier}, "TRIAGE")'>
      <true>
        <assign value='source.{OBX(k1)}' property='target.{OBX(k1)}' action='set'/>
      </true>
    </if>
  </foreach>

</transform>
}

}
