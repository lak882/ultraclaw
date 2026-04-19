Class InterClaw.Pipeline.Msg.ChatRequest Extends Ens.Request
{

Property BridgeId As %String;

Property PayloadJSON As %String(MAXLEN = "");

Property Prompt As %String(MAXLEN = "");

Property SessionId As %String;

Property Model As %String;

Property Namespace As %String;

Property Action As %String;

Property OperationTarget As %String;

/// SDK permission mode: default, acceptEdits, plan, bypassPermissions, dontAsk
Property PermissionMode As %String;

Storage Default
{
<Data name="ChatRequestDefaultData">
<Subscript>"ChatRequest"</Subscript>
<Value name="1">
<Value>BridgeId</Value>
</Value>
<Value name="2">
<Value>PayloadJSON</Value>
</Value>
<Value name="3">
<Value>Prompt</Value>
</Value>
<Value name="4">
<Value>SessionId</Value>
</Value>
<Value name="5">
<Value>Model</Value>
</Value>
<Value name="6">
<Value>Namespace</Value>
</Value>
<Value name="7">
<Value>Action</Value>
</Value>
<Value name="8">
<Value>OperationTarget</Value>
</Value>
<Value name="9">
<Value>PermissionMode</Value>
</Value>
</Data>
<DefaultData>ChatRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
