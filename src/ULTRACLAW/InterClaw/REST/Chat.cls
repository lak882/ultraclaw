/// REST gateway for the chatbot sidebar. Routes into the InterClaw native-IRIS
/// agent pipeline. Mounted at /api/interclaw/production by InterClaw.Installer.
Class InterClaw.REST.Chat Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

Parameter CHARSET = "utf-8";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/api/start"      Method="POST" Call="Start"/>
<Route Url="/api/status"     Method="GET"  Call="Status"/>
<Route Url="/api/tools"      Method="GET"  Call="Tools"/>
<Route Url="/api/approve"    Method="POST" Call="Approve"/>
<Route Url="/api/health"     Method="GET"  Call="Health"/>
<Route Url="/api/chats"      Method="GET"  Call="ChatsList"/>
<Route Url="/api/chats/:id"  Method="GET"  Call="ChatsGet"/>
<Route Url="/api/chats/:id"  Method="PUT"  Call="ChatsPut"/>
<Route Url="/api/chats/:id"  Method="DELETE" Call="ChatsDelete"/>
<Route Url="/api/chats/:id/retitle" Method="POST" Call="ChatsRetitle"/>
<Route Url="/api/skills"      Method="GET"  Call="SkillsList"/>
<Route Url="/api/portal-urls" Method="GET"  Call="PortalUrls"/>
</Routes>
}

