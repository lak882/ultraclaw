/// Generic exec tool. Runs arbitrary embedded Python in the current namespace
/// with the `iris` module in scope. Captures stdout, stderr, and an optional
/// `result` value bound by the snippet. No timeouts, no sandboxing — intended
/// for agent experiments only. Pairs with SpawnAgent.
Class InterClaw.Tools.Exec Extends InterClaw.Tools.Base
{

Parameter ToolName = "exec";

Parameter ToolDescription = "Run a block of Python inside the IRIS process. The `iris` module is pre-imported. Bind a variable named `result` to return structured data; otherwise stdout is returned. Useful for class CRUD via $System.OBJ, globals access, HL7 schema reads, DTL invocation, etc. Do NOT use this for SQL — use the `run_sql` tool. Calls to `iris.sql.exec` or `iris.sql.prepare` inside exec are rejected.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""code"":{""type"":""string"",""description"":""Python source to run. `iris` is in scope. Bind `result` to a string/number/dict/list for a structured return value.""}},""required"":[""code""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set code = input.%Get("code")
    If code = "" Return "Error: missing code"
    // Refuse SQL-via-exec. Any reach for iris.sql.exec or the bare SQL
    // entry points inside exec should use the typed `run_sql` tool —
    // both for performance and to keep the SQL-dialect quirks (NOT
    // parentheses, %STARTSWITH literal) in one place.
    If ($Find(code, "iris.sql.exec") > 0) || ($Find(code, "iris.sql.prepare") > 0) {
        Return "Error: SQL is not allowed inside `exec`. Use the `run_sql` tool directly — pass the query as {""sql"": ""SELECT ...""}. `run_sql` returns rows already JSON-encoded, handles cursor cleanup, and surfaces IRIS SQL syntax errors with actionable hints."
    }
    Return ..Run(code)
}

ClassMethod Run(code As %String) As %String [ Language = python ]
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
