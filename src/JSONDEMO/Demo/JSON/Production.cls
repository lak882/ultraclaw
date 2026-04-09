Class Demo.JSON.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Demo.JSON.Production" LogGeneralTraceEvents="true">
  <Description>JSON Adapter demo production - receives JSON via HTTP POST and deserializes into typed message classes</Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="JSON.HTTPService" Category="JSON Inbound" ClassName="Demo.JSON.BS.JSONHTTPService" PoolSize="0" Enabled="true" Foreground="false">
    <Setting Target="Host" Name="EnableStandardRequests">1</Setting>
    <Setting Target="Host" Name="JSONObjectClass">Demo.JSON.Msg.JSONRequest</Setting>
    <Setting Target="Host" Name="TargetConfigName">JSON.FileWriter</Setting>
    <Setting Target="Host" Name="OneWay">1</Setting>
  </Item>
  <Item Name="JSON.FileWriter" Category="JSON Outbound" ClassName="Demo.JSON.BO.JSONFileOperation" PoolSize="1" Enabled="true" Foreground="false">
    <Setting Target="Adapter" Name="FilePath">/tmp/</Setting>
  </Item>
  <Item Name="HL7.TCPService" Category="HL7 Inbound" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false">
    <Setting Target="Adapter" Name="Port">9999</Setting>
  </Item>
</Production>
}

}
