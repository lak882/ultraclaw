/// ProviderOperation
/// ------------------
/// Synchronous (non-streaming) model invocation layer.
/// 
/// Responsibilities:
/// - Resolve credentials
/// - Select provider + model defaults
/// - Call external LLM provider (Bedrock or Anthropic)
/// - Normalize response into ModelProviderResult shape
/// 
/// Notes:
/// - All streaming logic has been removed for simplicity.
/// - The Business Process (BP) consuming this BO expects a normalized JSON shape.
/// - Python is used for HTTP calls to avoid ObjectScript networking overhead.
Class InterClaw.BO.AnthropicOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

/// Default provider if none specified in request.
/// Supported values:
/// - "bedrock"
/// - "anthropic"
Property DefaultProvider As %String [ InitialExpression = "bedrock" ];

/// Default model identifier.
/// Example: Anthropic Claude via Bedrock
Property DefaultModel As %String [ InitialExpression = "us.anthropic.claude-opus-4-7" ];

/// Expose settings in production configuration UI
/// Config name of the ToolOperation BO. Each tool_use Claude emits becomes
/// a SendRequestSync to this target. Must be set when ToolNames is
/// non-empty on the ChatRequest.
Property ToolTarget As Ens.DataType.ConfigName [ InitialExpression = "InterClaw.BO.ToolOperation" ];

Parameter SETTINGS = "DefaultProvider:Basic,DefaultModel:Basic,ToolTarget:Basic";

/// GetCredentialSecret
/// -------------------
/// Fetches the stored credential JSON from Ens.Config.Credentials.
/// 
/// Expected credential format (JSON string in Password field):
/// {
///   "key": "...",
///   "region": "us-east-1"
/// }
/// 
/// Returns:
/// - JSON string (opaque to ObjectScript)
/// - "" if not found or error
Method GetCredentialSecret() As %String
{
    Set secret = ""
    Try {
        If ##class(Ens.Config.Credentials).%ExistsId("InterClaw.Bedrock") {
            Set cred = ##class(Ens.Config.Credentials).%OpenId("InterClaw.Bedrock")
            If cred '= "" {
                Set secret = cred.Password
            }
        }
    } Catch ex {
        // Swallow errors: caller handles empty secret
    }
    Return secret
}

