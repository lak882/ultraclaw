Class InterClaw.Pipeline.Msg.ChatResponse Extends Ens.Response
{

Property BridgeId As %String;

Property SessionId As %String;

Property Cost As %Numeric;

Property InputTokens As %Integer;

Property OutputTokens As %Integer;

Property Status As %String;

Property EventCount As %Integer;

Storage Default
{
<Data name="ChatResponseDefaultData">
<Subscript>"ChatResponse"</Subscript>
<Value name="1">
<Value>BridgeId</Value>
</Value>
<Value name="2">
<Value>SessionId</Value>
</Value>
<Value name="3">
<Value>Cost</Value>
</Value>
<Value name="4">
<Value>InputTokens</Value>
</Value>
<Value name="5">
<Value>OutputTokens</Value>
</Value>
<Value name="6">
<Value>Status</Value>
</Value>
<Value name="7">
<Value>EventCount</Value>
</Value>
</Data>
<DefaultData>ChatResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
