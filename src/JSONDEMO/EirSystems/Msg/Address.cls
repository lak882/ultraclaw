Class EirSystems.Msg.Address Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property street As %String;

Property city As %String;

Property state As %String;

Property zipCode As %String;

Storage Default
{
<Data name="AddressState">
<Value name="1">
<Value>street</Value>
</Value>
<Value name="2">
<Value>city</Value>
</Value>
<Value name="3">
<Value>state</Value>
</Value>
<Value name="4">
<Value>zipCode</Value>
</Value>
</Data>
<State>AddressState</State>
<StreamLocation>^EirSystems.Msg.AddressS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
