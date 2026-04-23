# Production Class Reference

Production class structure, package naming, XDATA format, and Item/Setting attributes. Load when creating or editing a production.

## Class Hierarchy

```
Ens.Production
  └── Your.Custom.Production
```

## Package Naming Conventions

All components in a production share a root package `<Pkg>`. Follow this layout:

```
<Pkg>.Production                              production class
<Pkg>.Msg.<Name>Request                       request message classes
<Pkg>.Msg.<Name>Response                      response message classes
<Pkg>.DTL.<SourceFormat>To<TargetFormat>      data transformations
<Pkg>.Rule.<Name>RoutingRule                  routing rules
<Pkg>.BPL.<Name>Process                       BPL processes (default for all orchestration)
<Pkg>.BP.<Name>Process                        code-based processes (rare exception only)
<Pkg>.BS.<Name>Service                        custom business services
<Pkg>.BO.<Name>Operation                      custom business operations
<Pkg>.RecordMap.<Name>                        record map definitions
```

Rules:

- Built-in classes (`EnsLib.HL7.Service.TCPService`, `EnsLib.HL7.Operation.FileOperation`, etc.) are referenced by their full class name in the production XML. Only create classes under `<Pkg>.BS.*` or `<Pkg>.BO.*` when writing custom code.
- DTL names describe the transformation: `<SourceType>To<TargetType>`. Include the HL7 event when specific (`ADTA01ToSDA3`, not `ADTToSDA3`).
- Message classes always go in `.Msg`. Never place request/response classes at the package root.
- One class per file. File path mirrors the package: `src/<Pkg>/BS/MyService.cls`.

### Multi-exercise POC naming

Scope all components under a build number when a POC has multiple exercises:

```
Sanford.Build1.DTL.ADTTransform    Sanford.Build1.BO.SystemA      Sanford.Build1.BS.ADTFileService
Sanford.Build2.DTL.ORUTransform    Sanford.Build2.BO.ORUOutput    Sanford.Build2.BS.ORUFileService
```

The production class itself stays at `<Pkg>.Production` — shared across all exercises. Use the `Category` attribute on each `<Item>` to group hosts by exercise.

## Production Class Structure

```objectscript
Class HSCUSTOM.ADTFeed.Production Extends Ens.Production
{

XData ProductionDefinition [ XMLNamespace = "http://www.intersystems.com/production" ]
{
<Production Name="HSCUSTOM.ADTFeed.Production" LogGeneralTraceEvents="false">
  <Description>ADT Feed — receives HL7, routes by type, sends downstream</Description>
  <ActorPoolSize>2</ActorPoolSize>

  <!-- Built-in HL7 TCP service — no custom class needed -->
  <Item Name="HL7.TCPInbound" Category="HL7 Inbound" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Receives HL7 via MLLP" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">2100</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">HL7.Router</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  </Item>

  <!-- HL7 routing engine — references our routing rule class -->
  <Item Name="HL7.Router" Category="Routing" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Routes HL7 by type" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">HSCUSTOM.ADTFeed.Rule.MainRoutingRule</Setting>
  </Item>

  <!-- Built-in HL7 TCP operation -->
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
| `ClassName` | Yes | ObjectScript class implementing this component |
| `Category` | No | Grouping label shown in Management Portal |
| `PoolSize` | No | Number of worker jobs (default: 1) |
| `Enabled` | No | Whether this item starts with the production (default: true) |
| `Foreground` | No | Run in the foreground (default: false) |
| `Comment` | No | Description shown in Management Portal |
| `LogTraceEvents` | No | Enable trace logging (default: false) |
| `Schedule` | No | Cron-like schedule for when this item runs |

## Setting Element

```xml
<Setting Target="Adapter|Host" Name="SettingName">Value</Setting>
```

- `Target="Adapter"` — setting on the adapter class
- `Target="Host"` — setting on the business host class

## Production-Level Settings

| Setting | Description |
|---------|-------------|
| `ActorPoolSize` | Default pool size for business processes |
| `LogGeneralTraceEvents` | Enable general trace events |
| `TestingEnabled` | Enable testing service |

## Programmatic Production Updates

```objectscript
Set tSC = ##class(Ens.Config.Production).OpenProduction("MyApp.Production", .tProd)
Set tItem = ##class(Ens.Config.Item).%New()
Set tItem.Name = "MyApp.NewService"
Set tItem.ClassName = "EnsLib.HL7.Service.TCPService"
Set tItem.Enabled = 1
Do tProd.Items.Insert(tItem)
Set tSC = tProd.SaveToClass()
```
