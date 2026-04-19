/// Claude's complete response for a conversation turn.
Class InterClaw.Msg.ChatResponse Extends Ens.Response
{

/// Full assistant text output.
Property Text As %String(MAXLEN = "");

/// Claude session ID.
Property SessionId As %String(MAXLEN = 200);

/// Whether the turn completed successfully.
Property Success As %Boolean [ InitialExpression = 1 ];

/// Number of tool calls made during this turn.
Property ToolCallCount As %Integer [ InitialExpression = 0 ];

/// API input tokens consumed.
Property InputTokens As %Integer;

/// API output tokens generated.
Property OutputTokens As %Integer;

/// Estimated cost in USD.
Property Cost As %Numeric(SCALE = 6);

/// Turn duration in seconds.
Property Duration As %Numeric(SCALE = 2);

/// When the response completed.
Property Timestamp As %TimeStamp [ InitialExpression = {$zdatetime($horolog, 3)} ];

Storage Default
{
<Data name="ChatResponseDefaultData">
<Subscript>"ChatResponse"</Subscript>
<Value name="1">
<Value>Text</Value>
</Value>
<Value name="2">
<Value>SessionId</Value>
</Value>
<Value name="3">
<Value>Success</Value>
</Value>
<Value name="4">
<Value>ToolCallCount</Value>
</Value>
<Value name="5">
<Value>InputTokens</Value>
</Value>
<Value name="6">
<Value>OutputTokens</Value>
</Value>
<Value name="7">
<Value>Cost</Value>
</Value>
<Value name="8">
<Value>Duration</Value>
</Value>
<Value name="9">
<Value>Timestamp</Value>
</Value>
</Data>
<DefaultData>ChatResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
