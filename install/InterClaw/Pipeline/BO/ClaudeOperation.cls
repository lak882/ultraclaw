/// Embedded Python operation — calls claude_agent_sdk.query() directly
/// and streams events via EventWriter for frontend polling and trace visibility.
Class InterClaw.Pipeline.BO.ClaudeOperation Extends Ens.BusinessOperation
{

Property ReadTimeout As %Integer [ InitialExpression = 300 ];

Property EventWriterTarget As Ens.DataType.ConfigName [ InitialExpression = "InterClaw.Pipeline.BP.EventWriter" ];

Parameter SETTINGS = "ReadTimeout:Basic,EventWriterTarget:Basic";

Parameter INVOCATION = "Queue";

/// Return a value from ^InterClaw.Config by key.
Method GetConfigValue(key As %String) As %String
{
    return $get(^InterClaw.Config(key), "")
}

/// Return the IRIS install directory path.
Method GetInstallDirectory() As %String
{
    return $system.Util.InstallDirectory()
}

/// Return the stored Bedrock API key JSON from Ens.Config.Credentials, or "" if not configured.
/// The credential "InterClaw.Bedrock" stores the JSON payload as its Password field.
Method GetCredentialSecret() As %String
{
    set secret = ""
    try {
        if ##class(Ens.Config.Credentials).%ExistsId("InterClaw.Bedrock") {
            set cred = ##class(Ens.Config.Credentials).%OpenId("InterClaw.Bedrock")
            if cred '= "" set secret = cred.Password
        }
    } catch ex {}
    return secret
}

/// Return 1 if an IRIS user credential is stored, 0 otherwise.
Method IsLoggedIn() As %Boolean
{
    try {
        if ##class(Ens.Config.Credentials).%ExistsId("InterClaw.User") {
            return 1
        }
    } catch ex {}
    return 0
}

/// Return the stored IRIS username, or "" if not logged in.
Method GetIRISUsername() As %String
{
    try {
        set cred = ##class(Ens.Config.Credentials).%OpenId("InterClaw.User")
        if cred '= "" return cred.Username
    } catch ex {}
    return ""
}

/// Return the stored IRIS password, or "" if not logged in.
Method GetIRISPassword() As %String
{
    try {
        set cred = ##class(Ens.Config.Credentials).%OpenId("InterClaw.User")
        if cred '= "" return cred.Password
    } catch ex {}
    return ""
}

/// Mark a bridge as pending approval.
Method SetPending(bridgeId As %String)
{
    set ^InterClaw.ChatPending(bridgeId, "pending") = "1"
}

/// Return the pending approval response for a bridge, or "" if none yet.
Method GetPendingResponse(bridgeId As %String) As %String
{
    return $get(^InterClaw.ChatPending(bridgeId, "response"), "")
}

/// Clear all pending approval state for a bridge.
Method ClearPending(bridgeId As %String)
{
    kill ^InterClaw.ChatPending(bridgeId)
}

/// Send an event to EventWriter for global storage and trace visibility.
Method EmitEvent(bridgeId As %String, eventJSON As %String)
{
    Set msg = ##class(InterClaw.Pipeline.Msg.ChatEvent).%New()
    Set msg.BridgeId = bridgeId
    Set msg.EventJSON = eventJSON
    Do ..SendRequestAsync(..EventWriterTarget, msg)
}

Method OnMessage(pRequest As InterClaw.Pipeline.Msg.ChatRequest, Output pResponse As InterClaw.Pipeline.Msg.ChatResponse) As %Status
{
    Set bridgeId = pRequest.BridgeId
    Set pResponse = ##class(InterClaw.Pipeline.Msg.ChatResponse).%New()
    Set pResponse.BridgeId = bridgeId
    Set pResponse.Status = "completed"

    Set resultJSON = ..RunQuery(bridgeId, pRequest.PayloadJSON)

    Try {
        Set result = ##class(%DynamicObject).%FromJSON(resultJSON)
        Set pResponse.SessionId = result.%Get("session_id")
        If result.%Get("cost") '= "" Set pResponse.Cost = result.%Get("cost")
        If result.%Get("input_tokens") '= "" Set pResponse.InputTokens = result.%Get("input_tokens")
        If result.%Get("output_tokens") '= "" Set pResponse.OutputTokens = result.%Get("output_tokens")
        If result.%Get("event_count") '= "" Set pResponse.EventCount = result.%Get("event_count")
        If result.%Get("error") '= "" Set pResponse.Status = "error"
    } Catch ex {
        Set pResponse.Status = "error"
    }

    Return $$$OK
}

