# Production Class Reference

A Production is the top-level container that defines which components are active, their settings, and how they're wired together.

## Class Hierarchy

```
Ens.Production
  └── Your.Custom.Production (extends Ens.Production)
```

## Package Naming Convention

All production components must follow this standardized package structure. Given a root package `<Pkg>`:

```
<Pkg>.Production                              — the production class itself
<Pkg>.Msg.<Name>Request                       — request message classes
<Pkg>.Msg.<Name>Response                      — response message classes
<Pkg>.DTL.<SourceFormat>To<TargetFormat>      — data transformations
      e.g., <Pkg>.DTL.ADTA01ToSDA3
            <Pkg>.DTL.ADTA01ToADTA08
            <Pkg>.DTL.ORUToLabResult
<Pkg>.Rule.<Name>RoutingRule                  — routing rules
      e.g., <Pkg>.Rule.HL7RoutingRule
            <Pkg>.Rule.ADTRoutingRule
<Pkg>.BP.<Name>Process                        — business processes (code-based)
      e.g., <Pkg>.BP.ADTProcessor
            <Pkg>.BP.OrderOrchestrator
<Pkg>.BPL.<Name>Process                       — BPL processes (visual/XML)
      e.g., <Pkg>.BPL.LabResultProcess
<Pkg>.BS.<Name>Service                        — business services (custom only)
      e.g., <Pkg>.BS.CSVFileService
            <Pkg>.BS.RESTInboundService
<Pkg>.BO.<Name>Operation                      — business operations (custom only)
      e.g., <Pkg>.BO.RESTOutboundOperation
            <Pkg>.BO.PatientAPIOperation
<Pkg>.RecordMap.<Name>                        — record map definitions
      e.g., <Pkg>.RecordMap.CSVPatient
            <Pkg>.RecordMap.FixedWidthLab
<Pkg>.LookupTable.<Name>Installer             — lookup table population classes (if needed)
```

### Example: Full Production Class Layout

For a package `HSCUSTOM.ADTFeed`:

```
HSCUSTOM.ADTFeed.Production                   — the production
HSCUSTOM.ADTFeed.Msg.ADTRequest               — message classes
HSCUSTOM.ADTFeed.Msg.ADTResponse
HSCUSTOM.ADTFeed.DTL.ADTA01ToSDA3             — transforms
HSCUSTOM.ADTFeed.DTL.ADTA01ToADTA08
HSCUSTOM.ADTFeed.Rule.MainRoutingRule         — routing rules
HSCUSTOM.ADTFeed.BP.ADTProcessor              — business processes
HSCUSTOM.ADTFeed.BS.HL7FileService            — custom services
HSCUSTOM.ADTFeed.BO.HubOperation              — custom operations
HSCUSTOM.ADTFeed.RecordMap.CSVDemographics    — record maps
```

### Rules

- **Built-in classes don't get subpackaged.** When using `EnsLib.HL7.Service.TCPService` or `EnsLib.HL7.Operation.FileOperation` directly, reference them by their full built-in class name in the production XML. Only create classes under `<Pkg>.BS.*` or `<Pkg>.BO.*` when writing custom code.
- **DTL names describe the transformation.** Format: `<SourceType>To<TargetType>`. Include the HL7 event type when specific (e.g., `ADTA01ToSDA3`, not just `ADTToSDA3`).
- **Message classes always go in `.Msg`.** Never put request/response classes at the root package level.
- **One class per file.** File path mirrors the package: `src/HSCUSTOM/ADTFeed/DTL/ADTA01ToSDA3.cls`.

## Structure

A Production class contains an `XDATA ProductionDefinition` block in XML that declares all components:

```objectscript
Class HSCUSTOM.ADTFeed.Production Extends Ens.Production
{
XData ProductionDefinition [ XMLNamespace = "http://www.intersystems.com/production" ]
{
<Production Name="HSCUSTOM.ADTFeed.Production" LogGeneralTraceEvents="false">
  <Description>ADT Feed — receives HL7, routes by type, sends to downstream systems</Description>
  <ActorPoolSize>2</ActorPoolSize>

  <!-- Inbound: built-in HL7 TCP service (no custom class needed) -->
  <Item Name="HL7.TCPInbound" Category="HL7 Inbound" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Receives HL7 messages via MLLP" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">2100</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">HL7.Router</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  </Item>

  <!-- Routing: built-in routing engine, references our custom rule class -->
  <Item Name="HL7.Router" Category="Routing" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Routes HL7 messages by type" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">HSCUSTOM.ADTFeed.Rule.MainRoutingRule</Setting>
  </Item>

  <!-- Outbound: built-in HL7 TCP operation -->
  <Item Name="HL7.TCPOutbound" Category="HL7 Outbound" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Sends HL7 via MLLP" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">192.168.1.100</Setting>
    <Setting Target="Adapter" Name="Port">2200</Setting>
    <Setting Target="Host" Name="SearchTableClass">EnsLib.HL7.SearchTable</Setting>
  </Item>

</Production>
}
}
```

## Item Attributes

| Attribute | Required | Description |
|-----------|----------|-------------|
| `Name` | Yes | Unique config name for this component instance |
| `ClassName` | Yes | The ObjectScript class implementing this component |
| `Category` | No | Grouping label shown in Management Portal |
| `PoolSize` | No | Number of worker jobs (default: 1) |
| `Enabled` | No | Whether this item starts with the production (default: true) |
| `Foreground` | No | Run in foreground (default: false) |
| `Comment` | No | Description shown in Management Portal |
| `LogTraceEvents` | No | Enable trace logging (default: false) |
| `Schedule` | No | Cron-like schedule for when this item runs |

## Setting Element

```xml
<Setting Target="Adapter|Host" Name="SettingName">Value</Setting>
```

- `Target="Adapter"` — setting on the adapter class
- `Target="Host"` — setting on the business host (service/process/operation) class

## Common Production-Level Settings

| Setting | Description |
|---------|-------------|
| `ActorPoolSize` | Default pool size for business processes |
| `LogGeneralTraceEvents` | Enable general trace events |
| `TestingEnabled` | Enable testing service (Ens.Enterprise.TestingService) |

## HealthShare-Specific Patterns

HealthShare productions typically include:
- **HL7 Services** receiving from EHR systems via MLLP (TCP)
- **HL7 Routing Engine** dispatching by message type (ADT, ORM, ORU, etc.)
- **DTL transforms** mapping between HL7 versions or to SDA3
- **FHIR services** using `HS.FHIRServer.Interop.Service`
- **Hub operations** sending to `HS.Hub.HSWS.WebServices.Operations`

## How to Add a Component

1. Define the class (BS, BP, or BO)
2. Add an `<Item>` element to the `XDATA ProductionDefinition`
3. Configure settings via `<Setting>` elements
4. Compile the production class
5. Restart the production or update it via Management Portal

## Programmatic Production Updates

You can also modify productions via SQL or ObjectScript:
```objectscript
// Add an item programmatically
Set tSC = ##class(Ens.Config.Production).OpenProduction("MyApp.Production", .tProd)
Set tItem = ##class(Ens.Config.Item).%New()
Set tItem.Name = "MyApp.NewService"
Set tItem.ClassName = "EnsLib.HL7.Service.TCPService"
Set tItem.Enabled = 1
Do tProd.Items.Insert(tItem)
Set tSC = tProd.SaveToClass()
```
