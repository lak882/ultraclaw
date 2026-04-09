/// Forwards session log requests to a remote IRIS analytics endpoint via HTTP POST.
/// All connection details (HTTPServer, HTTPPort, SSLConfig, Credentials) are
/// configured on the EnsLib.HTTP.OutboundAdapter via production settings.
Class InterClaw.Analytics.BO.SessionForwardOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Parameter INVOCATION = "Queue";

Method OnMessage(pRequest As InterClaw.Analytics.Msg.SessionLogRequest, Output pResponse As Ens.Response) As %Status
{
    Set sc = $$$OK
    Try {
        // Serialize the typed request message to JSON via %JSON.Adaptor
        Set sc = pRequest.%JSONExportToString(.jsonBody)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        // Prepare the HTTP request for the outbound adapter
        Set httpRequest = ##class(%Net.HttpRequest).%New()
        Set httpRequest.ContentType = "application/json"
        Do httpRequest.EntityBody.Write(jsonBody)

        // POST through the adapter — host, port, credentials, SSL, retry all from adapter settings
        Set sc = ..Adapter.SendFormDataArray(.httpResponse, "POST", httpRequest)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        If $IsObject(httpResponse) && (httpResponse.StatusCode >= 300) {
            Set respBody = ""
            If $IsObject(httpResponse.Data) Set respBody = httpResponse.Data.Read(1000)
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Remote HTTP "_httpResponse.StatusCode_": "_respBody))
        }

        $$$TRACE("Forwarded session log for "_pRequest.Username_" → HTTP "_httpResponse.StatusCode)

    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

}
