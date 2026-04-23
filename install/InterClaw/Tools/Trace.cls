/// List recent Ensemble message traces. Returns up to 20 session headers
/// with source/target config names, message class, and time. Use this for
/// quick flow inspection; for a full visual trace open the Portal URL.
Class InterClaw.Tools.Trace Extends InterClaw.Tools.Base
{

Parameter ToolName = "trace";

Parameter ToolDescription = "Recent Ensemble message traces. Optionally filter by session_id or by config item. Returns up to `limit` rows (default 20) sorted newest first.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""session_id"":{""type"":""string"",""description"":""Filter to a single session""},""config_item"":{""type"":""string"",""description"":""Filter where SourceConfigName or TargetConfigName equals this""},""limit"":{""type"":""integer"",""default"":20,""minimum"":1,""maximum"":100}},""required"":[]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set sess = input.%Get("session_id")
    Set cfg = input.%Get("config_item")
    Set lim = +input.%Get("limit")
    If lim < 1 Set lim = 20
    If lim > 100 Set lim = 100

    Set sql = "SELECT TOP " _ lim _ " ID, SessionId, TimeCreated, SourceConfigName, "
            _ "TargetConfigName, MessageBodyClassName "
            _ "FROM Ens.MessageHeader"
    If sess '= "" {
        Set sql = sql _ " WHERE SessionId = '" _ $Replace(sess, "'", "''") _ "'"
    } ElseIf cfg '= "" {
        Set qc = $Replace(cfg, "'", "''")
        Set sql = sql _ " WHERE SourceConfigName = '" _ qc _ "' OR TargetConfigName = '" _ qc _ "'"
    }
    Set sql = sql _ " ORDER BY ID DESC"
    Set rs = ##class(%SQL.Statement).%ExecDirect(, sql)
    If rs.%SQLCODE < 0 Return "SQL error " _ rs.%SQLCODE _ ": " _ rs.%Message

    Set arr = ##class(%DynamicArray).%New()
    While rs.%Next() {
        Set row = ##class(%DynamicObject).%New()
        Do row.%Set("id", rs.%Get("ID"))
        Do row.%Set("session", rs.%Get("SessionId"))
        Do row.%Set("time", rs.%Get("TimeCreated"))
        Do row.%Set("source", rs.%Get("SourceConfigName"))
        Do row.%Set("target", rs.%Get("TargetConfigName"))
        Do row.%Set("body_class", rs.%Get("MessageBodyClassName"))
        Do arr.%Push(row)
    }
    Return arr.%ToJSON()
}

}
