Class InterClaw.Analytics.SessionLog Extends %Persistent
{

/// Who ran the session
Property Username As %String(MAXLEN = 100);

/// Machine hostname
Property Hostname As %String(MAXLEN = 200);

/// When the Claude session started
Property SessionStart As %TimeStamp;

/// When it ended
Property SessionEnd As %TimeStamp;

/// Duration in seconds
Property DurationSeconds As %Integer;

/// Which IRIS server they were working on
Property ServerName As %String(MAXLEN = 100);

/// Which namespace
Property Namespace As %String(MAXLEN = 100);

/// JSON array of slash commands run
Property CommandsRun As %String(MAXLEN = 10000);

/// JSON array of classes pushed to server
Property FilesPushed As %String(MAXLEN = 10000);

/// JSON array of local files modified
Property FilesModified As %String(MAXLEN = 10000);

/// Number of errors encountered
Property ErrorCount As %Integer [ InitialExpression = 0 ];

/// JSON array of error messages
Property Errors As %String(MAXLEN = 32000);

/// JSON array of IRIS message trace session IDs
Property TraceSessionIds As %String(MAXLEN = 2000);

/// Approximate token usage
Property TokensUsed As %Integer;

/// Free-text user feedback
Property UserFeedback As %String(MAXLEN = 2000);

/// 1-5 rating
Property Rating As %Integer;

/// When the log was submitted to analytics
Property SubmittedAt As %TimeStamp [ InitialExpression = {$zdatetime($horolog, 3)} ];

Index IdxUser On Username;

Index IdxServer On (ServerName, Namespace);

Index IdxTime On SessionStart;

Storage Default
{
<Data name="SessionLogDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Username</Value>
</Value>
<Value name="3">
<Value>Hostname</Value>
</Value>
<Value name="4">
<Value>SessionStart</Value>
</Value>
<Value name="5">
<Value>SessionEnd</Value>
</Value>
<Value name="6">
<Value>DurationSeconds</Value>
</Value>
<Value name="7">
<Value>ServerName</Value>
</Value>
<Value name="8">
<Value>Namespace</Value>
</Value>
<Value name="9">
<Value>CommandsRun</Value>
</Value>
<Value name="10">
<Value>FilesPushed</Value>
</Value>
<Value name="11">
<Value>FilesModified</Value>
</Value>
<Value name="12">
<Value>ErrorCount</Value>
</Value>
<Value name="13">
<Value>Errors</Value>
</Value>
<Value name="14">
<Value>TraceSessionIds</Value>
</Value>
<Value name="15">
<Value>TokensUsed</Value>
</Value>
<Value name="16">
<Value>UserFeedback</Value>
</Value>
<Value name="17">
<Value>Rating</Value>
</Value>
<Value name="18">
<Value>SubmittedAt</Value>
</Value>
</Data>
<DataLocation>^InterClaw.Analyt.SessionLogD</DataLocation>
<DefaultData>SessionLogDefaultData</DefaultData>
<IdLocation>^InterClaw.Analyt.SessionLogD</IdLocation>
<IndexLocation>^InterClaw.Analyt.SessionLogI</IndexLocation>
<StreamLocation>^InterClaw.Analyt.SessionLogS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