ClassMethod Health() As %Status
{
    Set %response.ContentType = "application/json"
    Write "{""status"":""ok"",""service"":""interclaw-v2"",""namespace"":""" _ $Namespace _ """}"
    Return $$$OK
}

ClassMethod ReadBody() As %String
{
    Set body = ""
    If $IsObject(%request.Content) {
        Set stream = %request.Content
        While 'stream.AtEnd { Set body = body _ stream.Read(32000) }
    }
    Return body
}

ClassMethod EnsureProduction() As %Status
{
    Try {
        Set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
        If $Get(prodState) = 1 Return $$$OK
        If $Get(prodState) = 3 Return $$$OK
        If $Get(prodState) = 4 Return $$$OK
        Return $$$ERROR($$$GeneralError, "InterClaw production not running in " _ $Namespace)
    } Catch ex { Return ex.AsStatus() }
}

/// POST /api/start — frontend sends {action, prompt, session_id, model,
/// namespace, effort, editor_context}. Dispatch into InterClaw.BS.ChatService
/// and return {bridge_id}.
ClassMethod Start() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"

    Set sc = ..EnsureProduction()
    If $$$ISERR(sc) {
        Set %response.Status = "503 Service Unavailable"
        Write "{""error"":""" _ $Replace($System.Status.GetErrorText(sc), """", "\""") _ """}"
        Return $$$OK
    }

    Set body = ..ReadBody()
    Try { Set obj = ##class(%DynamicObject).%FromJSON(body) }
    Catch ex {
        Set %response.Status = "400 Bad Request"
        Write "{""error"":""Invalid JSON""}"
        Return $$$OK
    }

    Set prompt = obj.%Get("prompt")
    If prompt = "" {
        Set %response.Status = "400 Bad Request"
        Write "{""error"":""Missing prompt""}"
        Return $$$OK
    }

    // Optionally fold editor_context + namespace + effort into a leading
    // [Context: ...] line so the model has them. Matches how InterClaw v1
    // injects context.
    Set ctxNs = obj.%Get("namespace")
    Set ctxModel = obj.%Get("model")
    Set editorCtx = obj.%Get("editor_context")
    Set origin = $Get(%request.CgiEnvs("HTTP_ORIGIN"))
    Set instance = $Get(^InterClaw.Config("DefaultServer"), $System.INetInfo.LocalHostName())
    // Derive pathPrefix from the request URL so link URLs the model constructs
    // work regardless of how the CSP gateway is mounted.
    Set reqUrl = $Get(%request.CgiEnvs("REQUEST_URI"))
    Set pathPrefix = ""
    If reqUrl [ "/api/interclaw/production" {
        Set pathPrefix = $Piece(reqUrl, "/api/interclaw/production", 1)
    }
    // Prefer a frontend-supplied link_base. Fall back to deriving from
    // Origin + pathPrefix when the frontend does not send one (e.g. legacy
    // callers). The BO appends this into the system prompt so the model
    // can build editor links at the end of responses.
    Set linkBase = $Get(obj).%Get("link_base")
    If linkBase = "" {
        If (origin '= "") && (pathPrefix '= "") {
            Set linkBase = origin _ pathPrefix _ "/ui/interop/interclaw/legacy-ui/index.html"
        }
    }

    // Namespace / Model / Instance flow through typed properties on
    // Chat.Request; no longer prepended as a [Context: ...] line on the
    // user prompt. Page/editor context still propagates via PageContext.
    Set fullPrompt = prompt

    Set req = ##class(InterClaw.Msg.Chat.Request).%New()
    // Use frontend-supplied ids. Fall back to server-generated values only when absent.
    Set chatId = obj.%Get("chat_id")
    If chatId = "" Set chatId = "CHAT-" _ $Extract($System.Util.CreateGUID(), 1, 12)
    Set requestId = obj.%Get("request_id")
    If requestId = "" Set requestId = $Extract($System.Util.CreateGUID(), 1, 24)
    Set req.ChatId = chatId
    Set req.RequestId = requestId
    Set req.Prompt = fullPrompt
    Set req.Namespace = $Case(ctxNs, "":$Namespace, :ctxNs)
    Set req.Model = $Case(ctxModel, "":"", :..ResolveModelAlias(ctxModel))
    Set req.ModelProvider = "bedrock"
    Set req.Username = obj.%Get("username")
    If req.Username = "" Set req.Username = $Username
    Set effort = obj.%Get("effort")
    If (effort = "low") || (effort = "medium") || (effort = "high") || (effort = "max") Set req.Effort = effort
    Set req.PageContext = $Extract(obj.%Get("page_context"), 1, 512)
    Set req.LinkBase = $Extract(linkBase, 1, 512)

    Set sc = ##class(InterClaw.BS.ChatService).QueueAsync(req)
    If $$$ISERR(sc) {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""Dispatch failed: " _ $Replace($System.Status.GetErrorText(sc), """", "\""") _ """}"
        Return $$$OK
    }

    Do ##class(InterClaw.Chat.Meta).SetOwner(chatId, req.Username)

    Set resp = ##class(%DynamicObject).%New()
    Do resp.%Set("request_id", requestId)
    Do resp.%Set("chat_id", chatId)
    Write resp.%ToJSON()
    Return $$$OK
}

/// Map frontend short-name models (e.g. "opus", "sonnet") to Bedrock IDs.
/// Uses the current active profiles (4.6/4.7 family); the older 4.0 Opus
/// profile was marked Legacy by AWS and returns HTTP 404 for new accounts.
ClassMethod ResolveModelAlias(alias As %String) As %String
{
    If alias = "opus" Return "us.anthropic.claude-opus-4-7"
    If alias = "sonnet" Return "us.anthropic.claude-sonnet-4-6"
    If alias = "haiku" Return "us.anthropic.claude-haiku-4-5-20251001-v1:0"
    // Pass through any full model id unchanged.
    Return alias
}

