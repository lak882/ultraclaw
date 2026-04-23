/// Read/create/delete IRIS Security.Applications (CSP web apps) for the
/// current instance. Covers the common cases: CSP, REST, WSGI.
Class InterClaw.Tools.ManageWebApp Extends InterClaw.Tools.Base
{

Parameter ToolName = "manage_webapp";

Parameter ToolDescription = "Manage IRIS CSP web applications (Security.Applications). Actions: list, get (requires name), create (name + namespace + optional dispatch for REST or wsgi settings), delete (requires name). Runs in %SYS.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""action"":{""type"":""string"",""enum"":[""list"",""get"",""create"",""delete""]},""name"":{""type"":""string"",""description"":""Web app path, e.g. /myapp""},""namespace"":{""type"":""string""},""type"":{""type"":""string"",""enum"":[""csp"",""rest"",""wsgi""],""description"":""For create: csp (static + CSP files), rest (dispatch class), wsgi (Python)""},""dispatch"":{""type"":""string"",""description"":""For type=rest: dispatch class name, e.g. Demo.REST.Dispatch""},""wsgi_app_location"":{""type"":""string"",""description"":""For type=wsgi: filesystem dir containing the app""},""wsgi_app_name"":{""type"":""string"",""description"":""For type=wsgi: Python module name, no .py""},""wsgi_callable"":{""type"":""string"",""description"":""For type=wsgi: callable, e.g. 'app'""}},""required"":[""action""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set action = $ZConvert(input.%Get("action"), "L")
    Set name = input.%Get("name")

    Try {
        New $namespace
        Set $Namespace = "%SYS"

        If action = "list" {
            Set stmt = ##class(%SQL.Statement).%New()
            Do stmt.%Prepare("SELECT Name, NameSpace, Type, Enabled, DispatchClass FROM Security.Applications ORDER BY Name")
            Set rs = stmt.%Execute()
            Set arr = ##class(%DynamicArray).%New()
            While rs.%Next() {
                Set row = ##class(%DynamicObject).%New()
                Do row.%Set("name", rs.%Get("Name"))
                Do row.%Set("namespace", rs.%Get("NameSpace"))
                Do row.%Set("type", rs.%Get("Type"))
                Do row.%Set("enabled", ''rs.%Get("Enabled"), "boolean")
                Do row.%Set("dispatch", rs.%Get("DispatchClass"))
                Do arr.%Push(row)
            }
            Return arr.%ToJSON()
        }

        If name = "" Return "Error: name is required for action '" _ action _ "'"

        If action = "get" {
            If '##class(Security.Applications).Exists(name) Return "{""found"":false}"
            Set sc = ##class(Security.Applications).Get(name, .props)
            If $$$ISERR(sc) Return "Get failed: " _ $System.Status.GetErrorText(sc)
            Set obj = ##class(%DynamicObject).%New()
            Do obj.%Set("name", name)
            Set k = ""
            For { Set k = $Order(props(k), 1, v) Quit:k=""  Do obj.%Set(k, v) }
            Return obj.%ToJSON()
        }

        If action = "delete" {
            If '##class(Security.Applications).Exists(name) {
                Return "{""ok"":true,""deleted"":false,""message"":""web app not found""}"
            }
            Set sc = ##class(Security.Applications).Delete(name)
            If $$$ISERR(sc) Return "Delete failed: " _ $System.Status.GetErrorText(sc)
            Return "{""ok"":true,""deleted"":true}"
        }

        If action = "create" {
            Set ns = $ZConvert(input.%Get("namespace"), "U")
            Set type = $ZConvert(input.%Get("type"), "L")
            If ns = "" Return "Error: namespace is required for create"
            If '##class(%SYS.Namespace).Exists(ns) Return "Error: namespace " _ ns _ " does not exist"
            If ##class(Security.Applications).Exists(name) {
                Return "{""ok"":true,""created"":false,""message"":""web app already exists""}"
            }
            Kill props
            Set props("NameSpace") = ns
            Set props("Enabled") = 1
            Set props("AutheEnabled") = 64         // Password auth by default
            If type = "rest" {
                Set dispatch = input.%Get("dispatch")
                If dispatch = "" Return "Error: dispatch is required for type=rest"
                Set props("DispatchClass") = dispatch
                Set props("MatchRoles") = ":%All"
            } ElseIf type = "wsgi" {
                Set appLoc = input.%Get("wsgi_app_location")
                Set appName = input.%Get("wsgi_app_name")
                Set callable = input.%Get("wsgi_callable")
                If (appLoc = "") || (appName = "") {
                    Return "Error: wsgi_app_location and wsgi_app_name required for type=wsgi"
                }
                Set props("WSGIAppLocation") = appLoc
                Set props("WSGIAppName") = appName
                Set props("WSGICallable") = $Select(callable '= "": callable, 1: "app")
                Set props("DispatchClass") = "%SYS.Python.WSGIDispatcher"
            } Else {
                // Plain CSP app — serves static + .csp from a filesystem path.
                Set props("Path") = "/csp/" _ $ZConvert(ns, "L") _ "/"
                Set props("ServeFiles") = 1
                Set props("Recurse") = 1
            }
            Set sc = ##class(Security.Applications).Create(name, .props)
            If $$$ISERR(sc) Return "Create failed: " _ $System.Status.GetErrorText(sc)
            Return "{""ok"":true,""created"":true,""name"":""" _ name _ """}"
        }

        Return "Error: unknown action '" _ action _ "'"
    } Catch ex {
        Return "Tool error: " _ ex.DisplayString()
    }
}

}
