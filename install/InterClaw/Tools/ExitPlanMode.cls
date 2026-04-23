/// Exit plan mode and restore the full tool set. Mirrors Claude Code's
/// ExitPlanModeV2Tool.
Class InterClaw.Tools.ExitPlanMode Extends InterClaw.Tools.Base
{

Parameter ToolName = "exit_plan_mode";

Parameter ToolDescription = "Exit plan mode. Clears the plan-mode deny-list on the session so write/compile/exec tools are callable again. Use after the user has approved the plan.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""session_id"":{""type"":""string"",""description"":""Session to flip out of plan mode (optional; defaults to the current one).""}}}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set sid = input.%Get("session_id")
    If sid = "" Set sid = $Get(%InterClawSessionId)
    If sid = "" Return "Error: no session id available to toggle plan mode"
    Kill ^InterClaw.SessionPerm(sid, "deny")
    Kill ^InterClaw.SessionPerm(sid, "plan")
    Return "Plan mode DISABLED for session " _ sid _ ". Full tool set restored."
}

}
