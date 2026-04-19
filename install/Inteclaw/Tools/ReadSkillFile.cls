/// Read a file from the skill repo by relative path. Capped at 40000 chars by default.
Class Inteclaw.Tools.ReadSkillFile Extends Inteclaw.Tools.Base
{

Parameter ToolName = "read_skill_file";

Parameter ToolDescription = "Read a skill reference or command file. Supply the relative path like '.claude/commands/dtl.md' or '.claude/skills/interclaw/dtl/data-transformations.md'.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""path"":{""type"":""string""},""max_chars"":{""type"":""integer""}},""required"":[""path""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set path = input.%Get("path")
    If path = "" Return "Error: missing path"
    Set max = +input.%Get("max_chars")
    If max <= 0 Set max = 40000
    Return ##class(Inteclaw.Skill.Loader).ReadFile(path, max)
}

}
