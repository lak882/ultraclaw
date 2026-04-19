/// Event listener for %Net.WebSocket.Client — stores received messages in ^InterClaw.ChatEvents global.
Class InterClaw.Bridge.EventListener Extends (%RegisteredObject, %Net.WebSocket.IEventListener)
{

/// Bridge ID used as key in ^InterClaw.ChatEvents
Property BridgeId As %String;

Method OnOpen()
{
    // Connection established — nothing to do
}

Method OnMessage(pContent As %Stream.Object)
{
    Set raw = ""
    While 'pContent.AtEnd {
        Set raw = raw _ pContent.Read(32000)
    }
    If raw = "" Quit

    // Store event in global
    Set seq = $increment(^InterClaw.ChatEvents(..BridgeId, "seq"))
    Set ^InterClaw.ChatEvents(..BridgeId, "evt", seq) = raw

    // Check if done
    Try {
        Set obj = ##class(%DynamicObject).%FromJSON(raw)
        If obj.type = "done" {
            Set ^InterClaw.ChatEvents(..BridgeId, "done") = 1
        }
    } Catch ex {
        // Not valid JSON — ignore
    }
}

Method OnClose()
{
    // Mark done if not already
    If '$get(^InterClaw.ChatEvents(..BridgeId, "done")) {
        Set ^InterClaw.ChatEvents(..BridgeId, "done") = 1
    }
}

Method OnError(pError As %Exception.AbstractException)
{
    Set seq = $increment(^InterClaw.ChatEvents(..BridgeId, "seq"))
    Set ^InterClaw.ChatEvents(..BridgeId, "evt", seq) = "{""type"":""error"",""text"":""" _ $replace(pError.DisplayString(), """", "\""") _ """}"
    Set ^InterClaw.ChatEvents(..BridgeId, "done") = 1
}

}
