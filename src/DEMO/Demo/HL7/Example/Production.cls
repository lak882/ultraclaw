Class Demo.HL7.Example.Production Extends Ens.Production
{

XData ProductionDefinition [ XMLNamespace = "http://www.intersystems.com/production" ]
{
<Production Name="Demo.HL7.Example.Production" LogGeneralTraceEvents="false">
  <Description>HL7 HTTP service that routes messages to a file operation</Description>
  <ActorPoolSize>2</ActorPoolSize>

  <!-- Inbound: HL7 HTTP Service -->
  <Item Name="HTTPService" Category="HL7 Inbound" ClassName="EnsLib.HL7.Service.HTTPService" PoolSize="0" Enabled="true" Foreground="false" Comment="Receives HL7 messages via HTTP" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="EnableStandardRequests">1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">RoutingEngine</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  </Item>

  <!-- Routing: HL7 Routing Engine -->
  <Item Name="RoutingEngine" Category="Routing" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Routes HL7 messages using FileRoutingRule" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">Demo.HL7.Example.Rule.FileRoutingRule</Setting>
  </Item>

  <!-- Outbound: File Operation -->
  <Item Name="FileOperation" Category="HL7 Outbound" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Writes HL7 messages to files" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/isc/FileDrop/DEMO/Demo.HL7.Example/FileOperation/Out</Setting>
    <Setting Target="Host" Name="Filename">%f_%Q%!+(_a)</Setting>
  </Item>

</Production>
}

}
