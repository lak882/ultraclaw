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
    return $system.Util.InstallDirectory() _ "csp/interclaw/"
}

/// Resolve CLIHOME dynamically: ^InterClaw.Config > env var > fallback
ClassMethod GetCLIHome() As %String
{
    set val = $get(^InterClaw.Config("CLIHOME"))
    if val '= "" return val
    return $system.Util.InstallDirectory() _ "mgr/interclaw_home/"
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
<Route Url="/api/init"                Method="POST"  Call="InitSession"/>
<Route Url="/api/message"             Method="POST"  Call="SendMessage"/>
<Route Url="/api/upload"              Method="POST"  Call="Upload"/>
<Route Url="/api/telemetry/summary"   Method="GET"   Call="TelemetrySummary"/>
<Route Url="/api/telemetry"           Method="POST"  Call="Telemetry"/>
<Route Url="/api/feedback"            Method="POST"  Call="PostFeedback"/>
<Route Url="/api/feedback"            Method="GET"   Call="GetFeedback"/>
<Route Url="/api/test-claude"         Method="GET"   Call="TestClaude"/>
<Route Url="/api/bridge/start"        Method="POST"  Call="BridgeStart"/>
<Route Url="/api/bridge/events"       Method="GET"   Call="BridgeEvents"/>
</Routes>
}

