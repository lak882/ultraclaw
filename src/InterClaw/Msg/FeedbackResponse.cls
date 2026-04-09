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

}
