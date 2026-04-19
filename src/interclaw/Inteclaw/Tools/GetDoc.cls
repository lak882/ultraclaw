/// Read a class definition (source text) from the current namespace.
Class Inteclaw.Tools.GetDoc Extends Inteclaw.Tools.Base
{

Parameter ToolName = "get_doc";

Parameter ToolDescription = "Read a class or routine source from the current namespace. Name example: 'Inteclaw.Tools.RunSQL.cls' or 'MyRoutine.mac'.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""name"":{""type"":""string"",""description"":""Document name with extension (.cls, .mac, .inc)""}},""required"":[""name""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set name = input.%Get("name")
    If name = "" Return "Error: missing name"

    If '##class(%RoutineMgr).Exists(name) Return "Error: document not found: " _ name

    Set doc = ##class(%RoutineMgr).%OpenId(name, , .sc)
    If '$IsObject(doc) Return "Error: " _ $System.Status.GetErrorText(sc)

    Set text = ""
    Set lineCount = doc.Code.Size
    For i = 1:1:lineCount {
        Set text = text _ $Extract(doc.Code.ReadLine(.sc), 1, *) _ $Char(10)
        If lineCount > 1000 && (i > 1000) {
            Set text = text _ "... (truncated at 1000 lines)"
            Quit
        }
    }
    Return text
}

}
