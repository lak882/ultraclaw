/// Read recent error and warning rows from the Ensemble event log
/// (Ens_Util.Log). Default window is the last 24 hours.
Class InterClaw.Tools.GetErrors Extends InterClaw.Tools.Base
{

Parameter ToolName = "get_errors";

Parameter ToolDescription = "Recent errors/warnings from the Ensemble event log (Ens_Util.Log). Type codes: 2=Error, 3=Warning, 6=Alert. Returns newest first.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""hours"":{""type"":""number"",""default"":24,""description"":""Window in hours, default 24""},""config_item"":{""type"":""string"",""description"":""Optional ConfigName filter""},""limit"":{""type"":""integer"",""default"":25,""minimum"":1,""maximum"":200},""include_warnings"":{""type"":""boolean"",""default"":true}},""required"":[]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set hours = +input.%Get("hours")
    If hours <= 0 Set hours = 24
    Set lim = +input.%Get("limit")
    If lim < 1 Set lim = 25
    If lim > 200 Set lim = 200
    Set cfg = input.%Get("config_item")
    Set includeWarn = 1
    If input.%IsDefined("include_warnings") Set includeWarn = ''input.%Get("include_warnings")

    Set types = $Select(includeWarn: "(2,3,6)", 1: "(2,6)")
    Set where = "WHERE Type IN " _ types _ " AND TimeLogged >= DATEADD('hour', -" _ hours _ ", $Horolog)"
    If cfg '= "" {
        Set where = where _ " AND ConfigName = '" _ $Replace(cfg, "'", "''") _ "'"
    }
    Set sql = "SELECT TOP " _ lim _ " ID, TimeLogged, Type, ConfigName, SessionId, Text "
            _ "FROM Ens_Util.Log " _ where _ " ORDER BY ID DESC"

    Set rs = ##class(%SQL.Statement).%ExecDirect(, sql)
    If rs.%SQLCODE < 0 Return "SQL error " _ rs.%SQLCODE _ ": " _ rs.%Message

    Set arr = ##class(%DynamicArray).%New()
    While rs.%Next() {
        Set row = ##class(%DynamicObject).%New()
        Do row.%Set("id", rs.%Get("ID"))
        Do row.%Set("time", rs.%Get("TimeLogged"))
        Set t = rs.%Get("Type")
        Do row.%Set("type", t)
        Do row.%Set("level", $Case(+t, 2:"error", 3:"warning", 4:"info", 6:"alert", :"other"))
        Do row.%Set("config", rs.%Get("ConfigName"))
        Do row.%Set("session", rs.%Get("SessionId"))
        Do row.%Set("text", rs.%Get("Text"))
        Do arr.%Push(row)
    }
    Return arr.%ToJSON()
}

}
