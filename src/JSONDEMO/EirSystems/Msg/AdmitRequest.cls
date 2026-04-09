Class EirSystems.Msg.AdmitRequest Extends (Ens.Request, %JSON.Adaptor, %XML.Adaptor)
{

Property msh As EirSystems.Msg.MSHInfo;

Property pid As EirSystems.Msg.PIDInfo;

Property al1 As list Of EirSystems.Msg.AL1Info;

Storage Default
{
<Data name="AdmitRequestDefaultData">
<Subscript>"AdmitRequest"</Subscript>
<Value name="1">
<Value>msh</Value>
</Value>
<Value name="2">
<Value>pid</Value>
</Value>
<Value name="3">
<Value>al1</Value>
</Value>
</Data>
<DefaultData>AdmitRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
