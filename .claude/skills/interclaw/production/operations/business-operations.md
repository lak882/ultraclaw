# Business Operations Reference

Business Operations are the outbound layer. They send data to external systems via adapters. They receive requests from business processes or services and handle them via a message map.

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

## Key Concepts

### MessageMap XDATA

The MessageMap tells the operation which method to call for each request type:

```objectscript
XData MessageMap
{
<MapItems>
  <MapItem MessageType="MyApp.OrderRequest">
    <Method>ProcessOrder</Method>
  </MapItem>
  <MapItem MessageType="MyApp.StatusRequest">
    <Method>CheckStatus</Method>
  </MapItem>
</MapItems>
}
```

Each `<MapItem>` maps a request class to a handler method. The method signature is always:

```objectscript
Method ProcessOrder(pRequest As MyApp.OrderRequest, Output pResponse As MyApp.OrderResponse) As %Status
```

### INVOCATION Parameter

```objectscript
Parameter INVOCATION = "Queue";    // default — run in background job pool
// or
Parameter INVOCATION = "InProc";   // run in the caller's process
```

## Common Adapter Classes

| Adapter Class | Use Case | Key Settings |
|---------------|----------|--------------|
| `EnsLib.TCP.OutboundAdapter` | Raw TCP | `IPAddress`, `Port`, `SSLConfig` |
| `EnsLib.File.OutboundAdapter` | Write files | `FilePath`, `Overwrite`, `Charset` |
| `EnsLib.HL7.Adapter.TCPOutboundAdapter` | HL7 MLLP | `IPAddress`, `Port`, `StayConnected` |
| `EnsLib.HTTP.OutboundAdapter` | HTTP client | `HTTPServer`, `HTTPPort`, `SSLConfig`, `URL` |
| `EnsLib.FTP.OutboundAdapter` | FTP upload | `FTPServer`, `FTPPort`, `Credentials`, `FilePath` |
| `EnsLib.SQL.OutboundAdapter` | SQL operations | `DSN`, `Credentials` |

## Lifecycle Methods

| Method | When Called |
|--------|------------|
| `OnInit()` | When the operation starts |
| `OnTearDown()` | When the operation stops |
| `OnMessage(request)` | Default handler if no MessageMap match |
| `OnGetConnections()` | Declare connections for portal diagram |
| `OnKeepalive()` | Periodic keepalive (if configured) |

## Example: HL7 TCP Operation (Built-in)

Configure in production XML — no custom code needed:

```xml
<Item Name="HL7.TCPOutbound" Category="HL7 Outbound" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="IPAddress">10.0.1.50</Setting>
  <Setting Target="Adapter" Name="Port">2200</Setting>
  <Setting Target="Adapter" Name="StayConnected">-1</Setting>
  <Setting Target="Adapter" Name="ReconnectRetry">5</Setting>
  <Setting Target="Host" Name="SearchTableClass">EnsLib.HL7.SearchTable</Setting>
</Item>
```

## Example: Custom REST Operation

```objectscript
Class MyApp.RESTOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

Parameter SETTINGS = "APIEndpoint:Basic";

Property APIEndpoint As %String(MAXLEN = 500);

Method SendPatientData(pRequest As MyApp.PatientRequest, Output pResponse As MyApp.PatientResponse) As %Status
{
    Set tSC = $$$OK

    // Build JSON payload
    Set tJSON = {}
    Set tJSON.patientId = pRequest.PatientId
    Set tJSON.firstName = pRequest.FirstName
    Set tJSON.lastName = pRequest.LastName

    // Send via HTTP adapter
    Set tURL = ..APIEndpoint _ "/api/patients"
    Set tSC = ..Adapter.PostJSON(tURL, tJSON, .tHTTPResponse)
    If $$$ISERR(tSC) Return tSC

    // Parse response
    Set pResponse = ##class(MyApp.PatientResponse).%New()
    If tHTTPResponse.StatusCode = 200 {
        Set pResponse.Success = 1
        Set tRespJSON = {}.%FromJSON(tHTTPResponse.Data)
        Set pResponse.ExternalId = tRespJSON.id
    } Else {
        Set pResponse.Success = 0
        Set pResponse.ErrorMessage = "HTTP " _ tHTTPResponse.StatusCode
    }

    Return tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="MyApp.PatientRequest">
    <Method>SendPatientData</Method>
  </MapItem>
</MapItems>
}

}
```

## Example: HL7 File Operation

Write HL7 messages to files on disk:

```xml
<Item Name="HL7.FileOutbound" Category="HL7 Outbound" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="FilePath">/data/outbound/</Setting>
  <Setting Target="Adapter" Name="Overwrite">0</Setting>
  <Setting Target="Host" Name="Filename">%f_%Q.hl7</Setting>
  <Setting Target="Host" Name="SearchTableClass">EnsLib.HL7.SearchTable</Setting>
</Item>
```

Filename tokens: `%f` = original filename, `%Q` = unique counter, `%T` = timestamp.

## Example: HealthShare Hub Operation

```xml
<Item Name="HS.Hub.WebServices" Category="Hub" ClassName="HS.Hub.HSWS.WebServices.Operations" PoolSize="1" Enabled="true">
  <Setting Target="Host" Name="ServiceName">HS.Hub.HSWS.WebServices</Setting>
  <Setting Target="Adapter" Name="HTTPServer">hub.example.com</Setting>
  <Setting Target="Adapter" Name="HTTPPort">443</Setting>
  <Setting Target="Adapter" Name="SSLConfig">HubSSL</Setting>
</Item>
```

## Retry and Error Handling

Operations support built-in retry via production settings:

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
