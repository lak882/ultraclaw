/// Long-term SQL storage for document push events (create/update).
/// SQL table: InterClaw_Analytics_Log.DocumentPutLog
Class InterClaw.Analytics.Log.DocumentPutLog Extends %Persistent
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

Property DocumentName As %String(MAXLEN = 500);

Property Action As %String(MAXLEN = 50);

Property IsNew As %Boolean [ InitialExpression = 0 ];

Property LinesAdded As %Integer [ InitialExpression = 0 ];

Property LinesRemoved As %Integer [ InitialExpression = 0 ];

Property BeforeContent As %String(MAXLEN = "");

Property AfterContent As %String(MAXLEN = "");

Property CompileStatus As %String(MAXLEN = 50);

Property CompileMessages As %String(MAXLEN = "");

Index IdxTimestamp On EventTimestamp;

Index IdxSession On ChatSessionId;

Index IdxDocument On DocumentName;

Index IdxNamespace On (ServerName, NamespaceName);

}
