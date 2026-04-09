Class Demo.AdmitToDischarge.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Demo.AdmitToDischarge.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description>File-based HL7 production: reads ADT-A01 messages, converts to ADT-A03 (discharge) when patient name is Nicholai, writes to file</Description>
  <ActorPoolSize>2</ActorPoolSize>

  <Item Name="File_In" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="Read HL7 files from /In directory" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Router</Setting>
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/Demo/AdmitToDischarge/File_In/In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hl7</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/isc/FileDrop/JSONDEMO/Demo/AdmitToDischarge/File_In/Archive</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  </Item>

  <Item Name="Router" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Check patient name and route" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">Demo.AdmitToDischarge.Rule.CheckNicholaiRoutingRule</Setting>
  </Item>

  <Item Name="File_Out" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Write HL7 files to /Out directory" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/Demo/AdmitToDischarge/File_Out/Out</Setting>
    <Setting Target="Host" Name="Filename">%f_%Q.hl7</Setting>
  </Item>
</Production>
}

}
