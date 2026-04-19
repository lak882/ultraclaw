// shell.js — Top-level InterClaw shell controller.
//
// Responsibilities:
//   1. Resolve the active tab from the hash fragment (#tab=portal|traces|skills)
//      and set it as active. Default: portal.
//   2. Lazily assign src to each iframe on first activation, then keep the
//      iframe alive so state is preserved across tab switches.
//   3. Intercept header tab clicks so they switch the iframe instead of
//      navigating the top-level page. Update the hash fragment so reload
//      and bookmarking preserve the tab.
//   4. Forward active-context messages from iframes to the chatbot via
//      postMessage bridge.
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
  var loaded = {}; // tabId → boolean

  // ── Tab state ──
  function currentTabFromHash() {
    var h = window.location.hash || '';
    var m = h.match(/tab=(\w+)/);
    if (m && VALID_TABS[m[1]]) return m[1];
    return DEFAULT_TAB;
  }

  function setHash(tabId) {
    var target = '#tab=' + tabId;
    if (window.location.hash !== target) {
      // Use replaceState to avoid polluting history with every click.
      history.replaceState(null, '', window.location.pathname + window.location.search + target);
    }
  }

  function activateTab(tabId) {
    if (!VALID_TABS[tabId]) tabId = DEFAULT_TAB;

    // Lazy-load the iframe src on first activation.
    if (!loaded[tabId]) {
      var frame = document.getElementById('shell-iframe-' + tabId);
      if (frame) {
        frame.src = sources[tabId];
        loaded[tabId] = true;
      }
    }

    // Toggle the --active class.
    var frames = document.querySelectorAll('.shell-iframe');
    for (var i = 0; i < frames.length; i++) {
      frames[i].classList.toggle('shell-iframe--active', frames[i].dataset.tab === tabId);
    }

    // Sync the header tab highlight.
    syncHeaderTabs(tabId);

    // Broadcast to chatbot so its active-component state follows.
    if (window._cc) {
      window._cc.shellActiveTab = tabId;
    }
    window.dispatchEvent(new CustomEvent('interclaw-shell-tab-change', {
      detail: { tab: tabId }
    }));

    setHash(tabId);
  }

  function syncHeaderTabs(tabId) {
    var tabs = document.querySelectorAll('#interclaw-header .ic-header-tab');
    for (var i = 0; i < tabs.length; i++) {
      tabs[i].classList.toggle('active', tabs[i].dataset.tab === tabId);
    }
  }

  // ── Intercept header tab clicks ──
  // interclaw-header.js binds its own click handler, but the shell needs
  // tabs to switch iframes, not navigate away. We install a capture-phase
  // handler on the header nav so we run before the header's own handler.
  function installHeaderInterception() {
    var nav = document.querySelector('#interclaw-header .ic-header-tabs');
    if (!nav) {
      // Header may not be rendered yet — try again after microtask.
      setTimeout(installHeaderInterception, 50);
      return;
    }
    nav.addEventListener('click', function(e) {
      var tab = e.target.closest('.ic-header-tab');
      if (!tab) return;
      var tabId = tab.dataset.tab;
      // The 'chat' tab is handled by interclaw-header itself (expands the
      // chatbot sidebar) — let it pass through.
      if (tabId === 'chat') return;
      if (!VALID_TABS[tabId]) return;
      e.preventDefault();
      e.stopImmediatePropagation();
      activateTab(tabId);
    }, true);
  }

  // ── postMessage bridge: iframes → shell → chatbot ──
  // Iframes post { type: 'interclaw-context', tab, context } when their
  // active context changes (page load, selection, etc.). Same-origin, so
  // no origin check needed, but we validate the message shape.
  window.addEventListener('message', function(ev) {
    var data = ev.data;
    if (!data || typeof data !== 'object') return;
    if (data.type !== 'interclaw-context') return;
    // Expose to chatbot and any listeners.
    if (window._cc) {
      window._cc.shellIframeContext = window._cc.shellIframeContext || {};
      window._cc.shellIframeContext[data.tab] = data.context;
    }
    window.dispatchEvent(new CustomEvent('interclaw-shell-context', {
      detail: { tab: data.tab, context: data.context }
    }));
  });

  // ── Hash routing ──
  window.addEventListener('hashchange', function() {
    activateTab(currentTabFromHash());
  });

  // ── Auth gate ──
  // Workspace iframes (Portal / Traces / Skills) are frozen until the user
  // logs in via the chatbot (/login <user> <pass>). The chatbot itself stays
  // interactive so the login flow is reachable.
  //
  // The body class `shell-login-required` toggles the overlay + grey-out.
  // We refresh auth on boot, on window focus, on hash change (covers
  // back/forward nav), and whenever the chatbot dispatches the
  // `interclaw-auth-changed` event after a successful login/logout.
  function apiBase() {
    // Chatbot derives its API base from the URL path prefix:
    // page at /{prefix}/ui/interop/interclaw/... -> REST at /{prefix}/api/interclaw
    // Mirror the same resolution here.
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
      // On failure, fail closed — gate the workspace rather than leak access.
      console.warn('[shell] auth-status check failed:', e.message);
      applyAuthGate(false);
    }
  }

  window.addEventListener('focus', refreshAuth);
  window.addEventListener('interclaw-auth-changed', refreshAuth);

  // ── Boot ──
  function boot() {
    installHeaderInterception();
    activateTab(currentTabFromHash());
    refreshAuth();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
