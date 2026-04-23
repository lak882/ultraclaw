/// Helper for building Anthropic tool input schemas.
/// Provides methods to construct JSON Schema objects without manual string assembly.
Class InterClaw.Tools.SchemaBuilder Extends %RegisteredObject
{

/// Build a basic object schema with properties and required fields.
ClassMethod Object(properties As %DynamicObject, required As %DynamicArray = "") As %String
{
    Set schema = ##class(%DynamicObject).%New()
    Do schema.%Set("type", "object")
    Do schema.%Set("properties", properties)
    If $IsObject(required) && (required.%Size() > 0) {
        Do schema.%Set("required", required)
    }
    Return schema.%ToJSON()
}

/// Create a string property definition.
ClassMethod String(description As %String = "", enum As %DynamicArray = "") As %DynamicObject
{
    Set prop = ##class(%DynamicObject).%New()
    Do prop.%Set("type", "string")
    If description '= "" Do prop.%Set("description", description)
    If $IsObject(enum) && (enum.%Size() > 0) {
        Do prop.%Set("enum", enum)
    }
    Return prop
}

/// Create an integer property definition.
ClassMethod Integer(description As %String = "") As %DynamicObject
{
    Set prop = ##class(%DynamicObject).%New()
    Do prop.%Set("type", "integer")
    If description '= "" Do prop.%Set("description", description)
    Return prop
}

/// Create a boolean property definition.
ClassMethod Boolean(description As %String = "") As %DynamicObject
{
    Set prop = ##class(%DynamicObject).%New()
    Do prop.%Set("type", "boolean")
    If description '= "" Do prop.%Set("description", description)
    Return prop
}

/// Create an array property definition.
ClassMethod Array(itemType As %DynamicObject, description As %String = "") As %DynamicObject
{
    Set prop = ##class(%DynamicObject).%New()
    Do prop.%Set("type", "array")
    If $IsObject(itemType) Do prop.%Set("items", itemType)
    If description '= "" Do prop.%Set("description", description)
    Return prop
}

/// Create an enum property (string with allowed values).
ClassMethod Enum(values As %List, description As %String = "") As %DynamicObject
{
    Set arr = ##class(%DynamicArray).%New()
    Set len = $ListLength(values)
    For i = 1:1:len {
        Do arr.%Push($List(values, i))
    }
    Return ..String(description, arr)
}

/// Create a required fields array from a comma-separated list.
ClassMethod Required(fieldNames As %String) As %DynamicArray
{
    Set arr = ##class(%DynamicArray).%New()
    For i = 1:1:$Length(fieldNames, ",") {
        Set field = $ZStrip($Piece(fieldNames, ",", i), "<>W")
        If field '= "" Do arr.%Push(field)
    }
    Return arr
}

/// Build properties object from a structured array of (name, type, description, enum).
/// Example: ..BuildProperties($ListBuild(
///     $ListBuild("mode", "string", "Operation mode", "list,create"),
///     $ListBuild("name", "string", "Entity name", ""),
///     $ListBuild("count", "integer", "Number of items", "")
/// ))
ClassMethod BuildProperties(specs As %List) As %DynamicObject
{
    Set props = ##class(%DynamicObject).%New()
    Set len = $ListLength(specs)
    For i = 1:1:len {
        Set spec = $List(specs, i)
        Set name = $List(spec, 1)
        Set type = $List(spec, 2)
        Set desc = $List(spec, 3)
        Set enumValues = $List(spec, 4)

        If name = "" Continue
        Set prop = ""

        If type = "string" {
            If enumValues '= "" {
                Set prop = ..Enum($ListFromString(enumValues, ","), desc)
            } Else {
                Set prop = ..String(desc)
            }
        }
        ElseIf type = "integer" {
            Set prop = ..Integer(desc)
        }
        ElseIf type = "boolean" {
            Set prop = ..Boolean(desc)
        }

        If $IsObject(prop) {
            Do props.%Set(name, prop)
        }
    }
    Return props
}

}
