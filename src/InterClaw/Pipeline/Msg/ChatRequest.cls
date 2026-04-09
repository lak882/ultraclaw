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

}
