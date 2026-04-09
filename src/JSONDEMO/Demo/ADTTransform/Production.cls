Class Demo.ADTTransform.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Demo.ADTTransform.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description>Transform HL7 2.3 ADT_A01 to HL7 2.5.1 ADT_A04 and HL7 2.3 ADT_A34 to HL7 2.4 ADT_A34</Description>
  <ActorPoolSize>2</ActorPoolSize>

  <Item Name="HL7FileService" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.3</Setting>
    <Setting Target="Host" Name="TargetConfigNames">TransformRouter</Setting>
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/Demo.ADTTransform/HL7FileService/In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hl7</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/isc/FileDrop/JSONDEMO/Demo.ADTTransform/HL7FileService/Files</Setting>
  </Item>

  <Item Name="A34FileService" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="Reads HL7 2.3 A34 messages" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.3</Setting>
    <Setting Target="Host" Name="TargetConfigNames">TransformRouter</Setting>
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/Demo.ADTTransform/A34FileService/In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hl7</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/isc/FileDrop/JSONDEMO/Demo.ADTTransform/A34FileService/Files</Setting>
  </Item>

  <Item Name="TransformRouter" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">Demo.ADTTransform.Rule.TransformRoutingRule</Setting>
    <Setting Target="Host" Name="BadMessageHandler"></Setting>
  </Item>

  <Item Name="HL7FileOperation" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/Demo.ADTTransform/HL7FileOperation/Out</Setting>
    <Setting Target="Host" Name="Filename">ADT_A04_%f_%Q.hl7</Setting>
  </Item>

  <Item Name="A34FileOperation" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Writes HL7 2.4 A34 messages" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/Demo.ADTTransform/A34FileOperation/Out</Setting>
    <Setting Target="Host" Name="Filename">ADT_A34_%f_%Q.hl7</Setting>
  </Item>

</Production>
}

}
