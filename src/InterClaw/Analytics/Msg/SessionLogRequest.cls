Class InterClaw.Analytics.Msg.SessionLogRequest Extends (Ens.Request, %JSON.Adaptor, %XML.Adaptor)
{

Property Username As %String(MAXLEN = 100);

Property Hostname As %String(MAXLEN = 200);

Property SessionStart As %String(MAXLEN = 30);

Property SessionEnd As %String(MAXLEN = 30);

Property DurationSeconds As %Integer;

Property ServerName As %String(MAXLEN = 100);

Property Namespace As %String(MAXLEN = 100);

Property CommandsRun As %String(MAXLEN = 10000);

Property FilesPushed As %String(MAXLEN = 10000);

Property FilesModified As %String(MAXLEN = 10000);

Property ErrorCount As %Integer;

Property Errors As %String(MAXLEN = 32000);

Property TraceSessionIds As %String(MAXLEN = 2000);

Property TokensUsed As %Integer;

Property UserFeedback As %String(MAXLEN = 2000);

Property Rating As %Integer;

Property SubmittedAt As %String(MAXLEN = 30);

}
