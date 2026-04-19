/// Chat relay production — bridges HTTP polling to embedded Python Claude SDK
/// via an interoperability pipeline with tracing and managed process pools.
Class InterClaw.Pipeline.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="InterClaw.Pipeline.Production" LogGeneralTraceEvents="true">
  <Description>Chat relay pipeline: HTTP polling -> BS -> BP -> BO (embedded Python) -> EventWriter -> global</Description>
  <ActorPoolSize>10</ActorPoolSize>
  <Item Name="InterClaw.Pipeline.BS.ChatService" Category="Chat" ClassName="InterClaw.Pipeline.BS.ChatService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="ProcessTarget">InterClaw.Pipeline.BP.ChatProcess</Setting>
  </Item>
  <Item Name="InterClaw.Pipeline.BP.ChatProcess" Category="Chat" ClassName="InterClaw.Pipeline.BP.ChatProcess" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="OperationTarget">InterClaw.Pipeline.BO.ClaudeOperation</Setting>
  </Item>
  <Item Name="InterClaw.Pipeline.BO.ClaudeOperation" Category="Chat" ClassName="InterClaw.Pipeline.BO.ClaudeOperation" PoolSize="200" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="ReadTimeout">300</Setting>
    <Setting Target="Host" Name="EventWriterTarget">InterClaw.Pipeline.BP.EventWriter</Setting>
  </Item>
  <Item Name="InterClaw.Pipeline.BP.EventWriter" Category="Chat" ClassName="InterClaw.Pipeline.BP.EventWriter" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
</Production>
}

}
