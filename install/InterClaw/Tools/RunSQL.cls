/// Execute a read-only SQL query against the current namespace and return rows as JSON.
Class InterClaw.Tools.RunSQL Extends InterClaw.Tools.Base
{

Parameter ToolName = "run_sql";

Parameter ToolDescription = "Execute a read-only SQL SELECT query in the current IRIS namespace. Returns up to 100 rows as JSON.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""sql"":{""type"":""string"",""description"":""SELECT statement""}},""required"":[""sql""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set sql = input.%Get("sql")
    If sql = "" Return "Error: missing sql parameter"
    Set upper = $ZCONVERT(sql, "U")
    If ($Find(upper, "INSERT ")) || ($Find(upper, "UPDATE ")) || ($Find(upper, "DELETE ")) || ($Find(upper, "DROP ")) || ($Find(upper, "CREATE ")) || ($Find(upper, "TRUNCATE ")) {
        Return "Error: only SELECT statements are permitted"
    }

    Set rs = ##class(%SQL.Statement).%ExecDirect(, sql)
    If rs.%SQLCODE < 0 Return "SQL error " _ rs.%SQLCODE _ ": " _ rs.%Message

    Set arr = ##class(%DynamicArray).%New()
    Set rowCount = 0
    While rs.%Next() && (rowCount < 100) {
        Set row = ##class(%DynamicObject).%New()
        Set meta = rs.%GetMetadata()
        Set colCount = meta.columns.Count()
        For i = 1:1:colCount {
            Set col = meta.columns.GetAt(i)
            Do row.%Set(col.colName, rs.%GetData(i))
        }
        Do arr.%Push(row)
        Set rowCount = rowCount + 1
    }
    Return arr.%ToJSON()
}

}
