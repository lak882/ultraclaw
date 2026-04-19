/// InterClaw.REST.Dispatch — Pure %CSP.REST backend for the Claude chatbot sidebar.
/// All endpoint logic is embedded Python. Streaming endpoints (init, message)
/// write SSE events to a temp file; ObjectScript forwards via Write+Flush.
Class InterClaw.REST.Dispatch Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

Parameter CHARSET = "utf-8";

/// Resolve CWD dynamically: ^InterClaw.Config > env var > fallback
ClassMethod GetCWD() As %String
{
    set val = $get(^InterClaw.Config("CWD"))
    if val '= "" return val
    return ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(##class(%File).SubDirectoryName($system.Util.InstallDirectory(), "csp"), "interclaw"))
}

/// Resolve CLIHOME dynamically: ^InterClaw.Config > env var > fallback
ClassMethod GetCLIHome() As %String
{
    set val = $get(^InterClaw.Config("CLIHOME"))
    if val '= "" return val
    return ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(##class(%File).SubDirectoryName($system.Util.InstallDirectory(), "mgr"), "interclaw_home"))
}

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/api/health"              Method="GET"   Call="Health"/>
<Route Url="/api/config"              Method="GET"   Call="Config"/>
<Route Url="/api/commands"            Method="GET"   Call="Commands"/>
<Route Url="/api/permissions"         Method="GET"   Call="GetPermissions"/>
<Route Url="/api/permissions"         Method="POST"  Call="SetPermissions"/>
<Route Url="/api/auth-status"         Method="GET"   Call="AuthStatus"/>
<Route Url="/api/authenticate"        Method="POST"  Call="Authenticate"/>
<Route Url="/api/deauthenticate"      Method="POST"  Call="Deauthenticate"/>
<Route Url="/api/login"               Method="POST"  Call="Login"/>
<Route Url="/api/logout"              Method="POST"  Call="Logout"/>
<Route Url="/api/init"                Method="POST"  Call="InitSession"/>
<Route Url="/api/message"             Method="POST"  Call="SendMessage"/>
<Route Url="/api/upload"              Method="POST"  Call="Upload"/>
<Route Url="/api/telemetry/summary"   Method="GET"   Call="TelemetrySummary"/>
<Route Url="/api/telemetry"           Method="POST"  Call="Telemetry"/>
<Route Url="/api/feedback"            Method="POST"  Call="PostFeedback"/>
<Route Url="/api/feedback"            Method="GET"   Call="GetFeedback"/>
<Route Url="/api/test-claude"         Method="GET"   Call="TestClaude"/>
<Route Url="/api/namespace"            Method="GET"   Call="GetNamespace"/>
<Route Url="/api/namespace"            Method="PUT"   Call="SetNamespace"/>
<Route Url="/api/model"                Method="GET"   Call="GetModel"/>
<Route Url="/api/model"                Method="PUT"   Call="SetModel"/>
<Route Url="/api/bridge/start"        Method="POST"  Call="BridgeStart"/>
<Route Url="/api/bridge/events"       Method="GET"   Call="BridgeEvents"/>
<Route Url="/api/skill-index"         Method="GET"   Call="SkillIndex"/>
<Route Url="/api/skill-file"          Method="GET"   Call="SkillFile"/>
</Routes>
}

ClassMethod SetupEnv()
{
    set cwd = ..GetCWD()
    set cliHome = ..GetCLIHome()

    // Read credential secret from Ens.Config.Credentials
    set credSecret = ""
    try {
        if ##class(Ens.Config.Credentials).%ExistsId("InterClaw.Bedrock") {
            set cred = ##class(Ens.Config.Credentials).%OpenId("InterClaw.Bedrock")
            if cred '= "" set credSecret = cred.Password
        }
    } catch ex {}

    do ..SetupEnvPy(cwd, cliHome, credSecret)
}

ClassMethod SetupEnvPy(cwd As %String, cliHome As %String, walletSecret As %String) [ Language = python ]
{
    import os, sys, json

    if not os.environ.get("_INTERCLAW_ENV_LOADED"):
        if walletSecret:
            try:
                data = json.loads(walletSecret)
                os.environ["ANTHROPIC_API_KEY"] = data.get("key", "")
                os.environ["CLAUDE_CODE_USE_BEDROCK"] = "1"
                os.environ["AWS_REGION"] = data.get("region", "us-east-1")
                os.environ["AWS_BEARER_TOKEN_BEDROCK"] = data.get("key", "")
            except Exception:
                pass
        os.environ["_INTERCLAW_ENV_LOADED"] = "1"

    os.makedirs(cliHome, exist_ok=True)
    os.environ["HOME"] = cliHome
    if sys.platform == "win32":
        os.environ["USERPROFILE"] = cliHome
    os.environ["PYTHONDONTWRITEBYTECODE"] = "1"
    os.chdir(cwd)
}

ClassMethod WriteSSE(data As %String)
{
    Write "data: " _ data _ $char(10,10)
    Do %response.Flush()
}

ClassMethod ReadBody() As %String
{
    Set body = ""
    If $IsObject(%request.Content) {
        Set stream = %request.Content
        While 'stream.AtEnd {
            Set body = body _ stream.Read(32000)
        }
    }
    Return body
}

/// Resolve the CWD for Claude Code sessions.
/// Priority: INTERCLAW_CWD env var > ^InterClaw.Config > fallback.
ClassMethod ResolveCWD() As %String
{
    return ..GetCWD()
}

/// Read all entries from the InterClaw.ToolLabels lookup table as a JSON object.
/// Called once per request by ForwardSSE; the result is passed to ResolveToolLabel.
ClassMethod GetToolLabelsJSON() As %String
{
    Set obj = ##class(%DynamicObject).%New()
    Set key = ""
    For {
        Set key = $order(^Ens.LookupTable("InterClaw.ToolLabels", key))
        If key = "" Quit
        Set val = $get(^Ens.LookupTable("InterClaw.ToolLabels", key))
        Do obj.%Set(key, val)
    }
    Return obj.%ToJSON()
}

