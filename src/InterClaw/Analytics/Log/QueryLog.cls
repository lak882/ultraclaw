/// Long-term SQL storage for SQL query events.
/// SQL table: InterClaw_Analytics_Log.QueryLog
Class InterClaw.Analytics.Log.QueryLog Extends %Persistent
{

Property Source As %String(MAXLEN = 50);

Property EventType As %String(MAXLEN = 50);

Property ChatSessionId As %String(MAXLEN = 100);

Property MessageId As %String(MAXLEN = 100);

Property EventTimestamp As %TimeStamp [ InitialExpression = {$zdatetime($ztimestamp, 3)} ];

Property OriginalTimestamp As %String(MAXLEN = 50);

Property ServerName As %String(MAXLEN = 100);

Property NamespaceName As %String(MAXLEN = 100);

Property Summary As %String(MAXLEN = 1000);

Property SqlText As %String(MAXLEN = "");

Property RowCount As %Integer [ InitialExpression = 0 ];

Property StatusCode As %Integer;

Property Duration As %Numeric;

Index IdxTimestamp On EventTimestamp;

Index IdxSession On ChatSessionId;

Index IdxNamespace On (ServerName, NamespaceName);

}
