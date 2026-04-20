/// Compile one or more classes. Thin wrapper over $System.OBJ.Compile.
Class InterClaw.Tools.CompileClass Extends InterClaw.Tools.Base
{

Parameter ToolName = "compile_class";

Parameter ToolDescription = "Compile a class by name (e.g. 'Demo.DTL.ORUToORU'). Use comma-separated names to compile several at once.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""names"":{""type"":""string"",""description"":""Class name, or comma-separated list""}},""required"":[""names""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set names = input.%Get("names")
    If names = "" Return "Error: missing names"

    Set sc = $System.OBJ.Compile(names, "ck-d", .err)
    If $$$ISERR(sc) {
        Return "Compile failed: " _ $System.Status.GetErrorText(sc)
    }
    Return "Compiled: " _ names
}

}
