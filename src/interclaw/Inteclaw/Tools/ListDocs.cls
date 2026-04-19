/// List classes / routines in the current namespace.
Class Inteclaw.Tools.ListDocs Extends Inteclaw.Tools.Base
{

Parameter ToolName = "list_docs";

Parameter ToolDescription = "List classes in the current namespace, optionally filtered by package prefix.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""prefix"":{""type"":""string"",""description"":""Package prefix, e.g. Inteclaw""}},""required"":[]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set prefix = input.%Get("prefix")

    Set sql = "SELECT ID FROM %Dictionary.ClassDefinition WHERE System = 0"
    If prefix '= "" {
        Set sql = sql _ " AND ID %STARTSWITH '" _ prefix _ "'"
    }
    Set sql = sql _ " ORDER BY ID"

    Set rs = ##class(%SQL.Statement).%ExecDirect(, sql)
    Set arr = ##class(%DynamicArray).%New()
    Set count = 0
    While rs.%Next() && (count < 500) {
        Do arr.%Push(rs.%Get("ID"))
        Set count = count + 1
    }
    Return arr.%ToJSON()
}

}
