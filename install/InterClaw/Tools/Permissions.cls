/// Tool permission context — deny-list with optional prefix matching.
/// Mirrors claw-code's ToolPermissionContext: block(tool_name) returns 1
/// if the tool is denied, 0 otherwise. Used by Tools.Registry when
/// assembling the tool descriptor JSON and by Tools.Base.Execute to
/// short-circuit calls if the model tries to invoke a blocked tool anyway.
Class InterClaw.Tools.Permissions Extends %RegisteredObject
{

/// Build a context from a session. Reads state via SQL (not the ORM) so the
/// BP sees mutations committed by tool BOs that ran in a different job /
/// transaction. Returns a %DynamicObject with denyNames (lowercase set),
/// denyPrefixes (lowercase array), bypass (0/1).
ClassMethod Context(session As InterClaw.Session) As %DynamicObject
{
    Set ctx = ##class(%DynamicObject).%New()
    Set bypass = 0, rawNames = "", rawPrefixes = ""
    If $IsObject(session) {
        Set sid = session.SessionId
        // Read from the out-of-band globals that EnterPlanMode / ExitPlanMode
        // write to. These bypass ORM / transaction isolation — a different
        // job's global Set is visible immediately here, which %Persistent
        // properties are not inside an open BP transaction.
        Set bypass = +$Get(^InterClaw.SessionPerm(sid, "bypass"), 0)
        Set rawNames = $Get(^InterClaw.SessionPerm(sid, "deny"), "")
        Set rawPrefixes = $Get(^InterClaw.SessionPerm(sid, "denyPrefixes"), "")
    }
    Do ctx.%Set("bypass", (bypass = 1), "boolean")

    Set names = ##class(%DynamicObject).%New()
    Set prefixes = ##class(%DynamicArray).%New()
    If 1 {
        If rawNames '= "" {
            For i = 1:1:$Length(rawNames, ",") {
                Set n = $ZStrip($Piece(rawNames, ",", i), "<>W")
                If n '= "" Do names.%Set($ZConvert(n, "L"), 1, "boolean")
            }
        }
        If rawPrefixes '= "" {
            For i = 1:1:$Length(rawPrefixes, ",") {
                Set p = $ZStrip($Piece(rawPrefixes, ",", i), "<>W")
                If p '= "" Do prefixes.%Push($ZConvert(p, "L"))
            }
        }
    }
    Do ctx.%Set("denyNames", names)
    Do ctx.%Set("denyPrefixes", prefixes)
    Return ctx
}

/// Return 1 if the tool is blocked by the context.
ClassMethod Blocks(ctx As %DynamicObject, toolName As %String) As %Boolean
{
    If '$IsObject(ctx) Return 0
    If ctx.%Get("bypass") Return 0
    Set lower = $ZConvert(toolName, "L")
    Set names = ctx.%Get("denyNames")
    If $IsObject(names) {
        If names.%IsDefined(lower) Return 1
    }
    Set prefixes = ctx.%Get("denyPrefixes")
    If $IsObject(prefixes) {
        Set iter = prefixes.%GetIterator()
        While iter.%GetNext(.i, .p) {
            If $Extract(lower, 1, $Length(p)) = p Return 1
        }
    }
    Return 0
}

}
