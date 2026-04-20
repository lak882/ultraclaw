/// Tool invocation request — BP sends to tool BO.
Class InterClaw.Msg.ToolCall Extends Ens.Request
{

Property BridgeId As %String(MAXLEN = 64);

Property SessionId As %String(MAXLEN = 64);

Property ToolUseId As %String(MAXLEN = 128);

Property ToolName As %String(MAXLEN = 64);

Property InputJSON As %String(MAXLEN = "");

/// JSON-serialized permission context (denyNames, denyPrefixes, bypass).
/// Empty string = no filtering.
Property PermCtxJSON As %String(MAXLEN = "") [ InitialExpression = "" ];

Storage Default
{
<Data name="ToolCallDefaultData">
<Subscript>"ToolCall"</Subscript>
<Value name="1"><Value>BridgeId</Value></Value>
<Value name="2"><Value>ToolUseId</Value></Value>
<Value name="3"><Value>ToolName</Value></Value>
<Value name="4"><Value>InputJSON</Value></Value>
<Value name="5"><Value>SessionId</Value></Value>
<Value name="6"><Value>PermCtxJSON</Value></Value>
</Data>
<DefaultData>ToolCallDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
