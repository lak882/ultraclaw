/// InterClaw.BS.ScriptAudit — Business Service that polls the Python script audit queue.
///
/// Reads events from /tmp/interclaw/audit_queue.jsonl (written by Python scripts
/// via audit.log_event()) and creates InterClaw.Msg.AuditEvent messages.
/// Each message flows through the production and appears in the visual trace.
///
/// Settings:
///   AuditTarget — Business Operation to receive audit messages (default: InterClaw.BO.AuditLog)
Class InterClaw.BS.ScriptAudit Extends Ens.BusinessService
{

Parameter ADAPTER = "Ens.InboundAdapter";

/// Target config name for audit messages.
Property AuditTarget As %String [ InitialExpression = "InterClaw.BO.AuditLog" ];

Parameter SETTINGS = "AuditTarget:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

/// Poll the audit queue file and create IRIS interop messages.
/// Called by the InboundAdapter at each CallInterval.
Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
    // Read events from Python queue file
    set eventList = ..DrainQueue()
    if (eventList = "") || ('$isobject(eventList)) {
        return $$$OK
    }

    set target = ..AuditTarget
    set count = eventList.%Size()
    if count = 0 return $$$OK

    for i = 0:1:count-1 {
        try {
            set event = eventList.%Get(i)
            if '$isobject(event) continue

            set msg = ##class(InterClaw.Msg.AuditEvent).%New()
            set etype = event.%Get("type")
            set msg.EventType = etype

            if etype = "api_call" {
                set msg.Action = event.%Get("method")
                set url = $extract(event.%Get("url"), 1, 2000)
                set msg.Target = url
                set msg.StatusCode = +event.%Get("status")
                set msg.Duration = +event.%Get("duration_ms")
                // Shorten URL for summary
                set urlShort = url
                if url [ "/api/" set urlShort = "/api/" _ $piece(url, "/api/", 2)
                set msg.Summary = event.%Get("method") _ " " _ urlShort _ " -> " _ event.%Get("status") _ " (" _ $fnumber(event.%Get("duration_ms"),"",0) _ "ms)"
            } elseif etype = "terminal" {
                set msg.Action = "exec"
                set msg.Target = event.%Get("namespace")
                set msg.Duration = +event.%Get("duration_ms")
                set msg.Summary = "Terminal [" _ event.%Get("namespace") _ "]: " _ $extract(event.%Get("code"), 1, 200)
                set msg.Detail = $extract(event.%Get("output"), 1, 32000)
            } elseif etype = "file_change" {
                set msg.Action = event.%Get("action")
                set msg.ClassName = event.%Get("class_name")
                set added = +event.%Get("lines_added")
                set removed = +event.%Get("lines_removed")
                if event.%Get("is_new") {
                    set msg.Summary = "Created " _ event.%Get("class_name") _ " (" _ added _ " lines)"
                } else {
                    set msg.Summary = "Updated " _ event.%Get("class_name") _ " (+" _ added _ " -" _ removed _ ")"
                }
                set msg.Detail = $extract(event.%Get("summary"), 1, 32000)
            } else {
                set msg.Action = etype
                set msg.Summary = $extract(event.%Get("summary"), 1, 200)
            }

            set msg.Server = event.%Get("server")
            set msg.Namespace = event.%Get("namespace")
            set msg.OriginalTimestamp = event.%Get("ts")

            do ..SendRequestAsync(target, msg)
        } catch ex {
            $$$LOGWARNING("Failed to process audit event: " _ ex.DisplayString())
        }
    }

    $$$LOGINFO("Processed " _ count _ " audit events")
    return $$$OK
}

/// Read and clear the Python audit queue file. Returns a %DynamicArray of events.
ClassMethod DrainQueue() As %DynamicArray [ Language = python ]
{
    import json
    import os

    queue_file = "/tmp/interclaw/audit_queue.jsonl"
    if not os.path.exists(queue_file):
        return None

    try:
        sz = os.path.getsize(queue_file)
        if sz == 0:
            return None
    except OSError:
        return None

    try:
        import fcntl
        with open(queue_file, "r+") as f:
            fcntl.flock(f, fcntl.LOCK_EX)
            lines = f.readlines()
            f.seek(0)
            f.truncate()
            fcntl.flock(f, fcntl.LOCK_UN)
    except Exception:
        return None

    if not lines:
        return None

    import iris
    arr = iris.cls("%DynamicArray")._New()
    for line in lines:
        line = line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
            obj = iris.cls("%DynamicObject")._New()
            for k, v in event.items():
                obj._Set(k, v if v is not None else "")
            arr._Push(obj)
        except Exception:
            pass

    return arr
}

}
