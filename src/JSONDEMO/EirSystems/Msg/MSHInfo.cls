Class EirSystems.Msg.MSHInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property sendingApplication As %String;

Property sendingFacility As %String;

Property receivingApplication As %String;

Property receivingFacility As %String;

Property messageType As %String;

Property triggerEvent As %String;

Property controlId As %String;

Storage Default
{
<Data name="MSHInfoState">
<Value name="1">
<Value>sendingApplication</Value>
</Value>
<Value name="2">
<Value>sendingFacility</Value>
</Value>
<Value name="3">
<Value>receivingApplication</Value>
</Value>
<Value name="4">
<Value>receivingFacility</Value>
</Value>
<Value name="5">
<Value>messageType</Value>
</Value>
<Value name="6">
<Value>triggerEvent</Value>
</Value>
<Value name="7">
<Value>controlId</Value>
</Value>
</Data>
<State>MSHInfoState</State>
<StreamLocation>^EirSystems.Msg.MSHInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
