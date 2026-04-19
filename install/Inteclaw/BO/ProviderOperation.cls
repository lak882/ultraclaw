/// Model provider operation.
/// Dispatches to Bedrock (default) or Anthropic-direct based on ProviderCall.Provider.
/// Adding a new provider = add a new branch in CallProvider. The agent loop is
/// provider-agnostic and consumes the normalized ProviderResult shape.
Class Inteclaw.BO.ProviderOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property DefaultProvider As %String [ InitialExpression = "bedrock" ];

Property DefaultModel As %String [ InitialExpression = "us.anthropic.claude-opus-4-7" ];

Property EventWriterTarget As Ens.DataType.ConfigName [ InitialExpression = "Inteclaw.BP.EventWriter" ];

Parameter SETTINGS = "DefaultProvider:Basic,DefaultModel:Basic,EventWriterTarget:Basic";

/// Resolve the Bedrock API key JSON stored in Ens.Config.Credentials("Inteclaw.Bedrock").
Method GetCredentialSecret() As %String
{
    Set secret = ""
    Try {
        If ##class(Ens.Config.Credentials).%ExistsId("Inteclaw.Bedrock") {
            Set cred = ##class(Ens.Config.Credentials).%OpenId("Inteclaw.Bedrock")
            If cred '= "" Set secret = cred.Password
        }
    } Catch ex {}
    Return secret
}

/// Push an event onto the bridge's event stream.
ClassMethod WriteStreamEvent(bridgeId As %String, payloadJSON As %String)
{
    If bridgeId = "" Quit
    Set seq = $Increment(^Inteclaw.ChatEvents(bridgeId, "seq"))
    Set ^Inteclaw.ChatEvents(bridgeId, "evt", seq) = payloadJSON
}

