/// Generic exec tool. Runs a block of ObjectScript (default) or Python in
/// the current namespace. For ObjectScript, set %result for a structured
/// return value. For Python, the `iris` module is pre-imported and a
/// `result` variable is returned if bound. SQL through either path is
/// rejected — use `run_sql` instead.
Class InterClaw.Tools.Exec Extends InterClaw.Tools.Base
{

Parameter ToolName = "exec";

Parameter ToolDescription = "Run a block of ObjectScript (default) or Python in the current IRIS namespace. ObjectScript is the default and the preferred way to call IRIS APIs ($System.OBJ, ##class(...), global access). Bind `%result` to a string/number/object for the return value. Use language=""python"" only when Python-specific libraries are needed — `iris` is pre-imported and you can bind a `result` variable. SQL is rejected in both modes — call `run_sql` for queries.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""code"":{""type"":""string"",""description"":""ObjectScript (default) or Python source. See `language`. For ObjectScript: set `%result` for the return value. For Python: bind `result`.""},""language"":{""type"":""string"",""enum"":[""objectscript"",""python""],""default"":""objectscript"",""description"":""Source language. Defaults to objectscript; pass python only when Python-specific code is required.""}},""required"":[""code""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set code = input.%Get("code")
    If code = "" Return "Error: missing code"
    Set lang = $ZConvert(input.%Get("language"), "L")
    If lang = "" Set lang = "objectscript"
    If (lang = "os") || (lang = "cos") || (lang = "mumps") Set lang = "objectscript"
    If (lang = "py") Set lang = "python"

    // Block SQL in either mode — run_sql is the right tool.
    If (lang = "python") && (($Find(code, "iris.sql.exec") > 0) || ($Find(code, "iris.sql.prepare") > 0)) {
        Return "Error: SQL is not allowed inside `exec`. Use the `run_sql` tool directly."
    }
    // ObjectScript SQL check: flag embedded SQL / %SQL.Statement patterns.
    If (lang = "objectscript") && (($Find(code, "&sql(") > 0) || ($Find(code, "%SQL.Statement") > 0)) {
        Return "Error: SQL is not allowed inside `exec`. Use the `run_sql` tool directly."
    }

    If lang = "python" Return ..RunPython(code)
    If lang = "objectscript" Return ..RunObjectScript(code)
    Return "Error: unknown language '" _ lang _ "'. Use 'objectscript' or 'python'."
}

/// Run ObjectScript code under XECUTE. Errors are caught and returned.
/// Set %result in the snippet to return structured data; otherwise the
/// call returns "(ok, no output)".
ClassMethod RunObjectScript(code As %String) As %String
{
    // Runs `code` under XECUTE. Errors are caught and returned as text.
    // `write` output is NOT captured — use `%result` for structured data.
    // For quick scalar reports without a variable, concatenate values
    // into %result manually: Set %result = "name="_n_" count="_c
    Kill %result
    Set err = ""
    Try {
        Xecute code
    } Catch ex {
        Set err = ex.Name _ " at " _ ex.Location _ ": " _ ex.DisplayString()
    }

    Set parts = ""
    If $Data(%result) {
        Set parts = parts _ "%result:" _ $Char(10) _ ..ValueToJSON(%result) _ $Char(10, 10)
    }
    If err '= "" Set parts = parts _ "error:" _ $Char(10) _ err _ $Char(10)
    If parts = "" Return "(ok, no output)"
    Return $ZStrip(parts, ">W")
}

/// Convert a local variable value to a JSON-ish string. If the value is
/// a DynamicObject/Array, use %ToJSON. Otherwise stringify.
ClassMethod ValueToJSON(value) As %String
{
    If $IsObject(value) {
        Try { Return value.%ToJSON() }
        Catch ex { Return "(unserializable object: " _ ex.DisplayString() _ ")" }
    }
    // Numeric? return unquoted.
    If value '= "", value = +value Return ""_value
    // Boolean? treat canonical forms as unquoted.
    If (value = "true") || (value = "false") Return value
    // String — JSON-escape and quote.
    Set escaped = value
    Set escaped = $Replace(escaped, "\", "\\")
    Set escaped = $Replace(escaped, """", "\""")
    Set escaped = $Replace(escaped, $Char(10), "\n")
    Set escaped = $Replace(escaped, $Char(13), "\r")
    Set escaped = $Replace(escaped, $Char(9), "\t")
    Return """" _ escaped _ """"
}

ClassMethod RunPython(code As %String) As %String [ Language = python ]
{
    import io, json, traceback, contextlib
    try:
        import iris
    except Exception:
        iris = None

    buf_out = io.StringIO()
    buf_err = io.StringIO()
    ns = {"iris": iris, "__name__": "__exec__"}
    try:
        with contextlib.redirect_stdout(buf_out), contextlib.redirect_stderr(buf_err):
            exec(compile(str(code), "<exec>", "exec"), ns)
    except SystemExit:
        pass
    except Exception:
        err = buf_err.getvalue() + traceback.format_exc()
        out = buf_out.getvalue()
        parts = []
        if out:
            parts.append("stdout:\n" + out.rstrip())
        parts.append("error:\n" + err.rstrip())
        return "\n\n".join(parts)

    stdout = buf_out.getvalue()
    stderr = buf_err.getvalue()
    result = ns.get("result", None)

    parts = []
    if result is not None:
        try:
            parts.append("result:\n" + json.dumps(result, default=str, indent=2))
        except Exception:
            parts.append("result:\n" + repr(result))
    if stdout:
        parts.append("stdout:\n" + stdout.rstrip())
    if stderr:
        parts.append("stderr:\n" + stderr.rstrip())
    if not parts:
        return "(ok, no output)"
    return "\n\n".join(parts)
}

}
