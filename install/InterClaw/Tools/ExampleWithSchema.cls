/// Example tool using a separate InputSchema class
Class InterClaw.Tools.ExampleWithSchema Extends InterClaw.Tools.Base
{

Parameter ToolName = "example_with_schema";

Parameter ToolDescription = "Example tool that uses a separate schema class";

Parameter ToolInputSchema;

ClassMethod GetInputSchema() As %String
{
    Return ##class(InterClaw.Tools.Schemas.ExampleSchema).ToJSON()
}

/// Override Descriptor to use the schema class
ClassMethod Descriptor() As %DynamicObject
{
    Set obj = ##class(%DynamicObject).%New()
    Do obj.%Set("name", ..#ToolName)
    Do obj.%Set("description", ..#ToolDescription)
    Set schemaJSON = ..GetInputSchema()
    Do obj.%Set("input_schema", ##class(%DynamicObject).%FromJSON(schemaJSON))
    Return obj
}

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set mode = input.%Get("mode")
    Set name = input.%Get("name")
    Set count = input.%Get("count")

    Return "Executed: " _ mode _ " on " _ name _ " (count=" _ count _ ")"
}

}
