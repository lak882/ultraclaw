Class EirSystems.Msg.Allergen Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property code As %String;

Property description As %String;

Storage Default
{
<Data name="AllergenState">
<Value name="1">
<Value>code</Value>
</Value>
<Value name="2">
<Value>description</Value>
</Value>
</Data>
<State>AllergenState</State>
<StreamLocation>^EirSystems.Msg.AllergenS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
