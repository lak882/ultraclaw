/// Send an HL7 message to an HL7 HTTP service on this instance via the CSP
/// web gateway. The service must have EnableStandardRequests=1 and
/// PoolSize=0 (Host-level settings, not Adapter).
Class InterClaw.Tools.SendHL7 Extends InterClaw.Tools.Base
{

Parameter ToolName = "send_hl7";

Parameter ToolDescription = "POST an HL7 v2 message to a local EnsLib.HL7.Service.HTTPService config item and return the HTTP status. After sending, query Ens.MessageHeader (or use the `trace` tool) to confirm routing. Only works for services exposed via the CSP web gateway on the current namespace.";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""config_item"":{""type"":""string"",""description"":""CfgItem name of the HL7 HTTP service""},""message"":{""type"":""string"",""description"":""Raw HL7 v2 message (segments separated by CR or LF)""}},""required"":[""config_item"",""message""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set cfg = input.%Get("config_item")
    Set msg = input.%Get("message")
    If (cfg = "") || (msg = "") Return "Error: config_item and message are required"

    // Normalize line endings — HL7 over HTTP expects CR segment separators.
    Set msg = $Replace(msg, $Char(13, 10), $Char(13))
    Set msg = $Replace(msg, $Char(10), $Char(13))

    Set ns = $ZConvert($Namespace, "L")
    Set url = "/csp/healthshare/" _ ns _ "/EnsLib.HL7.Service.HTTPService.cls?CfgItem=" _ $ZConvert(cfg, "O", "URL")

    // Resolve web-gateway port from CSP config. Default to 52773 (IRIS container default).
    // Use %Net.HttpRequest with localhost so the call stays on this instance.
    Set req = ##class(%Net.HttpRequest).%New()
    Set req.Server = "localhost"
    Set req.Port = +$Get(^%SYS("WebServer", "PortInternal"), $Get(^%SYS("CSP", "DefaultPort"), 52773))
    Set req.ContentType = "application/hl7-v2; charset=utf-8"
    Do req.EntityBody.Write(msg)
    Set sc = req.Post(url)
    If $$$ISERR(sc) {
        Return "HTTP send failed: " _ $System.Status.GetErrorText(sc)
    }

    Set resp = ##class(%DynamicObject).%New()
    Do resp.%Set("status", req.HttpResponse.StatusCode, "number")
    Do resp.%Set("url", url)
    Set body = ""
    If $IsObject(req.HttpResponse.Data) {
        While 'req.HttpResponse.Data.AtEnd { Set body = body _ req.HttpResponse.Data.Read(8000) }
    }
    Do resp.%Set("body_preview", $Extract(body, 1, 800))
    Return resp.%ToJSON()
}

}
