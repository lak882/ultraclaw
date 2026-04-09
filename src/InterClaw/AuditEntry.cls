/// InterClaw.AuditEntry — Persistent storage for script audit events.
///
/// Stores every API call, terminal command, and file change made by
/// InterClaw Python scripts. Queryable via SQL:
///   SELECT * FROM InterClaw.AuditEntry ORDER BY Timestamp DESC
///   SELECT * FROM InterClaw.AuditEntry WHERE EventType = 'file_change'
///   SELECT * FROM InterClaw.AuditEntry WHERE ClassName LIKE 'MyPkg%'
Class InterClaw.AuditEntry Extends %Persistent [ SqlTableName = AuditEntry ]
{

/// When the entry was stored (IRIS server time).
Property Timestamp As %TimeStamp [ InitialExpression = {$zdatetime($ztimestamp, 3)} ];

/// Event type: "api_call", "terminal", "file_change".
Property EventType As %String(MAXLEN = 50);

/// Specific action: HTTP method, terminal exec, push/create/delete.
Property Action As %String(MAXLEN = 100);

/// Target: API URL path, terminal namespace, or class name.
Property Target As %String(MAXLEN = 2000);

/// HTTP status code (for API calls), 0 otherwise.
Property StatusCode As %Integer [ InitialExpression = 0 ];

/// Duration in milliseconds.
Property Duration As %Numeric [ InitialExpression = 0 ];

/// Affected class name, if applicable.
Property ClassName As %String(MAXLEN = 500);

/// IRIS namespace where the action occurred.
Property Namespace As %String(MAXLEN = 100);

/// Server name from config/servers.json.
Property Server As %String(MAXLEN = 100);

/// One-line human-readable summary.
Property Summary As %String(MAXLEN = 1000);

/// Original timestamp from the Python script (ISO format).
Property OriginalTimestamp As %String(MAXLEN = 50);

Index TimestampIdx On Timestamp;

Index EventTypeIdx On EventType;

Index ClassNameIdx On ClassName;

/// Recent events of any type, newest first.
Query RecentAll(count As %Integer = 100) As %SQLQuery [ SqlProc ]
{
    SELECT TOP :count ID, Timestamp, EventType, Action, Target, StatusCode, Duration, ClassName, Summary
    FROM InterClaw.AuditEntry
    ORDER BY Timestamp DESC
}

/// Recent events filtered by type, newest first.
Query RecentByType(eventType As %String, count As %Integer = 100) As %SQLQuery [ SqlProc ]
{
    SELECT TOP :count ID, Timestamp, EventType, Action, Target, StatusCode, Duration, ClassName, Summary
    FROM InterClaw.AuditEntry
    WHERE EventType = :eventType
    ORDER BY Timestamp DESC
}

}
