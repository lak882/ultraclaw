/// Simple echo tool — useful for round-trip testing of the tool dispatch path.
Class Inteclaw.Tools.Echo Extends Inteclaw.Tools.Base
{

Parameter ToolName = "echo";

Parameter ToolDescription = "Echo back the provided text, useful for verifying the tool pipeline.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""text"":{""type"":""string""}},""required"":[""text""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Return input.%Get("text")
}

}
