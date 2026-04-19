Create or manage an IRIS web application (REST API, WSGI/Python, or CSP/Zen page).

Usage: /web-app <description | action> [arguments]

Actions:
- **(default) description** — Generate a web application from a natural language description
- **list** — List existing CSP web applications
- **create** — Create a CSP web application entry (URL-to-namespace mapping)
- **delete** — Delete a CSP web application entry
- **get** — Show configuration of an existing web application

Types (specify with `--type`):
- **rest** — `%CSP.REST` dispatch class with UrlMap routing (default)
- **wsgi** — Python Flask/Django/FastAPI via `%SYS.Python.WSGI`
- **csp** — Server-rendered `%CSP.Page` or `%ZEN.Component.page`

Examples:
- /web-app REST API for managing patients with CRUD endpoints in package Demo.PatientAPI
- /web-app Flask app that serves a patient dashboard with SQL queries
- /web-app CSP page that displays system status
- /web-app list
- /web-app get /api/myapp
- /web-app create /api/myapp --namespace MYNS --type rest --dispatch MyApp.REST.Dispatch
- /web-app delete /api/myapp

---

## Parsing

Parse "$ARGUMENTS". Extract:
- If the first word is `list`, `create`, `delete`, `get` — treat as that action
- Otherwise — treat the entire argument string as a natural language description

Determine the active server and namespace from the conversation context.

---

## Action: list

```bash
<python> .claude/skills/interclaw/scripts/infrastructure/manage_webapp.py --server <server> --list
```

Optionally filter by namespace:
```bash
<python> .claude/skills/interclaw/scripts/infrastructure/manage_webapp.py --server <server> --list --filter-namespace <ns>
```

## Action: get

```bash
<python> .claude/skills/interclaw/scripts/infrastructure/manage_webapp.py --server <server> --get <name>
```

## Action: create

```bash
<python> .claude/skills/interclaw/scripts/infrastructure/manage_webapp.py --server <server> --create <name> --namespace <ns> --type <rest|wsgi|csp> [options]
```

Options:
- `--dispatch <class>` — dispatch class (required for REST)
- `--path <dir>` — physical directory for static files
- `--auth <bitmask>` — authentication (32=password, 64=unauthenticated)
- `--serve-files <0|1|2|3>` — static file serving mode
- `--cors-origins <origins>` — comma-separated CORS allowed origins
- `--wsgi-location <path>` — WSGI: Python app directory
- `--wsgi-module <name>` — WSGI: Python module name
- `--wsgi-callable <name>` — WSGI: callable object name
- `--wsgi-async` — WSGI: use ASGI mode (for FastAPI)

## Action: delete

```bash
<python> .claude/skills/interclaw/scripts/infrastructure/manage_webapp.py --server <server> --delete <name>
```

---

## Action: Generate Web Application from Description

When the arguments are a natural language description, follow this workflow based on the detected type.

### Step 1 — Determine the type and package

From the description, determine:
- **Type**: REST, WSGI, or CSP/Zen
  - Keywords like "REST", "API", "endpoint", "JSON" → REST
  - Keywords like "Flask", "Django", "FastAPI", "Python web", "dashboard" → WSGI
  - Keywords like "CSP page", "Zen", "server page", "HTML page" → CSP
- **Package name**: Extract from description or ask the user
- **Namespace**: Use the connected namespace

### Step 2 — Read references

Read the relevant reference docs:
- REST: `.claude/skills/interclaw-infra/rest-applications.md`
- WSGI: `.claude/skills/interclaw-infra/wsgi-applications.md`
- CSP/Zen: `.claude/skills/interclaw-infra/csp-zen-applications.md`
- Always: `.claude/skills/interclaw-infra/web-application-config.md`

### Step 3 — Plan

Show the user a plan with:
- All classes to create (dispatch, handlers, page classes)
- The CSP web application configuration (URL path, namespace, auth)
- Any static files or Python app files needed

---

### REST Workflow

#### Step 4a — Generate the dispatch class

Read the template: `.claude/skills/interclaw-infra/rest-dispatch.cls.template`

