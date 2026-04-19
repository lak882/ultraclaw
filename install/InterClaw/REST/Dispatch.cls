/// InterClaw.REST.Dispatch — control-plane REST for the chatbot sidebar.
/// Handles config, commands, permissions, auth, uploads, telemetry, feedback,
/// namespace/model preferences, and the skill index. Chat streaming lives in
/// InterClaw.V2.RESTAdapter, which owns /api/interclaw/production.
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
<Route Url="/api/upload"              Method="POST"  Call="Upload"/>
<Route Url="/api/telemetry/summary"   Method="GET"   Call="TelemetrySummary"/>
<Route Url="/api/telemetry"           Method="POST"  Call="Telemetry"/>
<Route Url="/api/feedback"            Method="POST"  Call="PostFeedback"/>
<Route Url="/api/feedback"            Method="GET"   Call="GetFeedback"/>
<Route Url="/api/namespace"            Method="GET"   Call="GetNamespace"/>
<Route Url="/api/namespace"            Method="PUT"   Call="SetNamespace"/>
<Route Url="/api/model"                Method="GET"   Call="GetModel"/>
<Route Url="/api/model"                Method="PUT"   Call="SetModel"/>
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
    Do ..WriteJSON("{""status"":""ok"",""service"":""interclaw-control""}")
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


}
