# Business Operations Reference

Business operation class hierarchy, MessageMap XDATA, adapter classes, and examples. Load when adding or writing an operation.

## Class Hierarchy

```
Ens.BusinessOperation
  ├── EnsLib.HL7.Operation.Standard
  │     ├── EnsLib.HL7.Operation.TCPOperation       (MLLP/TCP outbound)
  │     ├── EnsLib.HL7.Operation.FileOperation       (HL7 file write)
  │     ├── EnsLib.HL7.Operation.FTPOperation        (HL7 FTP)
  │     └── EnsLib.HL7.Operation.HTTPOperation       (HL7 HTTP)
  ├── EnsLib.File.PassthroughOperation              (generic file write)
  ├── EnsLib.HTTP.GenericOperation                   (generic HTTP)
  ├── EnsLib.REST.Operation                          (RESTful client)
  ├── EnsLib.SQL.Operation.GenericOperation           (SQL outbound)
  ├── EnsLib.SOAP.GenericOperation                   (SOAP client)
  ├── HS.Hub.HSWS.WebServices.Operations             (HealthShare Hub)
  ├── HS.FHIRServer.Interop.Operation                (HealthShare FHIR)
  ├── EnsLib.DICOM.Operation.TCP                     (DICOM outbound)
  └── Ens.Alert.Operation.SendEmail                  (email alerts)
```

## MessageMap XDATA

The MessageMap tells the operation which method to call for each request type:

```objectscript
XData MessageMap
{
<MapItems>
  <MapItem MessageType="MyApp.Msg.OrderRequest">
    <Method>ProcessOrder</Method>
  </MapItem>
  <MapItem MessageType="MyApp.Msg.StatusRequest">
    <Method>CheckStatus</Method>
  </MapItem>
</MapItems>
}
```

Handler method signature:

```objectscript
Method ProcessOrder(pRequest As MyApp.Msg.OrderRequest, Output pResponse As MyApp.Msg.OrderResponse) As %Status
```

## INVOCATION Parameter

```objectscript
Parameter INVOCATION = "Queue";    // default — background job pool
Parameter INVOCATION = "InProc";   // run in the caller's process
```

## Common Outbound Adapter Classes

| Adapter | Use Case | Key Settings |
|---------|----------|--------------|
| `EnsLib.HL7.Adapter.TCPOutboundAdapter` | HL7 MLLP | `IPAddress`, `Port`, `StayConnected` |
| `EnsLib.File.OutboundAdapter` | Write files | `FilePath`, `Overwrite`, `Charset` |
| `EnsLib.HTTP.OutboundAdapter` | HTTP client | `HTTPServer`, `HTTPPort`, `SSLConfig`, `URL` |
| `EnsLib.TCP.OutboundAdapter` | Raw TCP | `IPAddress`, `Port`, `SSLConfig` |
| `EnsLib.FTP.OutboundAdapter` | FTP upload | `FTPServer`, `FTPPort`, `Credentials`, `FilePath` |
| `EnsLib.SQL.OutboundAdapter` | SQL operations | `DSN`, `Credentials` |

## Lifecycle Methods

| Method | When Called |
|--------|------------|
| `OnInit()` | When the operation starts |
| `OnTearDown()` | When the operation stops |
| `OnMessage(request)` | Default handler if no MessageMap match |
| `OnGetConnections()` | Declare connections for portal diagram |
| `OnKeepalive()` | Periodic keepalive |

## Retry and Error Handling

| Setting | Description |
|---------|-------------|
| `FailureTimeout` | How long to keep retrying (-1 = forever) |
| `RetryInterval` | Seconds between retries |
| `ReplyCodeActions` | Action on specific reply codes (e.g., HL7 NACK) |
| `NoFailWhileDisconnected` | Don't count failures while adapter is disconnected |

```xml
<Setting Target="Host" Name="FailureTimeout">-1</Setting>
<Setting Target="Host" Name="RetryInterval">30</Setting>
```

## Example: HL7 TCP Operation (Built-in)

```xml
<Item Name="HL7.TCPOutbound" Category="HL7 Outbound" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="IPAddress">10.0.1.50</Setting>
  <Setting Target="Adapter" Name="Port">2200</Setting>
  <Setting Target="Adapter" Name="StayConnected">-1</Setting>
  <Setting Target="Host" Name="SearchTableClass">EnsLib.HL7.SearchTable</Setting>
</Item>
```

## Example: HL7 File Operation (Built-in)

```xml
<Item Name="HL7.FileOutbound" Category="HL7 Outbound" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="FilePath">/data/outbound/</Setting>
  <Setting Target="Adapter" Name="Overwrite">0</Setting>
  <Setting Target="Host" Name="Filename">%f_%Q.hl7</Setting>
  <Setting Target="Host" Name="SearchTableClass">EnsLib.HL7.SearchTable</Setting>
</Item>
```

Filename tokens: `%f` = original filename, `%Q` = unique counter, `%T` = timestamp.

## Example: Custom REST Operation

```objectscript
Class MyApp.BO.PatientAPIOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

Property APIEndpoint As %String(MAXLEN = 500);

Parameter SETTINGS = "APIEndpoint:Basic";

Method SendPatientData(pRequest As MyApp.Msg.PatientRequest, Output pResponse As MyApp.Msg.PatientResponse) As %Status
{
    Set tSC = $$$OK
    Set tJSON = {}
    Set tJSON.patientId = pRequest.PatientId
    Set tURL = ..APIEndpoint _ "/api/patients"
    Set tSC = ..Adapter.PostJSON(tURL, tJSON, .tHTTPResponse)
    If $$$ISERR(tSC) Return tSC
    Set pResponse = ##class(MyApp.Msg.PatientResponse).%New()
    Set pResponse.Success = (tHTTPResponse.StatusCode = 200)
    Return tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="MyApp.Msg.PatientRequest">
    <Method>SendPatientData</Method>
  </MapItem>
</MapItems>
}

}
```

## Example: HealthShare Hub Operation

```xml
<Item Name="HS.Hub.WebServices" Category="Hub" ClassName="HS.Hub.HSWS.WebServices.Operations" PoolSize="1" Enabled="true">
  <Setting Target="Host" Name="ServiceName">HS.Hub.HSWS.WebServices</Setting>
  <Setting Target="Adapter" Name="HTTPServer">hub.example.com</Setting>
  <Setting Target="Adapter" Name="HTTPPort">443</Setting>
  <Setting Target="Adapter" Name="SSLConfig">HubSSL</Setting>
</Item>
```
