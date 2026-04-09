Class EirSystems.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="EirSystems.Production" LogGeneralTraceEvents="true">
  <Description>EirSystems HL7 to JSON POC - Evaluation 1.1: ADT^A01 to Admit JSON</Description>
  <ActorPoolSize>2</ActorPoolSize>

  <Item Name="From_EirSystems" Category="Service" ClassName="EnsLib.HL7.Service.HTTPService" PoolSize="0" Enabled="true" Foreground="false" InactivityTimeout="0">
    <Setting Target="Host" Name="TargetConfigNames">EirSystems_Router</Setting>
    <Setting Target="Host" Name="EnableStandardRequests">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  </Item>

  <Item Name="EirSystems_Router" Category="Process" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" InactivityTimeout="0">
    <Setting Target="Host" Name="BusinessRuleName">EirSystems.Rule.InboundRoutingRule</Setting>
  </Item>

  <Item Name="ADT_AdmitProcess" Category="Process" ClassName="EirSystems.BPL.ADTAdmitProcess" PoolSize="1" Enabled="true" Foreground="false" InactivityTimeout="0">
    <Setting Target="Host" Name="LogTraceEvents">1</Setting>
  </Item>

  <Item Name="To_AdmitJSON_File" Category="Operation" ClassName="EirSystems.BO.JSONFileOperation" PoolSize="1" Enabled="true" Foreground="false" InactivityTimeout="0">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/JSONDEMO/EirSystems/To_AdmitJSON_File/Out</Setting>
  </Item>

</Production>
}

}
