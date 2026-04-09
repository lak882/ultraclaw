/// Compilation event — emitted by compile.py after compiling documents.
/// Source: "audit_doc_compile"
Class InterClaw.Pipeline.Msg.CompileEvent Extends InterClaw.Pipeline.Msg.BaseEvent
{

/// Document name(s) compiled.
Property DocumentName As %String(MAXLEN = 500);

/// Compilation status: "success" or "error".
Property CompileStatus As %String(MAXLEN = 50);

/// Full compilation output messages.
Property CompileMessages As %String(MAXLEN = "");

/// Duration in milliseconds.
Property Duration As %Numeric;

}
