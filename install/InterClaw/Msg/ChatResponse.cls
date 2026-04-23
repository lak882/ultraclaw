/// Final response from the agent BP.
Class InterClaw.Msg.ChatResponse Extends Ens.Response
{

Property BridgeId As %String(MAXLEN = 64);

Property SessionId As %String(MAXLEN = 64);

Property Status As %String(MAXLEN = 16);

Property FinalText As %String(MAXLEN = "");

Property Turns As %Integer;

Property InputTokens As %Integer;

Property OutputTokens As %Integer;

Storage Default
{
<Data name="ChatResponseDefaultData">
<Subscript>"ChatResponse"</Subscript>
<Value name="1"><Value>BridgeId</Value></Value>
<Value name="2"><Value>SessionId</Value></Value>
<Value name="3"><Value>Status</Value></Value>
<Value name="4"><Value>FinalText</Value></Value>
<Value name="5"><Value>Turns</Value></Value>
<Value name="6"><Value>InputTokens</Value></Value>
<Value name="7"><Value>OutputTokens</Value></Value>
</Data>
<DefaultData>ChatResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
