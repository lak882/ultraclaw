/// Tool discovery and dispatch.
/// Uses %Dictionary to find every concrete subclass of Inteclaw.Tools.Base.
Class Inteclaw.Tools.Registry Extends %RegisteredObject
{

/// Return a JSON array of tool descriptors for all discovered tools.
/// If permCtx is supplied, tools blocked by the context are omitted —
/// the model only sees the subset it is permitted to call.
ClassMethod DescriptorsJSON(permCtx As %DynamicObject = "") As %String
{
    Set arr = ##class(%DynamicArray).%New()
    Do ..Discover(.tools)
    Set key = ""
    For {
        Set key = $Order(tools(key), 1, cls)
        Quit:key=""
        If $IsObject(permCtx), ##class(Inteclaw.Tools.Permissions).Blocks(permCtx, key) Continue
        Try {
            Set desc = $ClassMethod(cls, "Descriptor")
            Do arr.%Push(desc)
        } Catch ex { }
    }
    Return arr.%ToJSON()
}

/// Return array of (name -> classname) for all discovered tools.
ClassMethod Discover(Output tools) As %Integer
{
    Kill tools
    Set count = 0
    Set rs = ##class(%SQL.Statement).%ExecDirect(,
        "SELECT ID FROM %Dictionary.ClassDefinition "
        _ "WHERE Super [ 'Inteclaw.Tools.Base' AND Abstract = 0")
    While rs.%Next() {
        Set cls = rs.%Get("ID")
        Try {
            Set name = $Parameter(cls, "ToolName")
            If name '= "" {
                Set tools(name) = cls
                Set count = count + 1
            }
        } Catch ex { }
    }
    Return count
}

/// Resolve a tool name to a class.
ClassMethod Resolve(toolName As %String) As %String
{
    Do ..Discover(.tools)
    Return $Get(tools(toolName), "")
}

/// Execute a tool by name with its JSON input. Returns (outputText, isError).
/// If permCtx is provided and blocks the tool, returns a permission-denied message.
ClassMethod Dispatch(toolName As %String, inputJSON As %String, Output isError As %Boolean, permCtx As %DynamicObject = "") As %String
{
    Set isError = 0
    If $IsObject(permCtx), ##class(Inteclaw.Tools.Permissions).Blocks(permCtx, toolName) {
        Set isError = 1
        Return "Permission denied: tool '" _ toolName _ "' is blocked in this session. Use enter_plan_mode to propose changes, or ask the user to adjust the deny-list."
    }
    Set cls = ..Resolve(toolName)
    If cls = "" {
        Set isError = 1
        Return "Unknown tool: " _ toolName
    }
    Try {
        Return $ClassMethod(cls, "Execute", inputJSON)
    } Catch ex {
        Set isError = 1
        Return "Tool error: " _ ex.DisplayString()
    }
}

}
