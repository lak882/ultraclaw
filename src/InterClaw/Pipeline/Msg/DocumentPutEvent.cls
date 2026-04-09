/// Document push event — emitted by put_doc.py after saving a document.
/// Replaces FileChangeEvent with richer data including compile status.
/// Source: "audit_doc_put"
Class InterClaw.Pipeline.Msg.DocumentPutEvent Extends InterClaw.Pipeline.Msg.BaseEvent
{

/// Document name (e.g., My.Package.ClassName.cls).
Property DocumentName As %String(MAXLEN = 500);

/// Action performed: "create" for new documents, "push" for updates.
Property Action As %String(MAXLEN = 50);

/// True for brand-new documents.
Property IsNew As %Boolean [ InitialExpression = 0 ];

/// Number of lines added.
Property LinesAdded As %Integer [ InitialExpression = 0 ];

/// Number of lines removed.
Property LinesRemoved As %Integer [ InitialExpression = 0 ];

/// Full file content before the change (empty for new documents).
Property BeforeContent As %String(MAXLEN = "");

/// Full file content after the change.
Property AfterContent As %String(MAXLEN = "");

/// Compilation status: "success", "error", or "not_compiled".
Property CompileStatus As %String(MAXLEN = 50) [ InitialExpression = "not_compiled" ];

/// Full compilation output messages.
Property CompileMessages As %String(MAXLEN = "");

}
