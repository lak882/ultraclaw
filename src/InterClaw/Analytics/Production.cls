/// Session analytics production — receives session logs via HTTP and persists them.
Class InterClaw.Analytics.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="InterClaw.Analytics.Production" LogGeneralTraceEvents="true">
  <Description>Session analytics: HTTP POST → SessionHTTPService → SessionPersistOperation → SQL table</Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="SessionHTTPService" Category="Analytics" ClassName="InterClaw.Analytics.BS.SessionHTTPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Receives session log JSON via HTTP POST" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Port">9880</Setting>
  </Item>
  <Item Name="SessionPersist" Category="Analytics" ClassName="InterClaw.Analytics.BO.SessionPersistOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Persists session logs to InterClaw.Analytics.SessionLog table" LogTraceEvents="true" Schedule="">
  </Item>
</Production>
}

}
