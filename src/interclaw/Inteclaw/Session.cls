/// Persistent conversation session.
/// Holds the running list of messages (user/assistant/tool) as a JSON array.
/// A session outlives any single chat request so that follow-up requests can
/// resume where the agent loop left off.
Class Inteclaw.Session Extends %Persistent
{

Property SessionId As %String(MAXLEN = 64) [ Required ];

Property Provider As %String(MAXLEN = 32);

Property Model As %String(MAXLEN = 128);

Property SystemPrompt As %String(MAXLEN = "");

/// JSON array of provider-normalized messages:
/// [{"role":"user","content":[{"type":"text","text":"..."}]},
///  {"role":"assistant","content":[{"type":"text","text":"..."}, {"type":"tool_use",...}]},
///  {"role":"user","content":[{"type":"tool_result","tool_use_id":"...","content":"..."}]}]
Property MessagesJSON As %String(MAXLEN = "") [ InitialExpression = "[]" ];

Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

Property UpdatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

Property TotalInputTokens As %Integer [ InitialExpression = 0 ];

Property TotalOutputTokens As %Integer [ InitialExpression = 0 ];

/// Plan-mode flag. When 1, destructive tools (write-class, exec, bash, etc.)
/// short-circuit to a "plan recorded" message instead of executing.
/// Toggled by Inteclaw.Tools.EnterPlanMode / ExitPlanMode.
Property PlanMode As %Boolean [ InitialExpression = 0 ];

/// Comma-separated list of tool names the model should not see in the
/// descriptor JSON. Empty = no filtering.
Property DenyTools As %String(MAXLEN = 4096) [ InitialExpression = "" ];

/// Comma-separated list of tool-name prefixes to deny (e.g. "exec,put").
Property DenyPrefixes As %String(MAXLEN = 1024) [ InitialExpression = "" ];

/// If 1, ignore DenyTools/DenyPrefixes. Analogue of --dangerously-skip-permissions.
Property BypassPermissions As %Boolean [ InitialExpression = 0 ];

Index SessionIdIdx On SessionId [ Unique ];

/// Open or create a session by id.
ClassMethod OpenOrCreate(sessionId As %String) As Inteclaw.Session
{
    Set session = ..SessionIdIdxOpen(sessionId, , .sc)
    If '$IsObject(session) {
        Set session = ..%New()
        Set session.SessionId = sessionId
    }
    Return session
}

/// Append a message to the session's MessagesJSON and persist.
Method AppendMessage(role As %String, contentJSON As %String) As %Status
{
    Set arr = ##class(%DynamicArray).%FromJSON(..MessagesJSON)
    Set msg = ##class(%DynamicObject).%New()
    Do msg.%Set("role", role)
    Do msg.%Set("content", ##class(%DynamicArray).%FromJSON(contentJSON))
    Do arr.%Push(msg)
    Set ..MessagesJSON = arr.%ToJSON()
    Set ..UpdatedAt = $ZDATETIME($HOROLOG, 3)
    Return ..%Save()
}

Storage Default
{
<Data name="SessionDefaultData">
<Value name="1"><Value>%%CLASSNAME</Value></Value>
<Value name="2"><Value>SessionId</Value></Value>
<Value name="3"><Value>Provider</Value></Value>
<Value name="4"><Value>Model</Value></Value>
<Value name="5"><Value>SystemPrompt</Value></Value>
<Value name="6"><Value>MessagesJSON</Value></Value>
<Value name="7"><Value>CreatedAt</Value></Value>
<Value name="8"><Value>UpdatedAt</Value></Value>
<Value name="9"><Value>TotalInputTokens</Value></Value>
<Value name="10"><Value>TotalOutputTokens</Value></Value>
<Value name="11"><Value>PlanMode</Value></Value>
<Value name="12"><Value>DenyTools</Value></Value>
<Value name="13"><Value>DenyPrefixes</Value></Value>
<Value name="14"><Value>BypassPermissions</Value></Value>
</Data>
<DataLocation>^Inteclaw.SessionD</DataLocation>
<DefaultData>SessionDefaultData</DefaultData>
<IdLocation>^Inteclaw.SessionD</IdLocation>
<IndexLocation>^Inteclaw.SessionI</IndexLocation>
<StreamLocation>^Inteclaw.SessionS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