/// Run the Claude SDK query in embedded Python.
/// Streams events to ^InterClaw.ChatEvents via EmitEvent().
/// Returns a JSON summary string with session_id, cost, tokens, event_count.
Method RunQuery(bridgeId As %String, payloadJSON As %String) As %String [ Language = python ]
{
    import asyncio, json, os, sys, time

    CWD = str(self.GetConfigValue("CWD")) or ""
    if not CWD:
        CWD = str(self.GetInstallDirectory()) + "csp/interclaw/"
    os.chdir(CWD)
    # Resolve HOME from the actual process UID, not the inherited $HOME
    # env var. On Linux after sudo ./irisinstall, $HOME points to the
    # installer's home, not irisusr's. Without this fix the Claude CLI
    # picks up the wrong ~/.claude/settings.json and breaks on restart.
    if sys.platform != "win32":
        import pwd
        home = pwd.getpwuid(os.getuid()).pw_dir
    else:
        home = os.path.expanduser("~")
    if not home or home == "~":
        home = "/tmp"
    os.environ["HOME"] = home

    # Give the CLI subprocess up to 120s to initialize (cold starts are slow)
    os.environ["CLAUDE_CODE_STREAM_CLOSE_TIMEOUT"] = "120000"

    # Pass logged-in IRIS credentials as env vars for scripts
    _iris_user = str(self.GetIRISUsername())
    _iris_pass = str(self.GetIRISPassword())
    if _iris_user:
        os.environ["IRIS_USERNAME"] = _iris_user
    if _iris_pass:
        os.environ["IRIS_PASSWORD"] = _iris_pass

    # On Windows, pywin32 DLLs installed via pip --target land in
    # Mgr/python/pywin32_system32/ where Python cannot find them.
    if sys.platform == "win32":
        _dll_dir = os.path.join(str(self.GetInstallDirectory()), "Mgr", "python", "pywin32_system32")
        if os.path.isdir(_dll_dir):
            os.add_dll_directory(_dll_dir)
            os.environ["PATH"] = _dll_dir + ";" + os.environ.get("PATH", "")

    from claude_agent_sdk import (
        query, ClaudeAgentOptions, AssistantMessage, ResultMessage,
        UserMessage, TextBlock, ToolUseBlock, ThinkingBlock, ToolResultBlock,
    )

    op = self
    bridge_id = str(bridgeId)

    def emit(data):
        op.EmitEvent(bridge_id, json.dumps(data))

    emit({"type": "connected"})

    # Read instance config from ^InterClaw.Config (set by installer)
    _default_server = str(self.GetConfigValue("DefaultServer")) or "localhost"
    _path_prefix = str(self.GetConfigValue("PathPrefix")) or ""
    _server_ctx = f"Instance: {_default_server}."

    # Parse the payload
    req = json.loads(str(payloadJSON))

    action = req.get("action", "message")
    session_id = req.get("session_id")
    model = req.get("model")
    bridge_id = req.get("bridge_id", bridge_id)
    permission_mode = req.get("permission_mode", "")
    effort = req.get("effort", "")

    prompt = req.get("prompt", "")
    namespace = req.get("namespace", "")
    editor_context = req.get("editor_context", {})

    # Re-check both credentials on every message so /login, /logout,
    # /authenticate, and /deauthenticate take effect immediately.
    _logged_in = bool(self.IsLoggedIn())
    if not _logged_in:
        emit({"type": "output", "text": "Not logged in. Please run `/login <username> <password>` to sign in."})
        emit({"type": "done", "session_id": session_id or ""})
        return json.dumps({"session_id": session_id or "", "event_count": 3})

    try:
        secret = self.GetCredentialSecret()
        if secret:
            _data = json.loads(str(secret))
            os.environ["ANTHROPIC_API_KEY"] = _data.get("key", "")
            os.environ["CLAUDE_CODE_USE_BEDROCK"] = "1"
            os.environ["AWS_REGION"] = _data.get("region", "us-east-1")
            os.environ["AWS_BEARER_TOKEN_BEDROCK"] = _data.get("key", "")
        else:
            for _k in ("ANTHROPIC_API_KEY", "CLAUDE_CODE_USE_BEDROCK",
                        "AWS_REGION", "AWS_BEARER_TOKEN_BEDROCK"):
                os.environ.pop(_k, None)
    except Exception:
        pass

    if not os.environ.get("ANTHROPIC_API_KEY"):
        emit({"type": "output", "text": "No API key configured. Please run `/authenticate <BEDROCK_KEY>` to connect."})
        emit({"type": "done", "session_id": session_id or ""})
        return json.dumps({"session_id": session_id or "", "event_count": 3})

    # Prepend namespace/server/editor context so Claude knows what's currently open
    if namespace:
        client_origin = editor_context.get("origin", "")
        if client_origin:
            server_ctx = f"Instance: {_default_server}. Origin: {client_origin}."
        else:
            server_ctx = _server_ctx
        editor_parts = []
        if editor_context.get("production"):
            editor_parts.append(f"Production={editor_context['production']}")
        if editor_context.get("active"):
            editor_parts.append(f"ActiveComponent={editor_context['active']}")
            if editor_context.get("activeType"):
                editor_parts.append(f"ActiveType={editor_context['activeType']}")
        components = editor_context.get("components", {})
        for ctype, cname in components.items():
            if cname != editor_context.get("active"):
                editor_parts.append(f"Open{ctype.upper()}={cname}")
        editor_ctx = " ".join(editor_parts)
        model_ctx = f" Model={model}." if model else ""
        ctx_line = f"[Context: Namespace={namespace}.{model_ctx} {server_ctx}"
        if editor_ctx:
            ctx_line += f" {editor_ctx}"
        ctx_line += "]"
        prompt = f"{ctx_line}\n\n{prompt}" if prompt else f"{ctx_line}"

    if not prompt:
        emit({"type": "error", "text": "Missing prompt"})
        return json.dumps({"error": "Missing prompt", "event_count": 2})

    # ── Build SDK options based on permission_mode ──────────────
    stderr_lines = []
    def _stderr_cb(line):
        stderr_lines.append(line)

    options = ClaudeAgentOptions(cwd=CWD)
    options.stderr = _stderr_cb
    # Disable tools that cause unnecessary SDK round-trips
    options.disallowed_tools = [
        "TodoWrite", "TaskCreate", "TaskUpdate", "TaskGet", "TaskList",
        "TaskOutput", "TaskStop", "ToolSearch",
        "NotebookEdit", "WebSearch",
        "EnterPlanMode", "ExitPlanMode", "EnterWorktree", "ExitWorktree",
        "ScheduleWakeup", "CronCreate", "CronDelete", "CronList",
    ]

    if permission_mode == "plan":
        options.permission_mode = "plan"
        prompt = "[PLAN MODE: If the request is clear enough, present a numbered plan of what you intend to do. Do NOT explore the codebase or make any changes yet. If the request is ambiguous or missing key details, ask clarifying questions first without presenting a plan. Only output a numbered plan when you know exactly what to build.]\n\n" + prompt
    elif permission_mode == "bypassPermissions":
        options.permission_mode = "bypassPermissions"
    elif permission_mode == "default":
        options.permission_mode = "default"
    elif permission_mode:
        options.permission_mode = permission_mode
    else:
        options.permission_mode = "bypassPermissions"

    if model:
        options.model = model
    if effort and effort in ("low", "medium", "high", "max"):
        options.effort = effort
    if session_id:
        options.resume = session_id

    # ── canUseTool callback (for ask mode) ─────────────────────
    if bridge_id:
        from claude_agent_sdk.types import (
            HookMatcher, PermissionResultAllow, PermissionResultDeny,
        )

        auto_approve_all = False

        # Map InterClaw script names to human-readable labels
        _SCRIPT_LABELS = {
            "manage_production": {"status": "Check production status", "start": "Start production",
                                  "stop": "Stop production", "list": "List productions"},
            "get_doc": "Pull class from server",
            "put_doc": "Push and compile class",
            "get_schema": "Fetch HL7 schema",
            "list_docs": "List classes",
            "send_hl7": "Send HL7 message",
            "send_json": "Send JSON message",
            "test_dtl": "Test data transformation",
            "trace": "Pull message trace",
            "get_errors": "Check event log",
            "run_query": "Run SQL query",
            "manage_namespace": "Manage namespace",
            "manage_lookup": "Manage lookup table",
            "diagram_production": "Generate production diagram",
            "validate_package": "Validate package",
            "test_suite": "Run test suite",
            "route_test": "Run route coverage test",
            "compile": "Compile class",
            "search_code": "Search code",
            "class_inspect": "Inspect class",
            "permissions": "Check permissions",
            "manage_webapp": "Manage web application",
            "reset_package": "Reset package",
            "register_schema": "Register HL7 schema",
        }

        def _bash_label(input_data):
            """Generate a descriptive label for Bash commands."""
            desc = input_data.get("description", "")
            if desc:
                return desc
            cmd = input_data.get("command", "")
            # Match InterClaw script calls
            import re
            m = re.search(r'/scripts/\w+/(\w+)\.py', cmd)
            if m:
                script = m.group(1)
                entry = _SCRIPT_LABELS.get(script)
                if isinstance(entry, dict):
                    # Check for --action flag
                    am = re.search(r'--action\s+(\w+)', cmd)
                    if am and am.group(1) in entry:
                        return entry[am.group(1)]
                    return list(entry.values())[0] if entry else script.replace("_", " ").title()
                elif isinstance(entry, str):
                    return entry
            return ""

        async def can_use_tool(tool_name, input_data, context):
            # Deny AskUserQuestion — forces the model to ask questions as
            # regular text, which fits the conversational chat UI better
            # than the CLI-style blocking prompt.
            if tool_name == "AskUserQuestion":
                return PermissionResultDeny(
                    message="AskUserQuestion is not available in this environment. "
                            "Ask your questions as regular text in your response instead."
                )

            nonlocal auto_approve_all
            if auto_approve_all:
                return PermissionResultAllow(updated_input=input_data)

            # Auto-approve plan metadata (allowedPrompts) — this is SDK
            # internal plan execution, not a user-facing permission request.
            if isinstance(input_data, dict) and "allowedPrompts" in input_data:
                return PermissionResultAllow(updated_input=input_data)

            # CLI decided this tool needs approval - format display based on tool type
            if tool_name == "Bash":
                display_input = _bash_label(input_data) or input_data.get("command", "")[:500]
            elif tool_name == "Edit":
                file_path = input_data.get("file_path", "")
                old_str = input_data.get("old_string", "")[:100]
                display_input = f"{file_path}: {old_str}..." if old_str else file_path
            elif tool_name == "Write":
                file_path = input_data.get("file_path", "")
                display_input = f"Write to {file_path}"
            else:
                display_input = json.dumps(input_data)[:300]

            # Emit permission_request - frontend shows edit accept panel
            perm_evt = {
                "type": "permission_request",
                "tool": tool_name,
                "input": display_input,
                "bridge_id": bridge_id,
            }
            # Include full input for detailed rendering in the chat
            if tool_name == "Edit":
                perm_evt["file_path"] = input_data.get("file_path", "")
                perm_evt["old_string"] = input_data.get("old_string", "")[:2000]
                perm_evt["new_string"] = input_data.get("new_string", "")[:2000]
            elif tool_name == "Write":
                perm_evt["file_path"] = input_data.get("file_path", "")
                perm_evt["content"] = input_data.get("content", "")[:2000]
            elif tool_name == "Bash":
                perm_evt["command"] = input_data.get("command", "")[:2000]
                perm_evt["label"] = _bash_label(input_data)
            emit(perm_evt)

            # Mark pending via ObjectScript helper
            op.SetPending(bridge_id)

            # Poll for response (timeout 5 min)
            start_t = time.time()
            while time.time() - start_t < 300:
                resp_raw = op.GetPendingResponse(bridge_id)
                if resp_raw is not None and resp_raw != "":
                    try:
                        resp = json.loads(str(resp_raw))
                    except Exception:
                        resp = {"choice": "deny"}

                    op.ClearPending(bridge_id)

                    choice = resp.get("choice", "deny")
                    feedback = resp.get("feedback") or resp.get("message", "")

                    if choice in ("allow", "accept"):
                        return PermissionResultAllow(updated_input=input_data)
                    elif choice == "accept-all":
                        auto_approve_all = True
                        return PermissionResultAllow(updated_input=input_data)
                    else:
                        return PermissionResultDeny(
                            message=feedback or "User denied this action"
                        )

                await asyncio.sleep(0.1)

            # Timeout
            op.ClearPending(bridge_id)
            return PermissionResultDeny(message="Permission request timed out")

        options.can_use_tool = can_use_tool

        # Required: PreToolUse hook keeps the stream open for can_use_tool
        async def _pre_tool_hook(input_data, tool_use_id, context):
            return {"continue_": True}

        options.hooks = {
            "PreToolUse": [HookMatcher(matcher=None, hooks=[_pre_tool_hook])]
        }

    # ── Run the SDK query ───────────────────────────────────────
    session_id_result = [None]
    cost = [0]
    input_tokens = [0]
    output_tokens = [0]
    event_count = [1]  # 1 for the "connected" event already emitted

    async def run():
        try:
            # canUseTool requires streaming input mode in Python SDK
            if bridge_id:
                async def prompt_stream():
                    yield {
                        "type": "user",
                        "message": {"role": "user", "content": prompt},
                    }
                q_prompt = prompt_stream()
            else:
                q_prompt = prompt

            async for message in query(prompt=q_prompt, options=options):
                if isinstance(message, AssistantMessage):
                    for block in message.content:
                        if isinstance(block, TextBlock):
                            emit({"type": "output", "text": block.text})
                            event_count[0] += 1
                        elif isinstance(block, ThinkingBlock):
                            emit({"type": "thinking", "text": block.thinking})
                            event_count[0] += 1
                        elif isinstance(block, ToolUseBlock):
                            tool_evt = {"type": "tool_use", "tool": block.name,
                                        "input": json.dumps(block.input)[:2000]}
                            if block.name == "Bash" and isinstance(block.input, dict):
                                lbl = _bash_label(block.input)
                                if lbl:
                                    tool_evt["label"] = lbl
                            emit(tool_evt)
                            event_count[0] += 1
                elif isinstance(message, UserMessage):
                    for block in message.content:
                        if isinstance(block, ToolResultBlock):
                            if isinstance(block.content, list):
                                tr_text = "\n".join(b.text for b in block.content if hasattr(b, "text"))
                            elif isinstance(block.content, str):
                                tr_text = block.content
                            else:
                                tr_text = str(block.content)
                            emit({"type": "tool_result",
                                  "text": tr_text[:8000]})
                            event_count[0] += 1
                            # Auto-detect /goto in tool results and emit as event
                            for line in tr_text.split("\n"):
                                line = line.strip()
                                if line.startswith("/goto "):
                                    parts = line[6:].strip().split()
                                    editor = None
                                    target = parts[0] if parts else None
                                    if len(parts) >= 2 and parts[0].startswith("--"):
                                        editor = parts[0][2:]
                                        target = parts[1]
                                    if target:
                                        emit({"type": "goto", "target": target, "editor": editor})
                                        event_count[0] += 1
                elif isinstance(message, ResultMessage):
                    session_id_result[0] = message.session_id
                    usage_evt = {"type": "usage"}
                    if message.total_cost_usd is not None:
                        usage_evt["cost"] = message.total_cost_usd
                        cost[0] = message.total_cost_usd
                    if message.usage:
                        u = message.usage
                        usage_evt["input_tokens"] = u.get("input_tokens", 0) + u.get("cache_creation_input_tokens", 0) + u.get("cache_read_input_tokens", 0)
                        usage_evt["output_tokens"] = u.get("output_tokens", 0)
                        input_tokens[0] = usage_evt["input_tokens"]
                        output_tokens[0] = usage_evt["output_tokens"]
                    if len(usage_evt) > 1:
                        emit(usage_evt)
                        event_count[0] += 1

        except Exception as e:
            # Suppress exit-code errors if the query already completed
            # (CLI subprocess may exit non-zero during cleanup after a
            # successful conversation; the results are already emitted).
            if session_id_result[0] and "exit code" in str(e).lower():
                pass
            else:
                err_detail = f"SDK error: {type(e).__name__}: {e}"
                if stderr_lines:
                    err_detail += " | stderr: " + " ".join(stderr_lines[-5:])
                emit({"type": "error", "text": err_detail})
                event_count[0] += 1

        emit({"type": "done", "session_id": session_id_result[0] or session_id or ""})
        event_count[0] += 1

    asyncio.run(run())

    return json.dumps({
        "session_id": session_id_result[0] or session_id or "",
        "cost": cost[0],
        "input_tokens": input_tokens[0],
        "output_tokens": output_tokens[0],
        "event_count": event_count[0],
    })
}

}

