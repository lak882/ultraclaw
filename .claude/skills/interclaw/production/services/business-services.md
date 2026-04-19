# Business Services Reference

Business Services are the entry point into a production. They receive data from external systems via adapters and dispatch messages into the production.

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
  └── EnsLib.SOAP.Service                           (SOAP/web service)
```

## Key Method: OnProcessInput

This is the main method you implement. Called by the adapter when data arrives.

```objectscript
Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
    Set tSC = $$$OK

    // Create a request message
    Set tRequest = ##class(MyApp.MyRequest).%New()
    Set tRequest.SomeProperty = pInput.SomeValue

    // Send to a target (business process or operation)
    Set tSC = ..SendRequestAsync("MyApp.TargetProcess", tRequest)

    Return tSC
}
```

**Parameters:**
- `pInput` — the object provided by the adapter. Type depends on the adapter:
  - `EnsLib.HL7.Message` for HL7 adapters
  - `%Stream.Object` for file adapters
  - `%String` or custom for others
- `pOutput` — optional output object (for synchronous responses)

## Other Lifecycle Methods

| Method | When Called |
|--------|------------|
| `OnInit()` | When the service starts |
| `OnTearDown()` | When the service stops |
| `OnGetConnections()` | To declare target connections for the portal diagram |

## Common Adapter Classes

| Adapter Class | Use Case | Key Settings |
|---------------|----------|--------------|
| `EnsLib.TCP.InboundAdapter` | Raw TCP socket listener | `Port`, `StayConnected`, `CallInterval` |
| `EnsLib.File.InboundAdapter` | Poll a directory for files | `FilePath`, `FileSpec`, `ArchivePath`, `CallInterval` |
| `EnsLib.HL7.Adapter.TCPInboundAdapter` | HL7 via MLLP | `Port`, `StayConnected`, `AckMode` |
| `EnsLib.HTTP.InboundAdapter` | HTTP listener | `Port`, `SSLConfig` |
| `EnsLib.FTP.InboundAdapter` | FTP file polling | `FTPServer`, `FTPPort`, `Credentials`, `FilePath` |
| `EnsLib.SQL.InboundAdapter` | Database polling | `DSN`, `Query`, `KeyFieldName` |

## Key Properties

| Property | Description |
|----------|-------------|
| `Adapter` | Reference to the adapter instance |
| `TargetConfigNames` | Comma-separated list of targets this service sends to |
| `%WaitForNextCallInterval` | Set to 1 in OnProcessInput to pause until next poll |

## SETTINGS Parameter

Declare configurable settings visible in the Management Portal:

```objectscript
Parameter SETTINGS = "TargetConfigNames:Basic:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";
```

## Example: HL7 MLLP Service (HealthShare)

This is a built-in class — you configure it in the production XML rather than writing code:

```xml
<Item Name="HL7.TCPInbound" Category="HL7" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="Port">2100</Setting>
  <Setting Target="Adapter" Name="StayConnected">-1</Setting>
  <Setting Target="Host" Name="TargetConfigNames">HL7Router</Setting>
  <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  <Setting Target="Host" Name="AckMode">Application</Setting>
  <Setting Target="Host" Name="SearchTableClass">EnsLib.HL7.SearchTable</Setting>
</Item>
```

## Example: Custom File-Polling Service

```objectscript
Class MyApp.CSVFileService Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

Property Adapter As EnsLib.File.InboundAdapter;

Property TargetConfigNames As %String(MAXLEN = 1000);

Parameter SETTINGS = "TargetConfigNames:Basic:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Method OnProcessInput(pInput As %Stream.Object, pOutput As %RegisteredObject) As %Status
{
    Set tSC = $$$OK

    // Read CSV content from the file stream
    Set tContent = ""
    While 'pInput.AtEnd {
        Set tContent = tContent _ pInput.ReadLine() _ $C(10)
    }

    // Create request and send
    Set tRequest = ##class(MyApp.CSVRequest).%New()
    Set tRequest.Content = tContent
    Set tRequest.Filename = ..Adapter.GetFileName()

    Set tSC = ..SendRequestAsync(..TargetConfigNames, tRequest)

    Return tSC
}

}
```

Production XML for this service:
```xml
<Item Name="CSVFilePoller" Category="Inbound" ClassName="MyApp.CSVFileService" PoolSize="1" Enabled="true">
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

## SendRequest Methods

| Method | Behavior |
|--------|----------|
| `..SendRequestSync(target, request, .response, timeout)` | Synchronous — waits for response |
| `..SendRequestAsync(target, request)` | Asynchronous — fire and forget |

Use `SendRequestSync` when you need to return an ACK based on the processing result (e.g., HL7 ACK). Use `SendRequestAsync` for fire-and-forget patterns.

## Example: HTTP-to-File Pipeline (No Filesystem Access)

Receive HL7 messages via HTTP POST and write them to files on the IRIS server. Both components are built-in — no custom ObjectScript needed.

```xml
<!-- Receive HL7 via HTTP POST -->
<Item Name="HL7.HTTPInbound" Category="HL7 Inbound" ClassName="EnsLib.HL7.Service.HTTPService" PoolSize="1" Enabled="true">
  <Setting Target="Host" Name="TargetConfigNames">HL7.FileWriter</Setting>
  <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  <Setting Target="Host" Name="AckMode">Application</Setting>
</Item>

<!-- Write HL7 messages to files -->
<Item Name="HL7.FileWriter" Category="HL7 Outbound" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true">
  <Setting Target="Adapter" Name="FilePath">/data/outbound/</Setting>
  <Setting Target="Adapter" Name="Overwrite">0</Setting>
  <Setting Target="Host" Name="Filename">%f_%Q.hl7</Setting>
  <Setting Target="Host" Name="SearchTableClass">EnsLib.HL7.SearchTable</Setting>
</Item>
```

Send from Python using `send_hl7.py`:
```bash
<python> .claude/skills/interclaw/scripts/hl7/send_hl7.py \
  --server myserver \
  --url /irishealth/csp/healthshare/hslib/EnsLib.HL7.Service.HTTPService \
  --input message.hl7
```

The HTTP service returns a synchronous HL7 ACK (MSA|AA = accepted, MSA|AE = error).
