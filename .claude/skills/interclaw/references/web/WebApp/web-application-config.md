# CSP Web Application Configuration Reference

Every web application in IRIS (REST, WSGI, CSP, Zen) requires a **CSP Web Application** entry that maps a URL path to a namespace and dispatch mechanism. These are stored as `Security.Applications` objects.

## Creating a Web Application

### Via ObjectScript (iris_terminal)

```objectscript
Kill props
Set props("NameSpace") = "MYNS"
Set props("Type") = 2                    // 2 = CSP/REST web application
Set props("Enabled") = 1
Set props("AutheEnabled") = 64           // 64 = Unauthenticated
Set props("CSPZENEnabled") = 1           // Process CSP/Zen pages
Set props("ServeFiles") = 1              // 0=No, 1=Always, 2=Cached
Set props("DispatchClass") = ""          // Set for REST/WSGI; empty for CSP
Set props("Path") = ""                   // Physical dir for static files
Set props("Timeout") = 900              // Session timeout (seconds)
Set props("UseCookies") = 1             // 0=Never, 1=Auto, 2=Always

Set sc = ##class(Security.Applications).Create("/csp/myapp", .props)
Write $Select($system.Status.IsError(sc):"ERROR: "_$system.Status.GetErrorText(sc), 1:"OK"),!
```

### Via Management Portal

System Administration > Security > Applications > Web Applications > Create New

## Type-Specific Configuration

### REST Application
```objectscript
Set props("DispatchClass") = "MyApp.REST.Dispatch"
Set props("CSPZENEnabled") = 0           // Not needed for pure REST
Set props("ServeFiles") = 0              // No static files (or 1 for SPA)
```

### WSGI Application
```objectscript
Set props("DispatchClass") = "%SYS.Python.WSGI"
Set props("WSGIAppLocation") = "/opt/iris-apps/myapp/"
Set props("WSGIAppName") = "app"
Set props("WSGICallable") = "app"
Set props("WSGIType") = 1               // 1=WSGI (Flask), 2=ASGI (FastAPI)
```

### CSP/Zen Application
```objectscript
Set props("DispatchClass") = ""          // No dispatch — pages accessed by class name
Set props("CSPZENEnabled") = 1           // Required
Set props("ServeFiles") = 1              // Serve static files
Set props("Path") = "/opt/myapp/static"  // Optional: physical file directory
```

## Properties Reference

| Property | Values | Purpose |
|----------|--------|---------|
| `Name` | `/path` (max 64 chars) | URL prefix (must start with `/`) |
| `Type` | `2` | 2=CSP/REST web application |
| `NameSpace` | namespace name | IRIS namespace for execution |
| `DispatchClass` | class name or empty | REST/WSGI dispatch class; empty for CSP |
| `Enabled` | `0`/`1` | Whether the app is active |
| `AutheEnabled` | bitmask | Authentication method(s) — see below |
| `ServeFiles` | `0`/`1`/`2`/`3` | 0=No, 1=Always, 2=Cached, 3=Security-checked |
| `CSPZENEnabled` | `0`/`1` | Process CSP/Zen page classes |
| `Path` | filesystem path | Physical directory for static files / .csp files |
| `Resource` | resource name | Security resource (empty=public) |
| `Timeout` | seconds | Session timeout |
| `UseCookies` | `0`/`1`/`2` | 0=Never, 1=Auto, 2=Always |
| `MatchRoles` | `role:target,...` | Role mapping |
| `CSRFToken` | `0`/`1` | CSRF protection |

### WSGI-Specific Properties

| Property | Purpose |
|----------|---------|
| `WSGIAppLocation` | Absolute filesystem path to Python app directory |
| `WSGIAppName` | Python module name (without `.py`) |
| `WSGICallable` | WSGI/ASGI callable object name |
| `WSGIType` | 1=WSGI (sync), 2=ASGI (async) |

### CORS Properties

| Property | Purpose |
|----------|---------|
| `CorsAllowlist` | Comma-separated allowed origins |
| `CorsCredentialsAllowed` | `0`/`1` — allow credentials |
| `CorsHeadersList` | Comma-separated allowed headers |

## Authentication Bitmask (`AutheEnabled`)

| Value | Method |
|-------|--------|
| 32 | Password authentication |
| 64 | Unauthenticated access |
| 96 | Password + Unauthenticated (32+64) |
| 8192 | LDAP |

## Managing Web Applications

```objectscript
// Check if exists
Write ##class(Security.Applications).Exists("/api/myapp"),!

// Get current config
Set sc = ##class(Security.Applications).Get("/api/myapp", .props)
// props("NameSpace"), props("DispatchClass"), etc.

// Modify
Kill props
Set props("Enabled") = 0
Set sc = ##class(Security.Applications).Modify("/api/myapp", .props)

// Delete
Set sc = ##class(Security.Applications).Delete("/api/myapp")

// Copy
Set sc = ##class(Security.Applications).Copy("/api/myapp", "/api/myapp-v2", "Copy of myapp")
```

## URL Routing

When a request arrives at `/api/myapp/v1/items`:

1. IRIS matches the longest URL prefix → finds `/api/myapp`
2. Strips the prefix → passes `/v1/items` to the dispatch class
3. **REST**: Dispatch class matches against its `XData UrlMap` routes
4. **WSGI**: `%SYS.Python.WSGI` forwards to the Python WSGI/ASGI callable
5. **CSP/Zen**: IRIS maps the remaining path to a class name (e.g., `MyApp.Page.cls`)

## Static File Serving

Three approaches:

1. **Same web app** — Set `ServeFiles=1` and `Path=/opt/myapp/static`. Files served at the app's URL prefix.

2. **Separate web app** — Create a second app (e.g., `/static/myapp`) pointing to the static directory, no dispatch class.

3. **Embedded in classes** — Use `CSSINCLUDES`, `JSINCLUDES` parameters or `XData Style` blocks (Zen only).

## Common Patterns

### REST API with Static SPA Frontend
```objectscript
// API endpoints
Set props("Name") = "/api/myapp"
Set props("DispatchClass") = "MyApp.REST.Dispatch"
Set props("ServeFiles") = 0

// SPA frontend (separate app)
Set props("Name") = "/myapp"
Set props("DispatchClass") = ""
Set props("Path") = "/opt/myapp/dist"
Set props("ServeFiles") = 1
Set props("CSPZENEnabled") = 0
```

### Authenticated API
```objectscript
Set props("AutheEnabled") = 32          // Password auth required
Set props("Resource") = "MyApp_Access"  // Must hold this resource
```
