Class AdmitToDischarge.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="AdmitToDischarge.Production" LogGeneralTraceEvents="false">
  <Description>File interface that converts ADT admits to discharges when patient name is nicholai</Description>
  <ActorPoolSize>2</ActorPoolSize>

  <Item Name="FileService" Category="Inbound" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="Reads ADT_A01 messages from file drop" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/AdmitToDischarge/In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hl7</Setting>
    <Setting Target="Adapter" Name="ArchivePath"></Setting>
    <Setting Target="Host" Name="TargetConfigNames">AdmitRouter</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  </Item>

  <Item Name="AdmitRouter" Category="Routing" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Routes based on patient name" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">AdmitToDischarge.Rule.AdmitRoutingRule</Setting>
  </Item>

  <Item Name="DischargeFileOperation" Category="Outbound" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Writes to output directory" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/AdmitToDischarge/Out</Setting>
    <Setting Target="Host" Name="Filename">%f_%Q.hl7</Setting>
  </Item>

</Production>
}

}
