// interclaw-chatbot/messages.js — addMessage, addMessageWithFiles, wrapMessage, saveState, restoreState
(function(cc) {

  cc.removeInitialLoader = function() {
    var loader = document.getElementById('chatbot-loading');
    if (loader) { loader.style.opacity = '0'; setTimeout(function() { loader.remove(); }, 400); }
  };

  cc.updateStatus = function(text) {
    if (text === 'Connected' || text === 'Ready' || text === 'Offline' || text === 'Error') { cc.removeInitialLoader(); }
    cc.lastStatusBase = text;
    if (cc.timerInterval && cc.queryStartTime) {
      var elapsed = ((Date.now() - cc.queryStartTime) / 1000).toFixed(1);
      document.getElementById('chatbot-status-text').textContent = text + ' (' + elapsed + 's)';
    } else {
      document.getElementById('chatbot-status-text').textContent = text;
    }
  };

  cc.formatTimestamp = function() {
    var now = new Date();
    var h = now.getHours(); var m = now.getMinutes();
    var ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12 || 12;
    return h + ':' + (m < 10 ? '0' : '') + m + ' ' + ampm;
  };

  cc.createTimestamp = function() {
    var ts = document.createElement('div');
    ts.className = 'msg-timestamp';
    ts.textContent = cc.formatTimestamp();
    return ts;
  };

  cc.wrapMessage = function(msgEl, isUser) {
    var wrap = document.createElement('div');
    wrap.className = 'chatbot-msg-wrap' + (isUser ? ' chatbot-msg-wrap--user' : '');
    wrap.appendChild(msgEl);
    wrap.appendChild(cc.createTimestamp());
    return wrap;
  };

  cc.addMessageWithFiles = function(type, text, fileNames) {
    if (!fileNames || fileNames.length === 0) return cc.addMessage(type, text);
    var content = document.getElementById('chatbot-content');
    var wrap = document.createElement('div');
    wrap.className = 'chatbot-msg-wrap chatbot-msg-wrap--user';
    var chipsRow = document.createElement('div');
    chipsRow.className = 'sent-file-chips';
    fileNames.forEach(function(name) {
      chipsRow.innerHTML += '<div class="sent-file-chip">' +
        '<div class="chip-icon">' + cc.getFileIcon(name) + '</div>' +
        '<div class="chip-info">' +
          '<span class="chip-name">' + cc.escapeHtml(name) + '</span>' +
          '<span class="chip-label">' + cc.getFileLabel(name) + '</span>' +
        '</div></div>';
    });
    wrap.appendChild(chipsRow);
    if (text.trim()) {
      var msg = document.createElement('div');
      msg.className = 'chatbot-message chatbot-message-user';
      msg.textContent = text;
      wrap.appendChild(msg);
    }
    content.appendChild(wrap);
    content.scrollTop = content.scrollHeight;
    cc.saveState();
  };

  cc.addMessage = function(type, text) {
    cc.removeTypingIndicator(); cc.removeInitialLoader();
    text = (text || '').trim();
    if (!text) return;
    var content = document.getElementById('chatbot-content');

    if (type === 'assistant') {
      var assistantMsg = document.createElement('div');
      assistantMsg.className = 'chatbot-message';
      assistantMsg.innerHTML = '<div class="msg-content">' + cc.renderMarkdown(text) + '</div>';
      content.appendChild(cc.wrapMessage(assistantMsg, false));
      content.scrollTop = content.scrollHeight;
      cc.saveState();
      return;
    }

    var msg = document.createElement('div');
    msg.className = 'chatbot-message';
    if (type === 'user') msg.className += ' chatbot-message-user';
    else if (type === 'system') msg.className += ' chatbot-message-system';
    else if (type === 'error') msg.className += ' chatbot-message-error';

    if (type === 'error') {
      cc.removeInitialLoader();
      msg.innerHTML = '<svg class="chatbot-error-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>'
        + '<span class="chatbot-error-text">' + cc.escapeHtml(text) + '</span>';
    } else {
      msg.textContent = text;
    }
    if (type === 'user' || type === 'assistant') {
      content.appendChild(cc.wrapMessage(msg, type === 'user'));
    } else {
      content.appendChild(msg);
    }
    content.scrollTop = content.scrollHeight;
    cc.saveState();
  };

  cc.showTypingIndicator = function() {
    // Idempotent: if a live streaming bubble is already in the DOM, reuse
    // it instead of stacking a fresh one. Stacking is how duplicate
    // "Hide steps" toggles accumulate inside a single turn (one bubble
    // from sendMessage, another from attachBridge running concurrently).
    if (cc.currentStreamEl && cc.currentStreamEl.parentNode) {
      cc.ensureStepsContainer();
      return;
    }
    var chatMessages = document.getElementById('chatbot-content');
    cc.currentStreamEl = document.createElement('div');
    cc.currentStreamEl.className = 'chatbot-message';
    cc.currentStreamEl.innerHTML = '<div class="msg-content"></div><div class="bubble-thinking-bar"><svg class="typing-icon" width="16" height="16" viewBox="-18 0 57 57" stroke="none"><polygon fill="#2F2A95" points="7.2 8 0.2 4.5 0.2 49.3 14.3 56.3 14.3 48.5 7.2 44.9"/><polygon fill="#00B2A9" points="14.3 48.5 21.3 52 21.3 7.2 7.2 0.2 7.2 8 14.3 11.6"/></svg><span class="typing-label">' + cc.currentThinkingWord + '</span></div>';
    cc.currentStreamWrap = document.createElement('div');
    cc.currentStreamWrap.className = 'chatbot-msg-wrap';
    cc.currentStreamWrap.appendChild(cc.currentStreamEl);
    chatMessages.appendChild(cc.currentStreamWrap);
    cc.currentStreamText = '';
    cc.currentThinkingEl = null;
    cc.currentThinkingText = '';
    cc._hiddenToolCount = 0;
    cc.ensureStepsContainer();
    chatMessages.scrollTop = chatMessages.scrollHeight;
  };

  cc.removeTypingIndicator = function() {
    // no-op — typing indicator is now part of the bubble
  };

  cc.removeBubbleThinkingBar = function() {
    if (!cc.currentStreamEl) return;
    var bar = cc.currentStreamEl.querySelector('.bubble-thinking-bar');
    if (bar) bar.remove();
  };

  cc.transformThinkingToUsage = function() {
    if (!cc.currentStreamEl) return;
    var bar = cc.currentStreamEl.querySelector('.bubble-thinking-bar');
    var elapsed = cc.queryStartTime ? ((Date.now() - cc.queryStartTime) / 1000).toFixed(1) + 's' : '';
    var usageText = cc.lastUsageText || (elapsed ? elapsed : '');
    if (bar && usageText) {
      bar.className = 'bubble-usage-bar';
      bar.innerHTML = '<svg class="usage-icon" width="16" height="16" viewBox="-18 0 57 57" stroke="none"><polygon fill="currentColor" points="7.2 8 0.2 4.5 0.2 49.3 14.3 56.3 14.3 48.5 7.2 44.9"/><polygon fill="currentColor" points="14.3 48.5 21.3 52 21.3 7.2 7.2 0.2 7.2 8 14.3 11.6"/></svg><span class="usage-text">' + cc.escapeHtml(usageText) + '</span>';
    } else if (bar) {
      bar.remove();
    }
  };

  // Strip purely transient streaming affordances before serializing:
  //   .bubble-thinking-bar  — the live "Making Connections · 3s" status
  //                           (gets replaced by .bubble-usage-bar on `done`)
  //   empty .reasoning-steps — a toggle wrapper created by the typing
  //                            indicator but never populated (artifact of
  //                            mid-turn re-render races)
  // .bubble-usage-bar STAYS: once the turn has completed, the usage bar
  // contains static tokens/cost/elapsed text that should persist across
  // reloads and chat-reopens. It's already a sibling of .msg-content and
  // re-renders fine from saved HTML.
  // Populated .reasoning-steps stay: they carry the tool-call history the
  // user expects to see after a reload. The delegated click handler in
  // init.js keeps their toggle working after rehydrate.
  function cleanBubbleHtml(msgEl) {
    var clone = msgEl.cloneNode(true);
    var bars = clone.querySelectorAll('.bubble-thinking-bar');
    for (var i = 0; i < bars.length; i++) {
      if (bars[i].parentNode) bars[i].parentNode.removeChild(bars[i]);
    }
    var steps = clone.querySelectorAll('.reasoning-steps');
    for (var j = 0; j < steps.length; j++) {
      var list = steps[j].querySelector('.reasoning-list');
      if (!list || !list.querySelector('.reasoning-step')) {
        if (steps[j].parentNode) steps[j].parentNode.removeChild(steps[j]);
      }
    }
    return clone.innerHTML;
  }

  cc.saveState = function() {
    var state = {
      sessionId: cc.sessionId,
      messages: []
    };
    var children = document.getElementById('chatbot-content').children;
    for (var i = 0; i < children.length; i++) {
      var el = children[i];
      var msgEl = el.classList.contains('chatbot-msg-wrap') ? el.querySelector('.chatbot-message') : el;
      if (!msgEl) continue;
      var type = 'assistant';
      if (msgEl.classList.contains('chatbot-message-user')) type = 'user';
      else if (msgEl.classList.contains('chatbot-message-system')) type = 'system';
      else if (msgEl.classList.contains('chatbot-message-error')) type = 'error';
      else if (msgEl.classList.contains('chatbot-message-tool')) type = 'tool';
      state.messages.push({ type: type, html: cleanBubbleHtml(msgEl) });
    }
    sessionStorage.setItem('chatbot-state', JSON.stringify(state));
  };

  cc.restoreState = function() {
    var saved = sessionStorage.getItem('chatbot-state');
    if (!saved) return false;
    try {
      var state = JSON.parse(saved);
      if (!state.sessionId) return false;

      cc.sessionId = state.sessionId;
      var content = document.getElementById('chatbot-content');

      state.messages.forEach(function(m) {
        var msg = document.createElement('div');
        msg.className = 'chatbot-message';
        if (m.type === 'user') msg.className += ' chatbot-message-user';
        else if (m.type === 'system') msg.className += ' chatbot-message-system';
        else if (m.type === 'error') msg.className += ' chatbot-message-error';
        else if (m.type === 'tool') msg.className += ' chatbot-message-tool';
        msg.innerHTML = m.html;
        // Legacy sessions may carry a live thinking-bar with an animated
        // label; drop those. Keep the .bubble-usage-bar — it's the static
        // post-turn tokens/cost/elapsed summary the user expects to see.
        var bars = msg.querySelectorAll('.bubble-thinking-bar');
        for (var bk = 0; bk < bars.length; bk++) {
          if (bars[bk].parentNode) bars[bk].parentNode.removeChild(bars[bk]);
        }
        var emptySteps = msg.querySelectorAll('.reasoning-steps');
        for (var esk = 0; esk < emptySteps.length; esk++) {
          var list = emptySteps[esk].querySelector('.reasoning-list');
          if (!list || !list.querySelector('.reasoning-step')) {
            if (emptySteps[esk].parentNode) emptySteps[esk].parentNode.removeChild(emptySteps[esk]);
          }
        }
        if (m.type === 'user' || m.type === 'assistant') {
          var wrap = document.createElement('div');
          wrap.className = 'chatbot-msg-wrap' + (m.type === 'user' ? ' chatbot-msg-wrap--user' : '');
          wrap.appendChild(msg);
          content.appendChild(wrap);
        } else {
          content.appendChild(msg);
        }
      });

      content.scrollTop = content.scrollHeight;
      cc.sessionReady = true;
      cc.updateStatus('Connected');
      return true;
    } catch(e) {
      return false;
    }
  };

})(window._cc);
