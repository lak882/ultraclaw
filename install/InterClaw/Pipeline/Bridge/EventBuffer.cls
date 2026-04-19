/// WebSocket frame buffer — stores the latest frame content for the BO to read.
/// Unlike InterClaw.Bridge.EventListener, this does NOT write to globals directly.
/// The BO reads LastContent after each ws.Next() and routes it through the production.
Class InterClaw.Pipeline.Bridge.EventBuffer Extends (%RegisteredObject, %Net.WebSocket.IEventListener)
{

Property LastContent As %String(MAXLEN = "");

Property IsClosed As %Boolean [ InitialExpression = 0 ];

Property HasError As %Boolean [ InitialExpression = 0 ];

Property ErrorText As %String(MAXLEN = 500);

Method OnOpen()
{
}

Method OnMessage(pContent As %Stream.Object)
{
    Set ..LastContent = ""
    While 'pContent.AtEnd {
        Set ..LastContent = ..LastContent _ pContent.Read(32000)
    }
}

Method OnClose()
{
    Set ..IsClosed = 1
}

Method OnError(pError As %Exception.AbstractException)
{
    Set ..HasError = 1
    Set ..ErrorText = pError.DisplayString()
    Set ..IsClosed = 1
}

}
