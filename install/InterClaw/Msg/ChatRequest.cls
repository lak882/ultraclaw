/// Inbound chat request passed from REST gateway -> BS -> BP.
Class InterClaw.Msg.ChatRequest Extends Ens.Request
{

Property BridgeId As %String(MAXLEN = 64);

Property SessionId As %String(MAXLEN = 64);

Property Prompt As %String(MAXLEN = "");

Property Model As %String(MAXLEN = 128);

Property Provider As %String(MAXLEN = 32);

Property SystemPrompt As %String(MAXLEN = "");

Property MaxTurns As %Integer [ InitialExpression = 12 ];

Property PayloadJSON As %String(MAXLEN = "");

/// Thinking effort for adaptive mode: "low" | "medium" | "high".
/// Frontend sends via the `effort` field on /api/start.
Property Effort As %String(MAXLEN = 16) [ InitialExpression = "medium" ];

Storage Default
{
<Data name="ChatRequestDefaultData">
<Subscript>"ChatRequest"</Subscript>
<Value name="1"><Value>BridgeId</Value></Value>
<Value name="2"><Value>SessionId</Value></Value>
<Value name="3"><Value>Prompt</Value></Value>
<Value name="4"><Value>Model</Value></Value>
<Value name="5"><Value>Provider</Value></Value>
<Value name="6"><Value>SystemPrompt</Value></Value>
<Value name="7"><Value>MaxTurns</Value></Value>
<Value name="8"><Value>PayloadJSON</Value></Value>
<Value name="9"><Value>Effort</Value></Value>
</Data>
<DefaultData>ChatRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
