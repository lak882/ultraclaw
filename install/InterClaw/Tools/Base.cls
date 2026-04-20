/// Base class for all InterClaw tools.
/// Subclasses must override the Name, Description, InputSchema parameters
/// and implement the Execute() classmethod. %Dictionary discovery picks them
/// up at runtime — no central registry file to maintain.
Class InterClaw.Tools.Base Extends %RegisteredObject [ Abstract ]
{

/// Unique tool name exposed to the LLM.
Parameter ToolName As STRING = "";

/// One-line description for the LLM.
Parameter ToolDescription As STRING = "";

/// JSON string of the tool's input schema (Anthropic tool format).
Parameter ToolInputSchema As STRING = "{""type"":""object"",""properties"":{}}";

/// Execute the tool. Return a string (shown to the LLM as tool result).
/// Throw or return a %Status error to signal tool error.
ClassMethod Execute(inputJSON As %String) As %String [ Abstract ]
{
}

/// Return the tool descriptor as a %DynamicObject for the Anthropic API.
ClassMethod Descriptor() As %DynamicObject
{
    Set obj = ##class(%DynamicObject).%New()
    Do obj.%Set("name", ..#ToolName)
    Do obj.%Set("description", ..#ToolDescription)
    Do obj.%Set("input_schema", ##class(%DynamicObject).%FromJSON(..#ToolInputSchema))
    Return obj
}

}
