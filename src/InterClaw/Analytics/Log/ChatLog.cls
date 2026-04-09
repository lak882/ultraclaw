/// Long-term SQL storage for chat pipeline events.
/// SQL table: InterClaw_Analytics_Log.ChatLog
Class InterClaw.Analytics.Log.ChatLog Extends %Persistent
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

Property EventJSON As %String(MAXLEN = "");

Property ChatText As %String(MAXLEN = "");

Property IsFinal As %Boolean [ InitialExpression = 0 ];

Index IdxTimestamp On EventTimestamp;

Index IdxSession On ChatSessionId;

Index IdxNamespace On (ServerName, NamespaceName);

}
