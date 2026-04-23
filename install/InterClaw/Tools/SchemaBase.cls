/// Base class for tools with declarative input schema definition.
/// Instead of hardcoding ToolInputSchema JSON, override DefineSchema() to
/// build the schema programmatically.
Class InterClaw.Tools.SchemaBase Extends InterClaw.Tools.Base [ Abstract ]
{

/// Override this method to define your tool's input schema.
/// Return a %DynamicObject representing the JSON Schema.
ClassMethod DefineSchema() As %DynamicObject
{
    // Default: empty object schema
    Set schema = ##class(%DynamicObject).%New()
    Do schema.%Set("type", "object")
    Do schema.%Set("properties", ##class(%DynamicObject).%New())
    Return schema
}

/// Auto-generate ToolInputSchema from DefineSchema().
/// Subclasses do not need to set the ToolInputSchema parameter.
Parameter ToolInputSchema;

ClassMethod GetInputSchema() As %String
{
    Set schema = ..DefineSchema()
    If '$IsObject(schema) {
        Return "{""type"":""object"",""properties"":{}}"
    }
    Return schema.%ToJSON()
}

/// Override Descriptor to use DefineSchema() instead of the parameter.
ClassMethod Descriptor() As %DynamicObject
{
    Set obj = ##class(%DynamicObject).%New()
    Do obj.%Set("name", ..#ToolName)
    Do obj.%Set("description", ..#ToolDescription)
    Set schemaJSON = ..GetInputSchema()
    Do obj.%Set("input_schema", ##class(%DynamicObject).%FromJSON(schemaJSON))
    Return obj
}

/// Helper: create string property
ClassMethod PropString(description As %String = "") As %DynamicObject
{
    Set prop = ##class(%DynamicObject).%New()
    Do prop.%Set("type", "string")
    If description '= "" Do prop.%Set("description", description)
    Return prop
}

/// Helper: create enum property (string with allowed values)
ClassMethod PropEnum(values As %List, description As %String = "") As %DynamicObject
{
    Set arr = ##class(%DynamicArray).%New()
    Set len = $ListLength(values)
    For i = 1:1:len {
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

/// Helper: create required fields array from comma-separated string
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
