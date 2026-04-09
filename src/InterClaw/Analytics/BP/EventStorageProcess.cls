/// Business Process that stores pipeline events to type-specific SQL tables.
/// Dispatches by message class name and uses embedded SQL to INSERT into
/// the appropriate InterClaw_Analytics_Log.* table.
Class InterClaw.Analytics.BP.EventStorageProcess Extends Ens.BusinessProcess
{

Parameter INVOCATION = "Queue";

Method OnRequest(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    Set className = $classname(pRequest)

    If className = "InterClaw.Pipeline.Msg.ApiCallEvent" {
        Return ..StoreApiCall(pRequest)
    } ElseIf className = "InterClaw.Pipeline.Msg.TerminalEvent" {
        Return ..StoreTerminal(pRequest)
    } ElseIf className = "InterClaw.Pipeline.Msg.DocumentGetEvent" {
        Return ..StoreDocumentGet(pRequest)
    } ElseIf className = "InterClaw.Pipeline.Msg.DocumentPutEvent" {
        Return ..StoreDocumentPut(pRequest)
    } ElseIf className = "InterClaw.Pipeline.Msg.CompileEvent" {
        Return ..StoreCompile(pRequest)
    } ElseIf className = "InterClaw.Pipeline.Msg.QueryEvent" {
        Return ..StoreQuery(pRequest)
    } ElseIf className = "InterClaw.Pipeline.Msg.ChatPipelineEvent" {
        Return ..StoreChat(pRequest)
    } ElseIf className = "InterClaw.Pipeline.Msg.FileChangeEvent" {
        Return ..StoreFileChange(pRequest)
    }

    $$$LOGWARNING("EventStorageProcess: unhandled message type: " _ className)
    Return $$$OK
}

Method OnResponse(pRequest As Ens.Request, ByRef pResponse As Ens.Response, pCallrequest As Ens.Request, pCallresponse As Ens.Response, pCompletionKey As %String) As %Status
{
    Return $$$OK
}

/// Store API call event (Atelier + InteropEditors).
Method StoreApiCall(pRequest As InterClaw.Pipeline.Msg.ApiCallEvent) As %Status
{
    Set src = pRequest.Source
    Set etype = pRequest.EventType
    Set sid = pRequest.ChatSessionId
    Set mid = pRequest.MessageId
    Set ots = pRequest.OriginalTimestamp
    Set srv = pRequest.Server
    Set ns = pRequest.Namespace
    Set sum = $extract(pRequest.Summary, 1, 1000)
    Set mth = pRequest.Method
    Set url = $extract(pRequest.URL, 1, 2000)
    Set sc = pRequest.StatusCode
    Set dur = pRequest.Duration
    Set reqb = pRequest.RequestBody
    Set resb = pRequest.ResponseBody

    &sql(INSERT INTO InterClaw_Analytics_Log.ApiCallLog
         (Source, EventType, ChatSessionId, MessageId, OriginalTimestamp,
          ServerName, NamespaceName, Summary,
          HttpMethod, URL, StatusCode, Duration, RequestBody, ResponseBody)
         VALUES (:src, :etype, :sid, :mid, :ots, :srv, :ns, :sum,
                 :mth, :url, :sc, :dur, :reqb, :resb))

    If SQLCODE && (SQLCODE '= 100) {
        $$$LOGWARNING("StoreApiCall failed: SQLCODE=" _ SQLCODE)
    }
    Return $$$OK
}

/// Store terminal execution event.
Method StoreTerminal(pRequest As InterClaw.Pipeline.Msg.TerminalEvent) As %Status
{
    Set src = pRequest.Source
    Set etype = pRequest.EventType
    Set sid = pRequest.ChatSessionId
    Set mid = pRequest.MessageId
    Set ots = pRequest.OriginalTimestamp
    Set srv = pRequest.Server
    Set ns = pRequest.Namespace
    Set sum = $extract(pRequest.Summary, 1, 1000)
    Set code = pRequest.Code
    Set output = pRequest.Output
    Set dur = pRequest.Duration
    Set success = pRequest.Success

    &sql(INSERT INTO InterClaw_Analytics_Log.TerminalLog
         (Source, EventType, ChatSessionId, MessageId, OriginalTimestamp,
          ServerName, NamespaceName, Summary,
          CommandCode, CommandOutput, Duration, Success)
         VALUES (:src, :etype, :sid, :mid, :ots, :srv, :ns, :sum,
                 :code, :output, :dur, :success))

    If SQLCODE && (SQLCODE '= 100) {
        $$$LOGWARNING("StoreTerminal failed: SQLCODE=" _ SQLCODE)
    }
    Return $$$OK
}

/// Store document pull event.
Method StoreDocumentGet(pRequest As InterClaw.Pipeline.Msg.DocumentGetEvent) As %Status
{
    Set src = pRequest.Source
    Set etype = pRequest.EventType
    Set sid = pRequest.ChatSessionId
    Set mid = pRequest.MessageId
    Set ots = pRequest.OriginalTimestamp
    Set srv = pRequest.Server
    Set ns = pRequest.Namespace
    Set sum = $extract(pRequest.Summary, 1, 1000)
    Set docName = pRequest.DocumentName
    Set content = pRequest.Content
    Set lineCount = pRequest.LineCount

    &sql(INSERT INTO InterClaw_Analytics_Log.DocumentGetLog
         (Source, EventType, ChatSessionId, MessageId, OriginalTimestamp,
          ServerName, NamespaceName, Summary,
          DocumentName, Content, LineCount)
         VALUES (:src, :etype, :sid, :mid, :ots, :srv, :ns, :sum,
                 :docName, :content, :lineCount))

    If SQLCODE && (SQLCODE '= 100) {
        $$$LOGWARNING("StoreDocumentGet failed: SQLCODE=" _ SQLCODE)
    }
    Return $$$OK
}

/// Store document push event (create/update with before/after content).
Method StoreDocumentPut(pRequest As InterClaw.Pipeline.Msg.DocumentPutEvent) As %Status
{
    Set src = pRequest.Source
    Set etype = pRequest.EventType
    Set sid = pRequest.ChatSessionId
    Set mid = pRequest.MessageId
    Set ots = pRequest.OriginalTimestamp
    Set srv = pRequest.Server
    Set ns = pRequest.Namespace
    Set sum = $extract(pRequest.Summary, 1, 1000)
    Set docName = pRequest.DocumentName
    Set action = pRequest.Action
    Set isNew = pRequest.IsNew
    Set added = pRequest.LinesAdded
    Set removed = pRequest.LinesRemoved
    Set before = pRequest.BeforeContent
    Set after = pRequest.AfterContent
    Set cStatus = pRequest.CompileStatus
    Set cMsgs = pRequest.CompileMessages

    &sql(INSERT INTO InterClaw_Analytics_Log.DocumentPutLog
         (Source, EventType, ChatSessionId, MessageId, OriginalTimestamp,
          ServerName, NamespaceName, Summary,
          DocumentName, Action, IsNew, LinesAdded, LinesRemoved,
          BeforeContent, AfterContent, CompileStatus, CompileMessages)
         VALUES (:src, :etype, :sid, :mid, :ots, :srv, :ns, :sum,
                 :docName, :action, :isNew, :added, :removed,
                 :before, :after, :cStatus, :cMsgs))

    If SQLCODE && (SQLCODE '= 100) {
        $$$LOGWARNING("StoreDocumentPut failed: SQLCODE=" _ SQLCODE)
    }
    Return $$$OK
}

/// Store compilation event.
Method StoreCompile(pRequest As InterClaw.Pipeline.Msg.CompileEvent) As %Status
{
    Set src = pRequest.Source
    Set etype = pRequest.EventType
    Set sid = pRequest.ChatSessionId
    Set mid = pRequest.MessageId
    Set ots = pRequest.OriginalTimestamp
    Set srv = pRequest.Server
    Set ns = pRequest.Namespace
    Set sum = $extract(pRequest.Summary, 1, 1000)
    Set docName = pRequest.DocumentName
    Set cStatus = pRequest.CompileStatus
    Set cMsgs = pRequest.CompileMessages
    Set dur = pRequest.Duration

    &sql(INSERT INTO InterClaw_Analytics_Log.CompileLog
         (Source, EventType, ChatSessionId, MessageId, OriginalTimestamp,
          ServerName, NamespaceName, Summary,
          DocumentName, CompileStatus, CompileMessages, Duration)
         VALUES (:src, :etype, :sid, :mid, :ots, :srv, :ns, :sum,
                 :docName, :cStatus, :cMsgs, :dur))

    If SQLCODE && (SQLCODE '= 100) {
        $$$LOGWARNING("StoreCompile failed: SQLCODE=" _ SQLCODE)
    }
    Return $$$OK
}

/// Store SQL query event.
Method StoreQuery(pRequest As InterClaw.Pipeline.Msg.QueryEvent) As %Status
{
    Set src = pRequest.Source
    Set etype = pRequest.EventType
    Set sid = pRequest.ChatSessionId
    Set mid = pRequest.MessageId
    Set ots = pRequest.OriginalTimestamp
    Set srv = pRequest.Server
    Set ns = pRequest.Namespace
    Set sum = $extract(pRequest.Summary, 1, 1000)
    Set sqlText = pRequest.SQL
    Set rowCount = pRequest.RowCount
    Set sc = pRequest.StatusCode
    Set dur = pRequest.Duration

    &sql(INSERT INTO InterClaw_Analytics_Log.QueryLog
         (Source, EventType, ChatSessionId, MessageId, OriginalTimestamp,
          ServerName, NamespaceName, Summary,
          SqlText, RowCount, StatusCode, Duration)
         VALUES (:src, :etype, :sid, :mid, :ots, :srv, :ns, :sum,
                 :sqlText, :rowCount, :sc, :dur))

    If SQLCODE && (SQLCODE '= 100) {
        $$$LOGWARNING("StoreQuery failed: SQLCODE=" _ SQLCODE)
    }
    Return $$$OK
}

/// Store chat pipeline event.
Method StoreChat(pRequest As InterClaw.Pipeline.Msg.ChatPipelineEvent) As %Status
{
    Set src = pRequest.Source
    Set etype = pRequest.EventType
    Set sid = pRequest.ChatSessionId
    Set mid = pRequest.MessageId
    Set ots = pRequest.OriginalTimestamp
    Set srv = pRequest.Server
    Set ns = pRequest.Namespace
    Set sum = $extract(pRequest.Summary, 1, 1000)
    Set evtJSON = pRequest.EventJSON
    Set chatText = pRequest.ChatText
    Set isFinal = pRequest.IsFinal

    &sql(INSERT INTO InterClaw_Analytics_Log.ChatLog
         (Source, EventType, ChatSessionId, MessageId, OriginalTimestamp,
          ServerName, NamespaceName, Summary,
          EventJSON, ChatText, IsFinal)
         VALUES (:src, :etype, :sid, :mid, :ots, :srv, :ns, :sum,
                 :evtJSON, :chatText, :isFinal))

    If SQLCODE && (SQLCODE '= 100) {
        $$$LOGWARNING("StoreChat failed: SQLCODE=" _ SQLCODE)
    }
    Return $$$OK
}

/// Store deprecated FileChangeEvent — maps to DocumentPutLog.
Method StoreFileChange(pRequest As InterClaw.Pipeline.Msg.FileChangeEvent) As %Status
{
    Set src = pRequest.Source
    Set etype = pRequest.EventType
    Set sid = pRequest.ChatSessionId
    Set mid = pRequest.MessageId
    Set ots = pRequest.OriginalTimestamp
    Set srv = pRequest.Server
    Set ns = pRequest.Namespace
    Set sum = $extract(pRequest.Summary, 1, 1000)
    Set docName = pRequest.ClassName
    Set action = pRequest.Action
    Set isNew = pRequest.IsNew
    Set added = pRequest.LinesAdded
    Set removed = pRequest.LinesRemoved
    Set before = pRequest.BeforeContent
    Set after = pRequest.AfterContent
    Set cStatus = "not_compiled"
    Set cMsgs = ""

    &sql(INSERT INTO InterClaw_Analytics_Log.DocumentPutLog
         (Source, EventType, ChatSessionId, MessageId, OriginalTimestamp,
          ServerName, NamespaceName, Summary,
          DocumentName, Action, IsNew, LinesAdded, LinesRemoved,
          BeforeContent, AfterContent, CompileStatus, CompileMessages)
         VALUES (:src, :etype, :sid, :mid, :ots, :srv, :ns, :sum,
                 :docName, :action, :isNew, :added, :removed,
                 :before, :after, :cStatus, :cMsgs))

    If SQLCODE && (SQLCODE '= 100) {
        $$$LOGWARNING("StoreFileChange failed: SQLCODE=" _ SQLCODE)
    }
    Return $$$OK
}

}
