/// Long-term SQL storage for API call audit events.
/// SQL table: InterClaw_Analytics_Log.ApiCallLog
Class InterClaw.Analytics.Log.ApiCallLog Extends %Persistent
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

Property HttpMethod As %String(MAXLEN = 10);

Property URL As %String(MAXLEN = 2000);

Property StatusCode As %Integer;

Property Duration As %Numeric;

Property RequestBody As %String(MAXLEN = "");

Property ResponseBody As %String(MAXLEN = "");

Index IdxTimestamp On EventTimestamp;

Index IdxSession On ChatSessionId;

Index IdxNamespace On (ServerName, NamespaceName);

}
