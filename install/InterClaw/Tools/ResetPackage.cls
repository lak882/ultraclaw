/// Delete every class under a package prefix. Defaults to dry-run so the
/// model can confirm the list before destroying anything. Only touches the
/// current namespace.
Class InterClaw.Tools.ResetPackage Extends InterClaw.Tools.Base
{

Parameter ToolName = "reset_package";

Parameter ToolDescription = "Delete every class whose name starts with a prefix. Defaults to dry-run (commit=false) which returns the list without deleting. Pass commit=true to actually drop. Stops the running production first when commit=true to avoid lock contention.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""prefix"":{""type"":""string"",""description"":""Package prefix, e.g. 'Demo.Build1'""},""commit"":{""type"":""boolean"",""default"":false},""include_subpackages"":{""type"":""boolean"",""default"":true}},""required"":[""prefix""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set prefix = input.%Get("prefix")
    Set commit = ''input.%Get("commit")
    Set subs = 1
    If input.%IsDefined("include_subpackages") Set subs = ''input.%Get("include_subpackages")
    If prefix = "" Return "Error: prefix is required"

    Set like = prefix _ $Select(subs: ".%", 1: "")
    Set stmt = ##class(%SQL.Statement).%New()
    Do stmt.%Prepare("SELECT Name FROM %Dictionary.ClassDefinition WHERE Name = ? OR Name LIKE ? ORDER BY Name")
    Set rs = stmt.%Execute(prefix, like)

    Set list = ##class(%DynamicArray).%New()
    Set names = ""
    While rs.%Next() {
        Set n = rs.%Get("Name")
        Do list.%Push(n)
        Set names = names _ $Select(names="":"",1:",") _ n
    }

    Set resp = ##class(%DynamicObject).%New()
    Do resp.%Set("prefix", prefix)
    Do resp.%Set("count", list.%Size(), "number")
    Do resp.%Set("classes", list)

    If 'commit {
        Do resp.%Set("committed", 0, "boolean")
        Do resp.%Set("note", "dry-run — pass commit=true to delete")
        Return resp.%ToJSON()
    }

    // Real delete: stop production first so we don't thrash locks/classes.
    Set prevState = 0
    Do ##class(Ens.Director).GetProductionStatus(.runningProd, .prevState)
    If +prevState = 1 {
        Do ##class(Ens.Director).StopProduction(30, 1)
        Do resp.%Set("stopped_production", runningProd)
    }

    Set deleted = ##class(%DynamicArray).%New()
    Set failed = ##class(%DynamicArray).%New()
    For i = 0:1:list.%Size()-1 {
        Set cls = list.%Get(i)
        Try {
            Set sc = $System.OBJ.Delete(cls, "-d")
            If $$$ISOK(sc) {
                Do deleted.%Push(cls)
            } Else {
                Set row = ##class(%DynamicObject).%New()
                Do row.%Set("class", cls)
                Do row.%Set("error", $System.Status.GetErrorText(sc))
                Do failed.%Push(row)
            }
        } Catch ex {
            Set row = ##class(%DynamicObject).%New()
            Do row.%Set("class", cls)
            Do row.%Set("error", ex.DisplayString())
            Do failed.%Push(row)
        }
    }
    Do resp.%Set("committed", 1, "boolean")
    Do resp.%Set("deleted_count", deleted.%Size(), "number")
    Do resp.%Set("failed_count", failed.%Size(), "number")
    Do resp.%Set("deleted", deleted)
    Do resp.%Set("failed", failed)
    Return resp.%ToJSON()
}

}
