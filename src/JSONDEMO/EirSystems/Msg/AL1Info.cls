Class EirSystems.Msg.AL1Info Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property setId As %String;

Property allergenType As %String;

Property allergen As EirSystems.Msg.Allergen;

Property severity As %String;

Storage Default
{
<Data name="AL1InfoState">
<Value name="1">
<Value>setId</Value>
</Value>
<Value name="2">
<Value>allergenType</Value>
</Value>
<Value name="3">
<Value>allergen</Value>
</Value>
<Value name="4">
<Value>severity</Value>
</Value>
</Data>
<State>AL1InfoState</State>
<StreamLocation>^EirSystems.Msg.AL1InfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
