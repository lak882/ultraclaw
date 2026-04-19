/// Feedback submission to be routed through the production.
Class InterClaw.Msg.FeedbackRequest Extends Ens.Request
{

/// Rating 1-5, or empty.
Property Rating As %Integer;

/// Category: bug, feature-request, general, praise.
Property Category As %String;

/// User's comment text.
Property Comment As %String(MAXLEN = 2000);

/// IRIS namespace the user is working in.
Property Namespace As %String;

/// Model used (opus, sonnet, haiku).
Property Model As %String;

/// When the feedback was submitted.
Property Timestamp As %TimeStamp [ InitialExpression = {$zdatetime($horolog, 3)} ];

Storage Default
{
<Data name="FeedbackRequestDefaultData">
<Subscript>"FeedbackRequest"</Subscript>
<Value name="1">
<Value>Rating</Value>
</Value>
<Value name="2">
<Value>Category</Value>
</Value>
<Value name="3">
<Value>Comment</Value>
</Value>
<Value name="4">
<Value>Namespace</Value>
</Value>
<Value name="5">
<Value>Model</Value>
</Value>
<Value name="6">
<Value>Timestamp</Value>
</Value>
</Data>
<DefaultData>FeedbackRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
