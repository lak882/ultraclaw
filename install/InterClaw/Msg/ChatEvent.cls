/// Event message — emitted from BP/BO to EventWriter for global storage and trace visibility.
Class InterClaw.Msg.ChatEvent Extends Ens.Request
{

Property BridgeId As %String(MAXLEN = 64);

Property EventJSON As %String(MAXLEN = "");

Storage Default
{
<Data name="ChatEventDefaultData">
<Subscript>"ChatEvent"</Subscript>
<Value name="1"><Value>BridgeId</Value></Value>
<Value name="2"><Value>EventJSON</Value></Value>
</Data>
<DefaultData>ChatEventDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
