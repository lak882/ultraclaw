# WSGI/ASGI Applications Reference

Run Python web frameworks (Flask, Django, FastAPI) inside IRIS with direct in-process access to globals, SQL, and objects.

## How It Works

The IRIS Web Gateway serves Python WSGI/ASGI applications **in-process** using Embedded Python. No external web server (Gunicorn, uvicorn) is needed. Python code runs inside the IRIS process with direct memory access to IRIS data.

## Configuration

A WSGI app is a CSP Web Application with a special dispatch class and WSGI-specific properties:

| Property | Purpose | Example |
|----------|---------|---------|
| `DispatchClass` | Always `%SYS.Python.WSGI` | `%SYS.Python.WSGI` |
| `WSGIAppLocation` | Absolute filesystem path to app directory | `/opt/iris-apps/myapp/` |
| `WSGIAppName` | Python module name (without `.py`) | `app` |
| `WSGICallable` | WSGI/ASGI callable object in the module | `app` |
| `WSGIType` | `1`=WSGI (sync), `2`=ASGI (async) | `1` for Flask, `2` for FastAPI |

## Framework Matrix

| Framework | WSGIType | WSGICallable | WSGIAppName | Notes |
|-----------|----------|-------------|-------------|-------|
| Flask | `1` (default) | `app` | `app` | Synchronous WSGI |
| Django | `1` | `application` | `<project>.wsgi` | Point location to project root |
| FastAPI | `2` | `app` | `app` | Must set WSGIType=2 for async |

## Creating the Web Application

```objectscript
Kill props
Set props("NameSpace") = "MYNS"
Set props("Type") = 2
Set props("Enabled") = 1
Set props("AutheEnabled") = 64
Set props("DispatchClass") = "%SYS.Python.WSGI"
Set props("WSGIAppLocation") = "/opt/iris-apps/myapp/"
Set props("WSGIAppName") = "app"
Set props("WSGICallable") = "app"
Set props("WSGIType") = 1                // 1=WSGI, 2=ASGI

Set sc = ##class(Security.Applications).Create("/myapp", .props)
```

## Accessing IRIS Data from Python

Since the app runs in-process, the `iris` module is available directly:

### Direct SQL
```python
import iris

rs = iris.sql.exec("SELECT Name, DOB FROM Sample.Person WHERE Age > ?", [30])
for row in rs:
    print(row)
```

### System API
```python
import iris
version = iris.system.Version.GetVersion()
```

### SQLAlchemy (embedded connection)
```python
# No network hop — in-process connection
app.config['SQLALCHEMY_DATABASE_URI'] = 'iris+emb://NAMESPACE'
```

### Interoperability / Production Integration
```python
from iop import Director
# Create OUTSIDE request handler scope (persist across requests)
bs = Director.create_python_business_service('MyBusinessService')

@app.route('/process')
def process():
    response = bs.on_process_input(request_data)
    return response
```

## App File Layout

```
/opt/iris-apps/<app-name>/
  app.py              — main Flask/FastAPI application
  requirements.txt    — Python dependencies
  templates/          — Jinja2 templates (Flask)
  static/             — CSS, JS, images
```

## Installing Python Dependencies

```bash
# Use IRIS's embedded Python pip
/usr/local/InterSystems/IRISHealth/bin/irispython -m pip install flask sqlalchemy

# Or from requirements.txt
/usr/local/InterSystems/IRISHealth/bin/irispython -m pip install -r requirements.txt
```

## Differences from Standalone Python Web Server

| Aspect | IRIS WSGI Gateway | Standalone (Gunicorn/uvicorn) |
|--------|-------------------|-------------------------------|
| Process model | In-process within IRIS | Separate Python process |
| Data access | Direct in-memory via `iris` module | Network connection (ODBC/REST) |
| Port | Uses IRIS web gateway port | Requires its own port |
| Security | Inherits IRIS authentication/roles | Must manage separately |
| Hot reload | Toggle DEBUG in Security Portal | Framework dev server |
| Production server | Web gateway IS the server | Need Gunicorn/uvicorn |

## Gotchas

- **WSGIType=2 is required for async frameworks** (FastAPI). Omitting it with an async framework causes failures.
- **WSGIAppLocation must be absolute** and accessible to the IRIS process user.
- **No hot reload without DEBUG mode** — toggle in the IRIS Security Portal, not in Python code. Without it, code changes require IRIS restart.
- **The `iris` module is only available inside Embedded Python** — not when running standalone Python.
- **Business service lifecycle** — when using `Director.create_python_business_service()`, instantiate at module level (outside request handlers) to avoid creating a new instance per request.
- **SQLAlchemy `__allow_unmapped__`** — required on models when using dataclass decorators with relationships.
