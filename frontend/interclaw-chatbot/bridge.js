// interclaw-chatbot/bridge.js — bridgeSend, wsSend, initSession, sendCommandToBackend
(function(cc) {

  cc.bridgeSend = async function(payload, opts) {
    opts = opts || {};

    // Hard-guard against concurrent sends. Without this, two overlapping
    // prompts share `cc.currentStreamEl` and `cc.queryStartTime` — the
    // second poll writes the same answer into the bubble the first poll
    // already rendered (doubled output), and `done` from turn N clears the
    // timer before turn N+1's usage event arrives (the "?s" cost label).
    // Queue the second prompt to fire after the first completes.
    if (cc.bridgePolling) {
      console.log('[bridge] busy — queuing prompt');
      cc.messageQueue.push(payload);
      return false;
    }

    try {
      // Let the server bind this bridge to the chat id. Pre-existing chats
      // adopt cc.sessionId as their id; brand-new chats have no id until the
      // `session` event comes back and openChat/startNewChat wires it up.
      if (cc.sessionId && !payload.chat_id) payload.chat_id = cc.sessionId;
      if (!payload.request_id) payload.request_id = 'REQ-' + Date.now().toString(36).toUpperCase() + '-' + Math.random().toString(36).slice(2, 8).toUpperCase();
      var startResp = await fetch(cc.chatApiBase + '/api/start', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      if (!startResp.ok) {
        var errText = '';
        try { var errJson = await startResp.json(); errText = errJson.error || ''; } catch(_) {}
        throw new Error(errText || ('Bridge start failed: HTTP ' + startResp.status));
      }
      var startData = await startResp.json();
      cc.currentBridgeId = startData.bridge_id;
      cc.currentRequestId = startData.request_id || null;
      console.log('[bridge] started:', cc.currentBridgeId, 'req:', cc.currentRequestId);
      // Push the chat id into the URL the moment the bridge starts.
      // Works on every tab (chat → path form, portal/traces/skills →
      // `?chat=<id>` query param), so the first message immediately
      // makes the URL shareable.
      if (cc.sessionId && cc.writeChatUrl) cc.writeChatUrl(cc.sessionId);
      // Optimistic: flip the active chat's status to running locally so
      // the sidebar dot lights up instantly, before the refreshChatsList
      // fetch returns. The server already wrote status:'running' inside
      // /api/start so the next refresh will confirm.
      if (cc.sessionId && cc.chatsStore && cc.chatsStore.chats) {
        for (var ci = 0; ci < cc.chatsStore.chats.length; ci++) {
          if (cc.chatsStore.chats[ci].id === cc.sessionId) {
            cc.chatsStore.chats[ci].status = 'running';
            break;
          }
        }
        if (cc.renderChatsSidebar) cc.renderChatsSidebar();
      }
      if (cc.refreshChatsList) cc.refreshChatsList();

      // Seed `after` from the last-seen seq for this session. Without
      // this, each new turn polls from seq=0 and receives every prior
      // turn's events — which the event handlers re-render, producing
      // the "old response reappears on new chat" bug.
      if (!cc._lastSeqBySession) cc._lastSeqBySession = {};
      cc.bridgePolling = true;
      cc.bridgeAbort = new AbortController();
      var _seenToolIds = {};
      var _seenToolDone = {};
      var pollRetries = 0;
      var maxPollRetries = 5;

      while (cc.bridgePolling) {
        try {
          var qs = 'chat_id=' + encodeURIComponent(payload.chat_id) + '&request_id=' + encodeURIComponent(payload.request_id);

          // Poll tools first so steps appear before the final answer.
          var toolsResp = await fetch(cc.chatApiBase + '/api/tools?' + qs, { signal: cc.bridgeAbort.signal });
          if (toolsResp.ok) {
            var toolsData = await toolsResp.json();
            var tools = toolsData.tools || [];
            for (var ti = 0; ti < tools.length; ti++) {
              var t = tools[ti];
              var tid = t.tool_use_id || String(t.id);
              if (!_seenToolIds[tid]) {
                // New tool call — add a running step.
                _seenToolIds[tid] = true;
                var toolLabel = cc.getToolLabel ? cc.getToolLabel(t.name, typeof t.input === 'string' ? t.input : JSON.stringify(t.input)) : t.name;
                var inputStr = typeof t.input === 'string' ? t.input : JSON.stringify(t.input || {}, null, 2);
                var toolContent = inputStr;
                try {
                  var _p = JSON.parse(inputStr);
                  if (_p.code) toolContent = _p.code;
                  else if (_p.sql) toolContent = _p.sql;
                  else if (_p.source) toolContent = _p.source.substring(0, 2000);
                  else if (_p.dtl) toolContent = _p.dtl;
                  else if (_p.plan) toolContent = _p.plan;
                } catch(e) {}
                cc.handleEvent({ type: 'tool_use', tool: t.name, label: toolLabel, input: toolContent });
              }
              if (t.done && !_seenToolDone[tid]) {
                // Tool completed — update the step with result.
                _seenToolDone[tid] = true;
                var outStr = typeof t.output === 'string' ? t.output : JSON.stringify(t.output || '');
                cc.handleEvent({ type: 'tool_result', text: outStr, is_error: t.is_error });
              }
            }
          }

          // Poll status to check if the turn is complete.
          var statusResp = await fetch(cc.chatApiBase + '/api/status?' + qs, { signal: cc.bridgeAbort.signal });
          if (!statusResp.ok) {
            if (statusResp.status >= 500 && pollRetries < maxPollRetries) {
              pollRetries++;
              await new Promise(function(r) { setTimeout(r, 1000 * pollRetries); });
              continue;
            }
            throw new Error('Poll failed: HTTP ' + statusResp.status);
          }
          pollRetries = 0;
          var statusData = await statusResp.json();

          if (!statusData.done) {
            if (cc.resetResponseTimeout) cc.resetResponseTimeout();
            await new Promise(function(r) { setTimeout(r, 2000); });
            continue;
          }

          // Turn complete — fire output, usage, done events.
          if (statusData.error) {
            cc.handleEvent({ type: 'error', text: statusData.error });
          } else if (statusData.response_text) {
            cc.handleEvent({ type: 'output', text: statusData.response_text });
          }
          cc.handleEvent({
            type: 'usage',
            input_tokens: statusData.input_tokens || 0,
            output_tokens: statusData.output_tokens || 0,
            cache_read_tokens: statusData.cache_read_tokens || 0,
            cache_write_tokens: statusData.cache_write_tokens || 0,
            cost: statusData.cost || 0,
            elapsed_ms: statusData.duration_ms || 0
          });
          cc.handleEvent({ type: 'done', chat_id: payload.chat_id });

          cc.bridgePolling = false;
          break;
        } catch (e) {
          if (e.name === 'AbortError') break;
          throw e;
        }
      }
    } catch (e) {
      if (e.name === 'AbortError') return false;
      console.error('[bridge] error:', e);
      if (cc.currentStreamWrap && cc.currentStreamWrap.parentNode) {
        cc.currentStreamWrap.parentNode.removeChild(cc.currentStreamWrap);
      }
      cc.currentStreamEl = null;
      cc.currentStreamWrap = null;
      cc.currentStreamText = '';
      cc.currentThinkingEl = null;
      cc.currentThinkingText = '';
      cc.isStreamingThinking = false;
      cc.removeTypingIndicator();
      cc.hideStopButton();
      var errMsg = e.message || 'Unknown error';
      if (errMsg.indexOf('HTTP 5') !== -1) errMsg = 'The production is not available. Check that InterClaw.Pipeline.Production is running.';
      cc.addMessage('error', errMsg);
      return false;
    } finally {
      cc.bridgePolling = false;
      cc.bridgeAbort = null;
      cc.currentBridgeId = null;
      cc.currentRequestId = null;
      if (cc.refreshChatsList) cc.refreshChatsList();
    }
    return true;
  };


  cc.wsSend = function(payload) {
    cc.bridgeSend(payload);
    return true;
  };

  cc.sendCommandToBackend = function(command) {
    cc.suppressAssistant = false;
    cc.updateStatus('Thinking...');
    cc.startTimer();
    cc.startResponseTimeout();
    cc.showStopButton();
    cc.showTypingIndicator();

    var editorCtx = cc.getEditorContext();
    var pageCtx = cc.buildPageContext ? cc.buildPageContext(editorCtx) : '';
    var linkBase = (function() {
      var m = window.location.pathname.match(/^(\/[^/]+)\/ui\/interop\/(?:interclaw|cc)\//);
      var pathPrefix = m ? m[1] : '';
      return window.location.origin + pathPrefix + '/ui/interop/interclaw/legacy-ui/index.html';
    })();
    cc.wsSend({ action: 'message', prompt: command, chat_id: cc.sessionId, model: cc.getSelectedModel(), namespace: editorCtx.namespace, effort: cc.currentEffort || 'medium', editor_context: editorCtx, page_context: pageCtx, link_base: linkBase });
  };

  cc.initSession = async function(opts) {
    opts = opts || {};
    // Don't clobber a sessionId set by openChat's URL auto-open. initSession
    // runs on page load (300ms setTimeout) AFTER refreshChatsList's
    // .then(openChat) already ran and set cc.sessionId to the deep-linked
    // chat. Nulling it here caused every new send to ensureChatId(true) →
    // mint a fresh local-id → create a new empty chat file.
    if (!opts.preserveSession) {
      cc.sessionId = null;
    }
    cc.sessionReady = false;
    cc.bridgeConnected = false;

    cc.updateStatus('Connecting...');

    try {
      var authResp = await fetch(cc.apiBase + '/api/auth-status', { signal: AbortSignal.timeout(5000) });
      if (!authResp.ok) {
        var errBody = '';
        try { var ej = await authResp.json(); errBody = ej.error || ej.message || ''; } catch(_) {}
        throw new Error(errBody || ('auth-status returned HTTP ' + authResp.status));
      }
      var authData = await authResp.json();

      cc.bridgeConnected = true;
      cc.updateStatus('Ready');
      console.log('[bridge] auth-status ok, user: ' + (authData.user || 'unknown'));
    } catch (e) {
      if (cc.isReloading) return;
      console.error('[bridge] init error:', e.message);
      cc.updateStatus('Offline');
    } finally {
      cc.setInputDisabled(false);
      cc.updateSendButton();
      if (!opts.skipWelcome) {
        cc.showWelcomeMessage();
      }
    }
  };

  cc.processQueue = function() {
    if (cc.messageQueue.length === 0) return;
    if (cc.bridgePolling) return;
    var nextMsg = cc.messageQueue.shift();
    var content = document.getElementById('chatbot-content');
    if (content) {
      var msgs = content.querySelectorAll('.chatbot-message-system');
      for (var i = msgs.length - 1; i >= 0; i--) {
        if (msgs[i].textContent.indexOf('Message queued') !== -1) {
          content.removeChild(msgs[i]);
          break;
        }
      }
    }
    cc.saveState();
    // Two shapes exist in the queue: a full /api/start payload (pushed by
    // bridgeSend's busy-guard) or a raw string (legacy path via
    // sendCommandToBackend). Dispatch by type.
    if (nextMsg && typeof nextMsg === 'object') {
      cc.showTypingIndicator();
      cc.startTimer();
      cc.startResponseTimeout();
      cc.showStopButton();
      cc.updateStatus('Thinking...');
      cc.bridgeSend(nextMsg);
    } else {
      cc.sendCommandToBackend(nextMsg);
    }
  };

})(window._cc);
