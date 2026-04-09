/// InterClaw Analytics receiver production.
/// Receives forwarded audit events via HTTP and stores them
/// in type-specific SQL tables for long-term analytics.
Class InterClaw.Analytics.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="InterClaw.Analytics.Production" LogGeneralTraceEvents="true">
  <Description>InterClaw analytics receiver — stores audit events in SQL tables by type</Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="EventReceiverService" Category="Receiver" ClassName="InterClaw.Analytics.BS.EventReceiverService" PoolSize="1" Enabled="true" Foreground="false" Comment="Receives audit events via HTTP on port 9882" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Port">9883</Setting>
    <Setting Target="Host" Name="StorageTarget">EventStorageProcess</Setting>
  </Item>
  <Item Name="EventStorageProcess" Category="Storage" ClassName="InterClaw.Analytics.BP.EventStorageProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="Dispatches events to type-specific SQL tables" LogTraceEvents="true" Schedule="">
  </Item>
</Production>
}

}
