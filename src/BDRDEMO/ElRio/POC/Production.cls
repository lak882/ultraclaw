Class ElRio.POC.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="ElRio.POC.Production" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description>El Rio Health POC - Three Interface Builds demonstrating HL7 routing, transformation, and filtering</Description>
  <ActorPoolSize>2</ActorPoolSize>

  <!-- Build 1: Vaccine Administration to ASIIS -->
  <Item Name="From_VaccineSource" Category="Build 1" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="Inbound VXU messages from vaccine source" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">VaccineRouter</Setting>
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/BDRDEMO/ElRio.POC/From_VaccineSource/In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hl7</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/isc/FileDrop/BDRDEMO/ElRio.POC/From_VaccineSource/In/Archive</Setting>
  </Item>

  <Item Name="VaccineRouter" Category="Build 1" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Routes and transforms VXU messages" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">ElRio.POC.Rule.VaccineRouter</Setting>
  </Item>

  <Item Name="To_ASIIS" Category="Build 1" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Outbound to ASIIS (file-based for POC testing)" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/BDRDEMO/ElRio.POC/To_ASIIS/Out</Setting>
    <Setting Target="Adapter" Name="Filename">ASIIS_%Q.hl7</Setting>
  </Item>

  <!-- Build 2: Imaging Orders to Rad Ltd -->
  <Item Name="From_ImagingOrders" Category="Build 2" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="Inbound ORM messages from imaging orders" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">ImagingRouter</Setting>
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/BDRDEMO/ElRio.POC/From_ImagingOrders/In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hl7</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/isc/FileDrop/BDRDEMO/ElRio.POC/From_ImagingOrders/In/Archive</Setting>
  </Item>

  <Item Name="ImagingRouter" Category="Build 2" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Routes and transforms ORM messages" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">ElRio.POC.Rule.FromImagingOrdersRouter</Setting>
  </Item>

  <Item Name="To_RadLtd" Category="Build 2" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Outbound to Rad Ltd imaging system" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/BDRDEMO/ElRio.POC/To_RadLtd/Out</Setting>
    <Setting Target="Adapter" Name="Filename">RadLtd_%Q.hl7</Setting>
  </Item>

  <!-- Build 3: Image Order Results to Epic -->
  <Item Name="From_EyePACS" Category="Build 3" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="Inbound ORU messages from EyePACS SFTP" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">EyepacsRouter</Setting>
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/BDRDEMO/ElRio.POC/From_EyePACS/In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hl7</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/isc/FileDrop/BDRDEMO/ElRio.POC/From_EyePACS/In/Archive</Setting>
  </Item>

  <Item Name="EyepacsRouter" Category="Build 3" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Routes and transforms ORU messages" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">ElRio.POC.Rule.EyepacsRouter</Setting>
  </Item>

  <Item Name="To_Epic" Category="Build 3" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Outbound to Epic" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/BDRDEMO/ElRio.POC/To_Epic/Out</Setting>
    <Setting Target="Adapter" Name="Filename">Epic_%Q.hl7</Setting>
  </Item>

</Production>
}

}