/// OnMessage
/// ---------
/// Entry point from Ensemble/IRIS production.
/// 
/// Flow:
/// 1. Resolve provider + model (fallback to defaults)
/// 2. Load credentials
/// 3. Call provider synchronously
/// 4. Parse + normalize response into ModelProviderResult
/// 
/// Input:
///   InterClaw.Msg.ModelProviderRequest
/// 
/// Output:
///   InterClaw.Msg.ModelProviderResult
/// 
/// Important:
/// - No streaming: entire response is returned at once
/// - Errors are captured into ErrorText (not thrown)
Method OnMessage(pRequest As InterClaw.Msg.Chat.Request, Output pResponse As InterClaw.Msg.Chat.Response) As %Status
{
    Set started = $ZH
    Set pResponse = ##class(InterClaw.Msg.Chat.Response).%New()
    Set pResponse.RequestId = pRequest.RequestId
    Set pResponse.ChatId = pRequest.ChatId

    Set provider = $Select(pRequest.ModelProvider'="":pRequest.ModelProvider, 1:..DefaultProvider)
    Set model = $Select(pRequest.Model'="":pRequest.Model, 1:..DefaultModel)

    Set secret = ..GetCredentialSecret()
    If secret = "" {
        Set pResponse.ErrorText = "No InterClaw.Bedrock credential configured"
        Set pResponse.DurationMs = +((($ZH - started) * 1000) \ 1)
        Do pResponse.%Save()
        Return $$$OK
    }

    // Build the conversation transcript. Replay any prior turns for
    // this session from the context global, then append the current
    // user turn. `msgs` is what Bedrock sees as messages[].
    Set msgs = ##class(%DynamicArray).%New()
    Do ##class(InterClaw.Chat.Context).Load(pRequest.ChatId, .msgs)

    Set turn = ##class(%DynamicObject).%New()
    Do turn.%Set("role", "user")
    Set content = ##class(%DynamicArray).%New()
    Set block = ##class(%DynamicObject).%New()
    Do block.%Set("type", "text")
    Do block.%Set("text", pRequest.Prompt)
    Do content.%Push(block)
    Do turn.%Set("content", content)
    Do msgs.%Push(turn)

    // Clear any stale stop flag from a previous turn so a prior stop
    // request does not suppress the new turn.
    Do ##class(InterClaw.Chat.Context).ClearStop(pRequest.ChatId)

    // Persist the user turn to the context global so the next turn
    // in this session sees it. Do this before the Bedrock call so a
    // mid-call crash doesn't lose the user's prompt.
    Do ##class(InterClaw.Chat.Context).Append(pRequest.ChatId, turn)

    // Resolve the tool surface for this turn. Empty / "*" = all registered.
    Set toolsJSON = ..ResolveToolsJSON(pRequest.ToolNames)

    // Update stored page context whenever the frontend sends a non-empty value.
    // Always read back the stored value so older turns without a fresh context
    // still see the last known page/class the user had open.
    If pRequest.PageContext '= "" {
        Set ^InterClaw.Chat.Meta(pRequest.ChatId, "pageContext") = pRequest.PageContext
    }
    Set pageCtx = $Get(^InterClaw.Chat.Meta(pRequest.ChatId, "pageContext"), "")

    // Same treatment for LinkBase — persist per chat so later turns can
    // build legacy-ui links even when the current POST didn't include it.
    If pRequest.LinkBase '= "" {
        Set ^InterClaw.Chat.Meta(pRequest.ChatId, "linkBase") = pRequest.LinkBase
    }
    Set linkBase = $Get(^InterClaw.Chat.Meta(pRequest.ChatId, "linkBase"), "")

    // Build the system prompt: SOUL.md (persona/voice) first, AGENTS.md
    // (operational guide) next, the <available_skills> block, then the
    // current page context and link base as stable anchors that survive
    // compaction.
    Set soulBody = ..ReadAgentFile("SOUL.md")
    Set agentsBody = ..ReadAgentFile("AGENTS.md")
    Set skillsBlock = ##class(InterClaw.Skill.Registry).BuildPromptBlock()
    Set systemPrompt = soulBody
    If (soulBody '= "") && (agentsBody '= "") Set systemPrompt = systemPrompt _ $Char(10) _ $Char(10)
    Set systemPrompt = systemPrompt _ agentsBody _ skillsBlock
    If pageCtx '= "" {
        Set systemPrompt = systemPrompt _ $Char(10) _ $Char(10)
            _ "<page_context>" _ $Char(10) _ pageCtx _ $Char(10) _ "</page_context>"
    }
    If linkBase '= "" {
        Set systemPrompt = systemPrompt _ $Char(10) _ $Char(10)
            _ "<link_base>" _ linkBase _ "</link_base>"
    }

    // Trace the context line prepended by the frontend so it appears in
    // Visual Trace for every turn — useful for debugging namespace / page context.
    Set contextLine = $Piece(pRequest.Prompt, $Char(10), 1)
    If $Extract(contextLine, 1, 9) = "[Context:" {
        $$$TRACE("Context: " _ contextLine)
    }

    // Agent loop: call Claude -> if tool_use, dispatch, append, repeat.
    Set lastText = ""
    Set totalIn = 0, totalOut = 0, totalCacheR = 0, totalCacheW = 0
    For {
        If ##class(InterClaw.Chat.Context).StopRequested(pRequest.ChatId) {
            Do ##class(InterClaw.Chat.Context).ClearStop(pRequest.ChatId)
            $$$LOGINFO("Chat " _ pRequest.ChatId _ " stopped by user " _ pRequest.Username)
            Set pResponse.ErrorText = "Stopped by user"
            Quit
        }
        Set resultJSON = ..CallProvider(provider, model, secret, systemPrompt, msgs.%ToJSON(), toolsJSON, 4096, pRequest.Effort)
        Set result = ""
        Try { Set result = ##class(%DynamicObject).%FromJSON(resultJSON) }
        Catch ex {
            Set pResponse.ErrorText = "Parse error: " _ ex.DisplayString()
            Quit
        }
        If result.%Get("error") '= "" {
            Set pResponse.ErrorText = result.%Get("error")
            Quit
        }

        // Accumulate usage across iterations.
        Set totalIn     = totalIn     + +result.%Get("input_tokens")
        Set totalOut    = totalOut    + +result.%Get("output_tokens")
        Set totalCacheR = totalCacheR + +result.%Get("cache_read_tokens")
        Set totalCacheW = totalCacheW + +result.%Get("cache_write_tokens")

        Set contentJSON = result.%Get("content_json")
        Set stopReason  = result.%Get("stop_reason")
        Set blocks = ##class(%DynamicArray).%New()
        If contentJSON '= "" {
            Try { Set blocks = ##class(%DynamicArray).%FromJSON(contentJSON) }
            Catch ex { Set pResponse.ErrorText = "Content parse error: " _ ex.DisplayString() Set stopReason = "end_turn" }
        }

        // Capture latest text, append assistant turn to transcript.
        Set assistantTurn = ##class(%DynamicObject).%New()
        Do assistantTurn.%Set("role", "assistant")
        Do assistantTurn.%Set("content", blocks)
        Do msgs.%Push(assistantTurn)

        Set iter = blocks.%GetIterator()
        Set toolUses = ##class(%DynamicArray).%New()
        While iter.%GetNext(.k, .b) {
            If '$IsObject(b) Continue
            If b.%Get("type") = "text" Set lastText = b.%Get("text")
            If b.%Get("type") = "tool_use" Do toolUses.%Push(b)
        }

        // No tool calls -> final turn, we're done.
        If stopReason '= "tool_use" Quit
        If toolUses.%Size() = 0 Quit

        // Dispatch each tool_use; fold all results into a single user turn.
        Set toolResults = ##class(%DynamicArray).%New()
        Set ti = toolUses.%GetIterator()
        While ti.%GetNext(.tk, .tu) {
            Set toolReq = ##class(InterClaw.Msg.Tool.Request).%New()
            Set toolReq.ToolUseId = tu.%Get("id")
            Set toolReq.ToolName = tu.%Get("name")
            Set toolReq.InputJSON = tu.%Get("input").%ToJSON()
            Set toolReq.Namespace = pRequest.Namespace
            Set toolReq.RequestId = pRequest.RequestId
            Set toolReq.ChatId = pRequest.ChatId
            Set sc = ..SendRequestSync(..ToolTarget, toolReq, .toolResp)
            If $$$ISERR(sc) || '$IsObject(toolResp) {
                Set trBlock = ##class(%DynamicObject).%New()
                Do trBlock.%Set("type", "tool_result")
                Do trBlock.%Set("tool_use_id", tu.%Get("id"))
                Do trBlock.%Set("content", "Error: dispatch failed " _ $System.Status.GetErrorText(sc), "string")
                Do trBlock.%Set("is_error", 1, "boolean")
                Do toolResults.%Push(trBlock)
                Continue
            }
            Set trBlock = ##class(%DynamicObject).%New()
            Do trBlock.%Set("type", "tool_result")
            Do trBlock.%Set("tool_use_id", toolResp.ToolUseId)
            Do trBlock.%Set("content", toolResp.OutputText, "string")
            Do trBlock.%Set("is_error", ''toolResp.IsError, "boolean")
            Do toolResults.%Push(trBlock)
        }
        Set userTurn = ##class(%DynamicObject).%New()
        Do userTurn.%Set("role", "user")
        Do userTurn.%Set("content", toolResults)
        Do msgs.%Push(userTurn)
    }

    Set pResponse.InputTokens      = totalIn
    Set pResponse.OutputTokens     = totalOut
    Set pResponse.CacheReadTokens  = totalCacheR
    Set pResponse.CacheWriteTokens = totalCacheW
    Set pResponse.CostUSD = ..CalculateCost(model, totalIn, totalOut, totalCacheR, totalCacheW)
    If pResponse.ErrorText = "" Set pResponse.ResponseText = lastText
    Set pResponse.DurationMs = +((($ZH - started) * 1000) \ 1)

    // Generate title before saving the response row so the first-turn check
    // (no prior rows for this ChatId) is reliable without any RequestId exclusion.
    Do ##class(InterClaw.Chat.Meta).SetOwner(pRequest.ChatId, pRequest.Username)
    $$$TRACE("Title: stripping context prefix from prompt for chat " _ pRequest.ChatId)
    Set titlePrompt = pRequest.Prompt
    While $Extract(titlePrompt, 1, 9) = "[Context:" {
        Set nlPos = $Find(titlePrompt, $Char(10))
        If nlPos = 0 Quit
        Set titlePrompt = $ZStrip($Extract(titlePrompt, nlPos, *), "<W")
    }
    $$$TRACE("Title: stripped prompt (first 120 chars): " _ $Extract(titlePrompt, 1, 120))
    Set existingTitle = $Get(^InterClaw.Chat.Meta(pRequest.ChatId, "title"))
    $$$TRACE("Title: existing Meta title for " _ pRequest.ChatId _ " = " _ $Select(existingTitle'="":"'" _ existingTitle _ "'", 1:"(none)"))
    If existingTitle = "" {
        $$$TRACE("Title: no title in Meta — calling GenerateTitlePy")
        Set generatedTitle = ##class(InterClaw.Chat.Meta).GenerateTitlePy(
            titlePrompt, lastText, secret, provider)
        $$$TRACE("Title: GenerateTitlePy returned: " _ $Select(generatedTitle'="":generatedTitle, 1:"(empty)"))
        If generatedTitle '= "" {
            Do ##class(InterClaw.Chat.Meta).SetTitle(pRequest.ChatId, generatedTitle)
            $$$TRACE("Title: stored '" _ generatedTitle _ "' for chat " _ pRequest.ChatId)
        } Else {
            $$$TRACE("Title: no title generated — Meta left empty")
        }
    } Else {
        $$$TRACE("Title: Meta title already set — skipping generation")
    }

    // Persist so async callers (REST events poller) can read it.
    Do pResponse.%Save()

    // Append assistant turn to the session's context global for the
    // next turn to load. Skip on errors so we don't poison the thread.
    If (pResponse.ErrorText = "") && (lastText '= "") {
        Set asstTurn = ##class(%DynamicObject).%New()
        Do asstTurn.%Set("role", "assistant")
        Set asstContent = ##class(%DynamicArray).%New()
        Set asstBlock = ##class(%DynamicObject).%New()
        Do asstBlock.%Set("type", "text")
        Do asstBlock.%Set("text", lastText)
        Do asstContent.%Push(asstBlock)
        Do asstTurn.%Set("content", asstContent)
        Do ##class(InterClaw.Chat.Context).Append(pRequest.ChatId, asstTurn)
    }
    Return $$$OK
}

/// Return the JSON array of tool descriptors to send to Claude. If
/// `toolNames` is empty or "*" returns every registered tool; otherwise
/// filters by comma-separated names. Unknown names are silently dropped.
ClassMethod ResolveToolsJSON(toolNames As %String) As %String
{
    Set all = ##class(InterClaw.ToolKit.Registry).Descriptors()
    Set toolNames = $ZStrip(toolNames, "<>W")
    If (toolNames = "") || (toolNames = "*") Return all.%ToJSON()

    // Build a {name: 1} filter set.
    Kill want
    For i = 1:1:$Length(toolNames, ",") {
        Set n = $ZStrip($Piece(toolNames, ",", i), "<>W")
        If n '= "" Set want(n) = 1
    }

    Set out = ##class(%DynamicArray).%New()
    Set iter = all.%GetIterator()
    While iter.%GetNext(.k, .tool) {
        If $IsObject(tool), $Data(want(tool.%Get("name"))) Do out.%Push(tool)
    }
    Return out.%ToJSON()
}

/// CalculateCost
/// -------------
/// Per-turn USD cost estimate. Prices are Anthropic public list rates per
/// million tokens. Cache-read billed at 10% of input; cache-write at 125%.
/// Returns 0 for any model string that doesn't contain opus, sonnet, or
/// haiku (case-insensitive), so unknown models never pretend to be free-
/// check the model string before trusting.
/// 
/// | Model  | Input | Output | CacheRead | CacheWrite |
/// |--------|-------|--------|-----------|------------|
/// | opus   | 15.00 | 75.00  | 1.50      | 18.75      |
/// | sonnet | 3.00  | 15.00  | 0.30      | 3.75       |
/// | haiku  | 0.80  | 4.00   | 0.08      | 1.00       |
ClassMethod CalculateCost(model As %String, inputTokens As %Integer, outputTokens As %Integer, cacheReadTokens As %Integer = 0, cacheWriteTokens As %Integer = 0) As %Numeric
{
    Set m = $ZConvert(model, "L")
    If m [ "opus" {
        Set pIn = 15.00, pOut = 75.00, pCR = 1.50, pCW = 18.75
    } ElseIf m [ "sonnet" {
        Set pIn = 3.00, pOut = 15.00, pCR = 0.30, pCW = 3.75
    } ElseIf m [ "haiku" {
        Set pIn = 0.80, pOut = 4.00, pCR = 0.08, pCW = 1.00
    } Else {
        Return 0
    }
    Set cost = ((+inputTokens * pIn) + (+outputTokens * pOut) + (+cacheReadTokens * pCR) + (+cacheWriteTokens * pCW)) / 1000000
    // Round to cents (SCALE=2 on the property enforces storage scale, but
    // do it here so the live return value matches).
    Return $Number(cost, 2)
}

/// CallProvider (Python)
/// ---------------------
/// Executes HTTP request to selected provider and returns normalized JSON.
/// 
/// Output JSON shape:
/// {
///   content_json: string (JSON array of content blocks),
///   stop_reason: string,
///   input_tokens: int,
///   output_tokens: int,
///   cache_read_tokens: int,
///   cache_write_tokens: int
/// }
/// 
/// Or:
/// { error: "..." }
/// 
/// Design notes:
/// - Provider-specific differences are handled internally
/// - Output is normalized to simplify BP logic
/// - No streaming: single request/response cycle
Method CallProvider(provider As %String, model As %String, secret As %String, systemPrompt As %String, messagesJSON As %String, toolsJSON As %String, maxTokens As %Integer, effort As %String = "medium") As %String [ Language = python ]
{
    import json, urllib.request, urllib.error

    # Parse credential JSON
    try:
        cred = json.loads(str(secret)) if secret else {}
    except Exception:
        cred = {}

    prov = str(provider).lower()
    model = str(model)

    system_prompt = str(systemPrompt) if systemPrompt else ""
    messages = json.loads(str(messagesJSON)) if messagesJSON else []
    tools = json.loads(str(toolsJSON)) if toolsJSON else []

    max_tokens = int(maxTokens) if maxTokens else 4096

    # Normalize effort value
    effort_level = str(effort).lower() if effort else "medium"
    if effort_level not in ("low", "medium", "high", "max"):
        effort_level = "medium"


    # normalize()
    # -----------
    # Converts provider response into unified schema
    def normalize(resp):
        usage = resp.get("usage", {})
        return {
            "content_json": json.dumps(resp.get("content", [])),
            "stop_reason": resp.get("stop_reason", ""),
            "input_tokens": usage.get("input_tokens", 0),
            "cache_read_tokens": usage.get("cache_read_input_tokens", 0),
            "cache_write_tokens": usage.get("cache_creation_input_tokens", 0),
            "output_tokens": usage.get("output_tokens", 0),
        }


    # apply_cache_control()
    # ----------------------
    # Adds Anthropic cache hints:
    # - system prompt marked ephemeral
    # - last user message block marked ephemeral
    #
    # This allows short-lived reuse (~5 min window).
    def apply_cache_control(system_text, msgs):
        sys_blocks = None

        if system_text:
            sys_blocks = [{
                "type": "text",
                "text": system_text,
                "cache_control": {"type": "ephemeral"}
            }]

        # Deep copy messages to avoid mutating caller data
        msgs_copy = json.loads(json.dumps(msgs))

        # Tag last user message block
        for i in range(len(msgs_copy) - 1, -1, -1):
            m = msgs_copy[i]
            if m.get("role") == "user":
                content = m.get("content")
                if isinstance(content, list) and content:
                    last_block = content[-1]
                    if isinstance(last_block, dict):
                        last_block["cache_control"] = {"type": "ephemeral"}
                break

        return sys_blocks, msgs_copy


    # post()
    # -------
    # Simple HTTP POST wrapper
    def post(url, headers, payload):
        body = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(url, data=body, headers=headers, method="POST")
        with urllib.request.urlopen(req, timeout=120) as r:
            return json.loads(r.read().decode("utf-8"))


    try:
        # ---- BEDROCK (Anthropic via AWS) ----
        if prov in ("bedrock", "anthropic-bedrock"):
            region = cred.get("region", "us-east-1")
            key = cred.get("key", "")

            if not key:
                return json.dumps({"error": "Bedrock credential missing key"})

            url = f"https://bedrock-runtime.{region}.amazonaws.com/model/{model}/invoke"

            headers = {
                "Authorization": f"Bearer {key}",
                "Content-Type": "application/json",
                "Accept": "application/json",
            }

            sys_blocks, msgs_cached = apply_cache_control(system_prompt, messages)

            payload = {
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": max_tokens,
                "messages": msgs_cached,
            }

            # Enable "thinking" only for higher effort levels
            if ("opus" in model.lower() or "sonnet" in model.lower()) and effort_level in ("high", "max"):
                payload["thinking"] = {"type": "adaptive"}
                payload["output_config"] = {"effort": effort_level}

            if sys_blocks:
                payload["system"] = sys_blocks

            if tools:
                payload["tools"] = tools

            resp = post(url, headers, payload)
            return json.dumps(normalize(resp))


        # ---- DIRECT ANTHROPIC ----
        elif prov == "anthropic":
            key = cred.get("key", "")

            if not key:
                return json.dumps({"error": "Anthropic credential missing key"})

            url = "https://api.anthropic.com/v1/messages"

            headers = {
                "x-api-key": key,
                "anthropic-version": "2023-06-01",
                "Content-Type": "application/json",
            }

            sys_blocks, msgs_cached = apply_cache_control(system_prompt, messages)

            payload = {
                "model": model,
                "max_tokens": max_tokens,
                "messages": msgs_cached,
            }

            if sys_blocks:
                payload["system"] = sys_blocks

            if tools:
                payload["tools"] = tools

            resp = post(url, headers, payload)
            return json.dumps(normalize(resp))


        # ---- UNKNOWN PROVIDER ----
        else:
            return json.dumps({"error": f"Unknown provider: {prov}"})


    # ---- ERROR HANDLING ----
    except urllib.error.HTTPError as e:
        try:
            detail = e.read().decode("utf-8")
        except Exception:
            detail = ""
        return json.dumps({"error": f"HTTP {e.code}: {detail[:2000]}"})

    except Exception as e:
        return json.dumps({"error": f"{type(e).__name__}: {e}"})
}

/// Load a top-level file from `.agent/` (e.g. SOUL.md, AGENTS.md).
/// Returns "" when the file is missing so callers can concat
/// unconditionally. Resolution mirrors InterClaw.Skill.Registry.SkillsDir:
/// prefer ISC_DATA_DIRECTORY, otherwise the IRIS install directory.
ClassMethod ReadAgentFile(name As %String) As %String
{
    If name = "" Return ""
    Set iscData = $System.Util.GetEnviron("ISC_DATA_DIRECTORY")
    If iscData '= "" {
        Set path = iscData _ "/csp/interclaw/.agent/" _ name
    } Else {
        Set path = $System.Util.InstallDirectory() _ "csp/interclaw/.agent/" _ name
    }
    If '##class(%File).Exists(path) Return ""

    Set stream = ##class(%Stream.FileCharacter).%New()
    Do stream.LinkToFile(path)
    Set body = ""
    While 'stream.AtEnd {
        Set body = body _ stream.Read(32000)
    }
    Return body
}

}
