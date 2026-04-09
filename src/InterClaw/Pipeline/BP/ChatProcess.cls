/// Main orchestrator — receives ChatRequest from the service,
/// calls the WebSocket operation, and handles the ChatResponse.
Class InterClaw.Pipeline.BP.ChatProcess Extends Ens.BusinessProcess
{

Property OperationTarget As %String [ InitialExpression = "InterClaw.Pipeline.BO.WebSocketOperation" ];

Parameter SETTINGS = "OperationTarget:Basic";

Method OnRequest(pRequest As InterClaw.Pipeline.Msg.ChatRequest, Output pResponse As InterClaw.Pipeline.Msg.ChatResponse) As %Status
{
    // Use per-request override if set, otherwise fall back to configured target
    Set target = pRequest.OperationTarget
    If target = "" Set target = ..OperationTarget

    // Fire to operation asynchronously — no response needed.
    // Events stream back to the client via EventWriter.
    Set sc = ..SendRequestAsync(target, pRequest)
    If $$$ISERR(sc) Return sc

    $$$TRACE("Chat dispatched async: bridge=" _ pRequest.BridgeId)

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
