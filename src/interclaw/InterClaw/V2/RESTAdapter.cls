/// Adapter REST gateway that speaks the frontend chatbot's vocabulary
/// (/api/start, /api/events, /api/approve) but routes work through the
/// Inteclaw native-IRIS agent pipeline.
/// 
/// Plan: this replaces the legacy InterClaw.Pipeline.REST.Dispatch when the
/// /api/interclaw/production web app is repointed to this class. The legacy
/// code stays installed for easy rollback.
Class InterClaw.V2.RESTAdapter Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

Parameter CHARSET = "utf-8";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/api/start"      Method="POST" Call="Start"/>
<Route Url="/api/events"     Method="GET"  Call="Events"/>
<Route Url="/api/approve"    Method="POST" Call="Approve"/>
<Route Url="/api/health"     Method="GET"  Call="Health"/>
<Route Url="/api/chats"      Method="GET"  Call="ChatsList"/>
<Route Url="/api/chats/:id"  Method="GET"  Call="ChatsGet"/>
<Route Url="/api/chats/:id"  Method="PUT"  Call="ChatsPut"/>
<Route Url="/api/chats/:id"  Method="DELETE" Call="ChatsDelete"/>
<Route Url="/api/portal-urls" Method="GET" Call="PortalUrls"/>
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
    // Force UTF-8 decoding. The frontend always sends JSON as UTF-8, but CSP
    // may hand us a stream whose TranslateTable defaults to the session
    // charset (not UTF-8), which mojibakes multibyte characters like "·"
    // into "Â·" and later double-encodes them on write.
    Set body = ""
    If $IsObject(%request.Content) {
        Set stream = %request.Content
        Try { Set stream.TranslateTable = "RAW" } Catch {}
        Do stream.Rewind()
        While 'stream.AtEnd { Set body = body _ stream.Read(32000) }
        Set body = $ZConvert(body, "I", "UTF8")
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
        Return $$$ERROR($$$GeneralError, "Inteclaw production not running in " _ $Namespace)
    } Catch ex { Return ex.AsStatus() }
}

/// POST /api/start — frontend sends {action, prompt, session_id, model,
/// namespace, effort, editor_context}. Dispatch into Inteclaw.BS.ChatService
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
    Set instance = $Get(^Inteclaw.Config("DefaultServer"), $System.INetInfo.LocalHostName())
    // Derive pathPrefix from the request URL so link URLs the model constructs
    // work regardless of how the CSP gateway is mounted.
    Set reqUrl = $Get(%request.CgiEnvs("REQUEST_URI"))
    Set pathPrefix = ""
    If reqUrl [ "/api/interclaw/production" {
        Set pathPrefix = $Piece(reqUrl, "/api/interclaw/production", 1)
    }
    Set ctxLine = "[Context: Namespace=" _ $Case(ctxNs, "":$Namespace, :ctxNs) _ "."
    If ctxModel '= "" Set ctxLine = ctxLine _ " Model=" _ ctxModel _ "."
    Set ctxLine = ctxLine _ " Instance: " _ instance _ "."
    If origin '= "" Set ctxLine = ctxLine _ " Origin: " _ origin _ "."
    If pathPrefix '= "" Set ctxLine = ctxLine _ " PathPrefix: " _ pathPrefix _ "."
    If $IsObject(editorCtx), editorCtx.%Get("activeComponent") '= "" {
        Set ctxLine = ctxLine _ " ActiveComponent: " _ editorCtx.%Get("activeComponent") _ "."
        If editorCtx.%Get("activeType") '= "" Set ctxLine = ctxLine _ " ActiveType: " _ editorCtx.%Get("activeType") _ "."
    }
    Set ctxLine = ctxLine _ "]"
    Set fullPrompt = ctxLine _ $Char(10, 10) _ prompt

    Set bridgeId = $Extract($System.Util.CreateGUID(), 1, 12)
    Set ^Inteclaw.ChatEvents(bridgeId, "seq") = 0
    Set ^Inteclaw.ChatEvents(bridgeId, "done") = 0

    Set req = ##class(Inteclaw.Msg.ChatRequest).%New()
    Set req.BridgeId = bridgeId
    Set req.SessionId = obj.%Get("session_id")
    Set req.Prompt = fullPrompt
    Set req.Model = $Case(ctxModel, "":"", :..ResolveModelAlias(ctxModel))
    Set req.Provider = "bedrock"
    Set req.PayloadJSON = body
    Set effort = obj.%Get("effort")
    If (effort = "low") || (effort = "medium") || (effort = "high") || (effort = "max") Set req.Effort = effort

    Set sc = ##class(Ens.Director).CreateBusinessService("Inteclaw.BS.ChatService", .service)
    If $$$ISERR(sc) {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""Service unavailable: " _ $Replace($System.Status.GetErrorText(sc), """", "\""") _ """}"
        Return $$$OK
    }
    Set sc = service.ProcessInput(req)
    If $$$ISERR(sc) {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""Dispatch failed: " _ $Replace($System.Status.GetErrorText(sc), """", "\""") _ """}"
        Return $$$OK
    }

    Set resp = ##class(%DynamicObject).%New()
    Do resp.%Set("bridge_id", bridgeId)
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

