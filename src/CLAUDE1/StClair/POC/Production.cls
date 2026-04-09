Class StClair.POC.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="StClair.POC.Production" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description>St. Clair Health POC Build 3 - Main ADT Feed (Many-To-One)</Description>
  <ActorPoolSize>2</ActorPoolSize>

  <!-- Business Service: From_EMR (Inbound HL7 File) -->
  <Item Name="From_EMR" Category="Build3" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="Inbound HL7 ADT messages from EMR" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/CLAUDE1/StClair.POC/From_EMR/In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hl7</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">StClairCustom</Setting>
    <Setting Target="Host" Name="TargetConfigNames">From_EMR_Router</Setting>
  </Item>

  <!-- Business Process: From_EMR_Router (HL7 Routing Engine) -->
  <Item Name="From_EMR_Router" Category="Build3" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Routes ADT messages to RIS and Ambulatory Billing" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">StClair.POC.Rule.FromEMRRoutingRule</Setting>
  </Item>

  <!-- Business Operation: To_RIS (TCP, enabled but unreachable - messages queue) -->
  <Item Name="To_RIS" Category="Build3" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Outbound TCP to RIS - messages queue up" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">10.0.0.1</Setting>
    <Setting Target="Adapter" Name="Port">2575</Setting>
    <Setting Target="Adapter" Name="StayConnected">0</Setting>
    <Setting Target="Host" Name="FailureTimeout">-1</Setting>
  </Item>

  <!-- Business Operation: To_Ambulatory_Billing (File with timestamped filename) -->
  <Item Name="To_Ambulatory_Billing" Category="Build3" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Outbound HL7 file to Ambulatory Billing" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/CLAUDE1/StClair.POC/To_Ambulatory_Billing/Out</Setting>
    <Setting Target="Adapter" Name="Filename">From_EMR_Router_%f.hl7</Setting>
  </Item>

</Production>
}

}
