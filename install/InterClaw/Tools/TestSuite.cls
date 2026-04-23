/// Run a directory of HL7 test messages against an HL7 HTTP service and
/// summarize per-message results. Reads every *.hl7 / *.txt file in the
/// given directory, POSTs each to the service, then groups the traces.
/// Intended as a single-call regression driver for a package's fixtures.
Class InterClaw.Tools.TestSuite Extends InterClaw.Tools.Base
{

Parameter ToolName = "test_suite";

Parameter ToolDescription = "Batch-send every HL7 test file in a directory to an HL7 HTTP service and return a summary of send status + downstream trace counts per message. Does not modify the filesystem.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""config_item"":{""type"":""string"",""description"":""HL7 HTTP service CfgItem""},""directory"":{""type"":""string"",""description"":""Absolute path containing .hl7 / .txt test files""},""pattern"":{""type"":""string"",""default"":""*.hl7"",""description"":""File glob, default *.hl7""},""pause_ms"":{""type"":""integer"",""default"":200,""description"":""Sleep between sends to keep SessionId ordering readable""}},""required"":[""config_item"",""directory""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set cfg = input.%Get("config_item")
    Set dir = input.%Get("directory")
    Set pattern = input.%Get("pattern")
    If pattern = "" Set pattern = "*.hl7"
    Set pauseMs = +input.%Get("pause_ms")
    If pauseMs < 0 Set pauseMs = 200
    If (cfg = "") || (dir = "") Return "Error: config_item and directory are required"

    If '##class(%File).DirectoryExists(dir) Return "Error: directory does not exist: " _ dir

    Set resp = ##class(%DynamicObject).%New()
    Do resp.%Set("config_item", cfg)
    Do resp.%Set("directory", dir)
    Do resp.%Set("pattern", pattern)

    Set results = ##class(%DynamicArray).%New()
    Set okCount = 0
    Set failCount = 0

    Set rs = ##class(%ResultSet).%New("%File:FileSet")
    Set sc = rs.Execute(dir, pattern)
    If $$$ISERR(sc) Return "FileSet error: " _ $System.Status.GetErrorText(sc)

    While rs.%Next() {
        Set path = rs.%Get("Name")
        Set fname = ##class(%File).GetFilename(path)
        Set row = ##class(%DynamicObject).%New()
        Do row.%Set("file", fname)

        // Read the message.
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set stream.Filename = path
        Set body = ""
        While 'stream.AtEnd { Set body = body _ stream.Read(32000) }
        Do stream.%Close()
        Set body = $Replace(body, $Char(13, 10), $Char(13))
        Set body = $Replace(body, $Char(10), $Char(13))

        Set beforeId = $Get(^Ens.MessageHeaderD, 0)

        Set sendSC = ..SendOne(cfg, body, .status, .preview)
        Do row.%Set("http_status", +status, "number")
        Do row.%Set("preview", $Extract(preview, 1, 200))

        If pauseMs > 0 Hang pauseMs / 1000

        Set afterId = $Get(^Ens.MessageHeaderD, 0)
        Set traceCount = afterId - beforeId
        Do row.%Set("new_traces", traceCount, "number")

        If $$$ISOK(sendSC) && (+status >= 200) && (+status < 300) {
            Set okCount = okCount + 1
            Do row.%Set("ok", 1, "boolean")
        } Else {
            Set failCount = failCount + 1
            Do row.%Set("ok", 0, "boolean")
            If $$$ISERR(sendSC) Do row.%Set("error", $System.Status.GetErrorText(sendSC))
        }
        Do results.%Push(row)
    }
    Do rs.Close()

    Do resp.%Set("sent", okCount + failCount, "number")
    Do resp.%Set("ok", okCount, "number")
    Do resp.%Set("failed", failCount, "number")
    Do resp.%Set("results", results)
    Return resp.%ToJSON()
}

ClassMethod SendOne(cfg As %String, body As %String, Output status As %Integer, Output preview As %String) As %Status
{
    Set ns = $ZConvert($Namespace, "L")
    Set url = "/csp/healthshare/" _ ns _ "/EnsLib.HL7.Service.HTTPService.cls?CfgItem=" _ $ZConvert(cfg, "O", "URL")
    Set req = ##class(%Net.HttpRequest).%New()
    Set req.Server = "localhost"
    Set req.Port = +$Get(^%SYS("WebServer", "PortInternal"), $Get(^%SYS("CSP", "DefaultPort"), 52773))
    Set req.ContentType = "application/hl7-v2; charset=utf-8"
    Do req.EntityBody.Write(body)
    Set sc = req.Post(url)
    Set status = 0
    Set preview = ""
    If $$$ISERR(sc) Return sc
    Set status = req.HttpResponse.StatusCode
    If $IsObject(req.HttpResponse.Data) {
        While 'req.HttpResponse.Data.AtEnd { Set preview = preview _ req.HttpResponse.Data.Read(2000) }
    }
    Return $$$OK
}

}
