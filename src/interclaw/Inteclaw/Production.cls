/// Inteclaw AI pipeline production.
/// Gateway (REST) -> ChatService (BS) -> ChatProcess (BP, agent loop)
///     -> ProviderOperation (BO, model-agnostic HTTP) + ToolOperation (BO, registry dispatch)
///     -> EventWriter (BP, ^Inteclaw.ChatEvents)
Class Inteclaw.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Inteclaw.Production" LogGeneralTraceEvents="true">
  <Description>IRIS-native AI agent pipeline — model-agnostic, tool-based, OpenClaw-inspired gateway.</Description>
  <ActorPoolSize>6</ActorPoolSize>
  <Item Name="Inteclaw.BS.ChatService" Category="Core" ClassName="Inteclaw.BS.ChatService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ProcessTarget">Inteclaw.BP.ChatProcess</Setting>
  </Item>
  <Item Name="Inteclaw.BP.ChatProcess" Category="Core" ClassName="Inteclaw.BP.ChatProcess" PoolSize="4" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ProviderTarget">Inteclaw.BO.ProviderOperation</Setting>
    <Setting Target="Host" Name="ToolTarget">Inteclaw.BO.ToolOperation</Setting>
    <Setting Target="Host" Name="EventTarget">Inteclaw.BP.EventWriter</Setting>
    <Setting Target="Host" Name="MaxTurns">12</Setting>
  </Item>
  <Item Name="Inteclaw.BO.ProviderOperation" Category="Core" ClassName="Inteclaw.BO.ProviderOperation" PoolSize="4" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="DefaultProvider">bedrock</Setting>
    <Setting Target="Host" Name="DefaultModel">us.anthropic.claude-opus-4-7</Setting>
    <Setting Target="Host" Name="EventWriterTarget">Inteclaw.BP.EventWriter</Setting>
  </Item>
  <Item Name="Inteclaw.BO.ToolOperation" Category="Core" ClassName="Inteclaw.BO.ToolOperation" PoolSize="4" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Inteclaw.BP.EventWriter" Category="Core" ClassName="Inteclaw.BP.EventWriter" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
