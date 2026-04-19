/// REST dispatch for the production-based chat pipeline.
/// POST /api/start — create bridge, send ChatRequest to production
/// GET  /api/events — poll ^InterClaw.ChatEvents global for streaming events
/// GET  /api/health — health check
Class InterClaw.Pipeline.REST.Dispatch Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

Parameter CHARSET = "utf-8";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/api/health"  Method="GET"  Call="Health"/>
<Route Url="/api/start"   Method="POST" Call="Start"/>
<Route Url="/api/events"  Method="GET"  Call="Events"/>
<Route Url="/api/approve" Method="POST" Call="Approve"/>
</Routes>
}

ClassMethod Health() As %Status
{
    Set %response.ContentType = "application/json"
    Write "{""status"":""ok"",""service"":""interclaw-pipeline""}"
    Return $$$OK
}

/// Check that a production is running. Called before each chat request.
ClassMethod EnsureProduction() As %Status
{
    try {
        set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
        // States: 1=Running, 3=Suspended, 4=Troubled — all have an active production
        if $get(prodState) >= 1 && ($get(prodState) '= 2) {
            return $$$OK
        }
        return $$$ERROR($$$GeneralError, "No production is running. Start it from the Management Portal or run: manage_production.py --start InterClaw.Pipeline.Production")
    } catch ex {
        return ex.AsStatus()
    }
}

ClassMethod ReadBody() As %String
{
    Set body = ""
    If $IsObject(%request.Content) {
        Set stream = %request.Content
        While 'stream.AtEnd {
            Set body = body _ stream.Read(32000)
        }
    }
    Return body
}

