/// InterClaw.BO.ConversationLog — Business Operation for conversation audit trail.
///
/// Receives InterClaw.Msg.ChatRequest, ChatResponse, and ToolEvent messages from
/// InterClaw.BS.ChatbotBackend. Every message creates an entry in the IRIS message
/// trace, providing full end-to-end visibility of chatbot conversations.
Class InterClaw.BO.ConversationLog Extends Ens.BusinessOperation
{

Parameter ADAPTER = "Ens.OutboundAdapter";

Parameter INVOCATION = "Queue";

/// Handle a user prompt.
Method ChatRequest(pRequest As InterClaw.Msg.ChatRequest, Output pResponse As Ens.Response) As %Status
{
    $$$LOGINFO("[" _ pRequest.SessionId _ "] User: " _ $extract(pRequest.Text, 1, 200))
    return $$$OK
}

/// Handle Claude's response.
Method ChatResponse(pRequest As InterClaw.Msg.ChatResponse, Output pResponse As Ens.Response) As %Status
{
    set status = $select(pRequest.Success:"OK", 1:"ERROR")
    $$$LOGINFO("[" _ pRequest.SessionId _ "] Claude: " _ status _ " | tools=" _ pRequest.ToolCallCount _ " | tokens=" _ pRequest.InputTokens _ "+" _ pRequest.OutputTokens _ " | $" _ pRequest.Cost)
    return $$$OK
}

/// Handle a tool call or result.
Method ToolEvent(pRequest As InterClaw.Msg.ToolEvent, Output pResponse As Ens.Response) As %Status
{
    $$$LOGINFO("[" _ pRequest.SessionId _ "] Tool " _ pRequest.EventType _ ": " _ pRequest.ToolName)
    return $$$OK
}

XData MessageMap
{
<MapItems>
    <MapItem MessageType="InterClaw.Msg.ChatRequest">
        <Method>ChatRequest</Method>
    </MapItem>
    <MapItem MessageType="InterClaw.Msg.ChatResponse">
        <Method>ChatResponse</Method>
    </MapItem>
    <MapItem MessageType="InterClaw.Msg.ToolEvent">
        <Method>ToolEvent</Method>
    </MapItem>
</MapItems>
}

}
