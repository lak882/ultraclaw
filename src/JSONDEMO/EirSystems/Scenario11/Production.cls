Class EirSystems.Scenario11.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="EirSystems.Scenario11.Production" LogGeneralTraceEvents="true">
  <Description>Scenario 1.1: ADT^A01 to Admit JSON</Description>
  <ActorPoolSize>2</ActorPoolSize>

  <Item Name="HL7_File_Service" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/EirSystems.Scenario11/HL7_File_Service/In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hl7</Setting>
    <Setting Target="Adapter" Name="ArchivePath"></Setting>
    <Setting Target="Host" Name="TargetConfigNames">ADT_Message_Router</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  </Item>

  <Item Name="ADT_Message_Router" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">EirSystems.Scenario11.Rule.ADTRoutingRule</Setting>
  </Item>

  <Item Name="JSON_File_Operation" Category="" ClassName="EirSystems.Scenario11.BO.JSONFileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/EirSystems.Scenario11/JSON_File_Operation/Out</Setting>
  </Item>

</Production>
}

}
