Class EirSystems.Msg.PatientName Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property lastName As %String;

Property firstName As %String;

Property middleInitial As %String;

Storage Default
{
<Data name="PatientNameState">
<Value name="1">
<Value>lastName</Value>
</Value>
<Value name="2">
<Value>firstName</Value>
</Value>
<Value name="3">
<Value>middleInitial</Value>
</Value>
</Data>
<State>PatientNameState</State>
<StreamLocation>^EirSystems.Msg.PatientNameS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
