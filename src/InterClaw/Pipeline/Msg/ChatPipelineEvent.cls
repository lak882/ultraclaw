/// Chat pipeline event — forwarded from EventWriter for external consumption.
/// Source: "chat"
Class InterClaw.Pipeline.Msg.ChatPipelineEvent Extends InterClaw.Pipeline.Msg.BaseEvent
{

/// Raw Claude stream JSON event.
Property EventJSON As %String(MAXLEN = "");

/// Extracted text content from the event.
Property ChatText As %String(MAXLEN = "");

/// True for the final event in a chat turn (done event).
Property IsFinal As %Boolean [ InitialExpression = 0 ];

}
