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
    If namespace = "" Set namespace = "CLAUDE"
    Set action = obj.%Get("action")
    If action = "" Set action = $select(sessionId = "":"init", 1:"message")

    // Create bridge
    Set bridgeId = $extract($system.Util.CreateGUID(), 1, 12)
    Set ^InterClaw.ChatEvents(bridgeId, "seq") = 0
    Set ^InterClaw.ChatEvents(bridgeId, "done") = 0

    // Build payload JSON for the WebSocket
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
    Set result = ..EventsPy(bridgeId, after)
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Write result
    Return $$$OK
}

/// POST /api/approve — respond to a canUseTool permission request.
/// Writes to ^InterClaw.ChatPending(bridgeId) which WS.Chat polls.
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

    // Write response to the pending global for WS.Chat's canUseTool to read
    Set ^InterClaw.ChatPending(bridgeId, "response") = obj.%ToJSON()

    Write "{""status"":""ok""}"
    Return $$$OK
}

ClassMethod EventsPy(bridgeId As %String, after As %Integer) As %String [ Language = python ]
{
    import json, time, iris

    if not bridgeId:
        return json.dumps({"error": "Missing bridge_id"})

    g = iris.gref("^InterClaw.ChatEvents")

    if g[bridgeId, "seq"] is None:
        return json.dumps({"error": "Unknown bridge_id"})

    events = []
    deadline = time.time() + 30

    while time.time() < deadline:
        current_seq = int(g[bridgeId, "seq"])

        if current_seq > after:
            for seq in range(after + 1, current_seq + 1):
                raw = g[bridgeId, "evt", seq]
                if raw is not None:
                    try:
                        events.append({"seq": seq, "data": json.loads(str(raw))})
                    except Exception:
                        events.append({"seq": seq, "data": {"type": "raw", "text": str(raw)}})
            break

        done = g[bridgeId, "done"]
        if done is not None and int(done) == 1 and current_seq <= after:
            break

        time.sleep(0.05)

    done_flag = g[bridgeId, "done"]
    is_done = done_flag is not None and int(done_flag) == 1

    return json.dumps({"events": events, "done": is_done})
}

}
