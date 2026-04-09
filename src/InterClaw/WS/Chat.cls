Class InterClaw.WS.Chat Extends %CSP.WebSocket
{

Method Server() As %Status [ Language = python ]
{
    import asyncio, json, os, time, iris

    CWD = "/usr/local/InterSystems/interop-agent-orchestrator"
    os.chdir(CWD)
    os.environ["HOME"] = "/home/irisusr"

    # Load API keys from %Wallet (set via /authenticate)
    _loaded = False
    try:
        secret = iris.cls('%Wallet.KeyValue').GetSecretValue("InterClaw.BedrockKey")
        if secret is not None:
            _data = json.loads(str(secret)) if not isinstance(secret, dict) else secret
            os.environ["ANTHROPIC_API_KEY"] = _data.get("key", "")
            os.environ["CLAUDE_CODE_USE_BEDROCK"] = "1"
            os.environ["AWS_REGION"] = _data.get("region", "us-east-1")
            os.environ["AWS_BEARER_TOKEN_BEDROCK"] = _data.get("key", "")
            _loaded = True
    except Exception:
        pass

    from claude_agent_sdk import (
        query, ClaudeAgentOptions, AssistantMessage, ResultMessage,
        UserMessage, TextBlock, ToolUseBlock, ThinkingBlock, ToolResultBlock,
    )

    ws = self  # capture reference for async closure

    def emit(data):
        ws.Write(json.dumps(data))

    emit({"type": "connected"})

    while True:
        msg = ws.Read()
        if msg is None:
            break
        if msg == "":
            continue

        try:
            req = json.loads(msg)
        except Exception:
            emit({"type": "error", "text": "Invalid JSON"})
            continue

        action = req.get("action", "message")
        session_id = req.get("session_id")
        model = req.get("model")
        bridge_id = req.get("bridge_id", "")
        permission_mode = req.get("permission_mode", "")
        effort = req.get("effort", "")

        prompt = req.get("prompt", "")
        namespace = req.get("namespace", "")
        editor_context = req.get("editor_context", {})

        # Prepend namespace/server/editor context so Claude knows what's currently open
        if namespace:
            server_ctx = "Server: vmdev1."
            try:
                import json as _json
                with open(os.path.join(CWD, "config", "servers.json")) as _sf:
                    _servers = _json.load(_sf).get("intersystems.servers", {})
                    _srv = _servers.get("vmdev1", {}).get("webServer", {})
                    _base = f"{_srv.get('scheme','http')}://{_srv.get('host','vmdev1.iscinternal.com')}:{_srv.get('port',80)}{_srv.get('pathPrefix','')}"
                    server_ctx = f"Server: vmdev1. Base URL: {_base}."
            except:
                pass
            # Build editor context string from structured data
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
            ctx_line = f"[Context: Namespace={namespace}. {server_ctx}"
            if editor_ctx:
                ctx_line += f" {editor_ctx}"
            ctx_line += "]"
            prompt = f"{ctx_line}\n\n{prompt}" if prompt else f"{ctx_line}"

        if not prompt:
            emit({"type": "error", "text": "Missing prompt"})
            continue

        # ── Build SDK options based on permission_mode ──────────────
        ALL_TOOLS = [
            "Bash", "Read", "Edit", "Write", "Glob", "Grep",
            "Agent", "WebFetch", "WebSearch", "Skill",
        ]
        # Pre-approved tools (everything except Bash — shell commands need approval)
        SAFE_TOOLS = [t for t in ALL_TOOLS if t != "Bash"]
        # Tools that trigger the canUseTool approval prompt
        APPROVAL_TOOLS = {"Bash"}

        needs_approval = permission_mode == "default"

        options = ClaudeAgentOptions(cwd=CWD)

        if permission_mode == "plan":
            # Plan mode: bypass permissions during exploration (prompt injection
            # tells Claude to plan, not edit). After the plan is presented, the
            # frontend shows approval — user picks bypass or ask for execution.
            options.permission_mode = "bypassPermissions"
            options.allowed_tools = ALL_TOOLS
            prompt = "[PLAN MODE: Explore the codebase first, then present a clear plan. Do NOT make changes until I approve.]\n\n" + prompt
        elif permission_mode == "bypassPermissions":
            options.permission_mode = "bypassPermissions"
            options.allowed_tools = ALL_TOOLS
        elif permission_mode == "default":
            # "Ask" mode — pre-approve file tools, prompt only for Bash
            options.permission_mode = "default"
            options.allowed_tools = SAFE_TOOLS
        else:
            # No mode specified — default to bypass (all tools, no prompts)
            options.permission_mode = "bypassPermissions"
            options.allowed_tools = ALL_TOOLS

        if model:
            options.model = model
        if effort and effort in ("low", "medium", "high", "max"):
            options.effort = effort
        if session_id:
            options.resume = session_id

        # ── canUseTool callback (for ask/plan modes) ─────────────
        # Only prompts for Bash (shell commands). File edits are auto-approved.
        # Emits a permission_request event via WS, then polls
        # ^InterClaw.ChatPending(bridgeId) for the user's response.
        if needs_approval and bridge_id:
            from claude_agent_sdk.types import (
                HookMatcher, PermissionResultAllow, PermissionResultDeny,
            )

            g_pending = iris.gref("^InterClaw.ChatPending")
            auto_approve_all = False

            async def can_use_tool(tool_name, input_data, context):
                nonlocal auto_approve_all
                if auto_approve_all:
                    return PermissionResultAllow(updated_input=input_data)

                # Only prompt for shell commands — everything else is auto-allowed
                if tool_name not in APPROVAL_TOOLS:
                    return PermissionResultAllow(updated_input=input_data)

                # Show the command that needs approval
                display_input = input_data.get("command", json.dumps(input_data)[:300])

                # Emit permission_request — always uses edit accept panel
                emit({
                    "type": "permission_request",
                    "tool": tool_name,
                    "input": display_input,
                    "bridge_id": bridge_id,
                })

                # Mark pending
                g_pending[bridge_id, "pending"] = "1"

                # Poll for response (timeout 5 min)
                start_t = time.time()
                while time.time() - start_t < 300:
                    resp_raw = g_pending[bridge_id, "response"]
                    if resp_raw is not None:
                        try:
                            resp = json.loads(str(resp_raw))
                        except Exception:
                            resp = {"choice": "deny"}

                        # Clean up pending state
                        try:
                            g_pending.kill([bridge_id])
                        except Exception:
                            pass

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
                try:
                    g_pending.kill([bridge_id])
                except Exception:
                    pass
                return PermissionResultDeny(message="Permission request timed out")

            options.can_use_tool = can_use_tool

            # Required: PreToolUse hook keeps the stream open for can_use_tool
            async def _pre_tool_hook(input_data, tool_use_id, context):
                return {"continue_": True}

            options.hooks = {
                "PreToolUse": [HookMatcher(matcher=None, hooks=[_pre_tool_hook])]
            }

        # ── Run the SDK query ───────────────────────────────────────
        async def run():
            claude_session_id = None
            try:
                # canUseTool requires streaming input mode in Python SDK
                if needs_approval and bridge_id:
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
                            elif isinstance(block, ThinkingBlock):
                                emit({"type": "thinking", "text": block.thinking})
                            elif isinstance(block, ToolUseBlock):
                                emit({"type": "tool_use", "tool": block.name,
                                      "input": json.dumps(block.input)[:2000]})
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
                    elif isinstance(message, ResultMessage):
                        claude_session_id = message.session_id
                        usage_evt = {"type": "usage"}
                        if message.total_cost_usd is not None:
                            usage_evt["cost"] = message.total_cost_usd
                        if message.usage:
                            u = message.usage
                            usage_evt["input_tokens"] = u.get("input_tokens", 0) + u.get("cache_creation_input_tokens", 0) + u.get("cache_read_input_tokens", 0)
                            usage_evt["output_tokens"] = u.get("output_tokens", 0)
                        if len(usage_evt) > 1:
                            emit(usage_evt)

            except Exception as e:
                err = str(e).lower()
                if "exit code: 255" not in err and "exit code 255" not in err:
                    emit({"type": "error", "text": str(e)})

            emit({"type": "done", "session_id": claude_session_id or session_id or ""})

        loop = asyncio.new_event_loop()
        try:
            loop.run_until_complete(run())
        finally:
            loop.close()

    return iris.cls("%SYSTEM.Status").OK()
}

}