/// Stream from AWS Bedrock /invoke-with-response-stream, parse the AWS
/// event-stream framing + Anthropic SSE event payloads, and emit `delta` /
/// `thinking_delta` / `tool_use` events to the bridge as they arrive.
/// Returns the final normalized JSON (same shape as CallProvider's result)
/// for the BP to persist into the session transcript.
ClassMethod StreamBedrock(region As %String, bearerKey As %String, model As %String, payloadJSON As %String, bridgeId As %String) As %String [ Language = python ]
{
    import json, struct, base64, ssl
    import http.client
    try:
        import iris
    except Exception:
        iris = None

    host = f"bedrock-runtime.{region}.amazonaws.com"
    path = f"/model/{model}/invoke-with-response-stream"
    body = payloadJSON.encode("utf-8") if isinstance(payloadJSON, str) else payloadJSON
    headers = {
        "Authorization": f"Bearer {bearerKey}",
        "Content-Type": "application/json",
        "Accept": "application/vnd.amazon.eventstream",
    }

    def emit(payload_dict):
        if not bridgeId or iris is None:
            return
        try:
            iris.cls("Inteclaw.BO.ProviderOperation").WriteStreamEvent(bridgeId, json.dumps(payload_dict))
        except Exception:
            pass

    content_blocks = []   # list of dicts keyed by content_block index
    stop_reason = ""
    usage_agg = {}

    conn = http.client.HTTPSConnection(host, timeout=300, context=ssl.create_default_context())
    try:
        conn.request("POST", path, body=body, headers=headers)
        resp = conn.getresponse()
        if resp.status != 200:
            err_body = resp.read(4000).decode("utf-8", errors="replace")
            return json.dumps({"error": f"HTTP {resp.status}: {err_body}"})

        buf = b""
        while True:
            chunk = resp.read(8192)
            if not chunk:
                break
            buf += chunk
            # Parse AWS event-stream frames greedily from buf.
            while len(buf) >= 12:
                total_len = struct.unpack(">I", buf[0:4])[0]
                if total_len < 16 or total_len > 16 * 1024 * 1024:
                    buf = b""
                    break
                if len(buf) < total_len:
                    break
                headers_len = struct.unpack(">I", buf[4:8])[0]
                msg_payload = buf[12 + headers_len : total_len - 4]
                buf = buf[total_len:]

                try:
                    envelope = json.loads(msg_payload.decode("utf-8", errors="replace"))
                except Exception:
                    continue
                b64 = envelope.get("bytes")
                if not b64:
                    continue
                try:
                    inner = json.loads(base64.b64decode(b64).decode("utf-8", errors="replace"))
                except Exception:
                    continue

                evt_type = inner.get("type", "")
                if evt_type == "message_start":
                    u = (inner.get("message") or {}).get("usage", {}) or {}
                    usage_agg.update(u)
                elif evt_type == "content_block_start":
                    idx = inner.get("index", 0)
                    block = dict(inner.get("content_block", {}))
                    btype = block.get("type")
                    if btype == "text":
                        block["text"] = ""
                    elif btype == "thinking":
                        block["thinking"] = ""
                    elif btype == "tool_use":
                        block["input"] = {}
                        block["_input_json"] = ""
                        # A tool call is starting — any text block that was
                        # streamed so far this turn is preamble narrative.
                        # Tell the UI to move the accumulated text from the
                        # main bubble into a thinking-step card.
                        preamble_text = ""
                        for b in content_blocks:
                            if b is not None and b.get("type") == "text":
                                preamble_text += b.get("text", "")
                        if preamble_text:
                            emit({"type": "reclassify_as_thinking", "text": preamble_text})
                    while len(content_blocks) <= idx:
                        content_blocks.append(None)
                    content_blocks[idx] = block
                elif evt_type == "content_block_delta":
                    delta = inner.get("delta", {}) or {}
                    dtype = delta.get("type", "")
                    idx = inner.get("index", 0)
                    if idx < len(content_blocks) and content_blocks[idx] is not None:
                        block = content_blocks[idx]
                        btype = block.get("type")
                        if dtype == "text_delta":
                            t = delta.get("text", "")
                            block["text"] = block.get("text", "") + t
                            # Route partial text to `thinking` for pre-tool
                            # narrative; we don't know yet whether this turn
                            # has tool_use, so always emit as `delta` and let
                            # the BP's post-scan re-classify at message end.
                            emit({"type": "delta", "text": t})
                        elif dtype == "thinking_delta":
                            t = delta.get("thinking", "")
                            block["thinking"] = block.get("thinking", "") + t
                            emit({"type": "thinking", "text": t})
                        elif dtype == "input_json_delta":
                            t = delta.get("partial_json", "")
                            block["_input_json"] = block.get("_input_json", "") + t
                elif evt_type == "content_block_stop":
                    idx = inner.get("index", 0)
                    if idx < len(content_blocks) and content_blocks[idx] is not None:
                        block = content_blocks[idx]
                        if block.get("type") == "tool_use":
                            try:
                                block["input"] = json.loads(block.get("_input_json") or "{}")
                            except Exception:
                                block["input"] = {}
                            block.pop("_input_json", None)
                            # Emit tool_use with the completed input so the UI
                            # can render the reasoning step with the real args.
                            emit({"type": "tool_use", "tool": block.get("name",""), "input": json.dumps(block.get("input", {})), "id": block.get("id","")})
                elif evt_type == "message_delta":
                    delta = inner.get("delta", {}) or {}
                    if "stop_reason" in delta:
                        stop_reason = delta["stop_reason"] or ""
                    u = inner.get("usage", {}) or {}
                    for k in ("output_tokens", "input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens"):
                        if k in u:
                            usage_agg[k] = u[k]
    finally:
        conn.close()

    final_blocks = [b for b in content_blocks if b is not None]
    for b in final_blocks:
        b.pop("_input_json", None)
    return json.dumps({
        "content_json": json.dumps(final_blocks),
        "stop_reason": stop_reason,
        "input_tokens": usage_agg.get("input_tokens", 0),
        "cache_read_tokens": usage_agg.get("cache_read_input_tokens", 0),
        "cache_write_tokens": usage_agg.get("cache_creation_input_tokens", 0),
        "output_tokens": usage_agg.get("output_tokens", 0),
    })
}

