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
      console.log('[bridge] started:', cc.currentBridgeId);
      if (cc.refreshChatsList) cc.refreshChatsList();

      var after = 0;
      cc.bridgePolling = true;
      cc.bridgeAbort = new AbortController();

      var pollRetries = 0;
      var maxPollRetries = 3;

      while (cc.bridgePolling) {
        try {
          var pollResp = await fetch(
            cc.chatApiBase + '/api/events?bridge_id=' + cc.currentBridgeId + '&after=' + after,
            { signal: cc.bridgeAbort.signal }
          );
          if (!pollResp.ok) {
            // Retry transient 500s up to maxPollRetries before giving up
            if (pollResp.status >= 500 && pollRetries < maxPollRetries) {
              pollRetries++;
              console.warn('[bridge] poll 500, retry ' + pollRetries + '/' + maxPollRetries);
              await new Promise(function(r) { setTimeout(r, 1000 * pollRetries); });
              continue;
            }
            throw new Error('Poll failed: HTTP ' + pollResp.status);
          }
          pollRetries = 0; // Reset on success
          var pollData = await pollResp.json();

          for (var i = 0; i < pollData.events.length; i++) {
            var evt = pollData.events[i];
            after = evt.seq;
            var data = evt.data;
            console.log('[bridge] evt:', data.type);
            if (data.type === 'connected') continue;
            cc.handleEvent(data);
          }

          if (pollData.done) {
            cc.bridgePolling = false;
            break;
          }
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
      if (cc.refreshChatsList) cc.refreshChatsList();
    }
    return true;
  };

  // Attach the event stream to an existing server-side bridge. Used when a
  // user reopens a chat whose previous turn is still streaming (e.g. after a
  // window close). afterSeq is the last event sequence the chat already has;
  // the poll resumes from there. Shares the same event loop as bridgeSend —
  // any new tool_use / delta / done events render into the reopened pane.
  cc.attachBridge = async function(bridgeId, afterSeq) {
    if (!bridgeId) return false;
    cc.currentBridgeId = bridgeId;
    var after = +afterSeq || 0;
    cc.bridgePolling = true;
    cc.bridgeAbort = new AbortController();
    var pollRetries = 0;
    var maxPollRetries = 3;
    cc.showStopButton();
    cc.showTypingIndicator();
    // Start the live thinking-bar timer. If openChat stashed the server's
    // turnStartedAt, snap queryStartTime back to it so the label shows
    // the turn's true age right away. Otherwise start from now and let
    // the next `usage` event refine via data.elapsed_ms.
    cc.startTimer();
    if (cc._resumeTurnStartedAt) {
      cc.queryStartTime = cc._resumeTurnStartedAt;
      cc._resumeTurnStartedAt = null;
    }
    cc.updateStatus('Resuming...');
    try {
      while (cc.bridgePolling) {
        try {
          var pollResp = await fetch(
            cc.chatApiBase + '/api/events?bridge_id=' + cc.currentBridgeId + '&after=' + after,
            { signal: cc.bridgeAbort.signal }
          );
          if (!pollResp.ok) {
            if (pollResp.status >= 500 && pollRetries < maxPollRetries) {
              pollRetries++;
              await new Promise(function(r) { setTimeout(r, 1000 * pollRetries); });
              continue;
            }
            throw new Error('Poll failed: HTTP ' + pollResp.status);
          }
          pollRetries = 0;
          var pollData = await pollResp.json();
          for (var i = 0; i < pollData.events.length; i++) {
            var evt = pollData.events[i];
            after = evt.seq;
            var data = evt.data;
            if (data.type === 'connected') continue;
            cc.handleEvent(data);
          }
          if (pollData.done) {
            cc.bridgePolling = false;
            break;
          }
        } catch (e) {
          if (e.name === 'AbortError') break;
          throw e;
        }
      }
    } catch (e) {
      console.warn('[bridge] attach error:', e && e.message);
      cc.updateStatus('Error');
      cc.removeTypingIndicator();
      cc.hideStopButton();
      return false;
    } finally {
      cc.bridgePolling = false;
      cc.bridgeAbort = null;
      cc.currentBridgeId = null;
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
    cc.wsSend({ action: 'message', prompt: command, session_id: cc.sessionId, model: cc.getSelectedModel(), namespace: editorCtx.namespace, effort: cc.currentEffort || 'medium', editor_context: editorCtx });
  };

  cc.initSession = async function(opts) {
    opts = opts || {};
    cc.sessionId = null;
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
      console.log('[bridge] auth-status check passed');

      if (!authData.logged_in) {
        opts._needsAuth = true;
        opts._needsLogin = true;
        console.log('[bridge] not logged in — showing login prompt');
      } else if (!authData.authenticated) {
        opts._needsAuth = true;
        console.log('[bridge] logged in as ' + authData.user + ' but API key not configured — showing setup prompt');
      } else {
        console.log('[bridge] authenticated via ' + authData.provider + ' (' + authData.key_prefix + '), user: ' + authData.user);
      }
    } catch (e) {
      if (cc.isReloading) return;
      console.error('[bridge] init error:', e.message);
      opts._needsAuth = true;
      cc.updateStatus('Offline');
    } finally {
      cc.setInputDisabled(false);
      cc.updateSendButton();
      if (!opts.skipWelcome) {
        if (opts._needsAuth) {
          cc.showSetupPrompt({ needsLogin: opts._needsLogin });
        } else {
          cc.showWelcomeMessage();
        }
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
      console.log('[bridge] processQueue draining payload — this produces a new bubble');
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
