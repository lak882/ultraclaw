/// File change event — document create or update via put_doc.py.
/// Source: "audit_file_change"
/// Tracks full before/after content for both creates (BeforeContent empty) and updates.
Class InterClaw.Pipeline.Msg.FileChangeEvent Extends InterClaw.Pipeline.Msg.BaseEvent
{

/// Document name (e.g., My.Package.ClassName.cls).
Property ClassName As %String(MAXLEN = 500);

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

}
