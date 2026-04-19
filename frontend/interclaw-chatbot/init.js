// interclaw-chatbot/init.js — window.addEventListener('load', ...), event delegation, global exports
(function(cc) {

  cc.init = function() {
    // Auto-connect on load (restore previous session if available)
    window.addEventListener('load', function() {
      cc.fetchConfig();
      cc.updateThinkingToggle();

      // ?FULL=TRUE — launch in fullscreen (chat only, no editor panel)
      var params = new URLSearchParams(window.location.search);
      if ((params.get('FULL') || '').toUpperCase() === 'TRUE') {
        document.body.classList.add('chatbot-fullscreen');
      }

      // Event delegation for reasoning steps — survives DOM serialization/restoration
      document.getElementById('chatbot-content').addEventListener('click', function(e) {
        var node = e.target;
        while (node && node !== this) {
          if (!node.classList) { node = node.parentElement; continue; }
          if (node.classList.contains('reasoning-toggle')) {
            var listEl = node.parentElement ? node.parentElement.querySelector('.reasoning-list') : null;
            if (listEl) {
              var isHidden = listEl.style.display === 'none';
              listEl.style.display = isHidden ? '' : 'none';
              node.innerHTML = '<span class="chevron-icon' + (isHidden ? ' open' : '') + '">' + cc.CHEVRON_SVG + '</span> ' + (isHidden ? 'Hide steps' : 'Show steps');
            }
            e.stopPropagation();
            return;
          }
          if (node.classList.contains('clickable') && node.classList.contains('reasoning-step-label')) {
            var stepNode = node.parentElement;
            while (stepNode && !(stepNode.classList && stepNode.classList.contains('reasoning-step'))) stepNode = stepNode.parentElement;
            if (stepNode && stepNode.id) {
              cc.toggleStepContent(stepNode.id.replace('reasoning-step-', ''));
            }
            e.stopPropagation();
            return;
          }
          node = node.parentElement;
        }
      });

      // Save chatbot state before any page navigation so it persists across
      // tab clicks. `beforeunload` covers navigation; `pagehide` covers the
      // bfcache/tab-close paths some browsers use instead. Both fire — the
      // server-side PUT is idempotent, so a duplicate call is harmless.
      function flushOnExit() {
        if (cc.sessionId) cc.saveState();
        if (cc.flushPersistChat) cc.flushPersistChat();
      }
      window.addEventListener('beforeunload', flushOnExit);
      window.addEventListener('pagehide', flushOnExit);

      // Pre-set status for tab navigation so user doesn't see "Not connected" flash
      var navType = 'navigate';
      try { navType = performance.getEntriesByType('navigation')[0].type; } catch(e) {}
      var isReload = navType === 'reload';
      if (!isReload && sessionStorage.getItem('chatbot-state')) {
        cc.updateStatus('Connected');
      }

      setTimeout(function() {
        sessionStorage.removeItem('chatbot-programmatic-reload');

        if (sessionStorage.getItem('chatbot-close-after-reload')) {
          sessionStorage.removeItem('chatbot-close-after-reload');
          document.body.classList.add('chatbot-closed');
        }

        // If the URL carries a chat id, buildSidebar already kicked off
        // openChat for it — which calls renderChatDoc, which prepends
        // welcome itself. Skip sessionStorage restore to avoid double
        // rendering. initSession still runs for auth but skips welcome
        // (renderChatDoc owns that on URL-deep-link paths).
        var hasUrlChat = /^#\/chat\/[^?]+/.test(window.location.hash || '');
        if (hasUrlChat) {
          sessionStorage.removeItem('chatbot-state');
          // preserveSession: the sidebar's URL auto-open has already called
          // openChat which set cc.sessionId. Don't null it here or the
          // next send will mint a fresh chat.
          cc.initSession({ skipWelcome: true, preserveSession: true });
        } else if (!isReload && cc.restoreState()) {
          // Restored conversation from tab navigation. restoreState set
          // cc.sessionId from sessionStorage — don't wipe it.
          if (cc.showWelcomeMessage) cc.showWelcomeMessage();
          cc.initSession({ skipWelcome: true, preserveSession: true });
        } else {
          sessionStorage.removeItem('chatbot-state');
          cc.initSession();
        }


      }, 300);
    });

    // ── Tree selection context indicator ──
    var folderSvg = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"/></svg>';
    var fileSvg = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/></svg>';

    function updateContextIndicator(sel) {
      var sep = document.getElementById('chatbot-context-sep');
      var body = document.getElementById('chatbot-context-body');
      if (!sep || !body) return;
      if (!sel || !sel.name) { sep.style.display = 'none'; body.style.display = 'none'; return; }
      var icon = sel.type === 'folder' ? folderSvg : fileSvg;
      body.innerHTML = icon + '<span>' + sel.name + '</span>';
      sep.style.display = '';
      body.style.display = '';
    }

    // Load from localStorage on init
    try {
      var saved = localStorage.getItem('interclaw-tree-selection');
      if (saved) updateContextIndicator(JSON.parse(saved));
    } catch(e) {}

    // Live updates from skills editor
    window.addEventListener('interclaw-tree-selection', function(e) {
      if (e.detail) updateContextIndicator(e.detail);
    });

    // Expose functions referenced by inline onclick handlers to global scope
    window.toggleChatbot = cc.toggleChatbot;
    window.toggleFullscreen = cc.toggleFullscreen;
    window.sendMessage = cc.sendMessage;
    window.stopGeneration = cc.stopGeneration;
    window.removeAttachment = cc.removeAttachment;
    window.sendQuickReply = cc.sendQuickReply;
    window.sendSuggestion = cc.sendSuggestion;
    window.showSuggestions = cc.showSuggestions;
  };

})(window._cc);
