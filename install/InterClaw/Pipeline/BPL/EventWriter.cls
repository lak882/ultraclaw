/// Writes individual chat events to the ^InterClaw.ChatEvents global.
/// Receives ChatEvent messages from the WebSocket operation via SendRequestAsync.
Class InterClaw.Pipeline.BPL.EventWriter Extends Ens.BusinessProcessBPL
{

/// Write an event to the global and return the sequence number.
ClassMethod WriteEvent(bridgeId As %String, eventJSON As %String, isFinal As %Boolean) As %Integer
{
    Set seq = $increment(^InterClaw.ChatEvents(bridgeId, "seq"))
    Set ^InterClaw.ChatEvents(bridgeId, "evt", seq) = eventJSON
    If isFinal Set ^InterClaw.ChatEvents(bridgeId, "done") = 1
    Return seq
}

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript'
         request='InterClaw.Pipeline.Msg.ChatEvent'
         response='Ens.Response'>
<context>
  <property name='seq' type='%Integer'/>
</context>
<sequence>

  <if name='CheckBridgeId' condition='request.BridgeId &apos;= ""'>
    <true>
      <assign name='WriteToGlobal' property='context.seq'
              value='##class(InterClaw.Pipeline.BPL.EventWriter).WriteEvent(request.BridgeId, request.EventJSON, request.IsFinal)'/>
      <trace name='LogWrite' value='"Wrote event seq=" _ context.seq _ " type=" _ request.EventType _ " bridge=" _ request.BridgeId'/>
    </true>
    <false>
      <trace name='MissingBridgeId' value='"EventWriter: Missing BridgeId"'/>
    </false>
  </if>

</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
