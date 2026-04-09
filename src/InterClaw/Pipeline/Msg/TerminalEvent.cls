/// Terminal event — ObjectScript command execution via iris_terminal.py.
/// Source: "audit_terminal"
Class InterClaw.Pipeline.Msg.TerminalEvent Extends InterClaw.Pipeline.Msg.BaseEvent
{

/// ObjectScript code that was executed.
Property Code As %String(MAXLEN = "");

/// Command output.
Property Output As %String(MAXLEN = "");

/// Duration in milliseconds.
Property Duration As %Numeric;

/// Whether execution succeeded.
Property Success As %Boolean [ InitialExpression = 0 ];

}
