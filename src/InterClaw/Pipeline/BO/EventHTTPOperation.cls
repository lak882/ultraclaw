/// Forwards pipeline events to a remote HTTP endpoint.
/// All connection details (HTTPServer, HTTPPort, SSLConfig)
/// configured on the EnsLib.HTTP.OutboundAdapter via production settings.
Class InterClaw.Pipeline.BO.EventHTTPOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Parameter INVOCATION = "Queue";

/// Polymorphic handler — accepts any BaseEvent subclass.
/// %JSONExportToString serializes only the properties on the actual runtime class.
Method ForwardEvent(pRequest As InterClaw.Pipeline.Msg.BaseEvent, Output pResponse As Ens.Response) As %Status
{
    Set sc = $$$OK
    Try {
        Set sc = pRequest.%JSONExportToString(.jsonBody)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        Set httpReq = ##class(%Net.HttpRequest).%New()
        Set httpReq.ContentType = "application/json"
        Do httpReq.EntityBody.Write(jsonBody)

        Set sc = ..Adapter.SendFormDataArray(.httpResp, "POST", httpReq)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        If $IsObject(httpResp) && (httpResp.StatusCode >= 300) {
            Set respBody = ""
            If $IsObject(httpResp.Data) Set respBody = httpResp.Data.Read(1000)
            $$$LOGWARNING("EventHTTP: remote returned HTTP "_httpResp.StatusCode_": "_respBody)
        }
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

XData MessageMap
{
<MapItems>
    <MapItem MessageType="InterClaw.Pipeline.Msg.ApiCallEvent">
        <Method>ForwardEvent</Method>
    </MapItem>
    <MapItem MessageType="InterClaw.Pipeline.Msg.TerminalEvent">
        <Method>ForwardEvent</Method>
    </MapItem>
    <MapItem MessageType="InterClaw.Pipeline.Msg.FileChangeEvent">
        <Method>ForwardEvent</Method>
    </MapItem>
    <MapItem MessageType="InterClaw.Pipeline.Msg.ChatPipelineEvent">
        <Method>ForwardEvent</Method>
    </MapItem>
    <MapItem MessageType="InterClaw.Pipeline.Msg.DocumentGetEvent">
        <Method>ForwardEvent</Method>
    </MapItem>
    <MapItem MessageType="InterClaw.Pipeline.Msg.DocumentPutEvent">
        <Method>ForwardEvent</Method>
    </MapItem>
    <MapItem MessageType="InterClaw.Pipeline.Msg.CompileEvent">
        <Method>ForwardEvent</Method>
    </MapItem>
    <MapItem MessageType="InterClaw.Pipeline.Msg.QueryEvent">
        <Method>ForwardEvent</Method>
    </MapItem>
    <MapItem MessageType="InterClaw.Pipeline.Msg.UnifiedEvent">
        <Method>ForwardEvent</Method>
    </MapItem>
</MapItems>
}

}
