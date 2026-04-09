// interclaw-chatbot/messages.js — addMessage, addMessageWithFiles, wrapMessage, saveState, restoreState
(function(cc) {

  cc.removeInitialLoader = function() {
    var loader = document.getElementById('chatbot-loading');
    if (loader) { loader.style.opacity = '0'; setTimeout(function() { loader.remove(); }, 400); }
  };

  cc.updateStatus = function(text) {
    if (text === 'Connected') { cc.removeInitialLoader(); }
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

    msg.textContent = text;
    if (type === 'user' || type === 'assistant') {
      content.appendChild(cc.wrapMessage(msg, type === 'user'));
    } else {
      content.appendChild(msg);
    }
    content.scrollTop = content.scrollHeight;
    cc.saveState();
  };

  cc.showTypingIndicator = function() {
    var chatMessages = document.getElementById('chatbot-content');
    cc.currentStreamEl = document.createElement('div');
    cc.currentStreamEl.className = 'chatbot-message';
    cc.currentStreamEl.innerHTML = '<div class="msg-content"></div><div class="bubble-thinking-bar"><svg class="typing-icon" width="16" height="16" viewBox="0 0 512 512" stroke="none"><path fill="#2F2A95" d="m175.656 22.375-48.47 82.094c-23.017 4.384-43.547 11.782-60.124 22.374-24.436 15.613-40.572 37.414-45.5 67.875-4.79 29.62 1.568 68.087 24.125 116.093 93.162 22.88 184.08-10.908 257.25-18.813 37.138-4.012 71.196-.898 96.344 22.97 22.33 21.19 36.21 56.808 41.908 113.436 29.246-35.682 44.538-69.065 49.343-99.594 5.543-35.207-2.526-66.97-20.31-95.593-8.52-13.708-19.368-26.618-32-38.626l14.217-33-41.218 10.625c-8.637-6.278-17.765-12.217-27.314-17.782l-7.03-59.782-38.157 37.406a423.505 423.505 0 0 0-38.158-13.812l-8.375-71.28-57.625 56.5c-9.344-1.316-18.625-2.333-27.812-2.97l-31.094-78.125z"/><path fill="#00B2A9" d="M222 325.345c-39.146 7.525-82.183 14.312-127.156 11.686 47.403 113.454 207.056 224.082 260.125 87-101.18 33.84-95.303-49.595-132.97-98.686z"/></svg><span class="typing-label">' + cc.currentThinkingWord + '</span></div>';
    cc.currentStreamWrap = document.createElement('div');
    cc.currentStreamWrap.className = 'chatbot-msg-wrap';
    cc.currentStreamWrap.appendChild(cc.currentStreamEl);
    chatMessages.appendChild(cc.currentStreamWrap);
    cc.currentStreamText = '';
    cc.currentThinkingEl = null;
    cc.currentThinkingText = '';
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
      bar.innerHTML = '<svg class="usage-icon" width="12" height="12" viewBox="0 0 512 512" stroke="none"><path fill="currentColor" d="m175.656 22.375-48.47 82.094c-23.017 4.384-43.547 11.782-60.124 22.374-24.436 15.613-40.572 37.414-45.5 67.875-4.79 29.62 1.568 68.087 24.125 116.093 93.162 22.88 184.08-10.908 257.25-18.813 37.138-4.012 71.196-.898 96.344 22.97 22.33 21.19 36.21 56.808 41.908 113.436 29.246-35.682 44.538-69.065 49.343-99.594 5.543-35.207-2.526-66.97-20.31-95.593-8.52-13.708-19.368-26.618-32-38.626l14.217-33-41.218 10.625c-8.637-6.278-17.765-12.217-27.314-17.782l-7.03-59.782-38.157 37.406a423.505 423.505 0 0 0-38.158-13.812l-8.375-71.28-57.625 56.5c-9.344-1.316-18.625-2.333-27.812-2.97l-31.094-78.125z"/><path fill="#2a9d8f" d="M222 325.345c-39.146 7.525-82.183 14.312-127.156 11.686 47.403 113.454 207.056 224.082 260.125 87-101.18 33.84-95.303-49.595-132.97-98.686z"/></svg><span class="usage-text">' + cc.escapeHtml(usageText) + '</span>';
    } else if (bar) {
      bar.remove();
    }
  };

  cc.saveState = function() {
    var state = {
      sessionId: cc.sessionId,
      effort: cc.currentEffort,
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
      state.messages.push({ type: type, html: msgEl.innerHTML });
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
      if (state.effort) {
        cc.currentEffort = state.effort;
        var effortOpts = document.querySelectorAll('.chatbot-effort-opt');
        effortOpts.forEach(function(o) { o.classList.toggle('active', o.dataset.effort === cc.currentEffort); });
      }
      var content = document.getElementById('chatbot-content');

      state.messages.forEach(function(m) {
        var msg = document.createElement('div');
        msg.className = 'chatbot-message';
        if (m.type === 'user') msg.className += ' chatbot-message-user';
        else if (m.type === 'system') msg.className += ' chatbot-message-system';
        else if (m.type === 'error') msg.className += ' chatbot-message-error';
        else if (m.type === 'tool') msg.className += ' chatbot-message-tool';
        msg.innerHTML = m.html;
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
