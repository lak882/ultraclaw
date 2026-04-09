/// Receives audit events from Python scripts via HTTP POST and routes
/// them into the production as type-specific pipeline messages.
/// Inspects the Source field to dispatch to the correct message class.
/// Port 9881, PoolSize=1 (adapter starts its own TCP listener).
Class InterClaw.Analytics.BS.AuditHTTPService Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.HTTP.InboundAdapter";

/// Target for persistent audit logging.
Property AuditLogTarget As %String [ InitialExpression = "InterClaw.BO.AuditLog" ];

/// Target for event forwarding (disabled by default).
Property EventHTTPTarget As %String [ InitialExpression = "EventHTTPOperation" ];

/// Target for long-term SQL storage.
Property EventStorageTarget As %String [ InitialExpression = "EventStorageProcess" ];

Parameter SETTINGS = "AuditLogTarget:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},EventHTTPTarget:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},EventStorageTarget:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
    Set sc = $$$OK
    Try {
        // Read JSON body from the HTTP request
        Set body = ""
        If $IsObject($Get(%request)) && $IsObject(%request.Content) {
            Set body = %request.Content.Read(%request.Content.Size)
        } ElseIf $IsObject(pInput) && pInput.%IsA("%Stream.Object") {
            Set body = pInput.Read(pInput.Size)
        }

        If body = "" {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Empty request body"))
        }

        // Peek at Source field to determine message type
        Set dynObj = ##class(%DynamicObject).%FromJSON(body)
        Set source = dynObj.%Get("Source")

        // Instantiate the correct subclass based on Source
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
            $$$LOGWARNING("AuditHTTPService: unknown Source '"_source_"', skipping")
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Unknown Source: "_source))
        }

        // Import JSON into the typed message (ignores irrelevant keys)
        Set sc = event.%JSONImport(body)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        // Route to audit log (persistent storage + trace)
        Set sc = ..SendRequestAsync(..AuditLogTarget, event)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        // Route to event HTTP forwarder (disabled until remote endpoint configured)
        Set sc = ..SendRequestAsync(..EventHTTPTarget, event)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        // Route to long-term SQL storage
        Set sc = ..SendRequestAsync(..EventStorageTarget, event)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        // Return 202 Accepted
        If $IsObject($Get(%response)) {
            Set %response.Status = "202 Accepted"
            Set %response.ContentType = "application/json"
        }
        Set pOutput = ##class(%Stream.GlobalCharacter).%New()
        Do pOutput.Write("{""status"":""accepted"",""type"":"""_event.%ClassName(1)_"""}")

    } Catch ex {
        Set sc = ex.AsStatus()
        If $IsObject($Get(%response)) {
            Set %response.Status = "400 Bad Request"
            Set %response.ContentType = "application/json"
        }
        Set pOutput = ##class(%Stream.GlobalCharacter).%New()
        Do pOutput.Write("{""error"":"""_$Replace($system.Status.GetErrorText(sc),"""","'")_"""}")
    }
    Return sc
}

}
