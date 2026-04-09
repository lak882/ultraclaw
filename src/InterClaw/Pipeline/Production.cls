/// Chat relay production — bridges HTTP polling to Claude WebSocket
/// via an interoperability pipeline with tracing and managed process pools.
Class InterClaw.Pipeline.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="InterClaw.Pipeline.Production" LogGeneralTraceEvents="true">
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
    <Setting Target="Host" Name="HTTPForwardTarget">EventHTTPOperation</Setting>
  </Item>
  <Item Name="InterClaw.Pipeline.BO.WebSocketOperation" Category="Chat" ClassName="InterClaw.Pipeline.BO.WebSocketOperation" PoolSize="200" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="WebSocketURL">ws://localhost/irishealth/api/ws/InterClaw.WS.Chat.cls</Setting>
    <Setting Target="Host" Name="EventWriterTarget">InterClaw.Pipeline.BP.EventWriter</Setting>
    <Setting Target="Host" Name="ConnectionTimeout">10</Setting>
    <Setting Target="Host" Name="ReadTimeout">300</Setting>
  </Item>
<Item Name="SessionHTTPService" Category="Analytics" ClassName="InterClaw.Analytics.BS.SessionHTTPService" PoolSize="1" Enabled="false" Foreground="false" Comment="Receives session analytics JSON on port 9880" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Port">9880</Setting>
  </Item>
  <Item Name="SessionForward" Category="Analytics" ClassName="InterClaw.Analytics.BO.SessionForwardOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="Forwards session logs to remote IRIS via HTTP" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="HTTPServer">vmdev1.iscinternal.com</Setting>
    <Setting Target="Adapter" Name="HTTPPort">9880</Setting>
    <Setting Target="Host" Name="RemotePath">/</Setting>
  </Item>
  <Item Name="AuditHTTPService" Category="Audit" ClassName="InterClaw.Analytics.BS.AuditHTTPService" PoolSize="1" Enabled="false" Foreground="false" Comment="Receives audit events from Python scripts on port 9881" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Port">9881</Setting>
    <Setting Target="Host" Name="AuditLogTarget">InterClaw.BO.AuditLog</Setting>
    <Setting Target="Host" Name="EventHTTPTarget">EventHTTPOperation</Setting>
    <Setting Target="Host" Name="EventStorageTarget">EventStorageProcess</Setting>
  </Item>
  <Item Name="InterClaw.BO.AuditLog" Category="Audit" ClassName="InterClaw.BO.AuditLog" PoolSize="1" Enabled="false" Foreground="false" Comment="Stores audit events to AuditEntry table" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="EventStorageProcess" Category="Audit" ClassName="InterClaw.Analytics.BP.EventStorageProcess" PoolSize="1" Enabled="false" Foreground="false" Comment="Stores events long-term in type-specific SQL tables" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="EventHTTPOperation" Category="Audit" ClassName="InterClaw.Pipeline.BO.EventHTTPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="Forwards audit events to analytics receiver" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="HTTPServer">localhost</Setting>
    <Setting Target="Adapter" Name="HTTPPort">9883</Setting>
  </Item>
</Production>
}

}
