/// Generic WebSocket operation — connects to InterClaw.WS.Chat, reads frames,
/// fires each event to the EventWriter process via SendRequestAsync,
/// and returns a summary ChatResponse when done.
Class InterClaw.Pipeline.BO.WebSocketOperation Extends Ens.BusinessOperation
{

Property WebSocketURL As %String [ InitialExpression = "ws://localhost/irishealth/api/ws/InterClaw.WS.Chat.cls" ];

Property EventWriterTarget As %String [ InitialExpression = "InterClaw.Pipeline.BP.EventWriter" ];

Property ConnectionTimeout As %Integer [ InitialExpression = 10 ];

Property ReadTimeout As %Integer [ InitialExpression = 300 ];

Parameter SETTINGS = "WebSocketURL:Basic,EventWriterTarget:Basic,ConnectionTimeout:Basic,ReadTimeout:Basic";

Parameter INVOCATION = "Queue";

Method OnMessage(pRequest As InterClaw.Pipeline.Msg.ChatRequest, Output pResponse As InterClaw.Pipeline.Msg.ChatResponse) As %Status
{
    Set bridgeId = pRequest.BridgeId
    Set pResponse = ##class(InterClaw.Pipeline.Msg.ChatResponse).%New()
    Set pResponse.BridgeId = bridgeId
    Set pResponse.Status = "completed"

    Set sessionId = ""
    Set cost = 0
    Set inputTokens = 0
    Set outputTokens = 0
    Set eventCount = 0
    Set isFinal = 0

    Try {
        // Create buffer to receive WS frames
        Set buffer = ##class(InterClaw.Pipeline.Bridge.EventBuffer).%New()

        // Connect to WebSocket
        Set ws = ##class(%Net.WebSocket.Client).%New(..WebSocketURL, , buffer)

        // Wait for initial "connected" message
        Set open = ws.Next(..ConnectionTimeout, .timedOut)
        If 'open || timedOut {
            Do ..SendEvent(bridgeId, "{""type"":""error"",""text"":""WebSocket connection failed""}", "error", 1)
            Set pResponse.Status = "error"
            Return $$$OK
        }

        // Forward the "connected" event
        If buffer.LastContent '= "" {
            Do ..SendEvent(bridgeId, buffer.LastContent, "connected", 0)
            Set eventCount = eventCount + 1
        }

        // Send the prompt payload
        Set sc = ws.Send(pRequest.PayloadJSON)
        If $$$ISERR(sc) {
            Do ..SendEvent(bridgeId, "{""type"":""error"",""text"":""Send failed: " _ $system.Status.GetOneStatusText(sc) _ """}", "error", 1)
            Set pResponse.Status = "error"
            Return $$$OK
        }

        // Read events until done or connection closes
        While ws.Next(..ReadTimeout, .timedOut) {
            If timedOut {
                Do ..SendEvent(bridgeId, "{""type"":""error"",""text"":""Timeout waiting for response""}", "error", 1)
                Set pResponse.Status = "timeout"
                Quit
            }

            Set raw = buffer.LastContent
            If raw = "" Continue

            // Parse event to extract metadata
            Set eventType = "raw"
            Try {
                Set obj = ##class(%DynamicObject).%FromJSON(raw)
                Set eventType = obj.type
                If eventType = "done" {
                    Set isFinal = 1
                    Set sessionId = obj.%Get("session_id")
                }
                If eventType = "usage" {
                    If obj.cost '= "" Set cost = obj.cost
                    If obj.%Get("input_tokens") '= "" Set inputTokens = obj.%Get("input_tokens")
                    If obj.%Get("output_tokens") '= "" Set outputTokens = obj.%Get("output_tokens")
                }
            } Catch ex {
                // Not valid JSON — send as raw
            }

            // Fire event to EventWriter
            Do ..SendEvent(bridgeId, raw, eventType, isFinal)
            Set eventCount = eventCount + 1

            If isFinal Quit
        }

        // If connection closed without done event
        If buffer.IsClosed && 'isFinal {
            Do ..SendEvent(bridgeId, "{""type"":""done"",""session_id"":""""}", "done", 1)
            Set eventCount = eventCount + 1
        }

    } Catch ex {
        Do ..SendEvent(bridgeId, "{""type"":""error"",""text"":""" _ $replace(ex.DisplayString(), """", "\""") _ """}", "error", 1)
        Set pResponse.Status = "error"
    }

    Set pResponse.SessionId = sessionId
    Set pResponse.Cost = cost
    Set pResponse.InputTokens = inputTokens
    Set pResponse.OutputTokens = outputTokens
    Set pResponse.EventCount = eventCount

    Return $$$OK
}

/// Send a ChatEvent to the EventWriter process asynchronously.
Method SendEvent(bridgeId As %String, eventJSON As %String, eventType As %String, isFinal As %Boolean) As %Status
{
    Set evt = ##class(InterClaw.Pipeline.Msg.ChatEvent).%New()
    Set evt.BridgeId = bridgeId
    Set evt.EventJSON = eventJSON
    Set evt.EventType = eventType
    Set evt.IsFinal = isFinal
    // Extract text from JSON if present
    Try { Set evt.Text = ##class(%DynamicObject).%FromJSON(eventJSON).text } Catch {}
    Return ..SendRequestAsync(..EventWriterTarget, evt)
}

}
