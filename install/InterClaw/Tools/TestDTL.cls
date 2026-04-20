/// Test a DTL transform by invoking it directly on an HL7 message.
/// Takes the transform class name plus the raw HL7 text (segments separated by \r or \n).
/// Returns a unified diff of pre/post segments, plus the full transformed output.
Class InterClaw.Tools.TestDTL Extends InterClaw.Tools.Base
{

Parameter ToolName = "test_dtl";

Parameter ToolDescription = "Test a DTL by transforming an HL7 message in memory. Returns segment-level diff plus full transformed output. No production, no trace, no HTTP.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""dtl"":{""type"":""string"",""description"":""DTL class name, e.g. 'Demo.DTL.ORUToORU'""},""message"":{""type"":""string"",""description"":""Raw HL7 message text""},""source_schema"":{""type"":""string"",""description"":""Optional source DocType override, e.g. '2.5.1:ORU_R01'""}},""required"":[""dtl"",""message""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set dtl = input.%Get("dtl")
    Set msgText = input.%Get("message")
    Set srcSchema = input.%Get("source_schema")

    If dtl = "" Return "Error: missing dtl"
    If msgText = "" Return "Error: missing message"

    // Normalize line endings to CR, which HL7 expects
    Set msgText = $Replace(msgText, $Char(13, 10), $Char(13))
    Set msgText = $Replace(msgText, $Char(10), $Char(13))

    // Build an HL7 message in memory
    Set msg = ##class(EnsLib.HL7.Message).ImportFromString(msgText, .sc)
    If $$$ISERR(sc) Return "Error parsing source: " _ $System.Status.GetErrorText(sc)
    If srcSchema '= "" Set msg.DocType = srcSchema

    // Run the transform
    Set sc = $ClassMethod(dtl, "Transform", msg, .target)
    If $$$ISERR(sc) Return "Error transforming: " _ $System.Status.GetErrorText(sc)
    If '$IsObject(target) Return "Error: transform returned no target"

    // Produce diff
    Set out = "Source segments: " _ msg.SegCount _ $Char(10)
    Set out = out _ "Target segments: " _ target.SegCount _ $Char(10)
    Set out = out _ "Source DocType: " _ msg.DocType _ $Char(10)
    Set out = out _ "Target DocType: " _ target.DocType _ $Char(10) _ $Char(10)
    Set out = out _ "=== DIFF (source -> target) ===" _ $Char(10)

    Set maxSeg = $Select(msg.SegCount > target.SegCount:msg.SegCount, 1:target.SegCount)
    Set changed = 0
    For i = 1:1:maxSeg {
        Set srcSeg = ""
        Set tgtSeg = ""
        If i <= msg.SegCount Set srcSeg = msg.GetSegmentAt(i).OutputToString()
        If i <= target.SegCount Set tgtSeg = target.GetSegmentAt(i).OutputToString()
        If srcSeg '= tgtSeg {
            Set changed = changed + 1
            Set out = out _ "- " _ srcSeg _ $Char(10)
            Set out = out _ "+ " _ tgtSeg _ $Char(10)
        }
    }
    If changed = 0 Set out = out _ "(no changes)" _ $Char(10)

    Set out = out _ $Char(10) _ "=== TARGET ===" _ $Char(10)
    Set out = out _ target.OutputToString() _ $Char(10)

    Return out
}

}
