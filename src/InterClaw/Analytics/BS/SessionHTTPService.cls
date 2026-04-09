/// Receives session analytics JSON via HTTP POST and routes into the production.
/// Configure with EnableStandardRequests=1 and PoolSize=0.
Class InterClaw.Analytics.BS.SessionHTTPService Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.HTTP.InboundAdapter";

/// Target operation to receive session log requests
Property TargetConfigName As %String [ InitialExpression = "SessionForward" ];

Parameter SETTINGS = "TargetConfigName:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

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

        // Deserialize JSON into typed request message
        Set request = ##class(InterClaw.Analytics.Msg.SessionLogRequest).%New()
        Set sc = request.%JSONImport(body)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        // Set submission timestamp if not provided
        If request.SubmittedAt = "" {
            Set request.SubmittedAt = $zdatetime($horolog, 3)
        }

        // Route to forward operation (async — don't block the HTTP response)
        Set sc = ..SendRequestAsync(..TargetConfigName, request)
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        // Return 202 Accepted
        If $IsObject($Get(%response)) {
            Set %response.Status = "202 Accepted"
            Set %response.ContentType = "application/json"
        }
        Set pOutput = ##class(%Stream.GlobalCharacter).%New()
        Do pOutput.Write("{""status"":""accepted""}")

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
