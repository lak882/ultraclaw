Class EirSystems.BO.JSONFileOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";

Property Adapter As EnsLib.File.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method AdmitRequest(pRequest As EirSystems.Msg.AdmitRequest, Output pResponse As Ens.Response) As %Status
{
    Set tSC = $$$OK
    Try {
        Set tJSON = ""
        Set tSC = pRequest.%JSONExportToString(.tJSON)
        If $$$ISERR(tSC) Quit
        Set tFilename = "Admit_"_$TR(pRequest.msh.controlId, " ", "_")_".json"
        Set tSC = ..Adapter.PutString(tFilename, tJSON)
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="EirSystems.Msg.AdmitRequest">
    <Method>AdmitRequest</Method>
  </MapItem>
</MapItems>
}

}
