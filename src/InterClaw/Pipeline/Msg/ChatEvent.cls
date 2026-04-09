Class InterClaw.Pipeline.Msg.ChatEvent Extends Ens.Request
{

Property BridgeId As %String;

Property EventJSON As %String(MAXLEN = "");

Property Text As %String(MAXLEN = "");

Property EventType As %String;

Property IsFinal As %Boolean [ InitialExpression = 0 ];

}
