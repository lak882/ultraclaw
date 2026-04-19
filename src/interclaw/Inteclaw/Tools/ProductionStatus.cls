/// Return the status of the running production in this namespace.
Class Inteclaw.Tools.ProductionStatus Extends Inteclaw.Tools.Base
{

Parameter ToolName = "production_status";

Parameter ToolDescription = "Get the status of the running IRIS production (name, state, running/stopped).";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{},""required"":[]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
    If $$$ISERR(sc) Return "Error: " _ $System.Status.GetErrorText(sc)
    Set stateName = $Case(prodState,
        1:"Running",
        2:"Stopped",
        3:"Suspended",
        4:"Troubled",
        :"Unknown")
    Set obj = ##class(%DynamicObject).%New()
    Do obj.%Set("name", prodName)
    Do obj.%Set("state", stateName)
    Do obj.%Set("namespace", $Namespace)
    Return obj.%ToJSON()
}

}
