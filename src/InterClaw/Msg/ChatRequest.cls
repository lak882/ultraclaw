/// User prompt sent to the chatbot.
Class InterClaw.Msg.ChatRequest Extends Ens.Request
{

/// The user's message text.
Property Text As %String(MAXLEN = 32000);

/// Claude session ID for conversation continuity.
Property SessionId As %String(MAXLEN = 200);

/// IRIS namespace the user is working in.
Property Namespace As %String;

/// Model used (opus, sonnet, haiku).
Property Model As %String;

/// When the request was sent.
Property Timestamp As %TimeStamp [ InitialExpression = {$zdatetime($horolog, 3)} ];

}
