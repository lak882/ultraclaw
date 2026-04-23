# Business Services Reference

Business service class hierarchy, `OnProcessInput`, adapter classes, and examples. Load when adding or writing a service.

## Class Hierarchy

```
Ens.BusinessService
  ├── EnsLib.HL7.Service.Standard
  │     ├── EnsLib.HL7.Service.TCPService          (MLLP/TCP)
  │     ├── EnsLib.HL7.Service.FileService          (file drop)
  │     ├── EnsLib.HL7.Service.FTPService           (FTP)
  │     └── EnsLib.HL7.Service.HTTPService          (HTTP)
  ├── EnsLib.File.PassthroughService               (generic file)
  ├── EnsLib.HTTP.GenericService                    (generic HTTP)
  ├── EnsLib.REST.Service                           (RESTful)
  ├── EnsLib.SQL.Service.GenericService             (SQL polling)
  ├── EnsLib.RecordMap.Service.FileService          (record map file)
  ├── EnsLib.DICOM.Service.TCP                      (DICOM)
  ├── HS.FHIRServer.Interop.Service                 (HealthShare FHIR)
  ├── HS.Hub.MPI.Manager                            (HealthShare MPI)
  └── EnsLib.SOAP.Service                           (SOAP)
```

## Key Method: OnProcessInput

Called by the adapter when data arrives. This is where all inbound logic lives.

```objectscript
Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    Set tRequest = ##class(MyApp.MyRequest).%New()
    Set tRequest.SomeProperty = pInput.SomeValue
    Set tSC = ..SendRequestAsync("MyApp.TargetProcess", tRequest)
    Return tSC
}
```

`pInput` type depends on the adapter: `EnsLib.HL7.Message` for HL7 adapters, `%Stream.Object` for file adapters.

## Lifecycle Methods

| Method | When Called |
|--------|------------|
| `OnInit()` | When the service starts |
| `OnTearDown()` | When the service stops |
| `OnGetConnections()` | Declare target connections for the portal diagram |

## Common Inbound Adapter Classes

| Adapter | Use Case | Key Settings |
|---------|----------|--------------|
| `EnsLib.HL7.Adapter.TCPInboundAdapter` | HL7 via MLLP | `Port`, `StayConnected`, `AckMode` |
| `EnsLib.File.InboundAdapter` | Poll a directory for files | `FilePath`, `FileSpec`, `ArchivePath`, `CallInterval` |
| `EnsLib.HTTP.InboundAdapter` | HTTP listener | `Port`, `SSLConfig` |
| `EnsLib.TCP.InboundAdapter` | Raw TCP socket | `Port`, `StayConnected`, `CallInterval` |
| `EnsLib.FTP.InboundAdapter` | FTP file polling | `FTPServer`, `FTPPort`, `Credentials`, `FilePath` |
| `EnsLib.SQL.InboundAdapter` | Database polling | `DSN`, `Query`, `KeyFieldName` |

## Key Properties

| Property | Description |
|----------|-------------|
| `Adapter` | Reference to the adapter instance |
| `TargetConfigNames` | Comma-separated list of targets this service sends to |
| `%WaitForNextCallInterval` | Set to 1 in OnProcessInput to pause until next poll |

## SETTINGS Parameter

```objectscript
Parameter SETTINGS = "TargetConfigNames:Basic:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";
```

## SendRequest Methods

| Method | Behavior |
|--------|----------|
| `..SendRequestSync(target, request, .response, timeout)` | Synchronous — waits for response |
| `..SendRequestAsync(target, request)` | Asynchronous — fire and forget |

Use `SendRequestSync` when you need to return an ACK based on the processing result. Use `SendRequestAsync` for fire-and-forget.

## Example: HL7 MLLP Service (Built-in)

Configure in production XML — no custom class needed:

```xml
<Item Name="HL7.TCPInbound" Category="HL7 Inbound" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="Port">2100</Setting>
  <Setting Target="Adapter" Name="StayConnected">-1</Setting>
  <Setting Target="Host" Name="TargetConfigNames">HL7Router</Setting>
  <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  <Setting Target="Host" Name="AckMode">Application</Setting>
  <Setting Target="Host" Name="SearchTableClass">EnsLib.HL7.SearchTable</Setting>
</Item>
```

## Example: HL7 HTTP Service (Built-in)

```xml
<Item Name="HL7.HTTPInbound" Category="HL7 Inbound" ClassName="EnsLib.HL7.Service.HTTPService" PoolSize="0" Enabled="true">
  <Setting Target="Host" Name="TargetConfigNames">HL7Router</Setting>
  <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  <Setting Target="Host" Name="EnableStandardRequests">1</Setting>
</Item>
```

Note: `EnableStandardRequests` is a `Target="Host"` setting, not `Target="Adapter"`. `PoolSize=0` is correct for HTTP services.

## Example: Custom File-Polling Service

```objectscript
Class MyApp.BS.CSVFileService Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

Property Adapter As EnsLib.File.InboundAdapter;

Property TargetConfigNames As %String(MAXLEN = 1000);

Parameter SETTINGS = "TargetConfigNames:Basic:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Method OnProcessInput(pInput As %Stream.Object, pOutput As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    Set tRequest = ##class(MyApp.Msg.CSVRequest).%New()
    Set tRequest.Content = pInput.Read(pInput.Size)
    Set tSC = ..SendRequestAsync(..TargetConfigNames, tRequest)
    Return tSC
}

}
```

Production XML:

```xml
<Item Name="CSVFilePoller" Category="Inbound" ClassName="MyApp.BS.CSVFileService" PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="FilePath">/data/inbound/</Setting>
  <Setting Target="Adapter" Name="FileSpec">*.csv</Setting>
  <Setting Target="Adapter" Name="ArchivePath">/data/archive/</Setting>
  <Setting Target="Adapter" Name="CallInterval">5</Setting>
  <Setting Target="Host" Name="TargetConfigNames">CSVProcessor</Setting>
</Item>
```

## Example: HealthShare FHIR Service

```xml
<Item Name="FHIR.Interop.Service" Category="FHIR" ClassName="HS.FHIRServer.Interop.Service" PoolSize="0" Enabled="true">
  <Setting Target="Host" Name="TargetConfigNames">FHIR.Interop.Process</Setting>
</Item>
```
