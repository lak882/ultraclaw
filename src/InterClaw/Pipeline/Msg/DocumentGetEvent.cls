/// Document retrieval event — emitted by get_doc.py after pulling a document.
/// Source: "audit_doc_get"
Class InterClaw.Pipeline.Msg.DocumentGetEvent Extends InterClaw.Pipeline.Msg.BaseEvent
{

/// Document name (e.g., My.Package.ClassName.cls).
Property DocumentName As %String(MAXLEN = 500);

/// Full document content retrieved from the server.
Property Content As %String(MAXLEN = "");

/// Number of lines in the document.
Property LineCount As %Integer [ InitialExpression = 0 ];

}
