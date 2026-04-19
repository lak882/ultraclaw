/// Main orchestrator BPL — receives ChatRequest from the service,
/// calls the WebSocket operation, and traces the ChatResponse metadata.
Class InterClaw.Pipeline.BPL.ChatProcess Extends Ens.BusinessProcessBPL
{

Property OperationTarget As %String [ InitialExpression = "InterClaw.Pipeline.BO.WebSocketOperation" ];

Parameter SETTINGS = "OperationTarget:Basic";

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript'
         request='InterClaw.Pipeline.Msg.ChatRequest'
         response='InterClaw.Pipeline.Msg.ChatResponse'>
<context>
  <property name='opResponse' type='InterClaw.Pipeline.Msg.ChatResponse' instantiate='0'/>
</context>
<sequence>

  <call name='CallWebSocket' target='@process.OperationTarget' async='0'>
    <request type='InterClaw.Pipeline.Msg.ChatRequest'>
      <assign property='callrequest.BridgeId' value='request.BridgeId' action='set'/>
      <assign property='callrequest.PayloadJSON' value='request.PayloadJSON' action='set'/>
      <assign property='callrequest.Prompt' value='request.Prompt' action='set'/>
      <assign property='callrequest.SessionId' value='request.SessionId' action='set'/>
      <assign property='callrequest.Model' value='request.Model' action='set'/>
      <assign property='callrequest.Namespace' value='request.Namespace' action='set'/>
      <assign property='callrequest.Action' value='request.Action' action='set'/>
    </request>
    <response type='InterClaw.Pipeline.Msg.ChatResponse'>
      <assign property='context.opResponse' value='callresponse' action='set'/>
    </response>
  </call>

  <assign name='SetResponse' property='response' value='context.opResponse' action='set'/>

  <trace name='LogCompletion'
         value='"Chat completed: bridge=" _ request.BridgeId _ " session=" _ context.opResponse.SessionId _ " cost=$" _ context.opResponse.Cost _ " events=" _ context.opResponse.EventCount'/>

</sequence>
</process>
}

Storage Default
{
<Data name="ChatProcessDefaultData">
<Subscript>"ChatProcess"</Subscript>
<Value name="1">
<Value>OperationTarget</Value>
</Value>
</Data>
<DefaultData>ChatProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
