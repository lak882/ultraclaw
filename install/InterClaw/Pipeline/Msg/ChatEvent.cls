/// Event message sent from ClaudeOperation to EventWriter for trace visibility.
Class InterClaw.Pipeline.Msg.ChatEvent Extends Ens.Request
{

Property BridgeId As %String(MAXLEN = "");

Property EventJSON As %String(MAXLEN = "");

Storage Default
{
<Data name="ChatEventDefaultData">
<Subscript>"ChatEvent"</Subscript>
<Value name="1">
<Value>BridgeId</Value>
</Value>
<Value name="2">
<Value>EventJSON</Value>
</Value>
</Data>
<DefaultData>ChatEventDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