/// GET /api/status?chat_id=...&request_id=... — poll for turn completion.
/// Returns {done, response_text, input_tokens, output_tokens, cost, duration_ms, error}.
/// The frontend polls this every 2s until done=true.
ClassMethod Status() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"

    Set chatId = $Get(%request.Data("chat_id", 1), "")
    Set requestId = $Get(%request.Data("request_id", 1), "")
    If chatId = "" { Write "{""error"":""Missing chat_id""}" Return $$$OK }
    If requestId = "" { Write "{""error"":""Missing request_id""}" Return $$$OK }

    Set sql = "SELECT ResponseText, InputTokens, OutputTokens, CacheReadTokens,"
            _ " CacheWriteTokens, CostUSD, DurationMs, ErrorText"
            _ " FROM InterClaw_Msg_Chat.Response"
            _ " WHERE ChatId = ? AND RequestId = ?"
    Set rs = ##class(%SQL.Statement).%ExecDirect(, sql, chatId, requestId)
    Set result = ##class(%DynamicObject).%New()
    If rs.%Next() {
        Do result.%Set("done", 1, "boolean")
        Do result.%Set("response_text", rs.%Get("ResponseText"))
        Do result.%Set("input_tokens", +rs.%Get("InputTokens"), "number")
        Do result.%Set("output_tokens", +rs.%Get("OutputTokens"), "number")
        Do result.%Set("cache_read_tokens", +rs.%Get("CacheReadTokens"), "number")
        Do result.%Set("cache_write_tokens", +rs.%Get("CacheWriteTokens"), "number")
        Do result.%Set("cost", +rs.%Get("CostUSD"), "number")
        Do result.%Set("duration_ms", +rs.%Get("DurationMs"), "number")
        Set errText = rs.%Get("ErrorText")
        If errText '= "" Do result.%Set("error", errText)
    } Else {
        Do result.%Set("done", 0, "boolean")
    }
    Write result.%ToJSON()
    Return $$$OK
}

/// GET /api/tools?chat_id=...&request_id=... — return all tool calls for this turn.
/// The frontend polls this every 2s alongside /api/status to show live tool steps.
ClassMethod Tools() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"

    Set chatId = $Get(%request.Data("chat_id", 1), "")
    Set requestId = $Get(%request.Data("request_id", 1), "")
    If chatId = "" { Write "{""error"":""Missing chat_id""}" Return $$$OK }
    If requestId = "" { Write "{""error"":""Missing request_id""}" Return $$$OK }

    Set sql = "SELECT treq.ID AS ID, treq.ToolName, treq.ToolUseId,"
            _ " treq.InputJSON, tresp.OutputText, tresp.IsError"
            _ " FROM InterClaw_Msg_Tool.Request treq"
            _ " LEFT JOIN InterClaw_Msg_Tool.Response tresp ON tresp.ToolUseId = treq.ToolUseId"
            _ " WHERE treq.ChatId = ? AND treq.RequestId = ? ORDER BY treq.ID ASC"
    Set rs = ##class(%SQL.Statement).%ExecDirect(, sql, chatId, requestId)
    Set arr = ##class(%DynamicArray).%New()
    While rs.%Next() {
        Set tool = ##class(%DynamicObject).%New()
        Do tool.%Set("id", +rs.%Get("ID"), "number")
        Do tool.%Set("name", rs.%Get("ToolName"))
        Do tool.%Set("tool_use_id", rs.%Get("ToolUseId"))
        Do tool.%Set("input", rs.%Get("InputJSON"))
        // OutputText and IsError are null until the response row is written.
        Set outText = rs.%Get("OutputText")
        If outText '= "" {
            Do tool.%Set("output", outText)
            Do tool.%Set("done", 1, "boolean")
            Do tool.%Set("is_error", ''rs.%Get("IsError"), "boolean")
        } Else {
            Do tool.%Set("done", 0, "boolean")
        }
        Do arr.%Push(tool)
    }
    Set result = ##class(%DynamicObject).%New()
    Do result.%Set("tools", arr)
    Write result.%ToJSON()
    Return $$$OK
}

