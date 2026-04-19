/// Tool-execution operation. Receives a ToolCall, dispatches through
/// the tool Registry, returns a ToolResult. Runs as its own pool so that
/// long-running tools do not block the agent BP job.
Class Inteclaw.BO.ToolOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Method OnMessage(pRequest As Inteclaw.Msg.ToolCall, Output pResponse As Inteclaw.Msg.ToolResult) As %Status
{
    Set pResponse = ##class(Inteclaw.Msg.ToolResult).%New()
    Set pResponse.BridgeId = pRequest.BridgeId
    Set pResponse.ToolUseId = pRequest.ToolUseId
    Set pResponse.ToolName = pRequest.ToolName

    // Publish session id in a process-wide variable so plan-mode tools can
    // find the session when the model calls them without an explicit id.
    If pRequest.SessionId '= "" Set %InteclawSessionId = pRequest.SessionId
    Set permCtx = ""
    If pRequest.PermCtxJSON '= "" {
        Try { Set permCtx = ##class(%DynamicObject).%FromJSON(pRequest.PermCtxJSON) } Catch ex { Set permCtx = "" }
    }
    Set out = ##class(Inteclaw.Tools.Registry).Dispatch(pRequest.ToolName, pRequest.InputJSON, .isError, permCtx)
    Kill %InteclawSessionId
    Set pResponse.OutputText = out
    Set pResponse.IsError = isError
    Return $$$OK
}

}
