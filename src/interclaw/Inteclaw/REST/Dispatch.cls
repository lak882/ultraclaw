/// REST gateway. Mirrors OpenClaw's control-plane surface:
///   POST /chat     — start an agent run, returns bridge_id
///   GET  /events   — long-poll chat events for a bridge_id
///   GET  /tools    — list discovered tools
///   GET  /health   — ok
Class Inteclaw.REST.Dispatch Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

Parameter CHARSET = "utf-8";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/health" Method="GET"  Call="Health"/>
<Route Url="/tools"  Method="GET"  Call="Tools"/>
<Route Url="/chat"   Method="POST" Call="Chat"/>
<Route Url="/events" Method="GET"  Call="Events"/>
</Routes>
}

ClassMethod Health() As %Status
{
    Set %response.ContentType = "application/json"
    Write "{""status"":""ok"",""service"":""inteclaw-gateway"",""namespace"":""" _ $Namespace _ """}"
    Return $$$OK
}

ClassMethod Tools() As %Status
{
    Set %response.ContentType = "application/json"
    Write ##class(Inteclaw.Tools.Registry).DescriptorsJSON()
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

ClassMethod EnsureProduction() As %Status
{
    Try {
        Set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
        If $Get(prodState) = 1 Return $$$OK
        If $Get(prodState) = 3 Return $$$OK
        If $Get(prodState) = 4 Return $$$OK
        Return $$$ERROR($$$GeneralError, "No production running in " _ $Namespace)
    } Catch ex {
        Return ex.AsStatus()
    }
}

ClassMethod Chat() As %Status
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
    Try {
        Set obj = ##class(%DynamicObject).%FromJSON(body)
    } Catch ex {
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

    Set bridgeId = $Extract($System.Util.CreateGUID(), 1, 12)
    Set ^Inteclaw.ChatEvents(bridgeId, "seq") = 0
    Set ^Inteclaw.ChatEvents(bridgeId, "done") = 0

    Set req = ##class(Inteclaw.Msg.ChatRequest).%New()
    Set req.BridgeId = bridgeId
    Set req.SessionId = obj.%Get("session_id")
    Set req.Prompt = prompt
    Set req.Model = obj.%Get("model")
    Set req.Provider = obj.%Get("provider")
    Set req.SystemPrompt = obj.%Get("system")
    Set mt = +obj.%Get("max_turns")
    If mt > 0 Set req.MaxTurns = mt
    Set req.PayloadJSON = body

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

/// Long-poll events. Waits up to ~30s for new events after `after`.
ClassMethod Events() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"

    Set bridgeId = $Get(%request.Data("bridge_id", 1), "")
    Set after = +$Get(%request.Data("after", 1), 0)
    If bridgeId = "" {
        Write "{""error"":""Missing bridge_id""}"
        Return $$$OK
    }
    If '$Data(^Inteclaw.ChatEvents(bridgeId, "seq")) {
        Write "{""error"":""Unknown bridge_id""}"
        Return $$$OK
    }

    Set arr = ##class(%DynamicArray).%New()
    Set start = $ZH
    For {
        Set cur = +$Get(^Inteclaw.ChatEvents(bridgeId, "seq"), 0)
        If cur > after {
            For seq = after+1:1:cur {
                Set raw = $Get(^Inteclaw.ChatEvents(bridgeId, "evt", seq))
                If raw '= "" {
                    Set evt = ##class(%DynamicObject).%New()
                    Do evt.%Set("seq", seq, "number")
                    Try {
                        Do evt.%Set("data", ##class(%DynamicObject).%FromJSON(raw))
                    } Catch ex {
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
        If ($ZH - start) >= 30 Quit
        Hang 0.05
    }

    Set result = ##class(%DynamicObject).%New()
    Do result.%Set("events", arr)
    Do result.%Set("done", (+$Get(^Inteclaw.ChatEvents(bridgeId, "done"), 0) = 1), "boolean")
    Write result.%ToJSON()
    Return $$$OK
}

}
