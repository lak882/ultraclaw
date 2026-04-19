/// Native HL7 schema introspection. Reads ^EnsHL7.Schema globals directly -
/// no Atelier HTTP round-trip, no XML parse.
Class Inteclaw.Tools.GetSchema Extends Inteclaw.Tools.Base
{

Parameter ToolName = "get_schema";

Parameter ToolDescription = "Inspect an HL7 schema. Modes: list_categories; list_messages (requires category); list_segments (requires category); message (requires category + message, e.g. '2.5.1','ORU_R01'); segment_fields (requires category + segment, e.g. '2.5.1','OBR').";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""mode"":{""type"":""string"",""enum"":[""list_categories"",""list_messages"",""list_segments"",""message"",""segment_fields""]},""category"":{""type"":""string""},""message"":{""type"":""string""},""segment"":{""type"":""string""}},""required"":[""mode""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set mode = input.%Get("mode")
    Set cat = input.%Get("category")
    Set msg = input.%Get("message")
    Set seg = input.%Get("segment")

    If mode = "list_categories" Return ..ListCategories()
    If mode = "list_messages" Return ..ListMessages(cat)
    If mode = "list_segments" Return ..ListSegments(cat)
    If mode = "message" Return ..MessageStructure(cat, msg)
    If mode = "segment_fields" Return ..SegmentFields(cat, seg)
    Return "Error: unknown mode " _ mode
}

ClassMethod ListCategories() As %String
{
    Set out = ""
    Set n = ""
    For { Set n = $Order(^EnsHL7.Schema(n)) Quit:n=""  Set out = out _ n _ $Char(10) }
    If out = "" Return "(no schemas loaded)"
    Return out
}

ClassMethod ListMessages(cat As %String) As %String
{
    If cat = "" Return "Error: category required"
    Set out = ""
    Set name = ""
    For {
        Set name = $Order(^EnsHL7.Schema(cat, "MS", name))
        Quit:name=""
        Set desc = $Get(^EnsHL7.Schema(cat, "MT", name))
        Set out = out _ name _ $Case(desc, "":"", :" - " _ $Piece(desc, "|", 1)) _ $Char(10)
    }
    If out = "" Return "(no messages for category " _ cat _ ")"
    Return out
}

ClassMethod ListSegments(cat As %String) As %String
{
    If cat = "" Return "Error: category required"
    Set out = ""
    Set name = ""
    For {
        Set name = $Order(^EnsHL7.Schema(cat, "SS", name))
        Quit:name=""
        Set out = out _ name _ $Char(10)
    }
    If out = "" Return "(no segments for category " _ cat _ ")"
    Return out
}

ClassMethod MessageStructure(cat As %String, msg As %String) As %String
{
    If (cat = "") || (msg = "") Return "Error: category and message required"
    Kill arr
    Set sc = ##class(EnsLib.HL7.Schema).GetContentArray(.arr, "source", cat _ ":" _ msg, 1, 1)
    If $$$ISERR(sc) Return "Error: " _ $System.Status.GetErrorText(sc)
    If '$Data(arr) Return "Error: structure not found: " _ cat _ ":" _ msg

    Set out = cat _ ":" _ msg _ $Char(10)
    Do ..WalkStructure(.arr, 0, .out)
    Return out
}

ClassMethod WalkStructure(ByRef node, depth As %Integer, ByRef out As %String)
{
    Set indent = $Justify("", depth * 2)
    Set count = +$Get(node)
    If count = 0 Quit
    For i = 1:1:count {
        Set name = $Get(node(i, "name"))
        Set type = $Get(node(i, "type"))
        Set opt = $Get(node(i, "opt"))
        If name '= "" {
            Set marker = $Case(opt, 1:"[opt] ", :"")
            Set out = out _ indent _ marker _ name _ $Char(10)
        }
        If +$Get(node(i)) > 0 {
            Kill child
            Merge child = node(i)
            Do ..WalkStructure(.child, depth + 1, .out)
        }
    }
}

ClassMethod SegmentFields(cat As %String, seg As %String) As %String
{
    If (cat = "") || (seg = "") Return "Error: category and segment required"
    If '$Data(^EnsHL7.Schema(cat, "SS", seg)) Return "Error: segment not found: " _ cat _ ":" _ seg

    Set list = ^EnsHL7.Schema(cat, "SS", seg)
    Set count = $ListLength(list)

    // Build index -> name map from the "names" subnode
    Kill idxToName
    Set n = ""
    For {
        Set n = $Order(^EnsHL7.Schema(cat, "SS", seg, "names", n))
        Quit:n=""
        Set idxToName($Get(^EnsHL7.Schema(cat, "SS", seg, "names", n))) = n
    }

    Set out = cat _ ":" _ seg _ $Char(10)
    For i = 1:1:count {
        Set item = $List(list, i)
        If $ListValid(item) {
            Set dtype = $List(item, 1)
            Set rep = $List(item, 2)
            Set maxLen = $List(item, 4)
            Set opt = $List(item, 5)
            Set isRep = $List(item, 6)
        } Else {
            Continue
        }
        Set fieldName = $Get(idxToName(i), "(unnamed)")
        Set repMarker = $Case(isRep, 1:"[]", :"")
        Set optMarker = $Case(opt, "R":" required", :"")
        Set out = out _ seg _ "-" _ i _ repMarker _ "  " _ fieldName _ "  [" _ $Piece(dtype, ":", 2, *) _ "]  maxLen=" _ maxLen _ optMarker _ $Char(10)
    }
    Return out
}

}
