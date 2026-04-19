/// Chat relay production — bridges HTTP polling to Claude WebSocket
/// via an interoperability pipeline with tracing and managed process pools.
Class InterClaw.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="InterClaw.Production" LogGeneralTraceEvents="true">
  <Description>Chat relay pipeline: HTTP polling → BS → BP → BO (WebSocket) → EventWriter → global</Description>
  <ActorPoolSize>10</ActorPoolSize>
  <Item Name="InterClaw.Pipeline.BS.ChatService" Category="Chat" ClassName="InterClaw.Pipeline.BS.ChatService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="ProcessTarget">InterClaw.Pipeline.BP.ChatProcess</Setting>
  </Item>
  <Item Name="InterClaw.Pipeline.BP.ChatProcess" Category="Chat" ClassName="InterClaw.Pipeline.BP.ChatProcess" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="OperationTarget">InterClaw.Pipeline.BO.WebSocketOperation</Setting>
  </Item>
  <Item Name="InterClaw.Pipeline.BP.EventWriter" Category="Chat" ClassName="InterClaw.Pipeline.BP.EventWriter" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="InterClaw.Pipeline.BO.WebSocketOperation" Category="Chat" ClassName="InterClaw.Pipeline.BO.WebSocketOperation" PoolSize="200" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="WebSocketURL"></Setting>
    <Setting Target="Host" Name="EventWriterTarget">InterClaw.Pipeline.BP.EventWriter</Setting>
    <Setting Target="Host" Name="ConnectionTimeout">10</Setting>
    <Setting Target="Host" Name="ReadTimeout">300</Setting>
  </Item>
</Production>
}

}
