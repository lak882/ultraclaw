# REST Applications Reference

Build JSON APIs and SPA backends on IRIS using `%CSP.REST`.

## Two Approaches

### A. Manual (`%CSP.REST` subclass)

Create a class extending `%CSP.REST`, define routes in `XData UrlMap`, implement handler ClassMethods. Best for simple APIs where you want full control.

### B. Spec-First (OpenAPI 2.0)

Write an OpenAPI 2.0 JSON spec. IRIS auto-generates three classes:

| Class | Extends | Regenerated? | Purpose |
|-------|---------|-------------|---------|
| `<Pkg>.spec` | `%REST.Spec` | YES | Stores OpenAPI JSON in `XData OpenAPI` |
| `<Pkg>.disp` | `%REST.disp` | YES | Auto-generated UrlMap from spec |
| `<Pkg>.impl` | `%REST.Impl` | NO (preserved) | Stub methods you fill in |

Best for contract-driven APIs with documentation.

## Class Hierarchy

```
%CSP.Page
  -> %CSP.Login
    -> %CSP.REST          <- Manual REST classes extend this
      -> %REST.disp       <- Spec-first dispatch classes extend this

%REST.Impl               <- Spec-first implementation classes extend this
%REST.Spec               <- Spec-first spec storage classes extend this
```

## UrlMap XData Block (Manual Approach)

```xml
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
  <Routes>
    <Route Url="/items" Method="GET" Call="GetItems" />
    <Route Url="/items/:id" Method="GET" Call="GetItem" />
    <Route Url="/items" Method="POST" Call="CreateItem" />
    <Route Url="/items/:id" Method="PUT" Call="UpdateItem" />
    <Route Url="/items/:id" Method="DELETE" Call="DeleteItem" />
    <Map Prefix="/v1" Forward="MyApp.REST.v1.Dispatch" />
  </Routes>
}
```

**URL pattern rules:**
- `:paramName` — named parameter, passed as method argument by position
- `(.*)` — regex capture group, passed as method argument
- `/v[0-9]*/` — regex for version-flexible matching
- Routes match top-to-bottom, first match wins
- `<Map>` forwards a URL prefix to another `%CSP.REST` subclass (modular APIs)

## Handler Method Signatures

```objectscript
ClassMethod GetItem(id As %String) As %Status
{
    // Read query parameters
    Set searchTerm = %request.Get("q")

    // Read JSON request body (POST/PUT)
    Set body = ##class(%DynamicObject).%FromJSON(%request.Content)

    // Set response
    Set %response.ContentType = "application/json"
    Set %response.Status = "200 OK"

    // Write JSON response
    Set result = {"name": "example", "id": (id)}
    Write result.%ToJSON()
    Quit $$$OK
}
```

**Available request/response objects:**
- `%request` (`%CSP.Request`) — URL params (`.Get()`), form data, cookies, headers
- `%response` (`%CSP.Response`) — status code, headers, content type, cookies
- `%session` (`%CSP.Session`) — session data (only if `UseSession=1`)

## Key %CSP.REST Parameters

| Parameter | Default | Purpose |
|-----------|---------|---------|
| `UseSession` | `0` | `0`=stateless (best practice), `1`=enable CSP sessions |
| `HandleCorsRequest` | `""` | `""`=not set, `1`=enable CORS, `0`=disable |
| `CONTENTTYPE` | `text/html` | Default response content type |
| `CHARSET` | `utf-8` | Character encoding |

**HTTP status constants:** `..#HTTP200OK`, `..#HTTP201CREATED`, `..#HTTP204NOCONTENT`, `..#HTTP400BADREQUEST`, `..#HTTP401UNAUTHORIZED`, `..#HTTP403FORBIDDEN`, `..#HTTP404NOTFOUND`, `..#HTTP500INTERNALSERVERERROR`

## Hooks

### OnPreDispatch — runs before every request

```objectscript
ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pContinue As %Boolean) As %Status
{
    // Logging, auth checks, rate limiting
    // Set pContinue=0 to abort dispatch
    Quit $$$OK
}
```

### AccessCheck — authorization hook

Override to implement custom authorization logic. Called before route matching.

## Spec-First: Creating from OpenAPI

### Via ObjectScript
```objectscript
Set spec = ##class(%DynamicObject).%FromJSON(specJSON)
Set sc = ##class(%REST.API).CreateApplication("/api/myapp", spec, .features, .newApp, .err)
```

### Via REST endpoint
```
POST /api/mgmnt/v2/{namespace}/{applicationName}
Content-Type: application/json
Body: <OpenAPI 2.0 JSON>
```

### Regeneration behavior
- Calling `CreateApplication()` again overwrites spec + dispatch, **preserves impl**
- `DeleteApplication()` removes spec + dispatch, **preserves impl**

## Spec-First Implementation Methods

Methods inherited from `%REST.Impl`:

| Method | Purpose |
|--------|---------|
| `%GetHeader(name)` | Read request header |
| `%SetHeader(name, value)` | Set response header |
| `%GetContentType()` | Get request content type |
| `%SetContentType(type)` | Set response content type |
| `%SetStatusCode(code)` | Set HTTP status code |
| `%WriteResponse(response)` | Write response body |
| `%CheckAccepts(produces)` | Validate Accept header |
| `%ReportRESTError(code, sc, expose)` | Error reporting |

## CORS Configuration

### Via class parameter
```objectscript
Parameter HandleCorsRequest = 1;
```

### Via web application properties
```objectscript
Set props("CorsAllowlist") = "https://app.example.com,https://other.example.com"
Set props("CorsCredentialsAllowed") = 1
Set props("CorsHeadersList") = "X-Custom-Header,Authorization"
```

## Sub-Dispatch Pattern (Modular APIs)

Split large APIs across multiple classes:

```objectscript
// Main dispatch
Class MyApp.REST.Dispatch Extends %CSP.REST
{
  XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
  {
    <Routes>
      <Map Prefix="/v1/items" Forward="MyApp.REST.v1.Items" />
      <Map Prefix="/v1/users" Forward="MyApp.REST.v1.Users" />
    </Routes>
  }
}

// Sub-dispatch for /v1/items/*
Class MyApp.REST.v1.Items Extends %CSP.REST
{
  XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
  {
    <Routes>
      <Route Url="/" Method="GET" Call="List" />
      <Route Url="/:id" Method="GET" Call="Get" />
    </Routes>
  }

  ClassMethod List() As %Status { /* ... */ }
  ClassMethod Get(id As %String) As %Status { /* ... */ }
}
```

## Package Naming Convention

```
<Pkg>.REST.Dispatch          — main dispatch class
<Pkg>.REST.v1.Dispatch       — versioned sub-dispatch
<Pkg>.REST.v1.<Resource>     — resource-specific sub-dispatch
<Pkg>.REST.Impl              — implementation (spec-first)
<Pkg>.REST.Spec              — OpenAPI spec storage (spec-first)
```
