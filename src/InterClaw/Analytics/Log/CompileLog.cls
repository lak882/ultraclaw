/// Long-term SQL storage for compilation events.
/// SQL table: InterClaw_Analytics_Log.CompileLog
Class InterClaw.Analytics.Log.CompileLog Extends %Persistent
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

Property CompileStatus As %String(MAXLEN = 50);

Property CompileMessages As %String(MAXLEN = "");

Property Duration As %Numeric;

Index IdxTimestamp On EventTimestamp;

Index IdxSession On ChatSessionId;

Index IdxDocument On DocumentName;

Index IdxNamespace On (ServerName, NamespaceName);

}
