/// Persists ChatEvent messages into the ^InterClaw.ChatEvents global
/// for polling clients and Visual Trace visibility.
Class InterClaw.BP.EventWriter Extends Ens.BusinessProcess
{

Method OnRequest(pRequest As InterClaw.Msg.ChatEvent, Output pResponse As Ens.Response) As %Status
{
    Set bridgeId = pRequest.BridgeId
    Set seq = $Increment(^InterClaw.ChatEvents(bridgeId, "seq"))
    Set ^InterClaw.ChatEvents(bridgeId, "evt", seq) = pRequest.EventJSON
    Try {
        Set obj = ##class(%DynamicObject).%FromJSON(pRequest.EventJSON)
        If obj.type = "done" Set ^InterClaw.ChatEvents(bridgeId, "done") = 1
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