Method OnMessage(pRequest As Inteclaw.Msg.ProviderCall, Output pResponse As Inteclaw.Msg.ProviderResult) As %Status
{
    Set pResponse = ##class(Inteclaw.Msg.ProviderResult).%New()
    Set pResponse.BridgeId = pRequest.BridgeId

    Set provider = pRequest.Provider
    If provider = "" Set provider = ..DefaultProvider
    Set model = pRequest.Model
    If model = "" Set model = ..DefaultModel

    Set secret = ..GetCredentialSecret()
    If secret = "" {
        Set pResponse.ErrorText = "No Inteclaw.Bedrock credential configured"
        Return $$$OK
    }

    // Bedrock with a bridge id => use the streaming path that emits delta
    // events to the UI in near-real-time. Other providers / no-bridge calls
    // fall through to the non-streaming CallProvider.
    Set useStreaming = ((provider = "bedrock") || (provider = "anthropic-bedrock")) && (pRequest.BridgeId '= "")
    If useStreaming {
        Set resultJSON = ..StreamProvider(model, secret,
            pRequest.SystemPrompt, pRequest.MessagesJSON,
            pRequest.ToolsJSON, pRequest.MaxTokens, pRequest.Effort,
            pRequest.BridgeId)
    } Else {
        Set resultJSON = ..CallProvider(provider, model, secret,
            pRequest.SystemPrompt, pRequest.MessagesJSON,
            pRequest.ToolsJSON, pRequest.MaxTokens, pRequest.Effort,
            pRequest.BridgeId)
    }

    Try {
        Set result = ##class(%DynamicObject).%FromJSON(resultJSON)
        If result.%Get("error") '= "" {
            Set pResponse.ErrorText = result.%Get("error")
        } Else {
            Set pResponse.StopReason = result.%Get("stop_reason")
            Set pResponse.ContentJSON = result.%Get("content_json")
            Set pResponse.InputTokens = +result.%Get("input_tokens")
            Set pResponse.OutputTokens = +result.%Get("output_tokens")
            Set pResponse.CacheReadTokens = +result.%Get("cache_read_tokens")
            Set pResponse.CacheWriteTokens = +result.%Get("cache_write_tokens")
        }
    } Catch ex {
        Set pResponse.ErrorText = "Parse error: " _ ex.DisplayString()
    }

    Return $$$OK
}

/// Streaming wrapper — builds the Bedrock payload (with cache_control +
/// adaptive thinking for Opus/Sonnet) and hands off to StreamBedrock.
ClassMethod StreamProvider(model As %String, secret As %String, systemPrompt As %String, messagesJSON As %String, toolsJSON As %String, maxTokens As %Integer, effort As %String = "medium", bridgeId As %String = "") As %String [ Language = python ]
{
    import json
    try:
        cred = json.loads(str(secret)) if secret else {}
    except Exception:
        cred = {}
    region = cred.get("region", "us-east-1")
    key = cred.get("key", "")
    if not key:
        return json.dumps({"error": "Bedrock credential missing key"})

    model = str(model)
    system_prompt = str(systemPrompt) if systemPrompt else ""
    messages = json.loads(str(messagesJSON)) if messagesJSON else []
    tools = json.loads(str(toolsJSON)) if toolsJSON else []
    max_tokens = int(maxTokens) if maxTokens else 4096
    effort_level = str(effort).lower() if effort else "medium"
    if effort_level not in ("low", "medium", "high", "max"):
        effort_level = "medium"

    # Apply cache_control the same way CallProvider does.
    sys_blocks = None
    if system_prompt:
        sys_blocks = [{"type": "text", "text": system_prompt, "cache_control": {"type": "ephemeral"}}]
    msgs_cached = json.loads(json.dumps(messages))
    for i in range(len(msgs_cached) - 1, -1, -1):
        m = msgs_cached[i]
        if m.get("role") == "user":
            content = m.get("content")
            if isinstance(content, list) and content:
                last_block = content[-1]
                if isinstance(last_block, dict):
                    last_block["cache_control"] = {"type": "ephemeral"}
            break

    payload = {
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": max_tokens,
        "messages": msgs_cached,
    }
    if "opus" in model.lower() or "sonnet" in model.lower():
        payload["thinking"] = {"type": "adaptive"}
        payload["output_config"] = {"effort": effort_level}
    if sys_blocks:
        payload["system"] = sys_blocks
    if tools:
        payload["tools"] = tools

    try:
        import iris
        return iris.cls("Inteclaw.BO.ProviderOperation").StreamBedrock(region, key, model, json.dumps(payload), str(bridgeId))
    except Exception as e:
        return json.dumps({"error": f"StreamBedrock error: {type(e).__name__}: {e}"})
}

