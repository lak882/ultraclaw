// interclaw-chatbot/timer-usage.js — Timer, token counter, usage tracking, response timeout
(function(cc) {

  cc.formatTokens = function(n) {
    if (n >= 1000000000) return (n / 1000000000).toFixed(1).replace(/\.0$/, '') + 'B';
    if (n >= 1000000) return (n / 1000000).toFixed(1).replace(/\.0$/, '') + 'M';
    if (n >= 10000) return (n / 1000).toFixed(1).replace(/\.0$/, '') + 'k';
    return n.toLocaleString();
  };

  cc.updateTokenCounter = function(n) {
    var el = document.getElementById('token-counter');
    if (el) el.textContent = cc.formatTokens(n) + ' tokens';
  };

  cc.startResponseTimeout = function() {
    cc.clearResponseTimeout();
  };

  cc.resetResponseTimeout = function() {
    if (cc.responseTimeout) {
      clearTimeout(cc.responseTimeout);
      cc.responseTimeout = null;
    }
  };

  cc.clearResponseTimeout = function() {
    if (cc.responseTimeout) {
      clearTimeout(cc.responseTimeout);
      cc.responseTimeout = null;
    }
  };

  cc.formatElapsed = function(ms) {
    var s = Math.floor(ms / 1000);
    if (s < 60) return s + 's';
    var m = Math.floor(s / 60); s = s % 60;
    if (m < 60) return m + 'm ' + s + 's';
    var h = Math.floor(m / 60); m = m % 60;
    return h + 'h ' + m + 'm ' + s + 's';
  };

  cc.startTimer = function() {
    cc.queryStartTime = Date.now();
    cc.usageShown = false;
    cc.lastUsageText = '';
    cc.lastTurnTokens = 0;
    cc.lastInputTokens = 0;
    cc.lastOutputTokens = 0;
    cc.lastCacheReadTokens = 0;
    cc.lastCacheWriteTokens = 0;
    cc.isStreamingThinking = false;
    cc.currentThinkingWord = cc.thinkingWords[Math.floor(Math.random() * cc.thinkingWords.length)];
    cc.lastStatusBase = cc.currentThinkingWord + '...';
    cc.timerInterval = setInterval(function() {
      var el = cc.formatElapsed(Date.now() - cc.queryStartTime);
      document.getElementById('chatbot-status-text').textContent = cc.lastStatusBase + ' (' + el + ')';
      if (cc.currentStreamEl) {
        var label = cc.currentStreamEl.querySelector('.bubble-thinking-bar .typing-label');
        if (label) label.textContent = cc.currentThinkingWord + ' \u00b7 ' + el;
      }
    }, 100);
  };

  cc.stopTimer = function() {
    if (cc.timerInterval) {
      clearInterval(cc.timerInterval);
      cc.timerInterval = null;
    }
  };

})(window._cc);
