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

        // Always show the welcome message on page open, regardless of
        // whether a chat is being resumed from URL, sessionStorage, or
        // a fresh load. The welcome is idempotent (one per pane) and
        // ephemeral (not persisted in the chat doc), so it just sits at
        // the top of the pane alongside any restored turns.
        var hasUrlChat = /^#\/chat\/[^?]+/.test(window.location.hash || '');
        if (hasUrlChat) {
          sessionStorage.removeItem('chatbot-state');
          if (cc.showWelcomeMessage) cc.showWelcomeMessage();
          cc.initSession({ skipWelcome: true, preserveSession: true });
        } else if (!isReload && cc.restoreState()) {
          if (cc.showWelcomeMessage) cc.showWelcomeMessage();
          cc.initSession({ skipWelcome: true, preserveSession: true });
        } else {
          sessionStorage.removeItem('chatbot-state');
          cc.initSession();
        }


      }, 300);
    });

    // ── Context indicator pills (skills tree selection + portal page) ──
    var folderSvg = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"/></svg>';
    var fileSvg = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/></svg>';
    var pageSvg = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18"/><path d="M9 21V9"/></svg>';

    // Pill state: tree = skills file/folder, portal = active Zen page
    var _treePill = null;
    var _portalPill = null;

    function renderContextPills() {
      var sep = document.getElementById('chatbot-context-sep');
      var body = document.getElementById('chatbot-context-body');
      if (!sep || !body) return;
      var pills = [];
      if (_treePill) {
        var icon = _treePill.type === 'folder' ? folderSvg : fileSvg;
        pills.push('<span class="chatbot-context-pill" title="' + cc.escapeHtml(_treePill.name) + '">' + icon + '<span>' + cc.escapeHtml(_treePill.name) + '</span></span>');
      }
      if (_portalPill) {
        pills.push('<span class="chatbot-context-pill" title="' + cc.escapeHtml(_portalPill) + '">' + pageSvg + '<span>' + cc.escapeHtml(_portalPill) + '</span></span>');
      }
      if (pills.length === 0) {
        sep.style.display = 'none';
        body.style.display = 'none';
        body.innerHTML = '';
      } else {
        body.innerHTML = pills.join('');
        sep.style.display = '';
        body.style.display = '';
      }
    }

    function updateContextIndicator(sel) {
      _treePill = (sel && sel.name) ? sel : null;
      renderContextPills();
    }

    // Parse a zenPath from the portal iframe into a short readable label.
    // zenPath looks like: /csp/healthshare/HSCUSTOM/EnsPortal.DTLEditor.zen?DT=Demo.DTL.Foo.cls
    function portalPillFromZenPath(zenPath) {
      if (!zenPath) return null;
      var pageLabels = {
        DTLEditor: 'DTL Editor', RuleEditor: 'Rule Editor', BPLEditor: 'BPL Editor',
        ProductionConfig: 'Production', MessageViewer: 'Message Viewer',
        VisualTrace: 'Visual Trace', EventLog: 'Event Log',
        'HL7.SchemaDocumentStructure': 'HL7 Schema',
        LookupSettings: 'Lookup Table', BusinessProcess: 'BP Editor'
      };
      // Extract Zen page name
      var pageMatch = zenPath.match(/EnsPortal\.([^.]+(?:\.[^?&/]+)?)?\.zen/);
      var pageName = pageMatch ? (pageLabels[pageMatch[1]] || pageMatch[1]) : null;
      // Extract component from query params
      var params = '';
      try { params = zenPath.indexOf('?') !== -1 ? zenPath.substring(zenPath.indexOf('?')) : ''; } catch(e) {}
      var qs = new URLSearchParams(params);
      var component = qs.get('DT') || qs.get('RULE') || qs.get('BP') || qs.get('PRODUCTION') || qs.get('MS') || qs.get('LookupTable');
      if (component) component = component.replace(/\.cls$/, '').replace(/\.lut$/, '');
      if (component && pageName) return pageName + ': ' + component;
      if (component) return component;
      if (pageName) return pageName;
      return null;
    }

    // Derive portal pill from cc._editorContext (already parsed from outer URL hash)
    function portalPillFromEditorContext() {
      var ctx = cc._editorContext;
      if (!ctx) return null;
      var pageLabels = {
        dtl: 'DTL Editor', rule: 'Rule Editor', bpl: 'BPL Editor',
        production: 'Production', schema: 'HL7 Schema', lookup: 'Lookup Table'
      };
      if (ctx.active && ctx.activeType) {
        var label = pageLabels[ctx.activeType] || ctx.activeType;
        return label + ': ' + ctx.active;
      }
      if (ctx.zenDetail && ctx.activeType) {
        return (pageLabels[ctx.activeType] || ctx.activeType) + ': ' + ctx.zenDetail;
      }
      if (ctx.zenPage) {
        var zenLabels = {
          MessageViewer: 'Message Viewer', VisualTrace: 'Visual Trace',
          EventLog: 'Event Log', LookupSettings: 'Lookup Table',
          ProductionConfig: 'Production'
        };
        return zenLabels[ctx.zenPage] || ctx.zenPage;
      }
      return null;
    }

    var _lastAnnouncedPill = null;

    function buildContextSentence(ctx, pill) {
      if (!pill) return null;
      var pageLabels = {
        dtl: 'DTL Editor', rule: 'Rule Editor', bpl: 'BPL Editor',
        production: 'Production Config', schema: 'HL7 Schema Browser', lookup: 'Lookup Table Editor',
        MessageViewer: 'Message Viewer', VisualTrace: 'Visual Trace',
        EventLog: 'Event Log', ProductionConfig: 'Production Config'
      };
      if (ctx && ctx.active && ctx.activeType) {
        var page = pageLabels[ctx.activeType] || ctx.activeType;
        return 'Currently viewing ' + page + ' — ' + ctx.active + '.';
      }
      if (ctx && ctx.zenPage) {
        var page2 = pageLabels[ctx.zenPage] || ctx.zenPage;
        return 'Currently viewing ' + page2 + '.';
      }
      return 'Currently viewing ' + pill + '.';
    }

    function refreshPortalPill() {
      if (cc.getEditorContext) cc.getEditorContext(); // re-parse URL
      _portalPill = portalPillFromEditorContext();
      renderContextPills();
      if (_portalPill !== _lastAnnouncedPill) {
        _lastAnnouncedPill = _portalPill;
      }
    }

    // Load from localStorage on init
    try {
      var saved = localStorage.getItem('interclaw-tree-selection');
      if (saved) updateContextIndicator(JSON.parse(saved));
    } catch(e) {}

    // Seed portal pill silently on init (no system message — user hasn't navigated).
    // The delayed retry handles the case where shell.js hasn't synced the hash yet.
    function seedPortalPill() {
      if (cc.getEditorContext) cc.getEditorContext();
      _portalPill = portalPillFromEditorContext();
      _lastAnnouncedPill = _portalPill; // suppress announcement on first seed
      renderContextPills();
    }
    seedPortalPill();
    setTimeout(seedPortalPill, 800);

    // Live updates from skills editor
    window.addEventListener('interclaw-tree-selection', function(e) {
      updateContextIndicator(e.detail || null);
    });

    // Live updates from portal iframe via shell.js postMessage bridge
    window.addEventListener('interclaw-shell-context', function(e) {
      var d = e.detail;
      if (!d) return;
      if (d.tab === 'portal' || d.tab === 'traces') {
        // Prefer the parsed zenPath from the iframe message; fall back to editorContext
        var pill = (d.context && d.context.zenPath) ? portalPillFromZenPath(d.context.zenPath) : null;
        _portalPill = pill || portalPillFromEditorContext();
        renderContextPills();
      }
    });

    // Update when outer URL hash changes (Angular / Zen navigation syncs hash)
    window.addEventListener('hashchange', refreshPortalPill);
    window.addEventListener('interclaw-namespace-change', refreshPortalPill);

    // Also listen on the parent window for shell-level navigation (Angular pushState)
    try {
      if (window.parent && window.parent !== window) {
        window.parent.addEventListener('hashchange', refreshPortalPill);
        window.parent.addEventListener('popstate', refreshPortalPill);
      }
    } catch(e) {}

    // Poll every 2s to catch Angular route changes that don't emit events
    setInterval(refreshPortalPill, 2000);

    // Watch h2.rule-name inside the rule editor iframe for rule switches
    var _ruleNameObserver = null;
    var _ruleNameEl = null;
    function getRuleDoc() {
      try {
        var shellDoc = (window.parent && window.parent !== window) ? window.parent.document : document;
        var pf = shellDoc.getElementById('shell-iframe-portal');
        if (!pf) return null;
        // Check viewer-frame first (legacy-ui wrapper)
        try {
          var vf = pf.contentDocument ? pf.contentDocument.getElementById('viewer-frame') : null;
          if (vf && vf.contentDocument && vf.contentDocument.querySelector('h2.rule-name')) {
            return vf.contentDocument;
          }
        } catch(e) {}
        // Fallback: rule editor loaded directly in portal iframe
        try {
          if (pf.contentDocument && pf.contentDocument.querySelector('h2.rule-name')) {
            return pf.contentDocument;
          }
        } catch(e) {}
      } catch(e) {}
      return null;
    }

    function attachRuleNameObserver() {
      try {
        var ruleDoc = getRuleDoc();
        if (!ruleDoc) {
          if (_ruleNameObserver) { _ruleNameObserver.disconnect(); _ruleNameObserver = null; _ruleNameEl = null; }
          return;
        }
        // Observe the parent of h2.rule-name so we catch Angular replacing the element.
        var h2 = ruleDoc.querySelector('h2.rule-name.ng-star-inserted') || ruleDoc.querySelector('h2.rule-name');
        var container = h2 ? h2.parentElement : ruleDoc.body;
        if (!container || container === _ruleNameEl) return;
        if (_ruleNameObserver) _ruleNameObserver.disconnect();
        _ruleNameEl = container;
        _ruleNameObserver = new MutationObserver(function() { refreshPortalPill(); });
        _ruleNameObserver.observe(container, { childList: true, subtree: true, characterData: true });
      } catch(e) {}
    }
    setInterval(attachRuleNameObserver, 1000);

    // Universal scroll-to-bottom. Any caller that changes the chat pane's
    // content (opening an existing chat, leaving chat mode for the portal,
    // etc.) can call cc.scrollChatToBottom() and the latest message lands
    // in view. Double-fires across rAF to catch late-rendered bubbles.
    cc.scrollChatToBottom = function() {
      var content = document.getElementById('chatbot-content');
      if (content) content.scrollTop = content.scrollHeight;
      requestAnimationFrame(function() {
        var c2 = document.getElementById('chatbot-content');
        if (c2) c2.scrollTop = c2.scrollHeight;
      });
    };
    // Shell tab change: park chat at the end whenever we're leaving it.
    window.addEventListener('interclaw-shell-tab-change', function(e) {
      if (!e.detail || !e.detail.tab) return;
      if (e.detail.tab === 'chat') return;
      cc.scrollChatToBottom();
    });
    // Opening an existing chat: scroll to bottom after the render settles.
    window.addEventListener('interclaw-chat-opened', function() {
      cc.scrollChatToBottom();
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
