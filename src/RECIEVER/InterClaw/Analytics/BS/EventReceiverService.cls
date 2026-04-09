/// Receives forwarded audit events via HTTP POST and routes them
/// to EventStorageProcess for long-term SQL storage.
/// Inspects the Source field to instantiate the correct message subclass.
Class InterClaw.Analytics.BS.EventReceiverService Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.HTTP.InboundAdapter";

/// Target BP for SQL storage.
Property StorageTarget As %String [ InitialExpression = "EventStorageProcess" ];

Parameter SETTINGS = "StorageTarget:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
    Set sc = $$$OK
    Try {
        // Read JSON body
        Set body = ""
        If $IsObject($Get(%request)) && $IsObject(%request.Content) {
            Set body = %request.Content.Read(%request.Content.Size)
        } ElseIf $IsObject(pInput) && pInput.%IsA("%Stream.Object") {
            Set body = pInput.Read(pInput.Size)
        }

        If body = "" {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Empty request body"))
        }

        // Peek at Source to determine message type
        Set dynObj = ##class(%DynamicObject).%FromJSON(body)
        Set source = dynObj.%Get("Source")

        // Instantiate correct subclass
        If (source = "audit_api") || (source = "audit_interop") {
            Set event = ##class(InterClaw.Pipeline.Msg.ApiCallEvent).%New()
        } ElseIf source = "audit_terminal" {
            Set event = ##class(InterClaw.Pipeline.Msg.TerminalEvent).%New()
        } ElseIf source = "audit_file_change" {
            Set event = ##class(InterClaw.Pipeline.Msg.FileChangeEvent).%New()
        } ElseIf source = "audit_doc_get" {
            Set event = ##class(InterClaw.Pipeline.Msg.DocumentGetEvent).%New()
        } ElseIf source = "audit_doc_put" {
            Set event = ##class(InterClaw.Pipeline.Msg.DocumentPutEvent).%New()
        } ElseIf source = "audit_doc_compile" {
            Set event = ##class(InterClaw.Pipeline.Msg.CompileEvent).%New()
        } ElseIf source = "audit_doc_query" {
            Set event = ##class(InterClaw.Pipeline.Msg.QueryEvent).%New()
        } ElseIf source = "chat" {
            Set event = ##class(InterClaw.Pipeline.Msg.ChatPipelineEvent).%New()
        } Else {
            $$$LOGWARNING("EventReceiverService: unknown Source '"_source_"', skipping")
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Unknown Source: "_source))
        }

        // Import JSON into typed message
        Set sc = event.%JSONImport(body)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        // Route to storage BP
        Set sc = ..SendRequestAsync(..StorageTarget, event)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        // Return 202 Accepted
        Set pOutput = ##class(%Stream.GlobalCharacter).%New()
        Do pOutput.Write("{""status"":""accepted"",""type"":"""_event.%ClassName(1)_"""}")

    } Catch ex {
        Set sc = ex.AsStatus()
        Set pOutput = ##class(%Stream.GlobalCharacter).%New()
        Do pOutput.Write("{""error"":"""_$Replace($system.Status.GetErrorText(sc),"""","'")_"""}")
    }
    Return sc
}

}
