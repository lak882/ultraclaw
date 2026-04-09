/// DEPRECATED — replaced by BaseEvent class hierarchy (ApiCallEvent,
/// TerminalEvent, FileChangeEvent, ChatPipelineEvent).
/// Retained for historical message visibility in the message bank.
Class InterClaw.Pipeline.Msg.UnifiedEvent Extends (Ens.Request, %JSON.Adaptor, %XML.Adaptor)
{

// --- Correlation ---

/// Event source: "chat", "audit_api", "audit_terminal", "audit_file_change", "audit_interop"
Property Source As %String(MAXLEN = 50);

/// Event type: chat (connected/thinking/output/tool_use/tool_result/done/usage/error)
/// or audit (api_call/terminal/file_change/interop_api)
Property EventType As %String(MAXLEN = 50);

/// Conversation-level correlation — groups all events from the same chat session.
/// Set from INTERCLAW_SESSION_ID env var.
Property ChatSessionId As %String(MAXLEN = 100);

/// Message-turn-level correlation — groups events from the same prompt/response.
/// For chat events: the BridgeId. For audit events: from INTERCLAW_MESSAGE_ID env var.
Property MessageId As %String(MAXLEN = 100);

/// IRIS server timestamp.
Property Timestamp As %TimeStamp [ InitialExpression = {$zdatetime($ztimestamp, 3)} ];

/// Original timestamp from the Python script (ISO 8601).
Property OriginalTimestamp As %String(MAXLEN = 50);

// --- Chat fields (Source="chat") ---

/// Raw Claude stream JSON event.
Property EventJSON As %String(MAXLEN = "");

/// Extracted text content from the event.
Property ChatText As %String(MAXLEN = "");

/// True for the final event in a chat turn (done event).
Property IsFinal As %Boolean [ InitialExpression = 0 ];

// --- Audit fields (Source="audit_*") ---

/// Action performed: HTTP method (GET/PUT/POST), "exec", "push", "create".
Property Action As %String(MAXLEN = 100);

/// Target of the action: API URL, terminal namespace, or class name.
Property Target As %String(MAXLEN = 2000);

/// HTTP status code (for API calls).
Property StatusCode As %Integer;

/// Duration in milliseconds.
Property Duration As %Numeric;

/// Affected class name (for file_change events).
Property ClassName As %String(MAXLEN = 500);

/// IRIS namespace where the action occurred.
Property Namespace As %String(MAXLEN = 100);

/// Server name from config/servers.json.
Property Server As %String(MAXLEN = 100);

/// One-line human-readable summary.
Property Summary As %String(MAXLEN = 1000);

/// Extended detail (diff output, terminal output, etc.).
Property Detail As %String(MAXLEN = 32000);

// --- API request/response detail (Source="audit_api" or "audit_interop") ---

/// JSON body sent in the API request.
Property RequestBody As %String(MAXLEN = "");

/// JSON body received in the API response.
Property ResponseBody As %String(MAXLEN = "");

// --- File change detail (Source="audit_file_change") ---

/// Full file content before the change (empty for new files).
Property BeforeContent As %String(MAXLEN = "");

/// Full file content after the change.
Property AfterContent As %String(MAXLEN = "");

}
