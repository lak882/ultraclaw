# CSP/Zen Applications Reference

Server-rendered web pages on IRIS using `%CSP.Page` (raw HTML) or `%ZEN.Component.page` (component-based UI).

## CSP Pages (`%CSP.Page`)

The simplest web page class. Override `OnPage()` to write HTML. All other IRIS web mechanisms (REST, Zen) are built on top of CSP.

### Class Hierarchy

```
%CSP.Page                    <- Raw CSP pages extend this
  -> %CSP.Login              <- Login pages
    -> %CSP.REST             <- REST APIs
  -> %ZEN.Component.object
    -> ... (chain)
      -> %ZEN.Component.page <- Zen pages extend this
```

### Key Parameters

| Parameter | Default | Purpose |
|-----------|---------|---------|
| `CONTENTTYPE` | `text/html` | HTTP Content-Type header |
| `CHARSET` | `utf-8` | Character encoding |
| `ENCODED` | `0` | Query param encryption (0=none, 1=encrypted) |
| `EXPIRES` | `-1` | Cache control (-1=immediate, ""=never, N=seconds) |
| `PRIVATE` | `0` | 1=only callable server-side |
| `SECURITYRESOURCE` | `""` | Resource:permission required |
| `UseSession` | `1` | Enable CSP sessions |
| `DOMAIN` | `""` | Localization domain |

### Lifecycle Methods

```objectscript
Class MyApp.Page Extends %CSP.Page
{
  // Before headers are sent — set cookies, redirects, content type
  ClassMethod OnPreHTTP() As %Boolean
  {
    Set %response.ContentType = "text/html"
    Quit 1  // Return 0 to abort
  }

  // Generate the response body
  ClassMethod OnPage() As %Status
  {
    Write "<!DOCTYPE html><html><body>"
    Write "<h1>Hello</h1>"
    Write "</body></html>"
    Quit $$$OK
  }

  // Cleanup after response is sent
  ClassMethod OnPostHTTP()
  {
    // cleanup logic
  }

  // Error handler
  ClassMethod OnPageError(ByRef sc As %Status)
  {
    // Set sc = $$$OK to suppress default error display
  }
}
```

### Request/Response Objects

Always available in page methods:

- **`%request`** (`%CSP.Request`) — URL params, form data, cookies, HTTP headers
  - `%request.Get("param")` — get URL query parameter
  - `%request.GetCookie("name")` — get cookie value
  - `%request.Method` — HTTP method (GET/POST)
  - `%request.URL` — request URL
  - `%request.Content` — request body (stream)

- **`%response`** (`%CSP.Response`) — controls the HTTP response
  - `%response.ContentType` — set content type
  - `%response.Status` — set status code ("200 OK", "404 Not Found")
  - `%response.SetCookie("name", "value")` — set cookie
  - `%response.Redirect(url)` — redirect (must be in OnPreHTTP)
  - `%response.SetHeader("name", "value")` — set custom header

- **`%session`** (`%CSP.Session`) — session persistence
  - `%session.Data("key")` — get/set session data
  - `%session.AppTimeout` — session timeout
  - `%session.Username` — authenticated user

### Utility Methods

| Method | Purpose |
|--------|---------|
| `..EscapeHTML(str)` | HTML entity encoding |
| `..EscapeURL(str)` | URL encoding |
| `..Link(url, params...)` | Generate URL with session tokens |
| `..QuoteJS(str)` | JavaScript string escaping |
| `..InsertHiddenField(name, val)` | Form hidden field with encryption |
| `..Include(url)` | Server-side page inclusion |

---

## Zen Pages (`%ZEN.Component.page`)

Component-based UI framework built on CSP. Declare page layout in XML, add client-side JavaScript methods.

**Note: Zen is deprecated.** InterSystems recommends Angular-based UI for new development. However, Zen is still widely used and fully functional.

### Zen Application Class

Optional — provides app-wide CSS, JS, and configuration:

```objectscript
Class MyApp.App Extends %ZEN.application
{
  Parameter APPLICATIONNAME = "My Application";
  Parameter HOMEPAGE = "MyApp.Dashboard.cls";
  Parameter CSSINCLUDES = "styles/main.css";
  Parameter JSINCLUDES = "scripts/utils.js";

  XData Style
  {
    <style type="text/css">
      body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
    </style>
  }
}
```

### Zen Page Class

```objectscript
Class MyApp.Dashboard Extends %ZEN.Component.page
{
  Parameter APPLICATION = "MyApp.App";
  Parameter PAGENAME = "Dashboard";

  // Component tree declared in XML
  XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
  {
    <page xmlns="http://www.intersystems.com/zen" title="Dashboard">
      <vgroup>
        <label id="title" value="System Dashboard"/>
        <tablePane id="tbl"
          sql="SELECT TOP 20 Name, Age FROM Sample.Person ORDER BY Name"
          showZebra="true"/>
        <button caption="Refresh" onclick="zenPage.refreshTable();"/>
      </vgroup>
    </page>
  }

  // Page-specific CSS
  XData Style
  {
    <style type="text/css">
      #title { font-size: 1.5em; font-weight: bold; }
    </style>
  }

  // Client-side JavaScript
  ClientMethod refreshTable() [ Language = javascript ]
  {
    var tbl = zen('tbl');
    tbl.executeQuery();
  }

  // Server-side callbacks
  Method %OnAfterCreatePage() As %Status
  {
    // Modify components after creation
    Set tbl = ..%GetComponentById("tbl")
    Quit $$$OK
  }
}
```

### Key Zen Components

**Layout containers:**
- `<vgroup>` — vertical layout
- `<hgroup>` — horizontal layout
- `<group>` — generic container
- `<form>` — HTML form
- `<tabGroup>` / `<tab>` — tabbed interface
- `<fieldSet>` — fieldset with legend

**Data display:**
- `<tablePane>` — SQL-driven data table
- `<label>` — text label
- `<html>` — raw HTML content

**Input controls:**
- `<text>` — text input
- `<textarea>` — multiline text
- `<select>` / `<option>` — dropdown
- `<checkbox>` — checkbox
- `<button>` — button
- `<dateText>` — date picker

**Component access:**
- Server: `..%GetComponentById("id")`, `..%SetValueById("id", value)`
- Client JS: `zen('id')`, `zenPage.getComponentById('id')`

### Zen Lifecycle Callbacks

| Method | When |
|--------|------|
| `%OnBeforeCreatePage()` | Before page object created |
| `%OnCreatePage()` | After object created, before children |
| `%OnAfterCreatePage()` | After full page creation |
| `%OnDrawHTMLHead()` | Custom HEAD content |
| `%OnDrawHTMLBody()` | Custom BODY content |

---

## Package Naming Convention

```
<Pkg>.App                    — Zen application class
<Pkg>.Page.<Name>            — CSP page classes
<Pkg>.Zen.<Name>             — Zen page classes
```
