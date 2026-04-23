/// Create, delete, check, or list HealthShare Foundation namespaces.
/// Delete uses Config.Namespaces and Config.Databases; create uses
/// HS.Util.Installer.Foundation which sets up HSLIB/HSCUSTOM mappings.
///
/// Heavy operations — the call will switch $Namespace via `new $namespace`
/// and `zn "%SYS"` as needed, so it should be called from a safe context.
Class InterClaw.Tools.ManageNamespace Extends InterClaw.Tools.Base
{

Parameter ToolName = "manage_namespace";

Parameter ToolDescription = "Manage HealthShare namespaces. Actions: exists, list, create (HealthShare Foundation), delete (drops namespace + its databases). `create` requires name; existing namespace = no-op success.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""action"":{""type"":""string"",""enum"":[""exists"",""list"",""create"",""delete""]},""name"":{""type"":""string""}},""required"":[""action""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set action = $ZConvert(input.%Get("action"), "L")
    Set name = $ZConvert(input.%Get("name"), "U")

    Try {
        If action = "list" {
            Set arr = ##class(%DynamicArray).%New()
            Set nsList = ""
            Do List^%SYS.NAMESPACE(.nsList)
            Set k = ""
            For { Set k = $Order(nsList(k)) Quit:k=""  Do arr.%Push(k) }
            Return arr.%ToJSON()
        }

        If name = "" Return "Error: name is required for action '" _ action _ "'"

        If action = "exists" {
            Set resp = ##class(%DynamicObject).%New()
            Do resp.%Set("name", name)
            Do resp.%Set("exists", ''##class(%SYS.Namespace).Exists(name), "boolean")
            Return resp.%ToJSON()
        }

        If action = "create" {
            If ##class(%SYS.Namespace).Exists(name) {
                Return "{""ok"":true,""created"":false,""message"":""namespace already exists""}"
            }
            New $namespace
            Set $Namespace = "HSLIB"
            Set sc = ##class(HS.Util.Installer.Foundation).Install(name)
            If $$$ISERR(sc) Return "Create failed: " _ $System.Status.GetErrorText(sc)
            Return "{""ok"":true,""created"":true,""name"":""" _ name _ """}"
        }

        If action = "delete" {
            If (name = "%SYS") || (name = "HSLIB") || (name = "HSCUSTOM") || (name = "HSSYS") {
                Return "Error: refusing to delete protected namespace " _ name
            }
            If '##class(%SYS.Namespace).Exists(name) {
                Return "{""ok"":true,""deleted"":false,""message"":""namespace does not exist""}"
            }
            Set resp = ##class(%DynamicObject).%New()
            Do resp.%Set("name", name)
            New $namespace
            Set $Namespace = "%SYS"
            // Snapshot the databases attached to the namespace before dropping it.
            Set dbs = ##class(%DynamicArray).%New()
            Set dbList = ""
            If ##class(Config.Namespaces).Exists(name, .nsObj), $IsObject(nsObj) {
                Do dbs.%Push(nsObj.Globals)
                If nsObj.Routines '= nsObj.Globals Do dbs.%Push(nsObj.Routines)
            }
            Do resp.%Set("databases", dbs)
            // Drop the namespace, then drop its databases.
            Set sc = ##class(Config.Namespaces).Delete(name)
            If $$$ISERR(sc) {
                Do resp.%Set("ok", 0, "boolean")
                Do resp.%Set("error", $System.Status.GetErrorText(sc))
                Return resp.%ToJSON()
            }
            For i = 0:1:dbs.%Size()-1 {
                Set dbName = dbs.%Get(i)
                If dbName = "" Continue
                Try {
                    Do ##class(Config.Databases).Delete(dbName)
                } Catch { }
            }
            Do resp.%Set("ok", 1, "boolean")
            Do resp.%Set("deleted", 1, "boolean")
            Return resp.%ToJSON()
        }

        Return "Error: unknown action '" _ action _ "'"
    } Catch ex {
        Return "Tool error: " _ ex.DisplayString()
    }
}

}
