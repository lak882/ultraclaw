/// Receives ChatEvent messages from ClaudeOperation and writes them
/// to ^InterClaw.ChatEvents globals for frontend polling.
/// Exists as a production component so events appear in Visual Trace.
Class InterClaw.Pipeline.BP.EventWriter Extends Ens.BusinessProcess
{

Method OnRequest(pRequest As InterClaw.Pipeline.Msg.ChatEvent, Output pResponse As Ens.Response) As %Status
{
    Set bridgeId = pRequest.BridgeId
    Set eventJSON = pRequest.EventJSON

    Set seq = $increment(^InterClaw.ChatEvents(bridgeId, "seq"))
    Set ^InterClaw.ChatEvents(bridgeId, "evt", seq) = eventJSON

    Try {
        Set obj = ##class(%DynamicObject).%FromJSON(eventJSON)
        If obj.type = "done" {
            Set ^InterClaw.ChatEvents(bridgeId, "done") = 1
        }
    } Catch ex {}

    Return $$$OK
}

Method OnResponse(pRequest As Ens.Request, ByRef pResponse As Ens.Response, pCallrequest As Ens.Request, pCallresponse As Ens.Response, pCompletionKey As %String) As %Status
{
    Return $$$OK
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
