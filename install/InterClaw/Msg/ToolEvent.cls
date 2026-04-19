/// A tool invocation or result within a conversation turn.
/// Sent for each tool_use and tool_result event during streaming.
Class InterClaw.Msg.ToolEvent Extends Ens.Request
{

/// Claude session ID.
Property SessionId As %String(MAXLEN = 200);

/// "call" for tool invocation, "result" for tool output.
Property EventType As %String;

/// Name of the tool (Bash, Read, Write, Edit, etc.).
Property ToolName As %String(MAXLEN = 200);

/// Tool input (JSON or text, truncated).
Property Input As %String(MAXLEN = 32000);

/// Tool output (truncated).
Property Output As %String(MAXLEN = 32000);

/// When the event occurred.
Property Timestamp As %TimeStamp [ InitialExpression = {$zdatetime($horolog, 3)} ];

Storage Default
{
<Data name="ToolEventDefaultData">
<Subscript>"ToolEvent"</Subscript>
<Value name="1">
<Value>SessionId</Value>
</Value>
<Value name="2">
<Value>EventType</Value>
</Value>
<Value name="3">
<Value>ToolName</Value>
</Value>
<Value name="4">
<Value>Input</Value>
</Value>
<Value name="5">
<Value>Output</Value>
</Value>
<Value name="6">
<Value>Timestamp</Value>
</Value>
</Data>
<DefaultData>ToolEventDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
