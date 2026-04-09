/// Persists session log requests to the InterClaw.Analytics.SessionLog table.
Class InterClaw.Analytics.BO.SessionPersistOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Method OnMessage(pRequest As InterClaw.Analytics.Msg.SessionLogRequest, Output pResponse As Ens.Response) As %Status
{
    Set sc = $$$OK
    Try {
        Set log = ##class(InterClaw.Analytics.SessionLog).%New()
        Set log.Username = pRequest.Username
        Set log.Hostname = pRequest.Hostname
        Set log.SessionStart = pRequest.SessionStart
        Set log.SessionEnd = pRequest.SessionEnd
        Set log.DurationSeconds = pRequest.DurationSeconds
        Set log.ServerName = pRequest.ServerName
        Set log.Namespace = pRequest.Namespace
        Set log.CommandsRun = pRequest.CommandsRun
        Set log.FilesPushed = pRequest.FilesPushed
        Set log.FilesModified = pRequest.FilesModified
        Set log.ErrorCount = pRequest.ErrorCount
        Set log.Errors = pRequest.Errors
        Set log.TraceSessionIds = pRequest.TraceSessionIds
        Set log.TokensUsed = pRequest.TokensUsed
        Set log.UserFeedback = pRequest.UserFeedback
        Set log.Rating = pRequest.Rating
        Set log.SubmittedAt = pRequest.SubmittedAt

        Set sc = log.%Save()
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        $$$TRACE("Saved session log for "_pRequest.Username_" ("_pRequest.ServerName_"/"_pRequest.Namespace_")")

    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

}
