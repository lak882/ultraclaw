/// InterClaw AI pipeline production.
/// Gateway (REST) -> ChatService (BS) -> ChatProcess (BP, agent loop)
///     -> ProviderOperation (BO, model-agnostic HTTP) + ToolOperation (BO, registry dispatch)
///     -> EventWriter (BP, ^InterClaw.ChatEvents)
Class InterClaw.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="InterClaw.Production" LogGeneralTraceEvents="true">
  <Description>IRIS-native AI agent pipeline — model-agnostic, tool-based, OpenClaw-inspired gateway.</Description>
  <ActorPoolSize>6</ActorPoolSize>
  <Item Name="InterClaw.BS.ChatService" Category="Core" ClassName="InterClaw.BS.ChatService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ProcessTarget">InterClaw.BP.ChatProcess</Setting>
  </Item>
  <Item Name="InterClaw.BP.ChatProcess" Category="Core" ClassName="InterClaw.BP.ChatProcess" PoolSize="4" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ProviderTarget">InterClaw.BO.ProviderOperation</Setting>
    <Setting Target="Host" Name="ToolTarget">InterClaw.BO.ToolOperation</Setting>
    <Setting Target="Host" Name="EventTarget">InterClaw.BP.EventWriter</Setting>
    <Setting Target="Host" Name="MaxTurns">12</Setting>
  </Item>
  <Item Name="InterClaw.BO.ProviderOperation" Category="Core" ClassName="InterClaw.BO.ProviderOperation" PoolSize="4" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="DefaultProvider">bedrock</Setting>
    <Setting Target="Host" Name="DefaultModel">us.anthropic.claude-opus-4-7</Setting>
    <Setting Target="Host" Name="EventWriterTarget">InterClaw.BP.EventWriter</Setting>
  </Item>
  <Item Name="InterClaw.BO.ToolOperation" Category="Core" ClassName="InterClaw.BO.ToolOperation" PoolSize="4" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="InterClaw.BP.EventWriter" Category="Core" ClassName="InterClaw.BP.EventWriter" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
