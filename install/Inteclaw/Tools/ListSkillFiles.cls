/// Browse the skill repo tree. Returns a JSON object { path, entries:[{name,is_dir,size}] }.
Class Inteclaw.Tools.ListSkillFiles Extends Inteclaw.Tools.Base
{

Parameter ToolName = "list_skill_files";

Parameter ToolDescription = "List files and subdirectories under the Inteclaw skill repo. Supply a relative path like '.claude/skills/interclaw/dtl' or leave empty for the project root.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""path"":{""type"":""string"",""description"":""Relative path from project root; empty string for root""}},""required"":[]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set path = input.%Get("path")
    If path = "" Set path = ""
    Return ##class(Inteclaw.Skill.Loader).ListFiles(path)
}

}