/// GET /api/chats — list all chat sessions sourced from InterClaw_Msg_Chat.Response,
/// with titles from ^InterClaw.Chat.Meta. Sorted newest-first by Response ID.
ClassMethod ChatsList() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Try {
        // One row per ChatId sourced from Request (exists the moment /api/start
        // fires) so chats appear immediately, before a response is stored.
        Set sql = "SELECT ChatId, MAX(ID) AS LastId FROM InterClaw_Msg_Chat.Request"
                _ " WHERE ChatId IS NOT NULL AND ChatId <> ''"
                _ " GROUP BY ChatId ORDER BY LastId DESC"
        Set rs = ##class(%SQL.Statement).%ExecDirect(, sql)
        Set arr = ##class(%DynamicArray).%New()
        While rs.%Next() {
            Set chatId = $ZConvert(rs.%Get("ChatId"), "L")
            If ##class(InterClaw.Chat.Meta).IsDeleted(chatId) Continue
            Set title = ##class(InterClaw.Chat.Meta).GetTitle(chatId)
            If title = "" Set title = "Untitled"
            Set lastId = rs.%Get("LastId")
            Set row = ##class(%DynamicObject).%New()
            Do row.%Set("id", chatId)
            Do row.%Set("title", title)
            Do row.%Set("updatedAt", lastId, "number")
            Do arr.%Push(row)
        }
        Set resp = ##class(%DynamicObject).%New()
        Do resp.%Set("user", "")
        Do resp.%Set("chats", arr)
        Write resp.%ToJSON()
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}"
    }
    Return $$$OK
}

