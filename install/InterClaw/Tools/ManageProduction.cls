/// Start, stop, update, or check the Ensemble production in this namespace.
/// Wraps Ens.Director calls so the model doesn't have to emit raw exec.
Class InterClaw.Tools.ManageProduction Extends InterClaw.Tools.Base
{

Parameter ToolName = "manage_production";

Parameter ToolDescription = "Control the Ensemble production in the current namespace. Actions: start (requires production name), stop, restart, update (reapply config to a running production), status. `status` is a richer alternative to the `production_status` tool.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""action"":{""type"":""string"",""enum"":[""start"",""stop"",""restart"",""update"",""status""]},""production"":{""type"":""string"",""description"":""Production class name — required for start/restart when no production is running""},""timeout"":{""type"":""integer"",""default"":30,""description"":""Seconds to wait for start/stop""}},""required"":[""action""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set action = $ZConvert(input.%Get("action"), "L")
    Set prod = input.%Get("production")
    Set timeout = +input.%Get("timeout")
    If timeout < 1 Set timeout = 30

    Set resp = ##class(%DynamicObject).%New()
    Do resp.%Set("action", action)

    Try {
        If action = "status" {
            Set sc = ##class(Ens.Director).GetProductionStatus(.name, .state)
            Do resp.%Set("production", $Get(name))
            Do resp.%Set("state_code", +$Get(state), "number")
            Do resp.%Set("state", ..StateName(+$Get(state)))
            Do resp.%Set("ok", $$$ISOK(sc), "boolean")
            If $$$ISERR(sc) Do resp.%Set("error", $System.Status.GetErrorText(sc))
            Return resp.%ToJSON()
        }

        If action = "stop" {
            Set sc = ##class(Ens.Director).StopProduction(timeout)
            Do ..Finish(resp, sc)
            Return resp.%ToJSON()
        }

        If action = "restart" {
            Set sc = ##class(Ens.Director).RestartProduction(timeout)
            If $$$ISERR(sc), prod '= "" {
                // RestartProduction fails if nothing is running — fall back to start.
                Set sc = ##class(Ens.Director).StartProduction(prod)
            }
            Do ..Finish(resp, sc)
            Return resp.%ToJSON()
        }

        If action = "update" {
            Set sc = ##class(Ens.Director).UpdateProduction(timeout)
            Do ..Finish(resp, sc)
            Return resp.%ToJSON()
        }

        If action = "start" {
            If prod = "" Return "Error: start requires a production class name"
            // If something else is running, stop it first.
            Do ##class(Ens.Director).GetProductionStatus(.running, .state)
            If (+$Get(state) = 1) && ($Get(running) '= prod) {
                Do ##class(Ens.Director).StopProduction(timeout, 1)
            }
            Set sc = ##class(Ens.Director).StartProduction(prod)
            Do ..Finish(resp, sc)
            Do resp.%Set("production", prod)
            Return resp.%ToJSON()
        }

        Return "Error: unknown action '" _ action _ "'"
    } Catch ex {
        Do resp.%Set("ok", 0, "boolean")
        Do resp.%Set("error", ex.DisplayString())
        Return resp.%ToJSON()
    }
}

ClassMethod Finish(resp As %DynamicObject, sc As %Status)
{
    Do resp.%Set("ok", $$$ISOK(sc), "boolean")
    If $$$ISERR(sc) Do resp.%Set("error", $System.Status.GetErrorText(sc))
    // Include the resulting status so the caller sees the effect immediately.
    Do ##class(Ens.Director).GetProductionStatus(.name, .state)
    Do resp.%Set("production", $Get(name))
    Do resp.%Set("state_code", +$Get(state), "number")
    Do resp.%Set("state", ..StateName(+$Get(state)))
}

ClassMethod StateName(code As %Integer) As %String
{
    Return $Case(code, 0:"stopped", 1:"running", 2:"suspended", 3:"troubled", 4:"network_stopped", 5:"unknown", :"code" _ code)
}

}
