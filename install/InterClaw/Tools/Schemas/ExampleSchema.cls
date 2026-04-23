/// Example input schema definition
Class InterClaw.Tools.Schemas.ExampleSchema Extends InterClaw.Tools.InputSchema
{

ClassMethod GetSchema() As %DynamicObject
{
    Set props = ##class(%DynamicObject).%New()

    Do props.%Set("mode", ..PropEnum(
        $ListBuild("create", "update", "delete"),
        "Operation mode"
    ))

    Do props.%Set("name", ..PropString("Entity name"))

    Do props.%Set("count", ..PropInteger("Number of items"))

    Set schema = ##class(%DynamicObject).%New()
    Do schema.%Set("type", "object")
    Do schema.%Set("properties", props)
    Do schema.%Set("required", ..Required("mode,name"))

    Return schema
}

}
