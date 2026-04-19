/// Normalized provider response returned from any model provider.
/// Providers must adapt their native response into this shape.
Class Inteclaw.Msg.ProviderResult Extends Ens.Response
{

Property BridgeId As %String(MAXLEN = 64);

Property StopReason As %String(MAXLEN = 32);

/// JSON array of content blocks: [{type:"text",text:"..."} | {type:"tool_use",id,name,input}]
Property ContentJSON As %String(MAXLEN = "");

/// Fresh (uncached) input tokens — billed at 100%.
Property InputTokens As %Integer;

Property OutputTokens As %Integer;

/// Cache-read input tokens — billed at 10% on Anthropic/Bedrock.
Property CacheReadTokens As %Integer [ InitialExpression = 0 ];

/// Cache-creation input tokens — billed at 125% on Anthropic/Bedrock.
Property CacheWriteTokens As %Integer [ InitialExpression = 0 ];

Property ErrorText As %String(MAXLEN = "");

Storage Default
{
<Data name="ProviderResultDefaultData">
<Subscript>"ProviderResult"</Subscript>
<Value name="1"><Value>BridgeId</Value></Value>
<Value name="2"><Value>StopReason</Value></Value>
<Value name="3"><Value>ContentJSON</Value></Value>
<Value name="4"><Value>InputTokens</Value></Value>
<Value name="5"><Value>OutputTokens</Value></Value>
<Value name="6"><Value>ErrorText</Value></Value>
<Value name="7"><Value>CacheReadTokens</Value></Value>
<Value name="8"><Value>CacheWriteTokens</Value></Value>
</Data>
<DefaultData>ProviderResultDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