/// GET /api/events?bridge_id=...&after=N — long-poll for new events.
/// Same wire format as Inteclaw.REST.Dispatch.Events.
ClassMethod Events() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"

    Set bridgeId = $Get(%request.Data("bridge_id", 1), "")
    Set after = +$Get(%request.Data("after", 1), 0)
    If bridgeId = "" { Write "{""error"":""Missing bridge_id""}" Return $$$OK }
    If '$Data(^Inteclaw.ChatEvents(bridgeId, "seq")) {
        Write "{""error"":""Unknown bridge_id""}"
        Return $$$OK
    }

    Set arr = ##class(%DynamicArray).%New()
    Set start = $ZH
    // Record the last-event wallclock so we can detect a stalled stream —
    // if no new events arrive for >90s while we're polling AND the bridge
    // hasn't been marked done, we'll return with an inline error so the
    // frontend stops hanging forever.
    Set lastSeqSeen = after
    Set lastProgress = $ZH
    For {
        Set cur = +$Get(^Inteclaw.ChatEvents(bridgeId, "seq"), 0)
        If cur > lastSeqSeen {
            Set lastSeqSeen = cur
            Set lastProgress = $ZH
        }
        If cur > after {
            For seq = after+1:1:cur {
                Set raw = $Get(^Inteclaw.ChatEvents(bridgeId, "evt", seq))
                If raw '= "" {
                    Set evt = ##class(%DynamicObject).%New()
                    Do evt.%Set("seq", seq, "number")
                    Try { Do evt.%Set("data", ##class(%DynamicObject).%FromJSON(raw)) }
                    Catch ex {
                        Set fb = ##class(%DynamicObject).%New()
                        Do fb.%Set("type", "raw")
                        Do fb.%Set("text", raw)
                        Do evt.%Set("data", fb)
                    }
                    Do arr.%Push(evt)
                }
            }
            Quit
        }
        Set done = $Get(^Inteclaw.ChatEvents(bridgeId, "done"))
        If (done = 1) && (cur <= after) Quit
        // Stall detection: 90s with no new events and no done flag => mark
        // bridge as errored so the frontend can recover.
        If ($ZH - lastProgress) >= 90 {
            Set errSeq = $Increment(^Inteclaw.ChatEvents(bridgeId, "seq"))
            Set ^Inteclaw.ChatEvents(bridgeId, "evt", errSeq) = "{""type"":""error"",""text"":""Stream stalled for 90s — aborted. Check production trace for the bridge id.""}"
            Set ^Inteclaw.ChatEvents(bridgeId, "done") = 1
            Quit
        }
        If ($ZH - start) >= 30 Quit
        Hang 0.05
    }

    Set result = ##class(%DynamicObject).%New()
    Do result.%Set("events", arr)
    Do result.%Set("done", (+$Get(^Inteclaw.ChatEvents(bridgeId, "done"), 0) = 1), "boolean")
    Write result.%ToJSON()
    Return $$$OK
}

