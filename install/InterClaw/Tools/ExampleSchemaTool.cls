/// Example tool demonstrating SchemaBase usage.
/// Instead of hardcoding ToolInputSchema JSON, override DefineSchema().
Class InterClaw.Tools.ExampleSchemaTool Extends InterClaw.Tools.SchemaBase
{

Parameter ToolName = "example_schema";

Parameter ToolDescription = "Example tool showing how to use SchemaBase for declarative input schema definition";

/// Define the input schema programmatically
ClassMethod DefineSchema() As %DynamicObject
{
    // Build properties
    Set props = ##class(%DynamicObject).%New()

    // mode: enum string (required)
    Do props.%Set("mode", ..PropEnum(
        $ListBuild("create", "update", "delete"),
        "Operation mode"
    ))

    // name: string (required)
    Do props.%Set("name", ..PropString("Name of the entity to operate on"))

    // count: integer (optional)
    Do props.%Set("count", ..PropInteger("Number of items to process"))

    // enabled: boolean (optional)
    Do props.%Set("enabled", ..PropBoolean("Whether the entity should be enabled"))

    // tags: array of strings (optional)
    Do props.%Set("tags", ..PropArray(
        ..PropString("Tag value"),
        "List of tags to apply"
    ))

    // Build schema
    Set schema = ##class(%DynamicObject).%New()
    Do schema.%Set("type", "object")
    Do schema.%Set("properties", props)
    Do schema.%Set("required", ..Required("mode,name"))

    Return schema
}

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set mode = input.%Get("mode")
    Set name = input.%Get("name")
    Set count = input.%Get("count")
    Set enabled = input.%Get("enabled")

    Return "Example: " _ mode _ " " _ name _ " (count=" _ count _ ", enabled=" _ enabled _ ")"
}

}
