Class Demo.Nicholai Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Demo.Nicholai" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="HL7_File_Service" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">HL7_Routing_Process</Setting>
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/Demo.Nicholai/HL7_File_Service/In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hl7</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/isc/FileDrop/JSONDEMO/Demo.Nicholai/HL7_File_Service/Archive</Setting>
  </Item>
  <Item Name="HL7_Routing_Process" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">Demo.Nicholai.Rule.DischargeRoutingRule</Setting>
  </Item>
  <Item Name="HL7_File_Operation" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/Demo.Nicholai/HL7_File_Operation/Out</Setting>
    <Setting Target="Host" Name="Filename">Discharge_%Q.hl7</Setting>
  </Item>
</Production>
}

}
