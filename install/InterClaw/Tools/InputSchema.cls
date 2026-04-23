/// Base class for tool input schemas.
/// Extend this to define a reusable input schema, then reference it from your tool.
Class InterClaw.Tools.InputSchema Extends %RegisteredObject [ Abstract ]
{

/// Override this to return the JSON Schema as a %DynamicObject
ClassMethod GetSchema() As %DynamicObject
{
    Set schema = ##class(%DynamicObject).%New()
    Do schema.%Set("type", "object")
    Do schema.%Set("properties", ##class(%DynamicObject).%New())
    Return schema
}

/// Return the schema as a JSON string
ClassMethod ToJSON() As %String
{
    Return ..GetSchema().%ToJSON()
}

/// Helper: create string property
ClassMethod PropString(description As %String = "") As %DynamicObject
{
    Set prop = ##class(%DynamicObject).%New()
    Do prop.%Set("type", "string")
    If description '= "" Do prop.%Set("description", description)
    Return prop
}

/// Helper: create enum property
ClassMethod PropEnum(values As %List, description As %String = "") As %DynamicObject
{
    Set arr = ##class(%DynamicArray).%New()
    For i = 1:1:$ListLength(values) {
        Do arr.%Push($List(values, i))
    }
    Set prop = ##class(%DynamicObject).%New()
    Do prop.%Set("type", "string")
    Do prop.%Set("enum", arr)
    If description '= "" Do prop.%Set("description", description)
    Return prop
}

/// Helper: create integer property
ClassMethod PropInteger(description As %String = "") As %DynamicObject
{
    Set prop = ##class(%DynamicObject).%New()
    Do prop.%Set("type", "integer")
    If description '= "" Do prop.%Set("description", description)
    Return prop
}

/// Helper: create boolean property
ClassMethod PropBoolean(description As %String = "") As %DynamicObject
{
    Set prop = ##class(%DynamicObject).%New()
    Do prop.%Set("type", "boolean")
    If description '= "" Do prop.%Set("description", description)
    Return prop
}

/// Helper: create array property
ClassMethod PropArray(itemSchema As %DynamicObject, description As %String = "") As %DynamicObject
{
    Set prop = ##class(%DynamicObject).%New()
    Do prop.%Set("type", "array")
    If $IsObject(itemSchema) Do prop.%Set("items", itemSchema)
    If description '= "" Do prop.%Set("description", description)
    Return prop
}

/// Helper: create required array from comma-separated fields
ClassMethod Required(fields As %String) As %DynamicArray
{
    Set arr = ##class(%DynamicArray).%New()
    For i = 1:1:$Length(fields, ",") {
        Set field = $ZStrip($Piece(fields, ",", i), "<>W")
        If field '= "" Do arr.%Push(field)
    }
    Return arr
}

}
