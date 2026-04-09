/// Abstract base class for all pipeline event types.
/// Carries correlation IDs and common context shared by every event.
Class InterClaw.Pipeline.Msg.BaseEvent Extends (Ens.Request, %JSON.Adaptor, %XML.Adaptor) [ Abstract ]
{

/// Event source: "chat", "audit_api", "audit_terminal", "audit_file_change", "audit_interop"
Property Source As %String(MAXLEN = 50);

/// Specific event type within the source category.
Property EventType As %String(MAXLEN = 50);

/// Conversation-level correlation — groups all events from the same chat session.
Property ChatSessionId As %String(MAXLEN = 100);

/// Message-turn-level correlation — groups events from the same prompt/response.
Property MessageId As %String(MAXLEN = 100);

/// IRIS server timestamp.
Property Timestamp As %TimeStamp [ InitialExpression = {$zdatetime($ztimestamp, 3)} ];

/// Original timestamp from the Python script (ISO 8601).
Property OriginalTimestamp As %String(MAXLEN = 50);

/// Server name from config/servers.json.
Property Server As %String(MAXLEN = 100);

/// IRIS namespace where the event occurred.
Property Namespace As %String(MAXLEN = 100);

/// One-line human-readable summary.
Property Summary As %String(MAXLEN = 1000);

}
