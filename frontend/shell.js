// shell.js — Top-level InterClaw shell controller.
//
// Responsibilities:
//   1. Eagerly load all three workspace iframes (portal / traces / skills)
//      so they exist and keep their state across tab switches.
//   2. Intercept header tab clicks at the window capture phase so they
//      switch the active iframe instead of navigating the top-level page.
//   3. Expose `window._interclawShell.openInTab(tabId, url)` so the chatbot's
//      /goto can target the correct iframe (portal/traces) instead of
//      opening new tabs.
//   4. Gate the workspace behind IRIS login and forward iframe context to
//      the chatbot via postMessage.
(function() {
  'use strict';

  var DEFAULT_TAB = 'portal';
  var VALID_TABS = { portal: 1, traces: 1, skills: 1 };

  // ── Resolve namespace and path prefix (same logic as interclaw-header) ──
  function resolveNamespace() {
    var params = new URLSearchParams(window.location.search);
    var urlNs = params.get('$NAMESPACE') || params.get('NAMESPACE') || '';
    var cfg = window._interclawConfig || {};
    var installNs = (cfg.namespace || 'INTERCLAW').toUpperCase();
    return (urlNs || installNs).toUpperCase();
  }

  function resolvePathPrefix() {
    var parts = window.location.pathname.split('/ui/interop/');
    return parts[0] || '';
  }

  var namespace = resolveNamespace();
  var pathPrefix = resolvePathPrefix();
  var nsLower = namespace.toLowerCase();

  // ── Build iframe source URLs ──
  // All three use chrome=none so they skip their own header and chatbot
  // injection — those live in the shell instead.
  function buildSources() {
    var base = window.location.pathname.replace(/index\.html.*$/, '').replace(/\/+$/, '/') || '/';
    return {
      portal: base + 'legacy-ui/index.html?$NAMESPACE=' + namespace + '&chrome=none'
            + '#/csp/healthshare/' + nsLower + '/EnsPortal.ProductionConfig.zen?$NAMESPACE=' + namespace,
      traces: base + 'legacy-ui/index.html?$NAMESPACE=' + namespace + '&chrome=none'
            + '#/csp/healthshare/' + nsLower + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + namespace,
      skills: base + 'skills-editor/index.html?$NAMESPACE=' + namespace + '&chrome=none'
    };
  }

  var sources = buildSources();
  var currentTab = DEFAULT_TAB;

  // ── Eager iframe load ──
  // Previously lazy. A lazy frame means the first click on a tab has to wait
  // for the whole page to boot inside the iframe before anything shows. Worse,
  // if the click handler ever fails to intercept (e.g. a race during header
  // render), the header's `<a href>` fires and navigates the top window —
  // the user sees the full standalone editor instead of the iframe. Eagerly
  // loading all three guarantees the iframe content is always the thing
  // visible when a tab is active, even if something else goes wrong.
  function preloadAllIframes() {
    Object.keys(sources).forEach(function(tabId) {
      var frame = document.getElementById('shell-iframe-' + tabId);
      if (frame && !frame.src) frame.src = sources[tabId];
    });
  }

  function activateTab(tabId) {
    if (!VALID_TABS[tabId]) tabId = DEFAULT_TAB;
    currentTab = tabId;

    var frames = document.querySelectorAll('.shell-iframe');
    for (var i = 0; i < frames.length; i++) {
      frames[i].classList.toggle('shell-iframe--active', frames[i].dataset.tab === tabId);
    }

    syncHeaderTabs(tabId);

    if (window._cc) {
      window._cc.shellActiveTab = tabId;
    }
    window.dispatchEvent(new CustomEvent('interclaw-shell-tab-change', {
      detail: { tab: tabId }
    }));
  }

  function syncHeaderTabs(tabId) {
    var tabs = document.querySelectorAll('#interclaw-header .ic-header-tab');
    for (var i = 0; i < tabs.length; i++) {
      tabs[i].classList.toggle('active', tabs[i].dataset.tab === tabId);
    }
  }

  // ── Intercept header tab clicks (window capture) ──
  // Attaching on `window` with capture:true means our handler runs before
  // any descendant handler regardless of when the header element is
  // rendered. This avoids the timing race the previous `setTimeout` retry
  // loop was papering over.
  window.addEventListener('click', function(e) {
    var tab = e.target.closest && e.target.closest('.ic-header-tab');
    if (!tab) return;
    var tabId = tab.dataset.tab;
    if (tabId === 'chat') return; // chat tab handled by interclaw-header
    if (!VALID_TABS[tabId]) return;
    e.preventDefault();
    e.stopImmediatePropagation();
    activateTab(tabId);
  }, true);

  // ── Public API for chatbot /goto ──
  // The chatbot resolves a class or portal page to a URL and needs to land
  // that URL inside the correct iframe. `openInTab` is the single entry
  // point: tabId is 'portal', 'traces', or 'skills'; url is the full URL
  // to load into that iframe. Returns true if the navigation was applied.
  window._interclawShell = {
    activateTab: activateTab,
    openInTab: function(tabId, url) {
      if (!VALID_TABS[tabId] || !url) return false;
      var frame = document.getElementById('shell-iframe-' + tabId);
      if (!frame) return false;
      // Always set src — even if the URL matches. A direct re-set forces
      // the iframe to reload, which is what the user expects from /goto.
      frame.src = url;
      activateTab(tabId);
      return true;
    },
    currentTab: function() { return currentTab; }
  };

  // ── postMessage bridge: iframes → shell → chatbot ──
  // Iframes post { type: 'interclaw-context', tab, context } when their
  // active context changes (page load, selection, etc.). Same-origin, so
  // no origin check needed, but we validate the message shape.
  window.addEventListener('message', function(ev) {
    var data = ev.data;
    if (!data || typeof data !== 'object') return;
    if (data.type !== 'interclaw-context') return;
    if (window._cc) {
      window._cc.shellIframeContext = window._cc.shellIframeContext || {};
      window._cc.shellIframeContext[data.tab] = data.context;
    }
    window.dispatchEvent(new CustomEvent('interclaw-shell-context', {
      detail: { tab: data.tab, context: data.context }
    }));
  });

  // ── Auth gate ──
  // Workspace iframes are frozen (pointer-events off, greyed out) until
  // the user logs in via the chatbot (/login <user> <pass>). The chatbot
  // itself stays interactive so the login flow is reachable.
  function apiBase() {
    var m = window.location.pathname.match(/^(\/[^/]+)\/ui\/interop\/(?:interclaw|cc)\//);
    return m ? m[1] + '/api/interclaw' : '/api/interclaw';
  }

  var authGateApplied = null;
  function applyAuthGate(loggedIn) {
    if (authGateApplied === loggedIn) return;
    authGateApplied = loggedIn;
    document.body.classList.toggle('shell-login-required', !loggedIn);
    var overlay = document.getElementById('shell-auth-overlay');
    if (overlay) overlay.setAttribute('aria-hidden', loggedIn ? 'true' : 'false');
  }

  async function refreshAuth() {
    try {
      var resp = await fetch(apiBase() + '/api/auth-status', {
        credentials: 'same-origin',
        signal: AbortSignal.timeout(5000),
      });
      if (!resp.ok) throw new Error('auth-status HTTP ' + resp.status);
      var data = await resp.json();
      applyAuthGate(!!data.logged_in);
    } catch (e) {
      console.warn('[shell] auth-status check failed:', e.message);
      applyAuthGate(false);
    }
  }

  window.addEventListener('focus', refreshAuth);
  window.addEventListener('interclaw-auth-changed', refreshAuth);

  // ── Hash sync: iframe hash → outer window URL ──
  // Format: #/<tab>[<inner-hash-without-leading-slash>]?NAMESPACE=<ns>
  // Examples:
  //   #/chat?NAMESPACE=INTERCLAW
  //   #/portal/csp/healthshare/interclaw/EnsPortal.ProductionConfig.zen?$NAMESPACE=INTERCLAW
  //   #/traces/csp/healthshare/interclaw/EnsPortal.MessageViewer.zen?$NAMESPACE=INTERCLAW
  //   #/skills?NAMESPACE=INTERCLAW
  function buildOuterHash(tabId, innerHash) {
    var h = '#/' + tabId;
    // innerHash begins with `#/csp/...` or `#/ui/...`; strip the `#`.
    if (innerHash && innerHash.indexOf('#') === 0) innerHash = innerHash.substring(1);
    if (innerHash) h += innerHash;
    // Ensure a trailing NAMESPACE so deep links carry it through.
    if (h.indexOf('NAMESPACE=') === -1) {
      h += (h.indexOf('?') !== -1 ? '&' : '?') + 'NAMESPACE=' + namespace;
    }
    return h;
  }

  var syncTimer = null;
  function syncOuterHashFromIframe() {
    clearTimeout(syncTimer);
    syncTimer = setTimeout(function() {
      var frame = document.getElementById('shell-iframe-' + currentTab);
      var innerHash = '';
      if (frame && frame.contentWindow) {
        try { innerHash = frame.contentWindow.location.hash || ''; } catch (e) {}
      }
      // Skills tab has no meaningful inner zen hash.
      if (currentTab === 'skills') innerHash = '';
      var outerHash = buildOuterHash(currentTab, innerHash);
      if (window.location.hash !== outerHash) {
        history.replaceState(null, '', window.location.pathname + window.location.search + outerHash);
      }
    }, 120);
  }

  function wireIframeHashSync() {
    var frames = document.querySelectorAll('.shell-iframe');
    for (var i = 0; i < frames.length; i++) {
      (function(frame) {
        frame.addEventListener('load', function() {
          if (frame.dataset.tab === currentTab) syncOuterHashFromIframe();
          try {
            frame.contentWindow.addEventListener('hashchange', function() {
              if (frame.dataset.tab === currentTab) syncOuterHashFromIframe();
            });
          } catch (e) {}
        });
      })(frames[i]);
    }
  }

  // Wrap activateTab so every tab switch writes the outer hash too.
  var _innerActivateTab = activateTab;
  activateTab = function(tabId) {
    _innerActivateTab(tabId);
    syncOuterHashFromIframe();
  };

  // ── Restore iframe hash from outer URL on load ──
  // Accepted forms:
  //   #/chat[?NAMESPACE=...]
  //   #/portal[/csp/.../EnsPortal....][?$NAMESPACE=...]
  //   #/traces[/csp/.../EnsPortal.MessageViewer.zen][?$NAMESPACE=...]
  //   #/skills[?NAMESPACE=...]
  // Legacy bare `#/csp/...` also still works (inferred → portal or traces).
  function restoreFromOuterHash() {
    var h = window.location.hash || '';
    if (!h) return false;

    // Legacy: bare zen path.
    if (h.indexOf('#/csp/') === 0 || h.indexOf('#/ui/') === 0) {
      var legacyTab = (h.indexOf('MessageViewer') !== -1 || h.indexOf('VisualTrace') !== -1) ? 'traces' : 'portal';
      var lframe = document.getElementById('shell-iframe-' + legacyTab);
      if (lframe) {
        lframe.src = sources[legacyTab].split('#')[0] + h;
        activateTab(legacyTab);
        return true;
      }
    }

    // New form: #/<tab>[<inner>]
    var m = h.match(/^#\/(chat|portal|traces|skills)(.*)$/);
    if (!m) return false;
    var tabId = m[1];
    var rest = m[2] || '';

    if (tabId === 'chat') {
      // Chat tab is handled by interclaw-header's ic-chat-mode toggle; we
      // just activate the portal iframe underneath as a background, set
      // the body class, and let the chatbot panel expand.
      activateTab(DEFAULT_TAB);
      document.body.classList.add('ic-chat-mode');
      return true;
    }

    if (!VALID_TABS[tabId]) return false;

    // Everything after the tab name is the inner hash — prepend `#`.
    var frame = document.getElementById('shell-iframe-' + tabId);
    if (!frame) return false;
    var base = sources[tabId].split('#')[0];
    if (rest) {
      frame.src = base + '#' + rest;
    } else {
      frame.src = sources[tabId];
    }
    activateTab(tabId);
    return true;
  }

  // ── Boot ──
  function boot() {
    preloadAllIframes();
    wireIframeHashSync();
    // If the user loaded a deep link (/index.html#portal:/csp/...), restore
    // the target tab + iframe hash before the default activateTab fires.
    var restored = restoreFromOuterHash();
    if (!restored) activateTab(DEFAULT_TAB);
    refreshAuth();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
