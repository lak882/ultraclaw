/// SQL query event — emitted by run_query.py after executing a query.
/// Source: "audit_doc_query"
Class InterClaw.Pipeline.Msg.QueryEvent Extends InterClaw.Pipeline.Msg.BaseEvent
{

/// SQL query text.
Property SQL As %String(MAXLEN = "");

/// Number of rows returned.
Property RowCount As %Integer [ InitialExpression = 0 ];

/// HTTP status code from the query request.
Property StatusCode As %Integer;

/// Duration in milliseconds.
Property Duration As %Numeric;

}