/// Map a raw tool call (name + input JSON) to a human-readable label.
/// Labels are stored in the InterClaw.ToolLabels lookup table (editable in Portal).
/// Template values use {1} as placeholder for the primary dynamic argument.
/// labelsJson: pre-loaded JSON from GetToolLabelsJSON() — avoids iris.gref in Python.
ClassMethod ResolveToolLabel(toolName As %String, toolInput As %String, labelsJson As %String = "") As %String [ Language = python ]
{
    import json, re, os

    labels = json.loads(labelsJson) if labelsJson else {}

    def lkup(key):
        return labels.get(key)

    def fill(template, val):
        if not val:
            return template.replace(' {1}', '').replace('{1}', '')
        return template.replace('{1}', str(val))

    try:
        inp = json.loads(toolInput) if toolInput else {}
    except Exception:
        inp = {}

    # --- Non-Bash tools: lookup by tool:<name> ---
    if toolName != 'Bash':
        tmpl = lkup('tool:' + toolName)
        if not tmpl:
            return toolName
        if toolName in ('Read', 'Write', 'Edit'):
            val = os.path.basename(inp.get('file_path', ''))
        elif toolName == 'Glob':
            val = inp.get('pattern', '')
        elif toolName == 'Grep':
            val = inp.get('pattern', '')[:50]
        elif toolName == 'Skill':
            val = inp.get('skill', 'unknown')
        elif toolName == 'Agent':
            val = inp.get('description', 'Agent task')[:60]
        elif toolName == 'WebFetch':
            url = inp.get('url', '')
            m = re.match(r'https?://([^/]+)', url)
            val = m.group(1) if m else url[:40]
        else:
            val = ''
        return fill(tmpl, val)

    # --- Bash tool: identify script + action, build lookup key ---
    cmd = inp.get('command', '')

    script_m = re.search(r'scripts/\w+/(\w+)\.py', cmd)
    if script_m:
        script = script_m.group(1)
        key = script
        arg = ''

        # --- Per-script key + arg extraction ---
        if script in ('put_doc', 'get_doc', 'compile'):
            m = re.search(r'--doc\s+(\S+)', cmd)
            arg = m.group(1).replace('.cls', '') if m else ''

        elif script == 'list_docs':
            m = re.search(r'--filter\s+(\S+)', cmd)
            if m:
                key = 'list_docs:filter'; arg = m.group(1)
            elif '--type cls' in cmd: key = 'list_docs:cls'
            elif '--type mac' in cmd: key = 'list_docs:mac'
            elif '--type inc' in cmd: key = 'list_docs:inc'

        elif script == 'run_query':
            m = re.search(r'--sql\s+["\'](.{0,60})', cmd)
            arg = m.group(1).rstrip('"\'') if m else ''

        elif script == 'search_code':
            m = re.search(r'--query\s+["\']?([^"\']+)', cmd)
            arg = m.group(1)[:50] if m else ''

        elif script == 'class_inspect':
            m = re.search(r'--class\s+(\S+)', cmd)
            arg = m.group(1) if m else ''

        elif script == 'manage_lookup':
            m = re.search(r'--table\s+"?(\S+?)"?(?:\s|$)', cmd)
            targ = m.group(1) if m else ''
            if '--list-tables' in cmd: key = 'manage_lookup:list-tables'
            elif '--set' in cmd: key = 'manage_lookup:set'; arg = targ
            elif '--clear' in cmd: key = 'manage_lookup:clear'; arg = targ
            elif '--delete' in cmd: key = 'manage_lookup:delete'; arg = targ
            elif '--list' in cmd: key = 'manage_lookup:list'; arg = targ
            elif '--count' in cmd: key = 'manage_lookup:list'; arg = targ
            else: arg = targ

        elif script == 'manage_production':
            m = re.search(r'--(?:start|stop|recover|clean|status|list)\s*(\S*)', cmd)
            parg = m.group(1) if m else ''
            if '--start' in cmd and '--stop-first' in cmd:
                key = 'manage_production:restart'; arg = parg
            elif '--start' in cmd: key = 'manage_production:start'; arg = parg
            elif '--stop' in cmd: key = 'manage_production:stop'
            elif '--status' in cmd: key = 'manage_production:status'
            elif '--recover' in cmd: key = 'manage_production:recover'
            elif '--clean' in cmd: key = 'manage_production:clean'
            elif '--list' in cmd: key = 'manage_production:list'

        elif script == 'diagram_production':
            m = re.search(r'--(?:package|production)\s+(\S+)', cmd)
            arg = m.group(1) if m else ''

        elif script == 'validate_package':
            m = re.search(r'--package\s+(\S+)', cmd)
            arg = m.group(1) if m else ''

        elif script == 'get_schema':
            if '--message' in cmd:
                key = 'get_schema:message'
                m = re.search(r'--message\s+(\S+)', cmd)
                arg = m.group(1) if m else ''
            elif '--segment' in cmd:
                key = 'get_schema:segment'
                m = re.search(r'--segment\s+(\S+)', cmd)
                arg = m.group(1) if m else ''
            elif '--list-categories' in cmd: key = 'get_schema:list-categories'
            elif '--list-messages' in cmd:
                key = 'get_schema:list-messages'
                m = re.search(r'--list-messages\s+(\S+)', cmd)
                arg = m.group(1) if m else ''
            elif '--list-segments' in cmd:
                key = 'get_schema:list-segments'
                m = re.search(r'--list-segments\s+(\S+)', cmd)
                arg = m.group(1) if m else ''

        elif script in ('send_hl7', 'send_json'):
            m = re.search(r'--to\s+(\S+)', cmd)
            if m and script == 'send_hl7': key = 'send_hl7:to'; arg = m.group(1)

        elif script == 'test_dtl':
            m = re.search(r'--dtl\s+(\S+)', cmd)
            arg = m.group(1) if m else ''

        elif script == 'test_suite':
            m = re.search(r'--package\s+(\S+)', cmd)
            arg = m.group(1) if m else ''

        elif script == 'test_connection':
            m = re.search(r'--namespace\s+(\S+)', cmd)
            ms = re.search(r'--server\s+(\S+)', cmd)
            if m and ms: key = 'test_connection:namespace'; arg = ms.group(1) + '/' + m.group(1)
            elif ms: arg = ms.group(1)

        elif script == 'get_settings':
            m = re.search(r'--class\s+(\S+)', cmd)
            arg = m.group(1) if m else ''

        elif script == 'trace':
            m = re.search(r'--session\s+(\S+)', cmd)
            if m: key = 'trace:session'; arg = m.group(1)
            else:
                m = re.search(r'--last\s+(\S+)', cmd)
                if m: key = 'trace:last'; arg = m.group(1)
                else:
                    m = re.search(r'--component\s+(\S+)', cmd)
                    if m: key = 'trace:component'; arg = m.group(1)

        elif script == 'get_errors':
            m = re.search(r'--package\s+(\S+)', cmd)
            if m: key = 'get_errors:package'; arg = m.group(1)

        elif script == 'changelog':
            m = re.search(r'--class\s+(\S+)', cmd)
            if m: key = 'changelog:class'; arg = m.group(1)

        elif script == 'manage_namespace':
            for act in ('create', 'delete', 'check'):
                m = re.search(r'--' + act + r'\s+(\S+)', cmd)
                if m: key = 'manage_namespace:' + act; arg = m.group(1); break
            else:
                if '--list' in cmd: key = 'manage_namespace:list'

        elif script == 'manage_webapp':
            for act in ('create', 'delete'):
                m = re.search(r'--' + act + r'\s+(\S+)', cmd)
                if m: key = 'manage_webapp:' + act; arg = m.group(1); break
            else:
                if '--list' in cmd: key = 'manage_webapp:list'

        elif script == 'reset_package':
            m = re.search(r'--package\s+(\S+)', cmd)
            arg = m.group(1) if m else ''
            if '--dry-run' in cmd: key = 'reset_package:dry-run'

        elif script == 'permissions':
            m = re.search(r'--check\s+(\S+)', cmd)
            if m: key = 'permissions:check'; arg = m.group(1)
            else:
                m = re.search(r'--mode\s+(\S+)', cmd)
                if m: key = 'permissions:mode'; arg = m.group(1)

        elif script == 'pull_docs':
            m = re.search(r'--key\s+(\S+)', cmd)
            if m: key = 'pull_docs:key'; arg = m.group(1)
            else:
                m = re.search(r'--search\s+["\']?([^"\']+)', cmd)
                if m: key = 'pull_docs:search'; arg = m.group(1)[:40]

        elif script == 'docx_to_md':
            m = re.search(r'--input\s+(\S+)', cmd)
            arg = os.path.basename(m.group(1)) if m else ''

        elif script == 'iris_terminal':
            m = re.search(r'--code\s+["\'](.{0,50})', cmd)
            arg = m.group(1).rstrip('"\'') if m else ''

        tmpl = lkup(key)
        if tmpl:
            return fill(tmpl, arg)
        return fill(script.replace('_', ' ').title(), arg)

    # --- Shell commands: lookup by shell:<cmd> ---
    stripped = cmd.strip()
    if '&&' in stripped:
        stripped = stripped.split('&&')[-1].strip()

    if stripped.startswith('git '):
        parts = stripped.split()
        git_cmd = parts[1] if len(parts) > 1 else ''
        tmpl = lkup('shell:git_' + git_cmd)
        if tmpl:
            arg = parts[2] if len(parts) > 2 and git_cmd in ('add', 'checkout') else ''
            return fill(tmpl, arg)
        return 'git ' + stripped[4:54]

    for prefix in ('ls', 'mkdir', 'cp', 'chmod', 'chown', 'curl', 'wc', 'cat'):
        if stripped.startswith(prefix + ' ') or stripped == prefix:
            tmpl = lkup('shell:' + prefix)
            if tmpl:
                return tmpl
            break

    # Fallback: truncate
    short = cmd[:70]
    if len(cmd) > 70:
        short += '...'
    return short
}

ClassMethod WriteJSON(json As %String, status As %Integer = 200)
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    If status '= 200 {
        Set %response.Status = status _ " " _ $case(status, 400:"Bad Request", 404:"Not Found", 413:"Payload Too Large", 500:"Internal Server Error", 501:"Not Implemented", 502:"Bad Gateway", :"Error")
    }
    Write json
}

ClassMethod Health() As %Status
{
    Set prodStatus = ..EnsureProduction()
    Set json = "{""status"":""ok"",""production"":" _ prodStatus _ "}"
    Do ..WriteJSON(json)
    Return $$$OK
}

