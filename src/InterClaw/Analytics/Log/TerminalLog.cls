/// Long-term SQL storage for terminal execution events.
/// SQL table: InterClaw_Analytics_Log.TerminalLog
Class InterClaw.Analytics.Log.TerminalLog Extends %Persistent
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

Property CommandCode As %String(MAXLEN = "");

Property CommandOutput As %String(MAXLEN = "");

Property Duration As %Numeric;

Property Success As %Boolean [ InitialExpression = 0 ];

Index IdxTimestamp On EventTimestamp;

Index IdxSession On ChatSessionId;

Index IdxNamespace On (ServerName, NamespaceName);

}
