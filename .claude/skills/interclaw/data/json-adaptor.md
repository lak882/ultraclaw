# JSON Adapter Reference

The `%JSON.Adaptor` class provides JSON serialization/deserialization for ObjectScript classes. Any class that extends `%JSON.Adaptor` gains `%JSONImport` and `%JSONExport` methods.

## Class Hierarchy for JSON Messages

```
%SerialObject + %JSON.Adaptor + %XML.Adaptor   — embedded sub-objects (nested JSON objects)
Ens.Request + %JSON.Adaptor + %XML.Adaptor     — top-level request message
Ens.Response + %JSON.Adaptor + %XML.Adaptor    — top-level response message
```

**Important:** All JSON message classes (and any serial classes they reference) must extend `%XML.Adaptor`. Without it, IRIS cannot display message contents in the Visual Trace and shows ERROR #6249.

### Key Methods

| Method | Description |
|--------|-------------|
| `%JSONImport(input)` | Import JSON (string, stream, or %DynamicAbstractObject) into the object |
| `%JSONExport()` | Export object as JSON to current device |
| `%JSONExportToString(.output)` | Export object as JSON string (by reference) |
| `%JSONExportToStream(.stream)` | Export object as JSON to a stream |

### Property Parameters

| Parameter | Description |
|-----------|-------------|
| `%JSONFIELDNAME` | JSON field name (defaults to property name) |
| `%JSONINCLUDE` | `"inout"` (default), `"outputonly"`, `"inputonly"`, `"none"` |
| `%JSONNULL` | `0` (default) skips empty; `1` exports as `null` |
| `%JSONIGNOREINVALIDFIELD` | `0` (default) errors on unknown fields; `1` ignores them |
| `%JSONREFERENCE` | `"OBJECT"` (default), `"ID"`, `"OID"`, `"GUID"` |

### Example: Mapping JSON field names

```objectscript
Class MyApp.Msg.Patient Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{
Property FirstName As %String(%JSONFIELDNAME = "first_name");
Property LastName As %String(%JSONFIELDNAME = "last_name");
Property DateOfBirth As %String(%JSONFIELDNAME = "dob");
}
```

## JSON HTTP Service Pattern

To receive JSON via HTTP in a production, create a custom service that extends `EnsLib.HTTP.GenericService`:

```objectscript
Class <Pkg>.BS.JSONHTTPService Extends EnsLib.HTTP.GenericService
{

Parameter ADAPTER = "EnsLib.HTTP.InboundAdapter";

Parameter SETTINGS = "JSONObjectClass:Basic:selector?context={Ens.ContextSearch/MessageClasses?mode=request}";

Property JSONObjectClass As %String;

Method OnProcessInput(pRequestBody As %CharacterStream, pResponseBody As %CharacterStream, ByRef pAction As %String) As %Status
{
    #Dim tSC As %Status = $$$OK

    If $$$IsdefObject(%request) {
        Set %session.UseSessionCookie = 0
        Set %response.OutputSessionToken = 0
    }
    Set pResponseBody = $$$NULLOREF

    If ..JSONObjectClass = "" {
        Set pResponseBody("ResponseCode") = "500 JSONObjectClass not configured"
        Return $$$ERROR($$$GeneralError, "JSONObjectClass not configured")
    }

    Try {
        Set tRequest = $CLASSMETHOD(..JSONObjectClass, "%New")
        Set tDynamic = ##class(%DynamicAbstractObject).%FromJSON(pRequestBody)
        Set tSC = tRequest.%JSONImport(tDynamic)
        If $$$ISERR(tSC) {
            Set pResponseBody("ResponseCode") = "400 JSON import error"
            Return tSC
        }
    } Catch ex {
        Set pResponseBody("ResponseCode") = "400 JSON parse error"
        Return ex.AsStatus()
    }

    If ..OneWay {
        Set tSC = ..SendRequestAsync(..TargetConfigName, tRequest)
        Set:$$$ISOK(tSC) pResponseBody("ResponseCode") = "202 Accepted"
    } Else {
        Set tSC = ..SendRequestSync(..TargetConfigName, tRequest, .tResponse)
        If $$$ISOK(tSC) && $$$IsdefObject(tResponse) && tResponse.%Extends("%JSON.Adaptor") {
            Do tResponse.%JSONExportToString(.tJSON)
            Set tStream = ##class(%GlobalCharacterStream).%New()
            Do tStream.Write(tJSON)
            Set pResponseBody = tStream
            Set pResponseBody("Content-Type") = "application/json"
            Set pResponseBody("ResponseCode") = "200 OK"
        }
    }
    Return tSC
}

}
```

### Production Configuration

```xml
<Item Name="JSON.HTTPService" Category="JSON Inbound" ClassName="<Pkg>.BS.JSONHTTPService" PoolSize="0" Enabled="true">
  <Setting Target="Host" Name="EnableStandardRequests">1</Setting>
  <Setting Target="Host" Name="JSONObjectClass"><Pkg>.Msg.JSONRequest</Setting>
  <Setting Target="Host" Name="TargetConfigName">TargetName</Setting>
  <Setting Target="Host" Name="OneWay">1</Setting>
</Item>
```

- `PoolSize="0"` + `EnableStandardRequests=1` routes through CSP web gateway
- `OneWay=1` for fire-and-forget (returns 202 Accepted)
- `OneWay=0` for synchronous response (returns JSON if response extends %JSON.Adaptor)

### Sending JSON

```bash
<python> .claude/skills/interclaw/scripts/hl7/send_json.py \
  --server <server> \
  --url "/irishealth/csp/healthshare/<namespace>/<ServiceClassName>.cls?CfgItem=<ConfigItemName>" \
  --input payload.json
```

## JSON-to-ObjectScript Type Mapping

| JSON Type | ObjectScript Type |
|-----------|------------------|
| String | `%String` |
| Number (integer) | `%Integer` |
| Number (decimal) | `%Numeric` or `%Double` |
| Boolean | `%Boolean` |
| Null | (property left empty) |
| Nested object | `%SerialObject` + `%JSON.Adaptor` |
| Array of objects | `list Of <SerialClass>` |
| Array of strings | `list Of %String` |
| Array of numbers | `list Of %Integer` or `list Of %Numeric` |

## JSON File Operation Pattern

To write JSON messages to files, create an operation that exports %JSON.Adaptor objects:

```objectscript
Class <Pkg>.BO.JSONFileOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";
Property Adapter As EnsLib.File.OutboundAdapter;
Parameter INVOCATION = "Queue";

Method OnMessage(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    Set tSC = $$$OK
    If pRequest.%Extends("%JSON.Adaptor") {
        Set tSC = pRequest.%JSONExportToString(.tJSON)
        If $$$ISERR(tSC) Return tSC
        Set tFormatter = ##class(%JSON.Formatter).%New()
        Do tFormatter.FormatToString(tJSON, .tFormatted)
        Set tFilename = "json_"_$TR($ZDT($H,3,1)," :-","___")_".json"
        Set tSC = ..Adapter.PutString(tFilename, tFormatted)
    }
    Return tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="Ens.Request">
    <Method>OnMessage</Method>
  </MapItem>
</MapItems>
}

}
```