/// GET /api/chats/:id — reconstruct conversation from InterClaw_Msg_Chat.Request
/// and InterClaw_Msg_Chat.Response, returning [{type,text}] pairs ordered by turn.
ClassMethod ChatsGet(id As %String) As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Try {
        // Verify the chat exists and isn't deleted.
        If ##class(InterClaw.Chat.Meta).IsDeleted(id) {
            Set %response.Status = "404 Not Found"
            Write "{""error"":""Chat not found""}"
            Return $$$OK
        }
        // Join Request + Response on RequestId, ordered by Response.ID.
        // Include token counts and cost so the client can show per-turn usage.
        Set sql = "SELECT resp.RequestId AS RequestId, req.Prompt AS Prompt, resp.ResponseText AS ResponseText,"
                _ " resp.InputTokens AS InputTokens, resp.OutputTokens AS OutputTokens,"
                _ " resp.CacheReadTokens AS CacheReadTokens, resp.CacheWriteTokens AS CacheWriteTokens,"
                _ " resp.CostUSD AS CostUSD, resp.DurationMs AS DurationMs"
                _ " FROM InterClaw_Msg_Chat.Response resp"
                _ " LEFT JOIN InterClaw_Msg_Chat.Request req ON req.RequestId = resp.RequestId"
                _ " WHERE resp.ChatId = ? ORDER BY resp.ID ASC"
        Set rs = ##class(%SQL.Statement).%ExecDirect(, sql, id)
        // Pre-load tool calls for this chat, keyed by RequestId.
        // Each RequestId maps to an ordered array of {name, input, output, isError}.
        Set toolSql = "SELECT treq.RequestId, treq.ToolName, treq.InputJSON,"
                    _ " tresp.OutputText, tresp.IsError"
                    _ " FROM InterClaw_Msg_Tool.Request treq"
                    _ " LEFT JOIN InterClaw_Msg_Tool.Response tresp ON tresp.ToolUseId = treq.ToolUseId"
                    _ " WHERE treq.ChatId = ? ORDER BY treq.ID ASC"
        Set trs = ##class(%SQL.Statement).%ExecDirect(, toolSql, id)
        Kill toolsByRequest
        While trs.%Next() {
            Set reqId = trs.%Get("RequestId")
            If reqId = "" Continue
            Set tool = ##class(%DynamicObject).%New()
            Do tool.%Set("name", trs.%Get("ToolName"))
            Do tool.%Set("input", trs.%Get("InputJSON"))
            Do tool.%Set("output", trs.%Get("OutputText"))
            Do tool.%Set("isError", ''trs.%Get("IsError"), "boolean")
            If '$Data(toolsByRequest(reqId)) Set toolsByRequest(reqId) = ##class(%DynamicArray).%New()
            Do toolsByRequest(reqId).%Push(tool)
        }
        Set messages = ##class(%DynamicArray).%New()
        While rs.%Next() {
            Set prompt = rs.%Get("Prompt")
            Set responseText = rs.%Get("ResponseText")
            Set reqId = rs.%Get("RequestId")
            // Strip leading [Context: ...] lines from the stored prompt.
            Set displayPrompt = prompt
            While $Extract(displayPrompt, 1, 9) = "[Context:" {
                Set nlPos = $Find(displayPrompt, $Char(10))
                If nlPos = 0 { Set displayPrompt = "" Quit }
                Set displayPrompt = $ZStrip($Extract(displayPrompt, nlPos, *), "<W")
            }
            If displayPrompt '= "" {
                Set userMsg = ##class(%DynamicObject).%New()
                Do userMsg.%Set("type", "user")
                Do userMsg.%Set("text", displayPrompt)
                Do messages.%Push(userMsg)
            }
            Set hasTurnTools = $Data(toolsByRequest(reqId))
            If (responseText '= "") || hasTurnTools {
                Set asstMsg = ##class(%DynamicObject).%New()
                Do asstMsg.%Set("type", "assistant")
                Do asstMsg.%Set("text", responseText)
                // Attach tool calls for this turn.
                If hasTurnTools {
                    Do asstMsg.%Set("tools", toolsByRequest(reqId))
                }
                // Attach per-turn usage so the client can render the cost footer.
                Set inTok = +rs.%Get("InputTokens")
                Set outTok = +rs.%Get("OutputTokens")
                Set cacheR = +rs.%Get("CacheReadTokens")
                Set cacheW = +rs.%Get("CacheWriteTokens")
                Set costUsd = +rs.%Get("CostUSD")
                Set durMs = +rs.%Get("DurationMs")
                If (inTok > 0) || (outTok > 0) || (costUsd > 0) {
                    Set usage = ##class(%DynamicObject).%New()
                    Do usage.%Set("input_tokens", inTok, "number")
                    Do usage.%Set("output_tokens", outTok, "number")
                    Do usage.%Set("cache_read_tokens", cacheR, "number")
                    Do usage.%Set("cache_write_tokens", cacheW, "number")
                    Do usage.%Set("cost", costUsd, "number")
                    Do usage.%Set("duration_ms", durMs, "number")
                    Do asstMsg.%Set("usage", usage)
                }
                Do messages.%Push(asstMsg)
            }
        }
        Set obj = ##class(%DynamicObject).%New()
        Do obj.%Set("id", id)
        Do obj.%Set("title", ##class(InterClaw.Chat.Meta).GetTitle(id))
        Do obj.%Set("messages", messages)
        Write obj.%ToJSON()
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}"
    }
    Return $$$OK
}

/// PUT /api/chats/:id — only used for title updates (titleLocked renames).
/// Message history is owned by the Ensemble message store, not pushed by the frontend.
ClassMethod ChatsPut(id As %String) As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Try {
        Set body = ..ReadBody()
        If body '= "" {
            Try {
                Set input = ##class(%DynamicObject).%FromJSON(body)
                Set title = input.%Get("title")
                If title '= "" {
                    Do ##class(InterClaw.Chat.Meta).UpdateTitle(id, title)
                    If input.%IsDefined("titleLocked") {
                        Set ^InterClaw.Chat.Meta(id, "titleLocked") = ''input.%Get("titleLocked")
                    }
                }
            } Catch {}
        }
        Set resp = ##class(%DynamicObject).%New()
        Do resp.%Set("id", id)
        Do resp.%Set("title", ##class(InterClaw.Chat.Meta).GetTitle(id))
        Write resp.%ToJSON()
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}"
    }
    Return $$$OK
}

