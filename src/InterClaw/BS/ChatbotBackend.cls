/// InterClaw.BS.ChatbotBackend — Business Service for the Claude chatbot.
///
/// Polls a Python event queue and creates IRIS interop messages
/// for every conversation event (user prompts, Claude responses, tool calls).
///
/// The audit trail gives full message trace visibility in the IRIS Management Portal.
/// HTTP is handled by the /api/interclaw ASGI web app (IRIS web gateway), not uvicorn.
///
/// Settings:
///   AuditTarget — Business Operation to receive audit messages
Class InterClaw.BS.ChatbotBackend Extends Ens.BusinessService
{

Parameter ADAPTER = "Ens.InboundAdapter";

/// Target config name for conversation audit messages.
Property AuditTarget As %String [ InitialExpression = "InterClaw.BO.ConversationLog" ];

Parameter SETTINGS = "AuditTarget:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

/// Ensure Python path includes the deployed backend directory.
Method OnInit() As %Status
{
    set pythonDir = $system.Util.InstallDirectory() _ "csp/interclaw/python/"
    try {
        set sys = ##class(%SYS.Python).Import("sys")
        set pathList = sys.path
        set found = 0
        set len = pathList."__len__"()
        for i = 0:1:len-1 {
            if pathList."__getitem__"(i) = pythonDir set found = 1 quit
        }
        if 'found do sys.path.insert(0, pythonDir)
        $$$LOGINFO("Python path configured: " _ pythonDir)
    } catch ex {
        $$$LOGWARNING("Could not configure Python path: " _ ex.DisplayString())
    }
    return $$$OK
}

/// Poll the Python audit queue and create IRIS interop messages.
/// Called by the InboundAdapter at each CallInterval (default: 1 second).
Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status [ Language = python ]
{
    import iris
    try:
        from cc_audit import drain_events
    except ImportError:
        return 1

    events = drain_events()
    if not events:
        return 1

    target = self.AuditTarget

    for event in events:
        try:
            etype = event.get('type', '')

            if etype == 'request':
                msg = iris.cls('InterClaw.Msg.ChatRequest')._New()
                msg.Text = str(event.get('text', ''))[:32000]
                msg.SessionId = str(event.get('session_id', ''))[:200]
                msg.Namespace = str(event.get('namespace', ''))
                msg.Model = str(event.get('model', ''))
                self.SendRequestAsync(target, msg)

            elif etype == 'response':
                msg = iris.cls('InterClaw.Msg.ChatResponse')._New()
                msg.Text = str(event.get('text', ''))
                msg.SessionId = str(event.get('session_id', ''))[:200]
                msg.Success = bool(event.get('success', True))
                msg.ToolCallCount = int(event.get('tool_count', 0))
                msg.InputTokens = int(event.get('input_tokens', 0))
                msg.OutputTokens = int(event.get('output_tokens', 0))
                msg.Cost = float(event.get('cost', 0))
                msg.Duration = float(event.get('duration', 0))
                self.SendRequestAsync(target, msg)

            elif etype == 'tool_event':
                msg = iris.cls('InterClaw.Msg.ToolEvent')._New()
                msg.SessionId = str(event.get('session_id', ''))[:200]
                msg.EventType = str(event.get('event_type', ''))
                msg.ToolName = str(event.get('tool_name', ''))[:200]
                msg.Input = str(event.get('input', ''))[:32000]
                msg.Output = str(event.get('output', ''))[:32000]
                self.SendRequestAsync(target, msg)

        except Exception as e:
            pass  # Don't fail the service on individual event errors

    return 1
}

}
