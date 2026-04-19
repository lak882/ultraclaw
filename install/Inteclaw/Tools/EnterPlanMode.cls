/// Enter plan mode. While plan mode is on, write-family tools (put_class,
/// compile_class, exec, spawn_agent) are blocked and return a plan-mode
/// notice instead of running. Read-family tools stay available so the model
/// can keep researching. Mirrors Claude Code's EnterPlanModeTool.
Class Inteclaw.Tools.EnterPlanMode Extends Inteclaw.Tools.Base
{

Parameter ToolName = "enter_plan_mode";

Parameter ToolDescription = "Enter plan mode for the current session. While in plan mode, write/compile/exec tools are blocked — only read tools (get_schema, get_doc, list_docs, run_sql, list_skill_files, read_skill_file, production_status, echo) run. Use plan mode to propose a multi-step plan before making changes. Call exit_plan_mode to resume normal execution.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""session_id"":{""type"":""string"",""description"":""Session to flip into plan mode (optional; defaults to the current one).""},""plan"":{""type"":""string"",""description"":""Optional plan summary recorded for the user to approve.""}}}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set sid = input.%Get("session_id")
    If sid = "" Set sid = $Get(%InteclawSessionId)
    If sid = "" Return "Error: no session id available to toggle plan mode"
    // Out-of-band globals so the BP sees the new state immediately even if
    // it is holding an open transaction / cached %Persistent object.
    Set ^Inteclaw.SessionPerm(sid, "deny") = "put_class,compile_class,exec,spawn_agent,test_dtl"
    Set ^Inteclaw.SessionPerm(sid, "plan") = 1
    Set plan = input.%Get("plan")
    Set out = "Plan mode ENABLED for session " _ sid _ "." _ $Char(10)
    Set out = out _ "Blocked tools: put_class, compile_class, exec, spawn_agent, test_dtl." _ $Char(10)
    Set out = out _ "Read tools remain available. Call exit_plan_mode when ready to execute."
    If plan '= "" Set out = out _ $Char(10, 10) _ "Plan recorded:" _ $Char(10) _ plan
    Return out
}

}