ClassMethod SetupEnv() [ Language = python ]
{
    import os, iris
    # Read paths from ^InterClaw.Config (set by Installer), with env var overrides
    g = iris.gref("^InterClaw.Config")
    cwd = os.environ.get("INTERCLAW_CWD") or str(g["CWD"] or "") or (os.path.join(iris.cls('%SYSTEM.Util').InstallDirectory(), "csp", "interclaw"))
    cli_home = os.environ.get("INTERCLAW_CLIHOME") or str(g["CLIHOME"] or "") or (os.path.join(iris.cls('%SYSTEM.Util').InstallDirectory(), "mgr", "interclaw_home"))

    if not os.environ.get("_INTERCLAW_ENV_LOADED"):
        loaded = False

        # Try %Wallet first
        try:
            import json
            secret = iris.cls('%Wallet.KeyValue').GetSecretValue("InterClaw.BedrockKey")
            if secret is not None:
                data = json.loads(str(secret)) if not isinstance(secret, dict) else secret
                os.environ["ANTHROPIC_API_KEY"] = data.get("key", "")
                os.environ["CLAUDE_CODE_USE_BEDROCK"] = "1"
                os.environ["AWS_REGION"] = data.get("region", "us-east-1")
                os.environ["AWS_BEARER_TOKEN_BEDROCK"] = data.get("key", "")
                loaded = True
        except Exception:
            pass

        os.environ["_INTERCLAW_ENV_LOADED"] = "1"

    os.makedirs(cli_home, exist_ok=True)
    os.environ["HOME"] = cli_home
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
ClassMethod ResolveCWD() As %String [ Language = python ]
{
    import os, iris
    cwd = os.environ.get("INTERCLAW_CWD")
    if cwd and os.path.isdir(cwd):
        return cwd
    g = iris.gref("^InterClaw.Config")
    val = g["CWD"]
    if val and os.path.isdir(str(val)):
        return str(val)
    return os.path.join(iris.cls('%SYSTEM.Util').InstallDirectory(), "csp", "interclaw")
}

/// Map a raw tool call (name + input JSON) to a human-readable label.
/// Labels are stored in the InterClaw.ToolLabels lookup table (editable in Portal).
/// Template values use {1} as placeholder for the primary dynamic argument.
ClassMethod ResolveToolLabel(toolName As %String, toolInput As %String) As %String [ Language = python ]
{
    import json, re, os
    import iris as _iris

    tbl = _iris.gref('^Ens.LookupTable')
    TABLE = 'InterClaw.ToolLabels'

    def lkup(key):
        try:
            v = tbl[TABLE, key]
            return v if v is not None else None
        except Exception:
            return None

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

/// Ensure InterClaw.Production is running. Handles every possible state:
///   1 (Running)        — if InterClaw.Production, no-op; if different, stop it then start ours
///   2 (Stopped)        — start InterClaw.Production
///   3 (Suspended)      — recover, fallback to clean+stop, then start
///   4 (Troubled)       — recover, fallback to clean+stop, then start
///   5 (NetworkStopped) — stop then start
///   0 (None)           — start InterClaw.Production
///
/// Returns a JSON string: {"running":true/false,"state":"...","action":"...","error":"..."}
ClassMethod EnsureProduction() As %String
{
    Set prodTarget = "InterClaw.Production"
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

        // ── Fast path: InterClaw.Production is already running ──
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

        // ── InterClaw.Production is registered but not running ──
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

        // ── Start InterClaw.Production ──
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
    Do ..WriteJSON(..AuthStatusPy())
    Return $$$OK
}

ClassMethod AuthStatusPy() As %String [ Language = python ]
{
    import json, os
    key = os.environ.get("ANTHROPIC_API_KEY", "")
    is_bedrock = os.environ.get("CLAUDE_CODE_USE_BEDROCK", "") == "1"
    has_key = bool(key) and key.startswith("ABSK")
    prefix = None
    if has_key and len(key) > 8:
        prefix = key[:4] + "..." + key[-4:]

    # Check storage backend
    wallet_exists = False
    try:
        import iris
        wallet_exists = bool(iris.cls('%Wallet.KeyValue').Exists("InterClaw.BedrockKey"))
    except Exception:
        pass

    return json.dumps(dict(
        authenticated=has_key and is_bedrock,
        provider="bedrock" if is_bedrock else "anthropic",
        key_prefix=prefix,
        region=os.environ.get("AWS_REGION", ""),
        storage="wallet" if wallet_exists else "env",
    ))
}

ClassMethod Authenticate() As %Status
{
    Set body = ..ReadBody()
    Set result = ..AuthenticatePy(..GetCWD(), body)
    Set status = $select(result [ """error""":400, 1:200)
    Do ..WriteJSON(result, status)
    Return $$$OK
}

ClassMethod AuthenticatePy(cwd As %String, body As %String) As %String [ Language = python ]
{
    import json, os
    data = json.loads(body) if body else dict()
    key = data.get("key", "").strip()
    region = data.get("region", "us-east-1").strip()
    if not key:
        return json.dumps(dict(error="No key provided"))
    if not key.startswith("ABSK"):
        return json.dumps(dict(error="Invalid key format. Bedrock keys start with ABSK."))

    wallet_stored = False
    wallet_error = None

    # Try %Wallet first
    try:
        import iris
        # Delete existing secret for key rotation
        if iris.cls('%Wallet.KeyValue').Exists("InterClaw.BedrockKey"):
            iris.cls('%Wallet.KeyValue').Delete("InterClaw.BedrockKey")
        secret_json = json.dumps({"key": key, "region": region, "provider": "bedrock"})
        props = iris.cls('%DynamicObject')._New()
        props._Set("Secret", secret_json)
        props._Set("Usage", "CUSTOM")
        sc = iris.cls('%Wallet.KeyValue').Create("InterClaw.BedrockKey", props)
        if iris.cls('%SYSTEM.Status').IsOK(sc):
            wallet_stored = True
        else:
            wallet_error = iris.cls('%SYSTEM.Status').GetOneStatusText(sc)
    except Exception as e:
        wallet_error = str(e)

    # Set in current process so this session works immediately
    env_lines = dict(
        ANTHROPIC_API_KEY=key,
        CLAUDE_CODE_USE_BEDROCK="1",
        AWS_REGION=region,
        AWS_BEARER_TOKEN_BEDROCK=key,
    )
    for k, v in env_lines.items():
        os.environ[k] = v
    os.environ["_INTERCLAW_ENV_LOADED"] = ""

    key_prefix = key[:4] + "..." + key[-4:] if len(key) > 8 else "****"
    result = dict(
        success=True,
        message="Bedrock key stored in wallet",
        key_prefix=key_prefix,
        wallet_stored=wallet_stored,
    )
    if wallet_error:
        result["wallet_warning"] = wallet_error
    if not wallet_stored:
        result["success"] = False
        result["message"] = "Failed to store key in wallet: " + (wallet_error or "unknown error")
    return json.dumps(result)
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

ClassMethod ForwardSSE(tmpFile As %String)
{
    If '##class(%File).Exists(tmpFile) Quit
    Set stream = ##class(%Stream.FileCharacter).%New()
    Set sc = stream.LinkToFile(tmpFile)
    If $$$ISERR(sc) Quit
    While 'stream.AtEnd {
        Set line = stream.ReadLine()
        If line '= "" {
            Do ..WriteSSE(line)
        }
    }
}

ClassMethod InitSession() As %Status
{
    Do ..SetupEnv()
    // Ensure InterClaw.Production is running before starting a Claude session
    Set prodResult = ..EnsureProduction()
    Set body = ..ReadBody()
    Set %response.ContentType = "text/event-stream"
    Set %response.CharSet = "utf-8"
    Do %response.SetHeader("Cache-Control", "no-cache")
    Do %response.SetHeader("X-Accel-Buffering", "no")
    Set tmpFile = ##class(%File).TempFilename("sse")
    Set result = ..InitSessionPy(..ResolveCWD(), ..GetCLIHome(), body, tmpFile)
    Do ..ForwardSSE(tmpFile)
    Set sessionId = $piece(result, "|", 1)
    Set claudeSessionId = $piece(result, "|", 2)
    Do ..WriteSSE("{""type"":""session"",""session_id"":""" _ sessionId _ """}")
    Do ..WriteSSE("{""type"":""status"",""text"":""Ready""}")
    Set ^InterClaw.Sessions(sessionId, "claude") = claudeSessionId
    Set ^InterClaw.Sessions(sessionId, "created") = $zdatetime($horolog, 3)
    If ##class(%File).Exists(tmpFile) { Do ##class(%File).Delete(tmpFile) }
    Return $$$OK
}

ClassMethod InitSessionPy(cwd As %String, cliHome As %String, body As %String, sseFile As %String) As %String [ Language = python ]
{
    import json, os, asyncio, uuid, re, iris
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
                            _label = iris.cls('InterClaw.REST.Dispatch').ResolveToolLabel(block.name, _tinp)
                            sse(dict(type="tool_use", tool=block.name, input=_tinp, label=str(_label)))
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
    Try {
        Set bodyObj = ##class(%DynamicObject).%FromJSON(body)
        Set sessionId = bodyObj.%Get("session_id")
        If sessionId '= "" {
            Set claudeSid = $get(^InterClaw.Sessions(sessionId, "claude"), "")
            If claudeSid '= "" {
                Do bodyObj.%Set("claude_session_id", claudeSid)
                Set body = bodyObj.%ToJSON()
            }
        }
    } Catch ex {}
    Set result = ..SendMessagePy(..ResolveCWD(), ..GetCLIHome(), body, tmpFile)
    Do ..ForwardSSE(tmpFile)
    Do ..WriteSSE("{""type"":""status"",""text"":""Ready""}")
    Set sessionId = $piece(result, "|", 1)
    Set claudeSessionId = $piece(result, "|", 2)
    If sessionId '= "" && (claudeSessionId '= "") {
        Set ^InterClaw.Sessions(sessionId, "claude") = claudeSessionId
        Set ^InterClaw.Sessions(sessionId, "lastMessage") = $zdatetime($horolog, 3)
    }
    If ##class(%File).Exists(tmpFile) { Do ##class(%File).Delete(tmpFile) }
    Return $$$OK
}

ClassMethod SendMessagePy(cwd As %String, cliHome As %String, body As %String, sseFile As %String) As %String [ Language = python ]
{
    import json, os, asyncio, re, iris
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
    claude_sid = data.get("claude_session_id", "")
    options = ClaudeAgentOptions(cwd=cwd, permission_mode="bypassPermissions")
    if model:
        options.model = model
    if claude_sid:
        options.resume = claude_sid
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
                            _label = iris.cls('InterClaw.REST.Dispatch').ResolveToolLabel(block.name, _tinp)
                            sse(dict(type="tool_use", tool=block.name, input=_tinp, label=str(_label)))
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

/// POST /api/bridge/start — start a chat via internal WebSocket, return bridge_id.
/// Body: {"prompt":"...", "session_id":"...", "model":"...", "namespace":"...", "action":"init|message"}
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

    // Build payload JSON for the WebSocket
    Set payload = ##class(%DynamicObject).%New()
    Do payload.%Set("action", action)
    Do payload.%Set("prompt", prompt)
    If model '= "" Do payload.%Set("model", model)
    If action = "init" Do payload.%Set("namespace", namespace)
    If sessionId '= "" Do payload.%Set("session_id", sessionId)

    // JOB a background process to do the WebSocket work
    Job ..BridgeWorker(bridgeId, payload.%ToJSON())

    Write "{""bridge_id"":""" _ bridgeId _ """}"
    Return $$$OK
}

/// Background worker: connect to InterClaw.WS.Chat via %Net.WebSocket.Client, store events in global.
/// Called via JOB from BridgeStart — runs in a separate IRIS process.
ClassMethod BridgeWorker(bridgeId As %String, payloadJSON As %String)
{
    // Derive WebSocket URL from ^%SYS("WebServer") — no hardcoded host/prefix
    Set wsPort = 80, wsPrefix = ""
    Do {
        new $namespace
        set $namespace = "%SYS"
        Set wsPort = $get(^%SYS("WebServer","Port"), 80)
        Set wsPrefix = $get(^%SYS("WebServer","URLPrefix"), "")
    } While 0
    If wsPrefix '= "" && ($extract(wsPrefix) '= "/") Set wsPrefix = "/" _ wsPrefix
    Set wsUrl = "ws://localhost:" _ wsPort _ wsPrefix _ "/api/ws/InterClaw.WS.Chat.cls"

    Try {
        // Create event listener that writes to ^InterClaw.ChatEvents
        Set listener = ##class(InterClaw.Bridge.EventListener).%New()
        Set listener.BridgeId = bridgeId

        // Connect to WebSocket
        Set ws = ##class(%Net.WebSocket.Client).%New(wsUrl, , listener)

        // Wait for initial "connected" message
        Set open = ws.Next(10, .timedOut)
        If 'open || timedOut {
            Set seq = $increment(^InterClaw.ChatEvents(bridgeId, "seq"))
            Set ^InterClaw.ChatEvents(bridgeId, "evt", seq) = "{""type"":""error"",""text"":""WebSocket connection failed""}"
            Set ^InterClaw.ChatEvents(bridgeId, "done") = 1
            Quit
        }

        // Send the prompt payload
        Set sc = ws.Send(payloadJSON)
        If $$$ISERR(sc) {
            Set seq = $increment(^InterClaw.ChatEvents(bridgeId, "seq"))
            Set ^InterClaw.ChatEvents(bridgeId, "evt", seq) = "{""type"":""error"",""text"":""Send failed: " _ $system.Status.GetOneStatusText(sc) _ """}"
            Set ^InterClaw.ChatEvents(bridgeId, "done") = 1
            Quit
        }

        // Read events until done or connection closes (5 min timeout per message)
        While ws.Next(300, .timedOut) {
            If timedOut {
                Set seq = $increment(^InterClaw.ChatEvents(bridgeId, "seq"))
                Set ^InterClaw.ChatEvents(bridgeId, "evt", seq) = "{""type"":""error"",""text"":""Timeout waiting for response""}"
                Set ^InterClaw.ChatEvents(bridgeId, "done") = 1
                Quit
            }
            // OnMessage callback in EventListener handles storage
            // Check if done flag was set by the listener
            If $get(^InterClaw.ChatEvents(bridgeId, "done")) Quit
        }

    } Catch ex {
        Set seq = $increment(^InterClaw.ChatEvents(bridgeId, "seq"))
        Set ^InterClaw.ChatEvents(bridgeId, "evt", seq) = "{""type"":""error"",""text"":""" _ $replace(ex.DisplayString(), """", "\""") _ """}"
        Set ^InterClaw.ChatEvents(bridgeId, "done") = 1
    }
}

