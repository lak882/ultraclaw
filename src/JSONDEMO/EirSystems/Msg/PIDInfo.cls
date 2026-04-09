Class EirSystems.Msg.PIDInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property id As %String;

Property patientName As EirSystems.Msg.PatientName;

Property dateOfBirth As %String;

Property administrativeSex As %String;

Property address As EirSystems.Msg.Address;

Storage Default
{
<Data name="PIDInfoState">
<Value name="1">
<Value>id</Value>
</Value>
<Value name="2">
<Value>patientName</Value>
</Value>
<Value name="3">
<Value>dateOfBirth</Value>
</Value>
<Value name="4">
<Value>administrativeSex</Value>
</Value>
<Value name="5">
<Value>address</Value>
</Value>
</Data>
<State>PIDInfoState</State>
<StreamLocation>^EirSystems.Msg.PIDInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