/// GET /api/chats — list chat headers (id/title/updatedAt) for the current user.
ClassMethod ChatsList() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Try {
        Set user = ##class(InterClaw.V2.ChatStore).ResolveUser()
        Set arr = ##class(InterClaw.V2.ChatStore).List(user)
        Set resp = ##class(%DynamicObject).%New()
        Do resp.%Set("user", user)
        Do resp.%Set("chats", arr)
        Write resp.%ToJSON()
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}"
    }
    Return $$$OK
}

/// GET /api/chats/:id — return a single chat with its full message history.
ClassMethod ChatsGet(id As %String) As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Try {
        Set user = ##class(InterClaw.V2.ChatStore).ResolveUser()
        Set obj = ##class(InterClaw.V2.ChatStore).Read(user, id)
        If '$IsObject(obj) {
            Set %response.Status = "404 Not Found"
            Write "{""error"":""Chat not found""}"
            Return $$$OK
        }
        Write obj.%ToJSON()
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}"
    }
    Return $$$OK
}

/// PUT /api/chats/:id — create-or-update a single chat. Body shape:
///   { "title": "...", "messages": [...], "model": "...", "namespace": "..." }
/// Any omitted field is left untouched on the existing file. The :id is
/// the frontend's local chat id (== Claude session id when available).
ClassMethod ChatsPut(id As %String) As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Try {
        Set user = ##class(InterClaw.V2.ChatStore).ResolveUser()
        Set body = ..ReadBody()
        Set input = ""
        If body '= "" {
            Try { Set input = ##class(%DynamicObject).%FromJSON(body) }
            Catch ex {
                Set %response.Status = "400 Bad Request"
                Write "{""error"":""Invalid JSON""}"
                Return $$$OK
            }
        }
        Set obj = ##class(InterClaw.V2.ChatStore).Put(user, id, input)
        If '$IsObject(obj) {
            Set %response.Status = "400 Bad Request"
            Write "{""error"":""Invalid chat id""}"
            Return $$$OK
        }
        Write obj.%ToJSON()
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}"
    }
    Return $$$OK
}

/// DELETE /api/chats/:id — remove a chat file. Returns {"deleted":true|false}.
ClassMethod ChatsDelete(id As %String) As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Try {
        Set user = ##class(InterClaw.V2.ChatStore).ResolveUser()
        Set ok = ##class(InterClaw.V2.ChatStore).Delete(user, id)
        Set resp = ##class(%DynamicObject).%New()
        Do resp.%Set("deleted", (ok = 1), "boolean")
        Write resp.%ToJSON()
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}"
    }
    Return $$$OK
}

/// GET /api/portal-urls — return the curated Management Portal catalog
/// (config/portal-urls.json) so the frontend can fuzzy-match slash-command
/// targets without bundling the file. Cached in-process per OS mtime so
/// editing the JSON file takes effect without a compile.
ClassMethod PortalUrls() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Try {
        Set root = ##class(InterClaw.Installer).DeployRoot()
        Set path = root _ "config/portal-urls.json"
        If '##class(%File).Exists(path) {
            Set %response.Status = "404 Not Found"
            Write "{""error"":""portal-urls.json not deployed""}"
            Return $$$OK
        }
        Set mtime = ##class(%File).GetFileDateModified(path)
        If $Data(^Inteclaw.PortalUrlsCache("body"))
           && ($Get(^Inteclaw.PortalUrlsCache("mtime")) = mtime) {
            Write ^Inteclaw.PortalUrlsCache("body")
            Return $$$OK
        }
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set stream.Filename = path
        Set raw = ""
        While 'stream.AtEnd { Set raw = raw _ stream.Read(32000) }
        Set ^Inteclaw.PortalUrlsCache("body") = raw
        Set ^Inteclaw.PortalUrlsCache("mtime") = mtime
        Write raw
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}"
    }
    Return $$$OK
}

/// POST /api/approve — legacy SDK permission endpoint. Not used by the
/// Inteclaw plan-mode design (plan mode is model-driven via tools), but the
/// frontend may still call it during a permission dialog. Accept-and-discard.
ClassMethod Approve() As %Status
{
    Set %response.ContentType = "application/json"
    Write "{""ok"":true,""note"":""v2 uses model-driven plan mode; /api/approve is a no-op""}"
    Return $$$OK
}

}
