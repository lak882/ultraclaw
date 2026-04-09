/// API call event — covers both Atelier API and InteropEditors API calls.
/// Source: "audit_api" or "audit_interop"
Class InterClaw.Pipeline.Msg.ApiCallEvent Extends InterClaw.Pipeline.Msg.BaseEvent
{

/// HTTP method: GET, PUT, POST, DELETE, HEAD.
Property Method As %String(MAXLEN = 10);

/// Full API URL.
Property URL As %String(MAXLEN = 2000);

/// HTTP response status code.
Property StatusCode As %Integer;

/// Duration in milliseconds.
Property Duration As %Numeric;

/// JSON body sent in the API request.
Property RequestBody As %String(MAXLEN = "");

/// JSON body received in the API response.
Property ResponseBody As %String(MAXLEN = "");

}