/// GET /api/namespace — return the server-stored active namespace
ClassMethod GetNamespace() As %Status
{
    Set ns = $get(^InterClaw.Config("Namespace"), "INTERCLAW")
    Set json = "{""namespace"":""" _ $zconvert(ns, "O", "JSON") _ """}"
    Do ..WriteJSON(json)
    Return $$$OK
}

/// PUT /api/namespace — persist the active namespace to ^InterClaw.Config
ClassMethod SetNamespace() As %Status
{
    Set body = ..ReadBody()
    If body = "" {
        Do ..WriteJSON("{""error"":""empty body""}", 400)
        Return $$$OK
    }
    Try {
        Set obj = ##class(%DynamicObject).%FromJSON(body)
        Set ns = obj.namespace
    } Catch ex {
        Do ..WriteJSON("{""error"":""invalid JSON""}", 400)
        Return $$$OK
    }
    If ns = "" {
        Do ..WriteJSON("{""error"":""namespace is required""}", 400)
        Return $$$OK
    }
    Set ns = $zconvert(ns, "U")
    Set ^InterClaw.Config("Namespace") = ns
    Set json = "{""namespace"":""" _ $zconvert(ns, "O", "JSON") _ """}"
    Do ..WriteJSON(json)
    Return $$$OK
}

/// GET /api/model — return the server-stored selected model
ClassMethod GetModel() As %Status
{
    Set model = $get(^InterClaw.Config("Model"), "opus")
    Set json = "{""model"":""" _ $zconvert(model, "O", "JSON") _ """}"
    Do ..WriteJSON(json)
    Return $$$OK
}

/// PUT /api/model — persist the selected model to ^InterClaw.Config
ClassMethod SetModel() As %Status
{
    Set body = ..ReadBody()
    If body = "" {
        Do ..WriteJSON("{""error"":""empty body""}", 400)
        Return $$$OK
    }
    Try {
        Set obj = ##class(%DynamicObject).%FromJSON(body)
        Set model = obj.model
    } Catch ex {
        Do ..WriteJSON("{""error"":""invalid JSON""}", 400)
        Return $$$OK
    }
    If model = "" {
        Do ..WriteJSON("{""error"":""model is required""}", 400)
        Return $$$OK
    }
    Set model = $zconvert(model, "L")
    Set ^InterClaw.Config("Model") = model
    Set json = "{""model"":""" _ $zconvert(model, "O", "JSON") _ """}"
    Do ..WriteJSON(json)
    Return $$$OK
}

/// Ensure InterClaw.Pipeline.Production is running. Handles every possible state:
///   1 (Running)        — if InterClaw.Pipeline.Production, no-op; if different, stop it then start ours
///   2 (Stopped)        — start InterClaw.Pipeline.Production
///   3 (Suspended)      — recover, fallback to clean+stop, then start
///   4 (Troubled)       — recover, fallback to clean+stop, then start
///   5 (NetworkStopped) — stop then start
///   0 (None)           — start InterClaw.Pipeline.Production
/// 
/// Returns a JSON string: {"running":true/false,"state":"...","action":"...","error":"..."}
ClassMethod EnsureProduction() As %String
{
    Set prodTarget = "InterClaw.Pipeline.Production"
    Set result = ##class(%DynamicObject).%New()
    Do result.%Set("running", 0, "boolean")
    Do result.%Set("action", "none")
    Do result.%Set("state", "unknown")
    Do result.%Set("error", "")

    Try {
        Set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
        Set prodName = $get(prodName, "")
        Set prodState = +$get(prodState, 0)

        // Map state number to label
        Set stateLabel = $case(prodState,
            1:"Running", 2:"Stopped", 3:"Suspended", 4:"Troubled", 5:"NetworkStopped", :"None")
        Do result.%Set("state", stateLabel)

        // ── Fast path: InterClaw.Pipeline.Production is already running ──
        If prodName = prodTarget && (prodState = 1) {
            Do result.%Set("running", 1, "boolean")
            Return result.%ToJSON()
        }

        // ── Another production is active (any state) — clear it first ──
        If prodName '= "" && (prodName '= prodTarget) {
            Do result.%Set("action", "replaced-" _ prodName)
            If prodState = 1 {
                // Running — graceful stop
                Set sc = ##class(Ens.Director).StopProduction(30, 1)
            } ElseIf prodState = 3 || (prodState = 4) {
                // Suspended or Troubled — recover then stop
                Set sc = ##class(Ens.Director).RecoverProduction(30)
                Set sc = ##class(Ens.Director).StopProduction(30, 1)
                If $$$ISERR(sc) {
                    // Recovery didn't help — force clean
                    Set sc = ##class(Ens.Director).CleanProduction(0)
                }
            } ElseIf prodState = 5 {
                // NetworkStopped — just stop
                Set sc = ##class(Ens.Director).StopProduction(30, 1)
            }
            // State 2 (Stopped) needs no action — already stopped
        }

        // ── InterClaw.Pipeline.Production is registered but not running ──
        If prodName = prodTarget {
            If prodState = 3 {
                // Suspended — try recover first (restarts suspended hosts)
                Do result.%Set("action", "recover-from-suspended")
                Set sc = ##class(Ens.Director).RecoverProduction(30)
                If $$$ISOK(sc) {
                    // Check if recover brought it back to Running
                    Set sc = ##class(Ens.Director).GetProductionStatus(.chkName, .chkState)
                    If $get(chkState) = 1 {
                        Do result.%Set("running", 1, "boolean")
                        Return result.%ToJSON()
                    }
                }
                // Recover didn't fully fix it — clean and restart
                Do result.%Set("action", "clean-from-suspended")
                Set sc = ##class(Ens.Director).CleanProduction(0)
                If $$$ISERR(sc) {
                    Do result.%Set("error", "CleanProduction failed: " _ $system.Status.GetOneStatusText(sc))
                    Return result.%ToJSON()
                }
            } ElseIf prodState = 4 {
                // Troubled — try recover, fallback to clean
                Do result.%Set("action", "recover-from-troubled")
                Set sc = ##class(Ens.Director).RecoverProduction(30)
                If $$$ISOK(sc) {
                    Set sc = ##class(Ens.Director).GetProductionStatus(.chkName, .chkState)
                    If $get(chkState) = 1 {
                        Do result.%Set("running", 1, "boolean")
                        Return result.%ToJSON()
                    }
                }
                Do result.%Set("action", "clean-from-troubled")
                Set sc = ##class(Ens.Director).CleanProduction(0)
                If $$$ISERR(sc) {
                    Do result.%Set("error", "CleanProduction failed: " _ $system.Status.GetOneStatusText(sc))
                    Return result.%ToJSON()
                }
            }
            // State 2 (Stopped) or cleaned state — fall through to StartProduction
        }

        // ── Start InterClaw.Pipeline.Production ──
        If result.action = "none" {
            Do result.%Set("action", "started")
        }
        Set sc = ##class(Ens.Director).StartProduction(prodTarget)
        If $$$ISERR(sc) {
            Do result.%Set("error", "StartProduction failed: " _ $system.Status.GetOneStatusText(sc))
            Return result.%ToJSON()
        }
        Do result.%Set("running", 1, "boolean")

    } Catch ex {
        Do result.%Set("error", "Exception: " _ ex.DisplayString())
    }

    Return result.%ToJSON()
}

ClassMethod TestClaude() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Do ..SetupEnv()
    Set result = ..TestClaudePy(..ResolveCWD(), ..GetCLIHome())
    Write result
    Return $$$OK
}

ClassMethod TestClaudePy(cwd As %String, cliHome As %String) As %String [ Language = python ]
{
    import json, os, asyncio
    os.chdir(cwd)
    os.makedirs(cliHome, exist_ok=True)
    os.environ["HOME"] = cliHome
    from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage, AssistantMessage, TextBlock
    options = ClaudeAgentOptions(cwd=cwd, permission_mode="bypassPermissions")
    output_text = []
    session_id = None
    async def _run():
        nonlocal session_id
        async for message in query(prompt="Say hi in one word", options=options):
            if isinstance(message, AssistantMessage):
                for block in message.content:
                    if isinstance(block, TextBlock):
                        output_text.append(block.text)
            elif isinstance(message, ResultMessage):
                session_id = message.session_id
    try:
        asyncio.run(_run())
        return json.dumps(dict(output="\n".join(output_text), session_id=session_id, error=None))
    except Exception as e:
        import traceback
        return json.dumps(dict(output=None, session_id=None, error=str(e), detail=traceback.format_exc()))
}

ClassMethod RunTest()
{
    Write ..TestClaudePy(..ResolveCWD(), ..GetCLIHome()),!
}

ClassMethod Config() As %Status
{
    Set result = ..ConfigPy(..GetCWD())
    Do ..WriteJSON(result, $select(result [ """error""":404, 1:200))
    Return $$$OK
}

ClassMethod ConfigPy(cwd As %String) As %String [ Language = python ]
{
    import json, os
    try:
        with open(os.path.join(cwd, "config", "orchestrator.json")) as f:
            return f.read()
    except FileNotFoundError:
        return json.dumps(dict(error="Config not found"))
}

ClassMethod Commands() As %Status
{
    Set result = ..CommandsPy(..GetCWD())
    Do ..WriteJSON(result, $select(result [ """error""":404, 1:200))
    Return $$$OK
}

ClassMethod CommandsPy(cwd As %String) As %String [ Language = python ]
{
    import json, os
    try:
        with open(os.path.join(cwd, "config", "commands.json")) as f:
            registry = json.load(f)
        cmds = registry.get("commands", [])
        visible = [c for c in cmds if not c.get("hidden")]
        return json.dumps(dict(commands=visible, categories=registry.get("categories", dict())))
    except FileNotFoundError:
        return json.dumps(dict(error="Commands registry not found"))
}

/// GET /api/skill-index — return JSON index of all files under .claude/
ClassMethod SkillIndex() As %Status
{
    Set result = ..SkillIndexPy(..GetCWD())
    Do ..WriteJSON(result)
    Return $$$OK
}

ClassMethod SkillIndexPy(cwd As %String) As %String [ Language = python ]
{
    import os, json

    claude_dir = os.path.join(cwd, ".claude")
    if not os.path.isdir(claude_dir):
        return json.dumps([])

    SKIP_NAMES = {"__pycache__", ".DS_Store", "skills-editor"}
    SKIP_EXTS = {".pyc", ".pyo"}
    entries = []

    for dirpath, dirnames, filenames in os.walk(claude_dir):
        dirnames[:] = sorted(d for d in dirnames if d not in SKIP_NAMES)
        for fname in sorted(filenames):
            if fname in SKIP_NAMES:
                continue
            ext = os.path.splitext(fname)[1]
            if ext in SKIP_EXTS:
                continue
            full_path = os.path.join(dirpath, fname)
            rel_path = os.path.relpath(full_path, claude_dir).replace(os.sep, "/")
            parts = rel_path.split("/")
            section = parts[0] if len(parts) > 1 and parts[0] in ("skills", "commands", "hooks", "context") else ""
            try:
                size = os.path.getsize(full_path)
            except OSError:
                size = 0
            entries.append(dict(path=rel_path, name=fname, section=section, ext=ext, size=size))

    return json.dumps(entries)
}

/// GET /api/skill-file?path=<relative-path> — return content of a .claude/ file
ClassMethod SkillFile() As %Status
{
    Set path = $get(%request.Data("path", 1))
    If path = "" {
        Do ..WriteJSON("{""error"":""missing path parameter""}", 400)
        Return $$$OK
    }

    // Build and normalize paths — NormalizeFilename strips trailing /
    Set claudeDir = ##class(%File).NormalizeFilename(..GetCWD() _ ".claude") _ "/"
    Set fullPath = ##class(%File).NormalizeFilename(claudeDir _ path)

    // Path traversal guard: resolved path must start with claudeDir
    If $extract(fullPath, 1, $length(claudeDir)) '= claudeDir {
        Do ..WriteJSON("{""error"":""invalid path""}", 400)
        Return $$$OK
    }

    If '##class(%File).Exists(fullPath) {
        Do ..WriteJSON("{""error"":""file not found""}", 404)
        Return $$$OK
    }

    // Stream the file content back
    Set stream = ##class(%Stream.FileCharacter).%New()
    Set stream.Filename = fullPath
    Set stream.TranslateTable = "UTF8"
    Set %response.ContentType = "text/plain"
    Set %response.CharSet = "utf-8"
    While 'stream.AtEnd {
        Write stream.Read(32000)
    }
    Return $$$OK
}

ClassMethod GetPermissions() As %Status
{
    Do ..WriteJSON(..GetPermissionsPy(..GetCWD()))
    Return $$$OK
}

ClassMethod GetPermissionsPy(cwd As %String) As %String [ Language = python ]
{
    import json, os
    try:
        with open(os.path.join(cwd, "config", "orchestrator.json")) as f:
            config = json.load(f)
        perm = config.get("permissions", dict())
        mode = perm.get("mode", "normal")
        modes = perm.get("modes", dict())
        mode_config = modes.get(mode, dict())
        return json.dumps(dict(
            mode=mode,
            description=mode_config.get("description", ""),
            settings=mode_config,
            guardrails=perm.get("guardrails", dict()),
            available_modes=list(modes.keys()),
        ))
    except Exception:
        return json.dumps(dict(error="Config not available"))
}

ClassMethod SetPermissions() As %Status
{
    Set body = ..ReadBody()
    Set result = ..SetPermissionsPy(..GetCWD(), body)
    Do ..WriteJSON(result, $select(result [ """error""":400, 1:200))
    Return $$$OK
}

ClassMethod SetPermissionsPy(cwd As %String, body As %String) As %String [ Language = python ]
{
    import json, os
    data = json.loads(body) if body else dict()
    new_mode = data.get("mode")
    if not new_mode:
        return json.dumps(dict(error="Missing 'mode' field"))
    config_path = os.path.join(cwd, "config", "orchestrator.json")
    try:
        with open(config_path, "r") as f:
            config = json.load(f)
        perm = config.get("permissions", dict())
        modes = perm.get("modes", dict())
        if new_mode not in modes:
            return json.dumps(dict(error="Unknown mode. Valid: " + str(list(modes.keys()))))
        perm["mode"] = new_mode
        config["permissions"] = perm
        with open(config_path, "w") as f:
            json.dump(config, f, indent=4)
            f.write("\n")
        mode_config = modes[new_mode]
        return json.dumps(dict(mode=new_mode, description=mode_config.get("description", ""), settings=mode_config))
    except Exception as e:
        return json.dumps(dict(error=str(e)))
}

ClassMethod AuthStatus() As %Status
{
    Do ..SetupEnv()

    // Check Bedrock credential from Ens.Config.Credentials (authoritative source)
    set credExists = 0
    set bedrockKey = ""
    set bedrockRegion = "us-east-1"
    try {
        if ##class(Ens.Config.Credentials).%ExistsId("InterClaw.Bedrock") {
            set cred = ##class(Ens.Config.Credentials).%OpenId("InterClaw.Bedrock")
            if cred '= "" {
                set credExists = 1
                set raw = cred.Password
                if raw '= "" {
                    set parsed = ##class(%DynamicObject).%FromJSON(raw)
                    if $IsObject(parsed) {
                        set bedrockKey = parsed.key
                        if (parsed.region '= "") set bedrockRegion = parsed.region
                    }
                }
            }
        }
    } catch ex {}

    // Check IRIS user login credential
    set loggedIn = 0
    set loginUser = ""
    try {
        if ##class(Ens.Config.Credentials).%ExistsId("InterClaw.User") {
            set userCred = ##class(Ens.Config.Credentials).%OpenId("InterClaw.User")
            if userCred '= "" {
                set loggedIn = 1
                set loginUser = userCred.Username
            }
        }
    } catch ex {}

    Do ..WriteJSON(..AuthStatusPy(credExists, bedrockKey, bedrockRegion, loggedIn, loginUser))
    Return $$$OK
}

ClassMethod AuthStatusPy(credExists As %Boolean, bedrockKey As %String, bedrockRegion As %String, loggedIn As %Boolean, loginUser As %String) As %String [ Language = python ]
{
    import json
    key = str(bedrockKey) if bedrockKey else ""
    has_key = bool(credExists) and bool(key) and key.startswith("ABSK")
    prefix = None
    if has_key and len(key) > 8:
        prefix = key[:4] + "..." + key[-4:]

    return json.dumps(dict(
        authenticated=has_key,
        provider="bedrock",
        key_prefix=prefix,
        region=str(bedrockRegion) if bedrockRegion else "us-east-1",
        storage="credential" if credExists else "none",
        logged_in=bool(loggedIn),
        user=loginUser or None,
    ))
}

ClassMethod Authenticate() As %Status
{
    set body = ..ReadBody()

    // Parse key and region from JSON body
    set json = ##class(%DynamicObject).%FromJSON(body)
    set key = $zstrip($select($IsObject(json) && (json.key '= ""): json.key, 1: ""), "<>W")
    set region = $zstrip($select($IsObject(json) && (json.region '= ""): json.region, 1: "us-east-1"), "<>W")

    if key = "" {
        Do ..WriteJSON("{""error"":""No key provided""}", 400)
        return $$$OK
    }
    if $extract(key, 1, 4) '= "ABSK" {
        Do ..WriteJSON("{""error"":""Invalid key format. Bedrock keys start with ABSK.""}", 400)
        return $$$OK
    }

    // Store in Ens.Config.Credentials (password field holds the JSON secret)
    set credStored = 0
    set credWarning = ""
    try {
        set secretObj = {"key": (key), "region": (region), "provider": "bedrock"}
        set secretJSON = secretObj.%ToJSON()
        if ##class(Ens.Config.Credentials).%ExistsId("InterClaw.Bedrock") {
            set cred = ##class(Ens.Config.Credentials).%OpenId("InterClaw.Bedrock")
        } else {
            set cred = ##class(Ens.Config.Credentials).%New()
            set cred.SystemName = "InterClaw.Bedrock"
        }
        set cred.Password = secretJSON
        set sc = cred.%Save()
        if $$$ISOK(sc) {
            set credStored = 1
        } else {
            set credWarning = $system.Status.GetOneStatusText(sc)
        }
    } catch ex {
        set credWarning = ex.DisplayString()
    }

    // Set env vars via Python so the current process can use the key immediately
    do ..AuthSetEnvPy(key, region)

    // Build response
    set keyPrefix = $extract(key, 1, 4) _ "..." _ $extract(key, $length(key) - 3, $length(key))
    set result = ##class(%DynamicObject).%New()
    do result.%Set("success", 1, "boolean")
    do result.%Set("key_prefix", keyPrefix)
    do result.%Set("credential_stored", credStored, "boolean")
    if credStored {
        do result.%Set("message", "Bedrock key stored in credential InterClaw.Bedrock")
    } else {
        do result.%Set("message", "Key set for this session only")
        if credWarning '= "" {
            do result.%Set("credential_warning", credWarning)
        }
    }
    Do ..WriteJSON(result.%ToJSON())
    return $$$OK
}

ClassMethod AuthSetEnvPy(key As %String, region As %String) [ Language = python ]
{
    import os
    os.environ["ANTHROPIC_API_KEY"] = key
    os.environ["CLAUDE_CODE_USE_BEDROCK"] = "1"
    os.environ["AWS_REGION"] = region
    os.environ["AWS_BEARER_TOKEN_BEDROCK"] = key
    os.environ["_INTERCLAW_ENV_LOADED"] = ""
}

ClassMethod Deauthenticate() As %Status
{
    // Remove from Ens.Config.Credentials
    set credRemoved = 0
    try {
        if ##class(Ens.Config.Credentials).%ExistsId("InterClaw.Bedrock") {
            set sc = ##class(Ens.Config.Credentials).%DeleteId("InterClaw.Bedrock")
            if $$$ISOK(sc) set credRemoved = 1
        }
    } catch ex {}

    // Clear env vars
    do ..AuthClearEnvPy()

    set result = ##class(%DynamicObject).%New()
    do result.%Set("success", 1, "boolean")
    do result.%Set("credential_removed", credRemoved, "boolean")
    do result.%Set("message", "API key removed")
    Do ..WriteJSON(result.%ToJSON())
    return $$$OK
}

ClassMethod AuthClearEnvPy() [ Language = python ]
{
    import os
    for k in ["ANTHROPIC_API_KEY", "CLAUDE_CODE_USE_BEDROCK", "AWS_REGION", "AWS_BEARER_TOKEN_BEDROCK", "_INTERCLAW_ENV_LOADED"]:
        os.environ.pop(k, None)
}

ClassMethod Login() As %Status
{
    set body = ..ReadBody()
    set json = ##class(%DynamicObject).%FromJSON(body)
    set username = $zstrip($select($IsObject(json) && (json.username '= ""): json.username, 1: ""), "<>W")
    set password = $select($IsObject(json) && (json.password '= ""): json.password, 1: "")

    if username = "" {
        Do ..WriteJSON("{""error"":""No username provided""}", 400)
        return $$$OK
    }
    if password = "" {
        Do ..WriteJSON("{""error"":""No password provided""}", 400)
        return $$$OK
    }

    // Validate credentials against IRIS Security
    set sc = $SYSTEM.Security.Login(username, password)
    if $$$ISERR(sc) {
        Do ..WriteJSON("{""error"":""Invalid credentials""}", 401)
        return $$$OK
    }

    // Store in Ens.Config.Credentials (same pattern as Bedrock key)
    set credStored = 0
    try {
        if ##class(Ens.Config.Credentials).%ExistsId("InterClaw.User") {
            set cred = ##class(Ens.Config.Credentials).%OpenId("InterClaw.User")
        } else {
            set cred = ##class(Ens.Config.Credentials).%New()
            set cred.SystemName = "InterClaw.User"
        }
        set cred.Username = username
        set cred.Password = password
        set sc = cred.%Save()
        if $$$ISOK(sc) set credStored = 1
    } catch ex {}

    set result = ##class(%DynamicObject).%New()
    do result.%Set("success", credStored, "boolean")
    do result.%Set("username", username)
    if credStored {
        do result.%Set("message", "Logged in as " _ username)
    } else {
        do result.%Set("message", "Credentials valid but could not persist")
    }
    Do ..WriteJSON(result.%ToJSON())
    return $$$OK
}

ClassMethod Logout() As %Status
{
    set removed = 0
    try {
        if ##class(Ens.Config.Credentials).%ExistsId("InterClaw.User") {
            set sc = ##class(Ens.Config.Credentials).%DeleteId("InterClaw.User")
            if $$$ISOK(sc) set removed = 1
        }
    } catch ex {}

    set result = ##class(%DynamicObject).%New()
    do result.%Set("success", 1, "boolean")
    do result.%Set("logged_out", removed, "boolean")
    do result.%Set("message", "Logged out")
    Do ..WriteJSON(result.%ToJSON())
    return $$$OK
}

ClassMethod Telemetry() As %Status
{
    Set body = ..ReadBody()
    Do ..WriteJSON(..TelemetryPy(..GetCWD(), body))
    Return $$$OK
}

ClassMethod TelemetryPy(cwd As %String, body As %String) As %String [ Language = python ]
{
    import json, os
    from datetime import datetime, date
    try:
        with open(os.path.join(cwd, "config", "orchestrator.json")) as f:
            config = json.load(f)
    except Exception:
        config = dict()
    if not config.get("telemetry", dict()).get("enabled", False):
        return json.dumps(dict(status="disabled"))
    data = json.loads(body) if body else dict()
    entry = dict(
        timestamp=datetime.utcnow().isoformat() + "Z",
        command=data.get("command"),
        namespace=data.get("namespace"),
        session_id=data.get("session_id"),
        duration_sec=data.get("duration"),
        success=data.get("success", True),
        source="frontend",
        extra=data.get("extra"),
    )
    log_path = os.path.join(cwd, config["telemetry"].get("logPath", "data/telemetry"))
    os.makedirs(log_path, exist_ok=True)
    filepath = os.path.join(log_path, date.today().isoformat() + ".jsonl")
    with open(filepath, "a") as f:
        f.write(json.dumps(entry, default=str) + "\n")
    return json.dumps(dict(status="ok"))
}

ClassMethod TelemetrySummary() As %Status
{
    Set params = "{}"
    Try {
        Set obj = ##class(%DynamicObject).%New()
        Set days = $get(%request.Data("days", 1), "30")
        Set command = $get(%request.Data("command", 1), "")
        Do obj.%Set("days", days)
        If command '= "" { Do obj.%Set("command", command) }
        Set params = obj.%ToJSON()
    } Catch ex {}
    Do ..WriteJSON(..TelemetrySummaryPy(..GetCWD(), params))
    Return $$$OK
}

ClassMethod TelemetrySummaryPy(cwd As %String, params As %String) As %String [ Language = python ]
{
    import json, os
    from datetime import date
    try:
        with open(os.path.join(cwd, "config", "orchestrator.json")) as f:
            config = json.load(f)
    except Exception:
        config = dict()
    if not config.get("telemetry", dict()).get("enabled", False):
        return json.dumps(dict(status="disabled"))
    qp = json.loads(params) if params else dict()
    days = int(qp.get("days", "30"))
    filter_command = qp.get("command")
    log_dir = os.path.join(cwd, config["telemetry"].get("logPath", "data/telemetry"))
    entries = []
    cutoff = date.today().toordinal() - days
    if os.path.isdir(log_dir):
        for fname in sorted(os.listdir(log_dir)):
            if not fname.endswith(".jsonl"):
                continue
            try:
                file_date = date.fromisoformat(fname.replace(".jsonl", ""))
                if file_date.toordinal() < cutoff:
                    continue
            except ValueError:
                continue
            with open(os.path.join(log_dir, fname)) as f:
                for line in f:
                    try:
                        e = json.loads(line)
                        if filter_command and e.get("command") != filter_command:
                            continue
                        entries.append(e)
                    except json.JSONDecodeError:
                        continue
    command_counts = dict()
    namespace_counts = dict()
    error_count = 0
    total_duration = 0.0
    daily_counts = dict()
    for e in entries:
        cmd = e.get("command", "unknown")
        command_counts[cmd] = command_counts.get(cmd, 0) + 1
        ns = e.get("namespace", "unknown")
        namespace_counts[ns] = namespace_counts.get(ns, 0) + 1
        if not e.get("success", True):
            error_count += 1
        total_duration += e.get("duration_sec", 0) or 0
        day = (e.get("timestamp", "")[:10]) or "unknown"
        daily_counts[day] = daily_counts.get(day, 0) + 1
    total = len(entries)
    return json.dumps(dict(
        total_events=total,
        period_days=days,
        top_commands=sorted(command_counts.items(), key=lambda x: -x[1])[:20],
        namespaces=namespace_counts,
        error_count=error_count,
        error_rate=round(error_count / total, 4) if total else 0,
        avg_duration_sec=round(total_duration / total, 2) if total else 0,
        daily_usage=daily_counts,
    ))
}

ClassMethod PostFeedback() As %Status
{
    Set body = ..ReadBody()
    Set result = ..PostFeedbackPy(..GetCWD(), body)
    Set status = $select(result [ """error""":502, 1:200)
    Do ..WriteJSON(result, status)
    Return $$$OK
}

ClassMethod PostFeedbackPy(cwd As %String, body As %String) As %String [ Language = python ]
{
    import json, os
    from datetime import datetime
    from urllib.request import Request, urlopen
    from urllib.error import HTTPError, URLError
    try:
        with open(os.path.join(cwd, "config", "orchestrator.json")) as f:
            config = json.load(f)
    except Exception:
        config = dict()
    fb = config.get("feedback", dict())
    if not fb.get("enabled", False):
        return json.dumps(dict(status="disabled"))
    data = json.loads(body) if body else dict()
    rating = data.get("rating")
    if rating is not None and (not isinstance(rating, int) or rating < 1 or rating > 5):
        return json.dumps(dict(error="Rating must be 1-5"))
    valid_categories = fb.get("categories", ["bug", "feature-request", "general", "praise"])
    category = data.get("category", "general")
    if category not in valid_categories:
        return json.dumps(dict(error="Invalid category. Valid: " + str(valid_categories)))
    comment = (data.get("comment") or "")[:2000].strip()
    gl = fb.get("gitlab", dict())
    gitlab_url = gl.get("url", "").rstrip("/")
    project_id = gl.get("projectId", "")
    token = gl.get("token", "")
    if not gitlab_url or not project_id or not token:
        return json.dumps(dict(error="GitLab feedback not configured"))
    first_line = comment.split("\n")[0][:80] if comment else ("Rating " + str(rating) + "/5" if rating else "General feedback")
    title = "[Feedback] " + category + ": " + first_line
    stars = ("+" * (rating or 0)) + ("-" * (5 - (rating or 0))) if rating else "N/A"
    description = "## Feedback\n\n| Field | Value |\n|-------|-------|\n| **Rating** | " + stars + " (" + str(rating) + "/5) |\n| **Category** | " + category + " |\n| **Namespace** | " + data.get("namespace", "N/A") + " |\n| **Timestamp** | " + datetime.utcnow().isoformat() + "Z |\n\n### Comment\n\n" + (comment or "_No comment._") + "\n\n---\n_Submitted via Agent Orchestrator._"
    labels = list(gl.get("labels", ["feedback"]))
    if category not in labels:
        labels.append(category)
    issue_data = json.dumps(dict(title=title, description=description, labels=",".join(labels), confidential=gl.get("confidential", True))).encode()
    api_url = gitlab_url + "/api/v4/projects/" + str(project_id) + "/issues"
    req = Request(api_url, data=issue_data, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("PRIVATE-TOKEN", token)
    try:
        with urlopen(req, timeout=15) as resp:
            result = json.loads(resp.read().decode())
            return json.dumps(dict(status="ok", issue_url=result.get("web_url", ""), issue_id=result.get("iid")))
    except HTTPError as e:
        err = e.read().decode("utf-8", errors="replace")[:500]
        return json.dumps(dict(error="GitLab API returned " + str(e.code), detail=err))
    except (URLError, OSError) as e:
        return json.dumps(dict(error="Could not reach GitLab: " + str(e)))
}

ClassMethod GetFeedback() As %Status
{
    Set params = "{}"
    Try {
        Set obj = ##class(%DynamicObject).%New()
        Do obj.%Set("state", $get(%request.Data("state", 1), "opened"))
        Do obj.%Set("limit", $get(%request.Data("limit", 1), "50"))
        Set cat = $get(%request.Data("category", 1), "")
        If cat '= "" { Do obj.%Set("category", cat) }
        Set params = obj.%ToJSON()
    } Catch ex {}
    Do ..WriteJSON(..GetFeedbackPy(..GetCWD(), params))
    Return $$$OK
}

ClassMethod GetFeedbackPy(cwd As %String, params As %String) As %String [ Language = python ]
{
    import json, os
    from urllib.request import Request, urlopen
    from urllib.error import HTTPError, URLError
    try:
        with open(os.path.join(cwd, "config", "orchestrator.json")) as f:
            config = json.load(f)
    except Exception:
        config = dict()
    fb = config.get("feedback", dict())
    if not fb.get("enabled", False):
        return json.dumps(dict(status="disabled"))
    qp = json.loads(params) if params else dict()
    gl = fb.get("gitlab", dict())
    gitlab_url = gl.get("url", "").rstrip("/")
    project_id = gl.get("projectId", "")
    token = gl.get("token", "")
    if not gitlab_url or not project_id or not token:
        return json.dumps(dict(error="GitLab feedback not configured"))
    state = qp.get("state", "opened")
    per_page = min(int(qp.get("limit", "50")), 100)
    labels = ",".join(gl.get("labels", ["feedback"]))
    cat = qp.get("category", "")
    if cat:
        labels += "," + cat
    api_url = gitlab_url + "/api/v4/projects/" + str(project_id) + "/issues?labels=" + labels + "&state=" + state + "&per_page=" + str(per_page) + "&order_by=created_at&sort=desc"
    req = Request(api_url)
    req.add_header("PRIVATE-TOKEN", token)
    try:
        with urlopen(req, timeout=15) as resp:
            issues = json.loads(resp.read().decode())
            return json.dumps(dict(
                total=len(issues),
                entries=[dict(id=i.get("iid"), title=i.get("title"), state=i.get("state"), labels=i.get("labels", []), created_at=i.get("created_at"), url=i.get("web_url")) for i in issues],
            ))
    except HTTPError as e:
        return json.dumps(dict(error="GitLab API returned " + str(e.code)))
    except (URLError, OSError) as e:
        return json.dumps(dict(error="Could not reach GitLab: " + str(e)))
}

ClassMethod Upload() As %Status
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Set mimeData = %request.GetMimeData("file")
    If '$IsObject(mimeData) {
        Do ..WriteJSON("{""error"":""No file uploaded""}", 400)
        Return $$$OK
    }
    Set filename = mimeData.FileName
    // Save MIME data to a temp file as binary stream (avoids string corruption
    // for binary formats like docx/pdf — ObjectScript string concat loses null bytes)
    Set tmpFile = ##class(%File).TempFilename("upload")
    Set fileStream = ##class(%Stream.FileBinary).%New()
    Set sc = fileStream.LinkToFile(tmpFile)
    If $$$ISERR(sc) {
        Do ..WriteJSON("{""error"":""Could not create temp file""}", 500)
        Return $$$OK
    }
    Set sc = fileStream.CopyFrom(mimeData)
    If $$$ISERR(sc) {
        Do ..WriteJSON("{""error"":""Could not save uploaded data""}", 500)
        Return $$$OK
    }
    Set sc = fileStream.%Save()
    Set result = ..UploadPy(..GetCWD(), tmpFile, filename)
    Do ##class(%File).Delete(tmpFile)
    Write result
    Return $$$OK
}

ClassMethod UploadPy(cwd As %String, tmpPath As %String, filename As %String) As %String [ Language = python ]
{
    import json, os, re, shutil
    from datetime import datetime
    ALLOWED = set([".docx", ".doc", ".pdf", ".txt", ".md", ".hl7", ".json", ".xml", ".csv", ".tsv", ".cls", ".mac", ".inc", ".int", ".hl7s"])
    MAX_SIZE = 10 * 1024 * 1024
    file_size = os.path.getsize(tmpPath)
    if file_size > MAX_SIZE:
        return json.dumps(dict(error="File too large. Max is 10MB."))
    name = os.path.basename(filename or "unnamed")
    name = name.replace("..", "").replace("/", "").replace("\\", "")
    name = re.sub(r"[^\w\-. ]", "_", name)
    name = re.sub(r"[_ ]+", "_", name).strip("_. ") or "unnamed_file"
    ext = os.path.splitext(name)[1].lower()
    if ext not in ALLOWED:
        return json.dumps(dict(error="File type not allowed: " + ext))
    date_dir = os.path.join(cwd, "uploads", datetime.now().strftime("%Y-%m-%d"))
    os.makedirs(date_dir, exist_ok=True)
    dest = os.path.join(date_dir, name)
    if os.path.exists(dest):
        base, ext2 = os.path.splitext(name)
        dest = os.path.join(date_dir, base + "_" + datetime.now().strftime("%H%M%S") + ext2)
    shutil.copy2(tmpPath, dest)
    return json.dumps(dict(success=True, path=dest, filename=name, size=file_size))
}

/// Forward SSE events from a temp file, enriching tool_use events with human-readable labels.
ClassMethod ForwardSSE(tmpFile As %String)
{
    If '##class(%File).Exists(tmpFile) Quit
    Set labelsJson = ..GetToolLabelsJSON()
    Set stream = ##class(%Stream.FileCharacter).%New()
    Set sc = stream.LinkToFile(tmpFile)
    If $$$ISERR(sc) Quit
    While 'stream.AtEnd {
        Set line = stream.ReadLine()
        If line '= "" {
            // Enrich tool_use events with resolved labels
            If line [ """type"":""tool_use""" {
                Try {
                    Set obj = ##class(%DynamicObject).%FromJSON(line)
                    Set toolName = obj.%Get("tool")
                    Set toolInput = obj.%Get("input")
                    If toolName '= "" {
                        Set label = ..ResolveToolLabel(toolName, $select(toolInput="":"", 1:toolInput), labelsJson)
                        Do obj.%Set("label", label)
                        Set line = obj.%ToJSON()
                    }
                } Catch ex {}
            }
            Do ..WriteSSE(line)
        }
    }
}

ClassMethod InitSession() As %Status
{
    Do ..SetupEnv()
    // Ensure InterClaw.Pipeline.Production is running before starting a Claude session
    Set prodResult = ..EnsureProduction()
    Set body = ..ReadBody()
    Set %response.ContentType = "text/event-stream"
    Set %response.CharSet = "utf-8"
    Do %response.SetHeader("Cache-Control", "no-cache")
    Do %response.SetHeader("X-Accel-Buffering", "no")
    Set tmpFile = ##class(%File).TempFilename("sse")
    Set result = ..InitSessionPy(..ResolveCWD(), ..GetCLIHome(), body, tmpFile)
    Do ..ForwardSSE(tmpFile)
    Set fallbackId = $piece(result, "|", 1)
    Set claudeId = $piece(result, "|", 2)
    // Claude session ID is the canonical identifier; UUID is fallback only
    Set sessionId = $select(claudeId '= "": claudeId, 1: fallbackId)
    // Resolve per-session model and namespace (body → Config defaults)
    Try {
        Set bodyObj = ##class(%DynamicObject).%FromJSON(body)
        Set sessionModel = bodyObj.%Get("model")
        Set sessionNs = bodyObj.%Get("namespace")
    } Catch ex {
        Set sessionModel = ""
        Set sessionNs = ""
    }
    If sessionModel = "" Set sessionModel = $get(^InterClaw.Config("Model"), "opus")
    If sessionNs = "" Set sessionNs = $get(^InterClaw.Config("Namespace"), "INTERCLAW")
    Do ..WriteSSE("{""type"":""session"",""session_id"":""" _ sessionId _ """,""model"":""" _ sessionModel _ """,""namespace"":""" _ sessionNs _ """}")
    Do ..WriteSSE("{""type"":""status"",""text"":""Ready""}")
    If ##class(%File).Exists(tmpFile) { Do ##class(%File).Delete(tmpFile) }
    Return $$$OK
}

ClassMethod InitSessionPy(cwd As %String, cliHome As %String, body As %String, sseFile As %String) As %String [ Language = python ]
{
    import json, os, asyncio, uuid, re
    os.makedirs(cliHome, exist_ok=True)
    os.environ["HOME"] = cliHome
    os.chdir(cwd)
    from claude_agent_sdk import (
        query, ClaudeAgentOptions, AssistantMessage, UserMessage,
        SystemMessage, ResultMessage, TextBlock, ToolUseBlock, ToolResultBlock, ThinkingBlock,
    )
    data = json.loads(body) if body else dict()
    namespace = data.get("namespace")
    model = data.get("model")
    session_id = str(uuid.uuid4())
    if namespace:
        init_prompt = "You are connected to InterSystems IRIS, namespace " + namespace + ". The user is working in the interop editor. Be ready to help with production components, DTLs, rules, etc. Do not list available commands - wait for the user to ask."
    else:
        init_prompt = "You are connected to InterSystems IRIS. Be ready to help. Do not list available commands."
    options = ClaudeAgentOptions(cwd=cwd, permission_mode="bypassPermissions")
    if model:
        options.model = model
    claude_session_id = None
    all_text = []
    sse_out = open(sseFile, "w")
    def sse(d):
        sse_out.write(json.dumps(d) + "\n")
        sse_out.flush()
    sse(dict(type="status", text="Connecting..."))
    async def _run():
        nonlocal claude_session_id
        try:
            async for message in query(prompt=init_prompt, options=options):
                if isinstance(message, SystemMessage):
                    if message.subtype == "init" and message.data:
                        sid = message.data.get("session_id")
                        if sid:
                            claude_session_id = sid
                elif isinstance(message, AssistantMessage):
                    for block in message.content:
                        if isinstance(block, TextBlock):
                            all_text.append(block.text)
                            sse(dict(type="output", text=block.text))
                        elif isinstance(block, ToolUseBlock):
                            _tinp = json.dumps(block.input)[:2000]
                            sse(dict(type="tool_use", tool=block.name, input=_tinp))
                        elif isinstance(block, ThinkingBlock):
                            sse(dict(type="thinking", text=block.thinking))
                elif isinstance(message, UserMessage):
                    for block in message.content:
                        if isinstance(block, ToolResultBlock):
                            result_str = str(block.content)[:8000]
                            all_text.append(result_str)
                            sse(dict(type="tool_result", text=result_str))
                elif isinstance(message, ResultMessage):
                    claude_session_id = message.session_id
        except Exception as e:
            err_str = str(e)
            if "exit code: 255" not in err_str and "exit code 255" not in err_str:
                sse(dict(type="error", text=err_str))
    asyncio.run(_run())
    full_text = "\n".join(all_text)
    def _infer_editor(cn):
        parts = cn.split(".")
        parent = parts[-2].lower() if len(parts) >= 2 else ""
        if parent == "dtl": return "dtl"
        if parent == "rule" or cn.lower().endswith("routingrule"): return "rule"
        if parent == "bpl": return "bpl"
        if cn.lower().endswith(".production"): return "production"
        return None
    for line in reversed(full_text.split("\n")):
        cleaned = line.strip().strip("`").strip()
        if cleaned.startswith("/goto-reload ") or cleaned.startswith("/goto "):
            is_reload = cleaned.startswith("/goto-reload ")
            offset = 13 if is_reload else 6
            target = cleaned[offset:].strip().strip("`.,;:!?")
            editor = None
            if target.startswith("--dtl "): editor = "dtl"; target = target[6:].strip()
            elif target.startswith("--rule "): editor = "rule"; target = target[7:].strip()
            elif target.startswith("--bpl "): editor = "bpl"; target = target[6:].strip()
            elif target.startswith("--trace"): editor = "trace"; target = target[7:].strip() or None
            if not editor and target:
                editor = _infer_editor(target)
            if target or editor == "trace":
                evt = dict(type="goto", target=target)
                if editor: evt["editor"] = editor
                sse(evt)
            break
    ok_classes = re.findall(r"OK: (?:Created|Updated|Compiled) '([^']+\.cls)'", full_text)
    if ok_classes:
        target = ok_classes[-1].replace(".cls", "")
        editor = _infer_editor(target)
        evt = dict(type="goto", target=target)
        if editor: evt["editor"] = editor
        sse(evt)
    sse(dict(type="done", session_id=claude_session_id or session_id))
    sse_out.close()
    return session_id + "|" + (claude_session_id or "")
}

ClassMethod SendMessage() As %Status
{
    Do ..SetupEnv()
    Set body = ..ReadBody()
    Set %response.ContentType = "text/event-stream"
    Set %response.CharSet = "utf-8"
    Do %response.SetHeader("Cache-Control", "no-cache")
    Do %response.SetHeader("X-Accel-Buffering", "no")
    Set tmpFile = ##class(%File).TempFilename("sse")
    // session_id from the frontend IS the Claude session ID — no lookup needed
    Set result = ..SendMessagePy(..ResolveCWD(), ..GetCLIHome(), body, tmpFile)
    Do ..ForwardSSE(tmpFile)
    Do ..WriteSSE("{""type"":""status"",""text"":""Ready""}")
    Set sessionId = $piece(result, "|", 1)
    Set latestId = $piece(result, "|", 2)
    Set activeId = $select(latestId '= "": latestId, 1: sessionId)
    If ##class(%File).Exists(tmpFile) { Do ##class(%File).Delete(tmpFile) }
    Return $$$OK
}

ClassMethod SendMessagePy(cwd As %String, cliHome As %String, body As %String, sseFile As %String) As %String [ Language = python ]
{
    import json, os, asyncio, re
    os.makedirs(cliHome, exist_ok=True)
    os.environ["HOME"] = cliHome
    os.chdir(cwd)
    from claude_agent_sdk import (
        query, ClaudeAgentOptions, AssistantMessage, UserMessage,
        SystemMessage, ResultMessage, TextBlock, ToolUseBlock, ToolResultBlock, ThinkingBlock,
    )
    data = json.loads(body) if body else dict()
    session_id = data.get("session_id", "")
    text = data.get("text", "")
    model = data.get("model")
    options = ClaudeAgentOptions(cwd=cwd, permission_mode="bypassPermissions")
    if model:
        options.model = model
    if session_id:
        options.resume = session_id
    all_text = []
    new_claude_sid = None
    sse_out = open(sseFile, "w")
    def sse(d):
        sse_out.write(json.dumps(d) + "\n")
        sse_out.flush()
    async def _run():
        nonlocal new_claude_sid
        try:
            async for message in query(prompt=text, options=options):
                if isinstance(message, SystemMessage):
                    if message.subtype == "init" and message.data:
                        sid = message.data.get("session_id")
                        if sid:
                            new_claude_sid = sid
                elif isinstance(message, AssistantMessage):
                    for block in message.content:
                        if isinstance(block, TextBlock):
                            all_text.append(block.text)
                            sse(dict(type="output", text=block.text))
                        elif isinstance(block, ToolUseBlock):
                            _tinp = json.dumps(block.input)[:2000]
                            sse(dict(type="tool_use", tool=block.name, input=_tinp))
                        elif isinstance(block, ThinkingBlock):
                            sse(dict(type="thinking", text=block.thinking))
                elif isinstance(message, UserMessage):
                    for block in message.content:
                        if isinstance(block, ToolResultBlock):
                            result_str = str(block.content)[:8000]
                            all_text.append(result_str)
                            sse(dict(type="tool_result", text=result_str))
                elif isinstance(message, ResultMessage):
                    new_claude_sid = message.session_id
        except Exception as e:
            err_str = str(e)
            if "exit code: 255" not in err_str and "exit code 255" not in err_str:
                sse(dict(type="error", text=err_str))
    asyncio.run(_run())
    full_text = "\n".join(all_text)
    def _infer_editor(cn):
        parts = cn.split(".")
        parent = parts[-2].lower() if len(parts) >= 2 else ""
        if parent == "dtl": return "dtl"
        if parent == "rule" or cn.lower().endswith("routingrule"): return "rule"
        if parent == "bpl": return "bpl"
        if cn.lower().endswith(".production"): return "production"
        return None
    for line in reversed(full_text.split("\n")):
        cleaned = line.strip().strip("`").strip()
        if cleaned.startswith("/goto-reload ") or cleaned.startswith("/goto "):
            is_reload = cleaned.startswith("/goto-reload ")
            offset = 13 if is_reload else 6
            target = cleaned[offset:].strip().strip("`.,;:!?")
            editor = None
            if target.startswith("--dtl "): editor = "dtl"; target = target[6:].strip()
            elif target.startswith("--rule "): editor = "rule"; target = target[7:].strip()
            elif target.startswith("--bpl "): editor = "bpl"; target = target[6:].strip()
            elif target.startswith("--trace"): editor = "trace"; target = target[7:].strip() or None
            if not editor and target:
                editor = _infer_editor(target)
            if target or editor == "trace":
                evt = dict(type="goto", target=target)
                if editor: evt["editor"] = editor
                sse(evt)
            break
    ok_classes = re.findall(r"OK: (?:Created|Updated|Compiled) '([^']+\.cls)'", full_text)
    if ok_classes:
        target = ok_classes[-1].replace(".cls", "")
        editor = _infer_editor(target)
        evt = dict(type="goto", target=target)
        if editor: evt["editor"] = editor
        sse(evt)
    sse(dict(type="done", session_id=new_claude_sid or session_id))
    sse_out.close()
    return session_id + "|" + (new_claude_sid or "")
}

/// POST /api/bridge/start — start a chat via the production pipeline, return bridge_id.
/// Body: {"prompt":"...", "session_id":"...", "model":"...", "namespace":"...", "action":"init|message",
///        "permission_mode":"...", "effort":"...", "editor_context":{...}}
ClassMethod BridgeStart() As %Status
{
    Do ..SetupEnv()
    Set body = ..ReadBody()
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"

    Try {
        Set obj = ##class(%DynamicObject).%FromJSON(body)
    } Catch ex {
        Do ..WriteJSON("{""error"":""Invalid JSON""}", 400)
        Return $$$OK
    }

    Set prompt = obj.%Get("prompt")
    Set sessionId = obj.%Get("session_id")
    Set model = obj.%Get("model")
    Set namespace = obj.%Get("namespace")
    If namespace = "" Set namespace = "CLAUDE"
    Set action = obj.%Get("action")
    If action = "" Set action = $select(sessionId = "":"init", 1:"message")

    // Create bridge session
    Set bridgeId = $extract($system.Util.CreateGUID(), 1, 12)
    Set ^InterClaw.ChatEvents(bridgeId, "seq") = 0
    Set ^InterClaw.ChatEvents(bridgeId, "done") = 0
    Set ^InterClaw.ChatEvents(bridgeId, "session") = sessionId

    // Build payload JSON for the BO (includes all fields the SDK needs)
    Set payload = ##class(%DynamicObject).%New()
    Do payload.%Set("action", action)
    Do payload.%Set("prompt", prompt)
    Do payload.%Set("bridge_id", bridgeId)
    Do payload.%Set("namespace", namespace)
    If model '= "" Do payload.%Set("model", model)
    If sessionId '= "" Do payload.%Set("session_id", sessionId)
    If obj.%Get("permission_mode") '= "" Do payload.%Set("permission_mode", obj.%Get("permission_mode"))
    If obj.%Get("effort") '= "" Do payload.%Set("effort", obj.%Get("effort"))
    If obj.%IsDefined("editor_context") Do payload.%Set("editor_context", obj.%Get("editor_context"))

    // Route through the production for tracing and management
    Set request = ##class(InterClaw.Pipeline.Msg.ChatRequest).%New()
    Set request.BridgeId = bridgeId
    Set request.PayloadJSON = payload.%ToJSON()
    Set request.Prompt = prompt
    Set request.SessionId = sessionId
    Set request.Model = model
    Set request.Namespace = namespace
    Set request.Action = action
    Set sc = ##class(Ens.Director).CreateBusinessService("InterClaw.Pipeline.BS.ChatService", .service)
    If $$$ISOK(sc) {
        Set sc = service.ProcessInput(request)
        If $$$ISERR(sc) {
            Do ..WriteJSON("{""error"":""" _ $replace($system.Status.GetOneStatusText(sc), """", "\""") _ """}", 500)
            Return $$$OK
        }
    } Else {
        Do ..WriteJSON("{""error"":""Failed to create service: " _ $replace($system.Status.GetOneStatusText(sc), """", "\""") _ """}", 500)
        Return $$$OK
    }

    Write "{""bridge_id"":""" _ bridgeId _ """}"
    Return $$$OK
}

/// GET /api/bridge/events?bridge_id=X&after=N — server-hold polling for events.
/// Waits up to 30s for new events, returns immediately when events are ready.
/// Pure ObjectScript — reads ^InterClaw.ChatEvents directly, no iris Python module.
ClassMethod BridgeEvents() As %Status
{
    Set bridgeId = $get(%request.Data("bridge_id", 1), "")
    Set after = +$get(%request.Data("after", 1), 0)
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"

    If bridgeId = "" {
        Write "{""error"":""Missing bridge_id""}"
        Return $$$OK
    }

    // Check session exists
    If '$data(^InterClaw.ChatEvents(bridgeId, "seq")) {
        Write "{""error"":""Unknown bridge_id""}"
        Return $$$OK
    }

    // Server-hold: wait up to 30s for new events
    Set events = ##class(%DynamicArray).%New()
    Set start = $zh

    For {
        Set currentSeq = +$get(^InterClaw.ChatEvents(bridgeId, "seq"), 0)

        If currentSeq > after {
            // Collect all events after the requested sequence
            For seq = after+1:1:currentSeq {
                Set raw = $get(^InterClaw.ChatEvents(bridgeId, "evt", seq))
                If raw '= "" {
                    Set evt = ##class(%DynamicObject).%New()
                    Do evt.%Set("seq", seq, "number")
                    Try {
                        Set data = ##class(%DynamicObject).%FromJSON(raw)
                        Do evt.%Set("data", data)
                    } Catch ex {
                        Set fallback = ##class(%DynamicObject).%New()
                        Do fallback.%Set("type", "raw")
                        Do fallback.%Set("text", raw)
                        Do evt.%Set("data", fallback)
                    }
                    Do events.%Push(evt)
                }
            }
            Quit
        }

        // Check if done with no new events
        Set done = $get(^InterClaw.ChatEvents(bridgeId, "done"))
        If (done = 1) && (currentSeq <= after) Quit

        // Check deadline
        If ($zh - start) >= 30 Quit

        // Wait a short interval before checking again
        Hang 0.05
    }

    Set doneFlag = +$get(^InterClaw.ChatEvents(bridgeId, "done"), 0)
    Set result = ##class(%DynamicObject).%New()
    Do result.%Set("events", events)
    Do result.%Set("done", (doneFlag = 1), "boolean")
    Write result.%ToJSON()
    Return $$$OK
}

}