Create a `%CSP.REST` subclass with:
- `XData UrlMap` with routes for all endpoints
- Handler ClassMethods for each route
- Proper use of `%request`, `%response`, `%DynamicObject`
- JSON responses with error handling

For large APIs, use the sub-dispatch pattern (`<Map>` forwarding).

Write to `src/<Namespace>/<Pkg>/REST/Dispatch.cls` (and sub-dispatches if needed).

#### Step 5a — Push and compile

```bash
<python> .claude/skills/interclaw/scripts/documents/put_doc.py --server <server> --namespace <ns> --doc <Pkg>.REST.Dispatch.cls --input src/<Namespace>/<Pkg>/REST/Dispatch.cls --compile --force
```

#### Step 6a — Create the web application

```bash
<python> .claude/skills/interclaw/scripts/infrastructure/manage_webapp.py --server <server> --create /api/<app-path> --namespace <ns> --type rest --dispatch <Pkg>.REST.Dispatch --auth 64
```

#### Step 7a — Test

Test each endpoint with curl-style requests using the Atelier API or direct HTTP:
```bash
<python> .claude/skills/interclaw/scripts/hl7/send_json.py --server <server> --url /<pathPrefix>/api/<app-path>/<route> --input <test-payload.json>
```

Use `run_query.py --sql "..."` to verify data was created/modified correctly.

---

### WSGI Workflow

#### Step 4b — Generate the Python app

Read the relevant template:
- Flask: `.claude/skills/interclaw-infra/flask-app.py.template`
- FastAPI: `.claude/skills/interclaw-infra/fastapi-app.py.template`

Create the Python application file with:
- Route handlers for all endpoints
- IRIS data access via the `iris` module
- Proper error handling

Determine the app deployment path on the IRIS server (e.g., `<IRIS>/csp/interclaw/apps/<app-name>/`).

#### Step 5b — Deploy the Python app

Create the directory and copy the app file:
```bash
mkdir -p <IRIS>/csp/interclaw/apps/<app-name>
cp <local-app-file> <IRIS>/csp/interclaw/apps/<app-name>/app.py
```

#### Step 6b — Install dependencies (if needed)

```bash
python3 -m pip install <packages>
```

#### Step 7b — Create the web application

```bash
<python> .claude/skills/interclaw/scripts/infrastructure/manage_webapp.py --server <server> --create /<app-path> --namespace <ns> --type wsgi --wsgi-location /opt/iris-apps/<app-name>/ --wsgi-module app --wsgi-callable app [--wsgi-async]
```

Use `--wsgi-async` for FastAPI.

#### Step 8b — Test

Provide the URL for testing: `http://<host>:<port>/<app-path>/`

---

### CSP/Zen Workflow

#### Step 4c — Generate the page class(es)

Read the relevant template:
- CSP: `.claude/skills/interclaw-infra/csp-page.cls.template`
- Zen: `.claude/skills/interclaw-infra/zen-page.cls.template` + `.claude/skills/interclaw-infra/zen-app.cls.template`

Create the page class(es) with appropriate content.

Write to `src/<Namespace>/<Pkg>/Page/<ClassName>.cls` or `src/<Namespace>/<Pkg>/Zen/<ClassName>.cls`.

#### Step 5c — Push and compile

```bash
<python> .claude/skills/interclaw/scripts/documents/put_doc.py --server <server> --namespace <ns> --doc <Pkg>.Page.<Name>.cls --input src/<Namespace>/<Pkg>/Page/<Name>.cls --compile --force
```

#### Step 6c — Create the web application

```bash
<python> .claude/skills/interclaw/scripts/infrastructure/manage_webapp.py --server <server> --create /csp/<app-path> --namespace <ns> --type csp --serve-files 1
```

#### Step 7c — Test

Provide the URL: `http://<host>:<port>/csp/<app-path>/<Pkg>.Page.<Name>.cls`

---

## Summary

After completing any workflow:
1. Show the user what was created (classes, files, web app config)
2. Provide the access URL for testing
3. Provide a clickable Management Portal link to the web application config:
   `[Web App Config](http://<host>:<port>/csp/sys/sec/%25CSP.UI.Portal.Applications.WebList.zen)`