/// DELETE /api/chats/:id — soft-delete via ^InterClaw.Chat.Meta.
ClassMethod ChatsDelete(id As %String) As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Try {
        Do ##class(InterClaw.Chat.Meta).MarkDeleted(id)
        Set resp = ##class(%DynamicObject).%New()
        Do resp.%Set("deleted", 1, "boolean")
        Write resp.%ToJSON()
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}"
    }
    Return $$$OK
}

/// POST /api/chats/:id/retitle — regenerate title from stored turns via Haiku.
/// Updates ^InterClaw.Chat.Meta. Returns {"title":"..."}.
ClassMethod ChatsRetitle(id As %String) As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Try {
        If $Get(^InterClaw.Chat.Meta(id, "titleLocked")) {
            Set resp = ##class(%DynamicObject).%New()
            Do resp.%Set("title", ##class(InterClaw.Chat.Meta).GetTitle(id))
            Write resp.%ToJSON()
            Return $$$OK
        }
        Set title = ##class(InterClaw.Chat.Meta).RetitleFromStore(id)
        Set resp = ##class(%DynamicObject).%New()
        Do resp.%Set("title", $Case(title, "":##class(InterClaw.Chat.Meta).GetTitle(id), :title))
        Write resp.%ToJSON()
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}"
    }
    Return $$$OK
}

/// POST /api/approve — legacy SDK permission endpoint. Not used by the
/// InterClaw plan-mode design (plan mode is model-driven via tools), but the
/// frontend may still call it during a permission dialog. Accept-and-discard.
ClassMethod Approve() As %Status
{
    Set %response.ContentType = "application/json"
    Write "{""ok"":true,""note"":""v2 uses model-driven plan mode; /api/approve is a no-op""}"
    Return $$$OK
}

/// Resolve project root (CWD) the same way InterClaw.REST.Dispatch does, so
/// both control-plane and chat endpoints read the same config/ directory.
ClassMethod GetCWD() As %String
{
    Set val = $Get(^InterClaw.Config("CWD"))
    If val '= "" Return val
    Return ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(##class(%File).SubDirectoryName($System.Util.InstallDirectory(), "csp"), "interclaw"))
}

/// GET /api/skills — list available skills from .agent/skills/ for the frontend slash menu.
/// Returns {skills: [{name, description}]} sorted by name.
ClassMethod SkillsList() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Try {
        Set skills = ##class(InterClaw.Skill.Registry).List()
        Set arr = ##class(%DynamicArray).%New()
        Set iter = skills.%GetIterator()
        While iter.%GetNext(.k, .s) {
            Set row = ##class(%DynamicObject).%New()
            Do row.%Set("name", s.%Get("name"))
            Do row.%Set("description", s.%Get("description"))
            Do arr.%Push(row)
        }
        Set resp = ##class(%DynamicObject).%New()
        Do resp.%Set("skills", arr)
        Write resp.%ToJSON()
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}"
    }
    Return $$$OK
}

/// GET /api/portal-urls — serve the curated Management Portal URL catalog
/// consumed by the chatbot's /goto fuzzy-match fallback (see goto.js).
/// The JSON is stored in config/portal-urls.json at the project root and
/// is shipped as a static asset; reading it here keeps the catalog in one
/// authoritative place instead of duplicating it inside the class.
ClassMethod PortalUrls() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Set json = ..ReadPortalUrlsPy(..GetCWD())
    If json = "" {
        Set %response.Status = "404 Not Found"
        Write "{""error"":""portal-urls.json not found"",""entries"":[]}"
        Return $$$OK
    }
    Write json
    Return $$$OK
}

ClassMethod ReadPortalUrlsPy(cwd As %String) As %String [ Language = python ]
{
    import os
    try:
        with open(os.path.join(cwd, "config", "portal-urls.json"), "r", encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        return ""
    except Exception:
        return ""
}

}
