/// Execute arbitrary ObjectScript code using XECUTE.
/// Simple wrapper around the XECUTE command - runs whatever code you give it.
Class InterClaw.Tools.ExecNamespace Extends InterClaw.Tools.Base
{

Parameter ToolName = "execute";

Parameter ToolDescription = "Execute arbitrary ObjectScript code using XECUTE. Can run any ObjectScript including namespace switching, method calls, global access, etc. Set %result to return structured data.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""code"":{""type"":""string"",""description"":""ObjectScript code to execute. Use Set $Namespace=... to switch namespaces. Set %result for return value.""}},""required"":[""code""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set code = input.%Get("code")

    If code = "" Return "Error: code parameter is required"

    // Execute the code
    Kill %result
    Set err = ""
    Try {
        Xecute code
    }
    Catch ex {
        Set err = ex.Name _ " at " _ ex.Location _ ": " _ ex.DisplayString()
    }

    // Build response
    Set parts = ""
    If $Data(%result) {
        Set parts = parts _ "%result:" _ $Char(10) _ ..ValueToJSON(%result) _ $Char(10, 10)
    }
    If err '= "" Set parts = parts _ "error:" _ $Char(10) _ err _ $Char(10)
    If parts = "" Return "(ok, no output)"
    Return $ZStrip(parts, ">W")
}

/// Convert a local variable value to JSON string
ClassMethod ValueToJSON(value) As %String
{
    If $IsObject(value) {
        Try { Return value.%ToJSON() }
        Catch ex { Return "(unserializable object: " _ ex.DisplayString() _ ")" }
    }
    // Numeric? return unquoted
    If value '= "", value = +value Return ""_value
    // Boolean?
    If (value = "true") || (value = "false") Return value
    // String - JSON-escape and quote
    Set escaped = value
    Set escaped = $Replace(escaped, "\", "\\")
    Set escaped = $Replace(escaped, """", "\""")
    Set escaped = $Replace(escaped, $Char(10), "\n")
    Set escaped = $Replace(escaped, $Char(13), "\r")
    Set escaped = $Replace(escaped, $Char(9), "\t")
    Return """" _ escaped _ """"
}

}
