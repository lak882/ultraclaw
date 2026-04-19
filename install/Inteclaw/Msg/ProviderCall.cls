/// Request sent from agent BP to the provider BO.
/// Carries the full conversation state needed for one inference turn.
Class Inteclaw.Msg.ProviderCall Extends Ens.Request
{

Property BridgeId As %String(MAXLEN = 64);

Property SessionId As %String(MAXLEN = 64);

Property Provider As %String(MAXLEN = 32);

Property Model As %String(MAXLEN = 128);

Property SystemPrompt As %String(MAXLEN = "");

/// JSON array of message objects: [{role, content}]
Property MessagesJSON As %String(MAXLEN = "");

/// JSON array of tool definitions: [{name, description, input_schema}]
Property ToolsJSON As %String(MAXLEN = "");

Property MaxTokens As %Integer [ InitialExpression = 4096 ];

/// Thinking effort: "low" | "medium" | "high". Drives output_config.effort
/// in adaptive thinking mode on Opus/Sonnet.
Property Effort As %String(MAXLEN = 16) [ InitialExpression = "medium" ];

Storage Default
{
<Data name="ProviderCallDefaultData">
<Subscript>"ProviderCall"</Subscript>
<Value name="1"><Value>BridgeId</Value></Value>
<Value name="2"><Value>SessionId</Value></Value>
<Value name="3"><Value>Provider</Value></Value>
<Value name="4"><Value>Model</Value></Value>
<Value name="5"><Value>SystemPrompt</Value></Value>
<Value name="6"><Value>MessagesJSON</Value></Value>
<Value name="7"><Value>ToolsJSON</Value></Value>
<Value name="8"><Value>MaxTokens</Value></Value>
<Value name="9"><Value>Effort</Value></Value>
</Data>
<DefaultData>ProviderCallDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
