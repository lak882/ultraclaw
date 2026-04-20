/// Agent loop. Receives a ChatRequest, drives the LLM through repeated
/// provider calls and tool executions until the model emits end_turn
/// or max turns is reached.
///
/// Uses SendRequestSync to the ProviderOperation and the ToolOperation
/// so the loop can be written as straight-line code instead of BPL state.
/// Events are streamed via EventWriter so frontends can poll ^Inteclaw.ChatEvents.
Class InterClaw.BP.ChatProcess Extends Ens.BusinessProcess
{

Property ProviderTarget As %String [ InitialExpression = "InterClaw.BO.ProviderOperation" ];

Property ToolTarget As %String [ InitialExpression = "InterClaw.BO.ToolOperation" ];

Property EventTarget As %String [ InitialExpression = "InterClaw.BP.EventWriter" ];

Property MaxTurns As %Integer [ InitialExpression = 12 ];

Parameter SETTINGS = "ProviderTarget:Basic,ToolTarget:Basic,EventTarget:Basic,MaxTurns:Basic";

/// Emit an event for frontend streaming and trace visibility.
Method Emit(bridgeId As %String, type As %String, payload As %DynamicObject)
{
    If '$IsObject(payload) Set payload = ##class(%DynamicObject).%New()
    Do payload.%Set("type", type)
    Set evt = ##class(InterClaw.Msg.ChatEvent).%New()
    Set evt.BridgeId = bridgeId
    Set evt.EventJSON = payload.%ToJSON()
    Do ..SendRequestAsync(..EventTarget, evt, 0)
    // Ensure the `done` flag is set synchronously so the long-poll sees it
    // the moment OnRequest returns, even if the async EventWriter job is
    // backed up. Prevents "final answer rendered but bridge hangs" races.
    If type = "done" {
        Set ^Inteclaw.ChatEvents(bridgeId, "done") = 1
    }
}

Method OnRequest(pRequest As InterClaw.Msg.ChatRequest, Output pResponse As InterClaw.Msg.ChatResponse) As %Status
{
    Set pResponse = ##class(InterClaw.Msg.ChatResponse).%New()
    Set pResponse.BridgeId = pRequest.BridgeId
    Set pResponse.Status = "completed"

    Set bridgeId = pRequest.BridgeId
    Set sessionId = pRequest.SessionId
    If sessionId = "" Set sessionId = $Extract($System.Util.CreateGUID(), 1, 12)
    Set pResponse.SessionId = sessionId

    // Guarantee that the bridge always gets a `done` flag set, even if an
    // uncaught exception escapes below. Without this, the frontend would
    // poll forever on a stalled bridge.
    Try {

    // Open or create session and append the user prompt
    Set session = ##class(InterClaw.Session).OpenOrCreate(sessionId)
    Set isNewSession = (session.MessagesJSON = "[]")
    If pRequest.Provider '= "" Set session.Provider = pRequest.Provider
    If pRequest.Model '= "" Set session.Model = pRequest.Model
    If pRequest.SystemPrompt '= "" {
        Set session.SystemPrompt = pRequest.SystemPrompt
    }
    ElseIf session.SystemPrompt = "" {
        // Short, stable system prompt — identity + tool index + pointer to
        // the operating manual. CLAUDE.md itself is posted as a first user
        // message below on new sessions only.
        Set session.SystemPrompt = ##class(InterClaw.Skill.Loader).BuildSystemPrompt()
    }

    // On a new session, persist the operating manual (CLAUDE.md) as a real
    // first user message + synthetic assistant ack. This matches the original
    // InterClaw pipeline's behavior: the model sees the full manual on every
    // turn. Anthropic prompt-caching (cache_control attached by the provider
    // operation) makes follow-up turns cheap despite the large prefix.
    If isNewSession {
        Set bootstrap = ##class(InterClaw.Skill.Loader).BuildBootstrapMessage()
        If bootstrap '= "" {
            Set bootstrapContent = "[{""type"":""text"",""text"":" _ ..JsonQuote(bootstrap) _ "}]"
            Do session.AppendMessage("user", bootstrapContent)
            Set ackContent = "[{""type"":""text"",""text"":""Operating manual acknowledged. Ready for your first request.""}]"
            Do session.AppendMessage("assistant", ackContent)
        }
    }

    // Append the actual user prompt as a fresh user message.
    Set userContent = "[{""type"":""text"",""text"":" _ ..JsonQuote(pRequest.Prompt) _ "}]"
    Do session.AppendMessage("user", userContent)

    // Connected event
    Do ..Emit(bridgeId, "connected", ##class(%DynamicObject).%New())
    Do ..Emit(bridgeId, "session", {"session_id": (sessionId)})

    Set maxTurns = pRequest.MaxTurns
    If maxTurns < 1 Set maxTurns = ..MaxTurns
    Set turns = 0
    Set totalInput = 0
    Set totalOutput = 0
    Set finalText = ""

    For turn = 1:1:maxTurns {
        Set turns = turn

        // Rebuild permission context + tool descriptor each turn — plan-mode
        // tools mutate the session and we want the new state reflected before
        // the next provider call.
        // OpenOrCreate may return a cached in-memory instance. Force a
        // fresh disk read so that a tool's mutations to PlanMode / DenyTools
        // (done in a different job) are visible here.
        Set session = ##class(InterClaw.Session).OpenOrCreate(sessionId)
        If $IsObject(session), session.%Id() '= "" {
            Do session.%Reload()
        }
        Set permCtx = ##class(InterClaw.Tools.Permissions).Context(session)
        Set permCtxJSON = permCtx.%ToJSON()
        Set toolsJSON = ##class(InterClaw.Tools.Registry).DescriptorsJSON(permCtx)

        Set call = ##class(InterClaw.Msg.ProviderCall).%New()
        Set call.BridgeId = bridgeId
        Set call.SessionId = sessionId
        Set call.Provider = session.Provider
        Set call.Model = session.Model
        Set call.SystemPrompt = session.SystemPrompt
        Set call.MessagesJSON = session.MessagesJSON
        If pRequest.Effort '= "" Set call.Effort = pRequest.Effort
        Set call.ToolsJSON = toolsJSON
        Set call.MaxTokens = 4096

        Set sc = ..SendRequestSync(..ProviderTarget, call, .result)
        If $$$ISERR(sc) {
            Do ..Emit(bridgeId, "error", {"text": ($System.Status.GetErrorText(sc))})
            Set pResponse.Status = "error"
            Quit
        }

        If result.ErrorText '= "" {
            Do ..Emit(bridgeId, "error", {"text": (result.ErrorText)})
            Set pResponse.Status = "error"
            Quit
        }

        Set totalInput = totalInput + result.InputTokens
        Set totalOutput = totalOutput + result.OutputTokens

        Do ..Emit(bridgeId, "usage", {
            "input_tokens": (result.InputTokens),
            "output_tokens": (result.OutputTokens),
            "cache_read_tokens": (result.CacheReadTokens),
            "cache_write_tokens": (result.CacheWriteTokens),
            "turn": (turn)
        })

        // Persist assistant message. Strip `thinking` content blocks — if
        // we send them back on the next turn without the matching signature
        // Anthropic rejects with "Invalid `signature` in `thinking` block".
        // The thinking was visible live via the `thinking` event stream; the
        // transcript only needs text + tool_use.
        Set persistContent = ..StripThinking(result.ContentJSON)
        Do session.AppendMessage("assistant", persistContent)

        // Walk content blocks, emit events, collect tool_use blocks
        Set blocks = ##class(%DynamicArray).%FromJSON(result.ContentJSON)
        // Pre-scan blocks to decide whether this assistant message is
        // "thinking turn" (has any tool_use — text is running narrative)
        // or "answer turn" (no tool_use — text is the final answer).
        Set hasToolUse = 0
        Set iter0 = blocks.%GetIterator()
        While iter0.%GetNext(.i0, .block0) {
            If block0.%Get("type") = "tool_use" Set hasToolUse = 1 Quit
        }

        // Streaming note: the ProviderOperation already emitted `delta`,
        // `thinking` (for thinking_delta), and `tool_use` events mid-stream.
        // We still post-walk to (a) collect tool_use blocks for dispatch,
        // (b) capture finalText for transcript bookkeeping, and (c) emit a
        // terminal `thinking` event for preamble text so the UI repositions
        // the streamed text out of the main bubble if this turn has tool_use.
        Set iter = blocks.%GetIterator()
        Set toolUses = ##class(%DynamicArray).%New()
        While iter.%GetNext(.i, .block) {
            Set btype = block.%Get("type")
            If btype = "text" {
                Set txt = block.%Get("text")
                Set finalText = txt
                // Reclassify-as-thinking fires mid-stream in the provider op
                // (on content_block_start for tool_use). Here we only emit
                // the terminal `output` for final-answer turns.
                If 'hasToolUse {
                    Do ..Emit(bridgeId, "output", {"text": (txt)})
                }
            }
            ElseIf btype = "thinking" {
                // Streaming already emitted per-chunk thinking events to the
                // UI. No post-walk emit — would duplicate or reset the card.
            }
            ElseIf btype = "tool_use" {
                // Do NOT re-emit tool_use here — streaming already did.
                Do toolUses.%Push(block)
            }
        }

        // If stop_reason is end_turn (or no tool_use), we're done
        If (result.StopReason = "end_turn") || (toolUses.%Size() = 0) {
            Quit
        }

        // Reorder: plan-mode toggles run FIRST so their deny-list takes
        // effect on the rest of the assistant turn's tool_use blocks.
        Set orderedUses = ##class(%DynamicArray).%New()
        Set iter2 = toolUses.%GetIterator()
        While iter2.%GetNext(.k1, .tuA) {
            Set nm = tuA.%Get("name")
            If (nm = "enter_plan_mode") || (nm = "exit_plan_mode") Do orderedUses.%Push(tuA)
        }
        Set iter2 = toolUses.%GetIterator()
        While iter2.%GetNext(.k2, .tuB) {
            Set nm = tuB.%Get("name")
            If (nm '= "enter_plan_mode") && (nm '= "exit_plan_mode") Do orderedUses.%Push(tuB)
        }

        // Execute tool_use blocks and build a user message of tool_results.
        // Refresh the permission context before EACH tool call — a plan-mode
        // tool earlier in the same assistant message may have just flipped
        // the session's deny-list, and we want that to take effect for the
        // very next tool within the same turn.
        Set toolResultContent = ##class(%DynamicArray).%New()
        Set titer = orderedUses.%GetIterator()
        While titer.%GetNext(.j, .tu) {
            Set session = ##class(InterClaw.Session).OpenOrCreate(sessionId)
            Set permCtx = ##class(InterClaw.Tools.Permissions).Context(session)
            Set permCtxJSON = permCtx.%ToJSON()
            Set ^Inteclaw.PlanTrace($I(^Inteclaw.PlanTrace)) = "dispatch tool=" _ tu.%Get("name") _ " plan=" _ session.PlanMode _ " deny=" _ session.DenyTools _ " ctx=" _ permCtxJSON

            Set tcall = ##class(InterClaw.Msg.ToolCall).%New()
            Set tcall.BridgeId = bridgeId
            Set tcall.SessionId = sessionId
            Set tcall.ToolUseId = tu.%Get("id")
            Set tcall.ToolName = tu.%Get("name")
            Set tcall.InputJSON = tu.%Get("input").%ToJSON()
            Set tcall.PermCtxJSON = permCtxJSON

            Set tsc = ..SendRequestSync(..ToolTarget, tcall, .tres)
            If $$$ISERR(tsc) {
                Set outText = "Error sending tool: " _ $System.Status.GetErrorText(tsc)
                Set isErr = 1
            } Else {
                Set outText = tres.OutputText
                Set isErr = tres.IsError
            }

            Do ..Emit(bridgeId, "tool_result", {"tool_use_id": (tu.%Get("id")), "text": (outText), "is_error": (isErr)})

            // Cap persisted tool_result content. Anything above ~2000 chars
            // gets truncated for the transcript — the model already saw the
            // full output this turn; on subsequent turns it only needs the
            // gist. Without this, large SQL/class listings bloat MessagesJSON
            // and cost real tokens every turn in cache_write/read.
            Set persistText = outText
            If $Length(persistText) > 2000 {
                Set persistText = $Extract(outText, 1, 2000) _ $Char(10) _ "... [truncated " _ ($Length(outText) - 2000) _ " chars for transcript]"
            }
            Set trBlock = ##class(%DynamicObject).%New()
            Do trBlock.%Set("type", "tool_result")
            Do trBlock.%Set("tool_use_id", tu.%Get("id"))
            Do trBlock.%Set("content", persistText)
            If isErr Do trBlock.%Set("is_error", 1, "boolean")
            Do toolResultContent.%Push(trBlock)
        }

        Do session.AppendMessage("user", toolResultContent.%ToJSON())
    }

    Set session.TotalInputTokens = session.TotalInputTokens + totalInput
    Set session.TotalOutputTokens = session.TotalOutputTokens + totalOutput
    Do session.%Save()

    Set pResponse.FinalText = finalText
    Set pResponse.Turns = turns
    Set pResponse.InputTokens = totalInput
    Set pResponse.OutputTokens = totalOutput

    Do ..Emit(bridgeId, "done", {"session_id": (sessionId), "turns": (turns)})
    } Catch ex {
        // Surface the error to the UI and ensure `done` is set so the
        // frontend stops polling.
        Do ..Emit(bridgeId, "error", {"text": ("BP error: " _ ex.DisplayString())})
        Do ..Emit(bridgeId, "done", {"session_id": (sessionId), "turns": (turns)})
    }
    // Safety belt: set the flag directly too, in case Emit's async delivery
    // hasn't reached the EventWriter yet.
    Set ^Inteclaw.ChatEvents(bridgeId, "done") = 1
    Return $$$OK
}

Method OnResponse(pRequest As Ens.Request, ByRef pResponse As Ens.Response, pCallrequest As Ens.Request, pCallresponse As Ens.Response, pCompletionKey As %String) As %Status
{
    Return $$$OK
}

/// JSON-quote a string for inline JSON construction.
/// Remove `thinking` and `redacted_thinking` blocks from a content-JSON
/// array. Required before persisting an assistant message to the session
/// transcript: Anthropic's Messages API will reject the next turn if a
/// thinking block is resent without its signature, and we don't reliably
/// have the signature when we stream.
ClassMethod StripThinking(contentJSON As %String) As %String [ Language = python ]
{
    import json
    try:
        blocks = json.loads(str(contentJSON))
    except Exception:
        return contentJSON
    if not isinstance(blocks, list):
        return contentJSON
    kept = [b for b in blocks if isinstance(b, dict) and b.get("type") not in ("thinking", "redacted_thinking")]
    return json.dumps(kept)
}

ClassMethod JsonQuote(s As %String) As %String [ Language = python ]
{
    import json
    return json.dumps(str(s) if s is not None else "")
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
