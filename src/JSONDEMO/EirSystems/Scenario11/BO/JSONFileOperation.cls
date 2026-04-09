Class EirSystems.Scenario11.BO.JSONFileOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";

Property Adapter As EnsLib.File.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method SendAdmitJSON(pRequest As EirSystems.Msg.AdmitRequest, Output pResponse As Ens.Response) As %Status
{
    Set tSC = $$$OK
    Try {
        // Create timestamp for filename
        Set tTimestamp = $ZDATE($HOROLOG, 8)_"-"_$ZTIME($PIECE($HOROLOG,",",2), 1)
        Set tTimestamp = $TRANSLATE(tTimestamp, ": ", "--")
        Set tFilename = "admit_"_tTimestamp_".json"

        // Convert request to JSON stream
        Set tStream = ##class(%Stream.TmpCharacter).%New()
        Set tSC = pRequest.%JSONExportToStream(.tStream)
        If $$$ISERR(tSC) Quit

        // Write stream to file via adapter
        Set tSC = ..Adapter.PutStream(tFilename, tStream)
        If $$$ISERR(tSC) Quit

        // Create response
        Set pResponse = ##class(Ens.Response).%New()

    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="EirSystems.Msg.AdmitRequest">
    <Method>SendAdmitJSON</Method>
  </MapItem>
</MapItems>
}

}
