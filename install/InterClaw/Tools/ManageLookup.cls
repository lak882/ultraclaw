/// Read or write rows in an Ens.Util.LookupTable. Covers the CRUD used
/// by DTL lookups: list tables, list/get keys, set a key, clear a key or
/// the whole table.
Class InterClaw.Tools.ManageLookup Extends InterClaw.Tools.Base
{

Parameter ToolName = "manage_lookup";

Parameter ToolDescription = "CRUD for Ensemble lookup tables (Ens.Util.LookupTable). Actions: list_tables; list_keys (requires table); get (table + key); set (table + key + value); clear_key (table + key); clear_table (table).";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""action"":{""type"":""string"",""enum"":[""list_tables"",""list_keys"",""get"",""set"",""clear_key"",""clear_table""]},""table"":{""type"":""string""},""key"":{""type"":""string""},""value"":{""type"":""string""}},""required"":[""action""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set action = $ZConvert(input.%Get("action"), "L")
    Set table = input.%Get("table")
    Set key = input.%Get("key")
    Set value = input.%Get("value")

    Try {
        If action = "list_tables" {
            Set rs = ##class(%SQL.Statement).%ExecDirect(,
                "SELECT DISTINCT TableName FROM Ens_Util.LookupTable ORDER BY TableName")
            Set arr = ##class(%DynamicArray).%New()
            While rs.%Next() { Do arr.%Push(rs.%Get("TableName")) }
            Return arr.%ToJSON()
        }

        If table = "" Return "Error: table is required for action '" _ action _ "'"

        If action = "list_keys" {
            Set stmt = ##class(%SQL.Statement).%New()
            Do stmt.%Prepare("SELECT KeyName, DataValue FROM Ens_Util.LookupTable WHERE TableName = ? ORDER BY KeyName")
            Set rs = stmt.%Execute(table)
            Set arr = ##class(%DynamicArray).%New()
            While rs.%Next() {
                Set row = ##class(%DynamicObject).%New()
                Do row.%Set("key", rs.%Get("KeyName"))
                Do row.%Set("value", rs.%Get("DataValue"))
                Do arr.%Push(row)
            }
            Return arr.%ToJSON()
        }

        If action = "get" {
            If key = "" Return "Error: key is required for get"
            Set stmt = ##class(%SQL.Statement).%New()
            Do stmt.%Prepare("SELECT DataValue FROM Ens_Util.LookupTable WHERE TableName = ? AND KeyName = ?")
            Set rs = stmt.%Execute(table, key)
            If rs.%Next() {
                Set resp = ##class(%DynamicObject).%New()
                Do resp.%Set("table", table)
                Do resp.%Set("key", key)
                Do resp.%Set("value", rs.%Get("DataValue"))
                Return resp.%ToJSON()
            }
            Return "{""found"":false}"
        }

        If action = "set" {
            If key = "" Return "Error: key is required for set"
            // Upsert via delete + insert — portable, avoids MERGE dialect variance.
            &sql(DELETE FROM Ens_Util.LookupTable WHERE TableName = :table AND KeyName = :key)
            &sql(INSERT INTO Ens_Util.LookupTable (TableName, KeyName, DataValue) VALUES (:table, :key, :value))
            If SQLCODE < 0 Return "SQL error " _ SQLCODE _ ": " _ $Get(%msg)
            Set resp = ##class(%DynamicObject).%New()
            Do resp.%Set("ok", 1, "boolean")
            Do resp.%Set("table", table)
            Do resp.%Set("key", key)
            Do resp.%Set("value", value)
            Return resp.%ToJSON()
        }

        If action = "clear_key" {
            If key = "" Return "Error: key is required for clear_key"
            &sql(DELETE FROM Ens_Util.LookupTable WHERE TableName = :table AND KeyName = :key)
            If SQLCODE < 0 Return "SQL error " _ SQLCODE _ ": " _ $Get(%msg)
            Return "{""ok"":true,""deleted"":" _ (%ROWCOUNT) _ "}"
        }

        If action = "clear_table" {
            &sql(DELETE FROM Ens_Util.LookupTable WHERE TableName = :table)
            If SQLCODE < 0 Return "SQL error " _ SQLCODE _ ": " _ $Get(%msg)
            Return "{""ok"":true,""deleted"":" _ (%ROWCOUNT) _ "}"
        }

        Return "Error: unknown action '" _ action _ "'"
    } Catch ex {
        Return "Tool error: " _ ex.DisplayString()
    }
}

}
