/// Per-session conversation context cached in a global so the BO
/// doesn't rebuild the transcript from SQL every turn.
/// 
/// Layout:
///   ^InterClaw.Context(chatId, N) = <JSON of one Anthropic messages[] entry>
/// where N is a monotonic integer from $Increment.
/// 
/// What gets stored: exactly what Claude's Bedrock Messages API wants —
///   {"role":"user",     "content":[{"type":"text","text":"..."}]}
///   {"role":"assistant","content":[{"type":"text","text":"..."}]}
/// 
/// Title and soft-delete metadata live in InterClaw.Chat.Meta, not here.
/// This global is a pure runtime cache: safe to clear at any time.
Class InterClaw.Chat.Context Extends %RegisteredObject [ Abstract ]
{

/// Append one message to the session's context. `msg` is a
/// %DynamicObject shaped like Anthropic's messages[] entry —
/// {role, content:[{type, text}, ...]}.
ClassMethod Append(chatId As %String, msg As %DynamicObject) As %Status
{
    If chatId = "" Return $$$OK
    If '$IsObject(msg) Return $$$OK
    Set n = $Increment(^InterClaw.Context(chatId))
    Set ^InterClaw.Context(chatId, n) = msg.%ToJSON()
    Return $$$OK
}

/// Load the session's context into `msgs` as a %DynamicArray in insert
/// order. Caller can then push the current user turn and hand the array
/// to CallProvider.
ClassMethod Load(chatId As %String, ByRef msgs As %DynamicArray)
{
    If '$IsObject($Get(msgs)) Set msgs = ##class(%DynamicArray).%New()
    If chatId = "" Return
    Set k = ""
    For {
        Set k = $Order(^InterClaw.Context(chatId, k))
        Quit:k=""
        // Skip non-integer subscripts (reserved for other uses).
        If k'=+k Continue
        Set json = $Get(^InterClaw.Context(chatId, k))
        If json = "" Continue
        Try {
            Do msgs.%Push(##class(%DynamicObject).%FromJSON(json))
        } Catch  {}
    }
}

/// Drop the session's context cache. Use when starting a new conversation
/// or discarding a corrupted cache. Does NOT affect InterClaw.Chat.Meta.
ClassMethod Clear(chatId As %String)
{
    If chatId = "" Return
    Kill ^InterClaw.Context(chatId)
}

/// Set a stop flag for this session. The BO checks this between agent loop
/// iterations. Stored as a string subscript so Load() skips it (Load already
/// guards with k'=+k Continue).
ClassMethod RequestStop(chatId As %String)
{
    If chatId = "" Return
    Set ^InterClaw.Context(chatId, "stop") = 1
}

/// Clear the stop flag. Called at the start of every new turn.
ClassMethod ClearStop(chatId As %String)
{
    If chatId = "" Return
    Kill ^InterClaw.Context(chatId, "stop")
}

/// Return 1 if a stop has been requested for this session.
ClassMethod StopRequested(chatId As %String) As %Boolean
{
    Return $Data(^InterClaw.Context(chatId, "stop")) > 0
}

}

