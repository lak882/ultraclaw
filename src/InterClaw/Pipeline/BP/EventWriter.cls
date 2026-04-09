/// Writes individual chat events to the ^InterClaw.ChatEvents global
/// and forwards them as ChatPipelineEvent messages to an HTTP operation.
/// Receives ChatEvent messages from the WebSocket operation via SendRequestAsync.
Class InterClaw.Pipeline.BP.EventWriter Extends Ens.BusinessProcess
{

/// Target for forwarding events as ChatPipelineEvent messages.
Property HTTPForwardTarget As %String [ InitialExpression = "EventHTTPOperation" ];

/// Comma-separated event types to forward to the HTTP target.
/// Only these types create pipeline messages — all others are written to
/// the global only, keeping the visual trace clean.
Property ForwardEventTypes As %String [ InitialExpression = "output,done,error" ];

Parameter SETTINGS = "HTTPForwardTarget:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},ForwardEventTypes:Basic";

Method OnRequest(pRequest As InterClaw.Pipeline.Msg.ChatEvent, Output pResponse As Ens.Response) As %Status
{
    Set bridgeId = pRequest.BridgeId
    If bridgeId = "" Return $$$ERROR($$$GeneralError, "Missing BridgeId")

    // Always write to global (real-time buffer for frontend)
    Set seq = $increment(^InterClaw.ChatEvents(bridgeId, "seq"))
    Set ^InterClaw.ChatEvents(bridgeId, "evt", seq) = pRequest.EventJSON

    If pRequest.IsFinal {
        Set ^InterClaw.ChatEvents(bridgeId, "done") = 1
    }

    // Only forward significant events to HTTP target to keep traces clean
    If ..HTTPForwardTarget '= "" && ..ShouldForward(pRequest.EventType) {
        Try {
            Set chatEvt = ##class(InterClaw.Pipeline.Msg.ChatPipelineEvent).%New()
            Set chatEvt.Source = "chat"
            Set chatEvt.EventType = pRequest.EventType
            Set chatEvt.MessageId = pRequest.BridgeId
            Set chatEvt.EventJSON = pRequest.EventJSON
            Set chatEvt.ChatText = pRequest.Text
            Set chatEvt.IsFinal = pRequest.IsFinal
            Do ..SendRequestAsync(..HTTPForwardTarget, chatEvt)
        } Catch ex {
            $$$LOGWARNING("EventWriter: failed to forward ChatPipelineEvent: " _ ex.DisplayString())
        }
    }

    Return $$$OK
}

/// Handle async responses from the HTTP forward target.
/// Without this, the default Ens.BusinessProcess.OnResponse returns
/// ERROR #5003 "Not implemented", terminating the BP on every HTTP reply.
Method OnResponse(pRequest As Ens.Request, ByRef pResponse As Ens.Response, pCallrequest As Ens.Request, pCallresponse As Ens.Response, pCompletionKey As %String) As %Status
{
    Return $$$OK
}

/// Check if an event type should be forwarded to the HTTP target.
Method ShouldForward(eventType As %String) As %Boolean
{
    If ..ForwardEventTypes = "" Return 1
    For i=1:1:$length(..ForwardEventTypes, ",") {
        If $zstrip($piece(..ForwardEventTypes, ",", i), "<>W") = eventType Return 1
    }
    Return 0
}

Storage Default
{
<Data name="EventWriterDefaultData">
<Subscript>"EventWriter"</Subscript>
<Value name="1">
<Value>HTTPForwardTarget</Value>
</Value>
<Value name="2">
<Value>ForwardEventTypes</Value>
</Value>
</Data>
<DefaultData>EventWriterDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
