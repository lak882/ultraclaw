/// Create or update a class in the current namespace by importing UDL source
/// directly via $System.OBJ.LoadStream. No Atelier HTTP round-trip.
Class InterClaw.Tools.PutClass Extends InterClaw.Tools.Base
{

Parameter ToolName = "put_class";

Parameter ToolDescription = "Create or update a class from UDL source text. Pass the full class definition (starting with 'Class Name.Space Extends ...'). Set compile=true (default) to compile after load.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""source"":{""type"":""string"",""description"":""Full UDL source including 'Class ... Extends ...' header""},""compile"":{""type"":""boolean"",""default"":true}},""required"":[""source""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set source = input.%Get("source")
    If source = "" Return "Error: missing source"
    Set doCompile = 1
    If input.%IsDefined("compile"), input.%Get("compile") = 0 Set doCompile = 0

    Set stream = ##class(%Stream.GlobalCharacter).%New()
    Do stream.Write(source)

    // Extract class name for reporting
    Set className = ""
    Set lineNum = 1
    For i = 1:1:$Length(source, $Char(10)) {
        Set line = $Piece(source, $Char(10), i)
        If $$$UPPER($Extract(line, 1, 6)) = "CLASS " {
            Set rest = $Piece(line, " ", 2)
            Set className = rest
            Quit
        }
    }
    If className = "" Return "Error: could not find 'Class <Name>' header in source"

    Set qualifiers = "-d"
    If doCompile Set qualifiers = "ck" _ qualifiers

    Set sc = $System.OBJ.LoadStream(stream, qualifiers, .err, .loaded)
    If $$$ISERR(sc) {
        Return "Error loading " _ className _ ": " _ $System.Status.GetErrorText(sc)
    }

    Set result = "Loaded: " _ className
    If doCompile Set result = result _ " (compiled)"
    Return result
}

}