/// Provider-agnostic Python dispatcher.
/// Returns a JSON string {content_json, stop_reason, input_tokens, output_tokens} or {error}.
Method CallProvider(provider As %String, model As %String, secret As %String, systemPrompt As %String, messagesJSON As %String, toolsJSON As %String, maxTokens As %Integer, effort As %String = "medium", bridgeId As %String = "") As %String [ Language = python ]
{
    import json, urllib.request, urllib.error
    effort_level = str(effort).lower() if effort else "medium"
    if effort_level not in ("low", "medium", "high", "max"):
        effort_level = "medium"
    bridge = str(bridgeId) if bridgeId else ""

    try:
        cred = json.loads(str(secret)) if secret else {}
    except Exception:
        cred = {}

    prov = str(provider).lower()
    model = str(model)
    system_prompt = str(systemPrompt) if systemPrompt else ""
    messages = json.loads(str(messagesJSON)) if messagesJSON else []
    tools = json.loads(str(toolsJSON)) if toolsJSON else []
    max_tokens = int(maxTokens) if maxTokens else 4096

    def _normalize(resp):
        # Normalize an Anthropic Messages-API response into our ProviderResult shape.
        # Keep the three usage buckets separate so downstream can price them at
        # their real Anthropic rates (input 1.00, cacheRead 0.10, cacheWrite 1.25).
        content = resp.get("content", [])
        usage = resp.get("usage", {})
        return {
            "content_json": json.dumps(content),
            "stop_reason": resp.get("stop_reason", ""),
            "input_tokens": usage.get("input_tokens", 0),
            "cache_read_tokens": usage.get("cache_read_input_tokens", 0),
            "cache_write_tokens": usage.get("cache_creation_input_tokens", 0),
            "output_tokens": usage.get("output_tokens", 0),
        }

    def _apply_cache_control(system_text, msgs):
        # Attach `cache_control: {type: "ephemeral"}` to the system prompt and
        # to the final content block of the last user message. Anthropic caches
        # content up to each breakpoint with a 5-minute TTL by default.
        # We MUST return structured system blocks when caching, not a raw string.
        sys_blocks = None
        if system_text:
            sys_blocks = [{"type": "text", "text": system_text, "cache_control": {"type": "ephemeral"}}]
        # Deep-copy messages and tag the final block of the last user message.
        msgs_copy = json.loads(json.dumps(msgs))
        for i in range(len(msgs_copy) - 1, -1, -1):
            m = msgs_copy[i]
            if m.get("role") == "user":
                content = m.get("content")
                if isinstance(content, list) and content:
                    last_block = content[-1]
                    if isinstance(last_block, dict):
                        last_block["cache_control"] = {"type": "ephemeral"}
                break
        return sys_blocks, msgs_copy

    def _post(url, headers, payload):
        body = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(url, data=body, headers=headers, method="POST")
        with urllib.request.urlopen(req, timeout=120) as r:
            return json.loads(r.read().decode("utf-8"))

    def _emit(event_type, **kw):
        if not bridge:
            return
        try:
            import iris as _iris
            payload = {"type": event_type}
            payload.update(kw)
            _iris.cls("Inteclaw.BO.ProviderOperation").WriteStreamEvent(bridge, json.dumps(payload))
        except Exception:
            pass

    def _stream_post(url, headers, payload):
        import struct, base64
        _emit("debug", text=f"entered _stream_post model in payload={payload.get('model','<no-model-key>')}")
        body = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(url, data=body, headers=headers, method="POST")
        content = {"blocks": [], "stop_reason": "", "usage": {}}
        current_block = None
        _emit("debug", text=f"stream_post started url={url[-80:]}")
        total_frames = 0
        with urllib.request.urlopen(req, timeout=300) as r:
            buf = b""
            first_bytes = b""
            while True:
                chunk = r.read(8192)
                if not chunk:
                    break
                if not first_bytes:
                    first_bytes = chunk[:64]
                    _emit("debug", text=f"first bytes hex={first_bytes.hex()[:120]}")
                buf += chunk
                while len(buf) >= 12:
                    total_len = struct.unpack(">I", buf[0:4])[0]
                    if total_len < 16 or total_len > 16 * 1024 * 1024:
                        _emit("debug", text=f"bailed on total_len={total_len}")
                        buf = b""
                        break
                    if len(buf) < total_len:
                        break
                    headers_len = struct.unpack(">I", buf[4:8])[0]
                    msg_payload = buf[12 + headers_len : total_len - 4]
                    buf = buf[total_len:]
                    total_frames += 1
                    try:
                        envelope = json.loads(msg_payload.decode("utf-8", errors="replace"))
                    except Exception:
                        continue
                    b64 = envelope.get("bytes")
                    if not b64:
                        continue
                    try:
                        inner = json.loads(base64.b64decode(b64).decode("utf-8", errors="replace"))
                    except Exception:
                        continue
                    evt_type = inner.get("type", "")
                    if total_frames <= 3:
                        _emit("debug", text=f"frame{total_frames} type={evt_type}")
                    if evt_type == "message_start":
                        msg = inner.get("message", {})
                        u = msg.get("usage", {}) or {}
                        content["usage"].update(u)
                    elif evt_type == "content_block_start":
                        idx = inner.get("index", 0)
                        block = dict(inner.get("content_block", {}))
                        if block.get("type") == "text":
                            block["text"] = ""
                        elif block.get("type") == "thinking":
                            block["thinking"] = ""
                        elif block.get("type") == "tool_use":
                            block["input"] = {}
                            block["_input_json"] = ""
                        current_block = (idx, block)
                        while len(content["blocks"]) <= idx:
                            content["blocks"].append(None)
                        content["blocks"][idx] = block
                    elif evt_type == "content_block_delta":
                        delta = inner.get("delta", {}) or {}
                        dtype = delta.get("type", "")
                        idx = inner.get("index", 0)
                        if idx < len(content["blocks"]) and content["blocks"][idx] is not None:
                            block = content["blocks"][idx]
                            if dtype == "text_delta":
                                t = delta.get("text", "")
                                block["text"] = block.get("text", "") + t
                                _emit("delta", text=t)
                            elif dtype == "thinking_delta":
                                t = delta.get("thinking", "")
                                block["thinking"] = block.get("thinking", "") + t
                                _emit("thinking_delta", text=t)
                            elif dtype == "input_json_delta":
                                t = delta.get("partial_json", "")
                                block["_input_json"] = block.get("_input_json", "") + t
                    elif evt_type == "content_block_stop":
                        idx = inner.get("index", 0)
                        if idx < len(content["blocks"]) and content["blocks"][idx] is not None:
                            block = content["blocks"][idx]
                            if block.get("type") == "tool_use":
                                try:
                                    block["input"] = json.loads(block.get("_input_json") or "{}")
                                except Exception:
                                    block["input"] = {}
                                block.pop("_input_json", None)
                    elif evt_type == "message_delta":
                        delta = inner.get("delta", {}) or {}
                        if "stop_reason" in delta:
                            content["stop_reason"] = delta["stop_reason"] or ""
                        u = inner.get("usage", {}) or {}
                        for k in ("output_tokens", "input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens"):
                            if k in u:
                                content["usage"][k] = u[k]
                    elif evt_type == "message_stop":
                        pass
        # Strip any internal bookkeeping keys and drop None entries
        final_blocks = [b for b in content["blocks"] if b is not None]
        for b in final_blocks:
            b.pop("_input_json", None)
        return {
            "content": final_blocks,
            "stop_reason": content["stop_reason"],
            "usage": content["usage"],
        }

    try:
        if prov in ("bedrock", "anthropic-bedrock"):
            # Bedrock: use the Anthropic-compatible Messages API on AWS Bedrock.
            # The stored "key" is an AWS Bedrock bearer token (ABSK...); pass as
            # Authorization: Bearer <token>.
            region = cred.get("region", "us-east-1")
            key = cred.get("key", "")
            if not key:
                return json.dumps({"error": "Bedrock credential missing key"})
            # Non-streaming endpoint. We attempted streaming via
            # invoke-with-response-stream but the Python-side iris.cls(...)
            # callback pattern didn't fire inside the Ensemble BO job — left
            # as a follow-up (would need an ObjectScript-side SSE parser via
            # %Net.HttpRequest instead).
            url = f"https://bedrock-runtime.{region}.amazonaws.com/model/{model}/invoke"
            headers = {
                "Authorization": f"Bearer {key}",
                "Content-Type": "application/json",
                "Accept": "application/json",
            }
            sys_blocks, msgs_cached = _apply_cache_control(system_prompt, messages)
            payload = {
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": max_tokens,
                "messages": msgs_cached,
            }
            # Extended thinking: adaptive mode lets the model choose its own
            # budget per turn (Opus 4.7 / Sonnet 4.6 only accept adaptive, not
            # the older enabled+budget_tokens form).
            if "opus" in model.lower() or "sonnet" in model.lower():
                payload["thinking"] = {"type": "adaptive"}
                payload["output_config"] = {"effort": effort_level}
            if sys_blocks:
                payload["system"] = sys_blocks
            if tools:
                payload["tools"] = tools
            resp = _post(url, headers, payload)
            return json.dumps(_normalize(resp))

        elif prov == "anthropic":
            key = cred.get("key", "")
            if not key:
                return json.dumps({"error": "Anthropic credential missing key"})
            url = "https://api.anthropic.com/v1/messages"
            headers = {
                "x-api-key": key,
                "anthropic-version": "2023-06-01",
                "Content-Type": "application/json",
            }
            sys_blocks, msgs_cached = _apply_cache_control(system_prompt, messages)
            payload = {
                "model": model,
                "max_tokens": max_tokens,
                "messages": msgs_cached,
            }
            if sys_blocks:
                payload["system"] = sys_blocks
            if tools:
                payload["tools"] = tools
            resp = _post(url, headers, payload)
            return json.dumps(_normalize(resp))

        else:
            return json.dumps({"error": f"Unknown provider: {prov}"})

    except urllib.error.HTTPError as e:
        try:
            detail = e.read().decode("utf-8")
        except Exception:
            detail = ""
        _emit("debug", text=f"HTTPError {e.code}: {detail[:500]}")
        return json.dumps({"error": f"HTTP {e.code}: {detail[:2000]}"})
    except Exception as e:
        import traceback
        _emit("debug", text=f"Exception {type(e).__name__}: {e}\n{traceback.format_exc()[:800]}")
        return json.dumps({"error": f"{type(e).__name__}: {e}"})
}

}