/// GET /api/bridge/events?bridge_id=X&after=N — server-hold polling for events.
/// Waits up to 30s for new events, returns immediately when events are ready.
ClassMethod BridgeEvents() As %Status
{
    Set bridgeId = $get(%request.Data("bridge_id", 1), "")
    Set after = +$get(%request.Data("after", 1), 0)
    Set result = ..BridgeEventsPy(bridgeId, after)
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    Write result
    Return $$$OK
}

ClassMethod BridgeEventsPy(bridgeId As %String, after As %Integer) As %String [ Language = python ]
{
    import json, time, iris

    if not bridgeId:
        return json.dumps({"error": "Missing bridge_id"})

    g = iris.gref("^InterClaw.ChatEvents")

    # Check session exists
    if g[bridgeId, "seq"] is None:
        return json.dumps({"error": "Unknown bridge_id"})

    # Server-hold: wait up to 30s for new events
    events = []
    deadline = time.time() + 30

    while time.time() < deadline:
        current_seq = int(g[bridgeId, "seq"])

        if current_seq > after:
            # Collect all events after the requested sequence
            for seq in range(after + 1, current_seq + 1):
                raw = g[bridgeId, "evt", seq]
                if raw is not None:
                    try:
                        events.append({"seq": seq, "data": json.loads(str(raw))})
                    except Exception:
                        events.append({"seq": seq, "data": {"type": "raw", "text": str(raw)}})
            break

        # Check if done with no new events
        done = g[bridgeId, "done"]
        if done is not None and int(done) == 1 and current_seq <= after:
            break

        # Wait a short interval before checking again
        time.sleep(0.05)

    done_flag = g[bridgeId, "done"]
    is_done = done_flag is not None and int(done_flag) == 1

    return json.dumps({"events": events, "done": is_done})
}

}
