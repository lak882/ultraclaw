/// Response from GitHub issue creation.
Class InterClaw.Msg.FeedbackResponse Extends Ens.Response
{

/// "ok" or "error".
Property Status As %String;

/// GitHub issue URL on success.
Property IssueURL As %String(MAXLEN = 500);

/// GitHub issue number on success.
Property IssueNumber As %Integer;

/// Error message on failure.
Property ErrorMessage As %String(MAXLEN = 1000);

Storage Default
{
<Data name="FeedbackResponseDefaultData">
<Subscript>"FeedbackResponse"</Subscript>
<Value name="1">
<Value>Status</Value>
</Value>
<Value name="2">
<Value>IssueURL</Value>
</Value>
<Value name="3">
<Value>IssueNumber</Value>
</Value>
<Value name="4">
<Value>ErrorMessage</Value>
</Value>
</Data>
<DefaultData>FeedbackResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
