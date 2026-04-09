/// InterClaw.BO.AuditLog — Business Operation that stores audit events.
///
/// Receives InterClaw.Msg.AuditEvent messages from ScriptAudit and stores them
/// as InterClaw.AuditEntry rows. Every message creates a trace entry in the
/// IRIS visual trace for debugging and observability.
Class InterClaw.BO.AuditLog Extends Ens.BusinessOperation
{

Parameter ADAPTER = "Ens.OutboundAdapter";

Parameter INVOCATION = "Queue";

/// Handle audit events from the ScriptAudit service.
Method AuditEvent(pRequest As InterClaw.Msg.AuditEvent, Output pResponse As Ens.Response) As %Status
{
    set etype = pRequest.EventType
    set summary = pRequest.Summary

    if etype = "api_call" {
        $$$LOGINFO("[API] " _ pRequest.Action _ " " _ pRequest.StatusCode _ " (" _ pRequest.Duration _ "ms) " _ $extract(pRequest.Target, 1, 100))
    } elseif etype = "terminal" {
        $$$LOGINFO("[TERM] " _ pRequest.Namespace _ ": " _ $extract(pRequest.Summary, 1, 200))
    } elseif etype = "file_change" {
        $$$LOGINFO("[FILE] " _ summary)
    } else {
        $$$LOGINFO("[AUDIT] " _ etype _ ": " _ $extract(summary, 1, 200))
    }

    try {
        set entry = ##class(InterClaw.AuditEntry).%New()
        set entry.EventType = etype
        set entry.Action = pRequest.Action
        set entry.Target = $extract(pRequest.Target, 1, 2000)
        set entry.StatusCode = pRequest.StatusCode
        set entry.Duration = pRequest.Duration
        set entry.ClassName = pRequest.ClassName
        set entry.Namespace = pRequest.Namespace
        set entry.Server = pRequest.Server
        set entry.Summary = $extract(summary, 1, 1000)
        set entry.OriginalTimestamp = pRequest.OriginalTimestamp
        set sc = entry.%Save()
    } catch ex {
        $$$LOGWARNING("Failed to save audit entry: " _ ex.DisplayString())
    }

    return $$$OK
}

XData MessageMap
{
<MapItems>
    <MapItem MessageType="InterClaw.Msg.AuditEvent">
        <Method>AuditEvent</Method>
    </MapItem>
</MapItems>
}

}
