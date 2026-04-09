// interclaw-chatbot/bridge.js — bridgeSend, wsSend, initSession, sendCommandToBackend
(function(cc) {

  cc.bridgeSend = async function(payload, opts) {
    opts = opts || {};

    try {
      var startResp = await fetch(cc.chatApiBase + '/api/start', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      if (!startResp.ok) throw new Error('Bridge start failed: HTTP ' + startResp.status);
      var startData = await startResp.json();
      cc.currentBridgeId = startData.bridge_id;
      console.log('[bridge] started:', cc.currentBridgeId);

      var after = 0;
      cc.bridgePolling = true;
      cc.bridgeAbort = new AbortController();

      while (cc.bridgePolling) {
        try {
          var pollResp = await fetch(
            cc.chatApiBase + '/api/events?bridge_id=' + cc.currentBridgeId + '&after=' + after,
            { signal: cc.bridgeAbort.signal }
          );
          if (!pollResp.ok) throw new Error('Poll failed: HTTP ' + pollResp.status);
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
    cc.wsSend({ action: 'message', prompt: command, session_id: cc.sessionId, model: cc.getSelectedModel(), namespace: editorCtx.namespace, effort: cc.currentEffort, editor_context: editorCtx });
  };

  cc.initSession = async function(opts) {
    opts = opts || {};
    cc.sessionId = null;
    cc.sessionReady = false;
    cc.bridgeConnected = false;

    cc.updateStatus('Connecting...');

    try {
      var healthResp = await fetch(cc.chatApiBase + '/api/health', { signal: AbortSignal.timeout(5000) });
      if (!healthResp.ok) throw new Error('HTTP ' + healthResp.status);
      var healthData = await healthResp.json();
      if (healthData.status !== 'ok') throw new Error('Production unhealthy');

      cc.bridgeConnected = true;
      cc.updateStatus('Ready');
      console.log('[bridge] health check passed');
    } catch (e) {
      if (cc.isReloading) return;
      var initErr = e.message || 'Unknown error';
      if (initErr.indexOf('HTTP 5') !== -1 || initErr.indexOf('HTTP 4') !== -1) initErr = 'Could not reach the chat service. Check that InterClaw.Pipeline.Production is running.';
      else if (initErr.indexOf('timeout') !== -1 || initErr.indexOf('Timeout') !== -1) initErr = 'Connection timed out. The server may be starting up \u2014 try again in a moment.';
      cc.addMessage('error', initErr);
      cc.updateStatus('Offline');
      opts._initFailed = true;
    } finally {
      cc.setInputDisabled(false);
      cc.updateSendButton();
      if (!opts.skipWelcome && !opts._initFailed) cc.showWelcomeMessage();
    }
  };

  cc.processQueue = function() {
    if (cc.messageQueue.length > 0 && cc.sessionId) {
      var nextMsg = cc.messageQueue.shift();
      var content = document.getElementById('chatbot-content');
      var msgs = content.querySelectorAll('.chatbot-message-system');
      for (var i = msgs.length - 1; i >= 0; i--) {
        if (msgs[i].textContent.indexOf('Message queued') !== -1) {
          content.removeChild(msgs[i]);
          break;
        }
      }
      cc.saveState();
      cc.sendCommandToBackend(nextMsg);
    }
  };

})(window._cc);
