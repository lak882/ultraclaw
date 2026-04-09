/// An audit event from InterClaw Python scripts.
/// Captures API calls, terminal commands, and file changes.
Class InterClaw.Msg.AuditEvent Extends Ens.Request
{

/// Event type: "api_call", "terminal", "file_change".
Property EventType As %String(MAXLEN = 50);

/// Specific action: HTTP method (GET, PUT, POST), terminal command, or file action (push, create).
Property Action As %String(MAXLEN = 100);

/// Target: API URL, terminal namespace, or class name.
Property Target As %String(MAXLEN = 2000);

/// HTTP status code (for API calls).
Property StatusCode As %Integer;

/// Duration in milliseconds.
Property Duration As %Numeric;

/// Affected class name, if applicable.
Property ClassName As %String(MAXLEN = 500);

/// IRIS namespace where the action occurred.
Property Namespace As %String(MAXLEN = 100);

/// Server name from config/servers.json.
Property Server As %String(MAXLEN = 100);

/// One-line human-readable summary.
Property Summary As %String(MAXLEN = 1000);

/// Extended detail (diff, output, etc.) — truncated to 32KB.
Property Detail As %String(MAXLEN = 32000);

/// When the event originally occurred (from the Python script).
Property OriginalTimestamp As %String(MAXLEN = 50);

/// Standard message timestamp.
Property Timestamp As %TimeStamp [ InitialExpression = {$zdatetime($horolog, 3)} ];

}
