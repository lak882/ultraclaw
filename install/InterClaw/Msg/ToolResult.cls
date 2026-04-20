/// Tool execution result returned from tool BO to agent BP.
Class InterClaw.Msg.ToolResult Extends Ens.Response
{

Property BridgeId As %String(MAXLEN = 64);

Property ToolUseId As %String(MAXLEN = 128);

Property ToolName As %String(MAXLEN = 64);

Property OutputText As %String(MAXLEN = "");

Property IsError As %Boolean [ InitialExpression = 0 ];

Storage Default
{
<Data name="ToolResultDefaultData">
<Subscript>"ToolResult"</Subscript>
<Value name="1"><Value>BridgeId</Value></Value>
<Value name="2"><Value>ToolUseId</Value></Value>
<Value name="3"><Value>ToolName</Value></Value>
<Value name="4"><Value>OutputText</Value></Value>
<Value name="5"><Value>IsError</Value></Value>
</Data>
<DefaultData>ToolResultDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
