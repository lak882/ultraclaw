/// InterClaw.Production — IRIS Interoperability Production for the Claude chatbot.
///
/// Components:
///   InterClaw.BS.ChatbotBackend   — Manages uvicorn, polls Python audit queue
///   InterClaw.BO.ConversationLog  — Receives conversation events for trace visibility
Class InterClaw.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="InterClaw.Production" LogGeneralTraceEvents="true">
  <Description>InterClaw — manages the chatbot backend and traces all conversation events through IRIS interoperability.</Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="InterClaw.BS.ChatbotBackend" Category="Chatbot" ClassName="InterClaw.BS.ChatbotBackend" PoolSize="1" Enabled="true">
    <Setting Target="Host" Name="AuditTarget">InterClaw.BO.ConversationLog</Setting>
    <Setting Target="Adapter" Name="CallInterval">1</Setting>
  </Item>
  <Item Name="InterClaw.BO.ConversationLog" Category="Chatbot" ClassName="InterClaw.BO.ConversationLog" PoolSize="1" Enabled="true">
  </Item>
  <Item Name="InterClaw.BO.GitHubFeedback" Category="Feedback" ClassName="InterClaw.BO.GitHubFeedback" PoolSize="1" Enabled="true">
    <Setting Target="Host" Name="Repo">lak882/claude-connector-gitlab-mirror</Setting>
    <Setting Target="Host" Name="CredentialId">GitHubFeedback</Setting>
  </Item>
  <Item Name="InterClaw.BS.ScriptAudit" Category="Audit" ClassName="InterClaw.BS.ScriptAudit" PoolSize="1" Enabled="true">
    <Setting Target="Host" Name="AuditTarget">InterClaw.BO.AuditLog</Setting>
    <Setting Target="Adapter" Name="CallInterval">1</Setting>
  </Item>
  <Item Name="InterClaw.BO.AuditLog" Category="Audit" ClassName="InterClaw.BO.AuditLog" PoolSize="1" Enabled="true">
  </Item>
  <Item Name="EnsLib.Testing.Service" Category="Feedback" ClassName="EnsLib.Testing.Service" PoolSize="0" Enabled="true">
  </Item>
</Production>
}

}