/// POST /api/start — parse chat request, init global, send to production.
ClassMethod Start() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"

    // Ensure production is running before processing chat
    Set sc = ..EnsureProduction()
    If $$$ISERR(sc) {
        Set %response.Status = "503 Service Unavailable"
        Write "{""error"":""Could not start production: " _ $replace($system.Status.GetOneStatusText(sc), """", "\""") _ """}"
        Return $$$OK
    }

    Set body = ..ReadBody()
    Try {
        Set obj = ##class(%DynamicObject).%FromJSON(body)
    } Catch ex {
        Set %response.Status = "400 Bad Request"
        Write "{""error"":""Invalid JSON""}"
        Return $$$OK
    }

    Set prompt = obj.%Get("prompt")
    Set sessionId = obj.%Get("session_id")
    Set model = obj.%Get("model")
    Set namespace = obj.%Get("namespace")
    If namespace = "" Set namespace = "INTERCLAW"
    Set action = obj.%Get("action")
    If action = "" Set action = $select(sessionId = "":"init", 1:"message")

    // Create bridge
    Set bridgeId = $extract($system.Util.CreateGUID(), 1, 12)
    Set ^InterClaw.ChatEvents(bridgeId, "seq") = 0
    Set ^InterClaw.ChatEvents(bridgeId, "done") = 0

    // Build payload JSON for the BO
    Set payload = ##class(%DynamicObject).%New()
    Do payload.%Set("action", action)
    Do payload.%Set("prompt", prompt)
    If model '= "" Do payload.%Set("model", model)
    Do payload.%Set("namespace", namespace)
    If sessionId '= "" Do payload.%Set("session_id", sessionId)
    Do payload.%Set("bridge_id", bridgeId)
    Set permissionMode = obj.%Get("permission_mode")
    If permissionMode '= "" Do payload.%Set("permission_mode", permissionMode)
    Set effort = obj.%Get("effort")
    If effort '= "" Do payload.%Set("effort", effort)
    Set editorCtx = obj.%Get("editor_context")
    If editorCtx '= "" Do payload.%Set("editor_context", editorCtx)

    // Create request message
    Set request = ##class(InterClaw.Pipeline.Msg.ChatRequest).%New()
    Set request.BridgeId = bridgeId
    Set request.PayloadJSON = payload.%ToJSON()
    Set request.Prompt = prompt
    Set request.SessionId = sessionId
    Set request.Model = model
    Set request.Namespace = namespace
    Set request.Action = action
    Set request.PermissionMode = permissionMode
    Set operationTarget = obj.%Get("operation_target")
    If operationTarget '= "" Set request.OperationTarget = operationTarget

    // Send to production via business service
    Set sc = ##class(Ens.Director).CreateBusinessService("InterClaw.Pipeline.BS.ChatService", .service)
    If $$$ISERR(sc) {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""Production not available: " _ $replace($system.Status.GetOneStatusText(sc), """", "\""") _ """}"
        Return $$$OK
    }

    Set sc = service.ProcessInput(request)
    If $$$ISERR(sc) {
        Set %response.Status = "500 Internal Server Error"
        Write "{""error"":""Failed to send request: " _ $replace($system.Status.GetOneStatusText(sc), """", "\""") _ """}"
        Return $$$OK
    }

    Write "{""bridge_id"":""" _ bridgeId _ """}"
    Return $$$OK
}

/// GET /api/events?bridge_id=X&after=N — server-hold polling for events.
ClassMethod Events() As %Status
{
    Set bridgeId = $get(%request.Data("bridge_id", 1), "")
    Set after = +$get(%request.Data("after", 1), 0)
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"

    If bridgeId = "" {
        Write "{""error"":""Missing bridge_id""}"
        Return $$$OK
    }
    If '$data(^InterClaw.ChatEvents(bridgeId, "seq")) {
        Write "{""error"":""Unknown bridge_id""}"
        Return $$$OK
    }

    Set events = ##class(%DynamicArray).%New()
    Set start = $zh
    For {
        Set currentSeq = +$get(^InterClaw.ChatEvents(bridgeId, "seq"), 0)
        If currentSeq > after {
            For seq = after+1:1:currentSeq {
                Set raw = $get(^InterClaw.ChatEvents(bridgeId, "evt", seq))
                If raw '= "" {
                    Set evt = ##class(%DynamicObject).%New()
                    Do evt.%Set("seq", seq, "number")
                    Try {
                        Set data = ##class(%DynamicObject).%FromJSON(raw)
                        Do evt.%Set("data", data)
                    } Catch ex {
                        Set fallback = ##class(%DynamicObject).%New()
                        Do fallback.%Set("type", "raw")
                        Do fallback.%Set("text", raw)
                        Do evt.%Set("data", fallback)
                    }
                    Do events.%Push(evt)
                }
            }
            Quit
        }
        Set done = $get(^InterClaw.ChatEvents(bridgeId, "done"))
        If (done = 1) && (currentSeq <= after) Quit
        If ($zh - start) >= 30 Quit
        Hang 0.05
    }

    Set doneFlag = +$get(^InterClaw.ChatEvents(bridgeId, "done"), 0)
    Set result = ##class(%DynamicObject).%New()
    Do result.%Set("events", events)
    Do result.%Set("done", (doneFlag = 1), "boolean")
    Write result.%ToJSON()
    Return $$$OK
}

/// POST /api/approve — respond to a canUseTool permission request.
/// Writes to ^InterClaw.ChatPending(bridgeId) which ClaudeOperation polls.
ClassMethod Approve() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"

    Set body = ..ReadBody()
    Try {
        Set obj = ##class(%DynamicObject).%FromJSON(body)
    } Catch ex {
        Set %response.Status = "400 Bad Request"
        Write "{""error"":""Invalid JSON""}"
        Return $$$OK
    }

    Set bridgeId = obj.%Get("bridge_id")
    If bridgeId = "" {
        Set %response.Status = "400 Bad Request"
        Write "{""error"":""Missing bridge_id""}"
        Return $$$OK
    }

    // Write response to the pending global for ClaudeOperation's canUseTool to read
    Set ^InterClaw.ChatPending(bridgeId, "response") = obj.%ToJSON()

    Write "{""status"":""ok""}"
    Return $$$OK
}

}
