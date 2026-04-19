// shell.js — Top-level InterClaw shell controller.
//
// Two iframes live under the shell header:
//   * portal  — the legacy-ui wrapper. Hosts BOTH the Portal (Production
//               Configuration) AND the Traces (Message Viewer / Visual Trace)
//               views. Clicking "Traces" navigates the same iframe; it does
//               not swap to a different iframe. This matches how the portal
//               has always worked — visual trace opens in place, back button
//               works, and the browser history inside the iframe stays intact.
//   * skills  — the standalone Skills Editor.
//
// The header's active-tab highlight is computed from the Portal iframe's
// current URL: if the zen path contains MessageViewer / VisualTrace, the
// "Traces" tab lights up, otherwise "Portal" does. Skills is its own tab.
(function() {
  'use strict';

  // tabId → iframe id. 'traces' is an alias that points at the portal iframe.
  // Keep the alias so /goto and other callers can still say "open this in
  // the traces tab" and land in the right place without knowing the merge.
  var TAB_TO_FRAME = {
    portal: 'shell-iframe-portal',
    traces: 'shell-iframe-portal',
    skills: 'shell-iframe-skills'
  };
  var DEFAULT_TAB = 'portal';

  function isValidTab(tabId) { return TAB_TO_FRAME.hasOwnProperty(tabId); }

  // ── Resolve namespace and path prefix (same logic as interclaw-header) ──
  function resolveNamespace() {
    var params = new URLSearchParams(window.location.search);
    var urlNs = params.get('$NAMESPACE') || params.get('NAMESPACE') || '';
    var cfg = window._interclawConfig || {};
    var installNs = (cfg.namespace || 'INTERCLAW').toUpperCase();
    return (urlNs || installNs).toUpperCase();
  }

  var namespace = resolveNamespace();
  var nsLower = namespace.toLowerCase();

  // ── Build iframe source URLs ──
  // Portal boots on ProductionConfig; clicking Traces will navigate the same
  // iframe to MessageViewer. Skills boots on the skills-editor.
  function buildSources() {
    var base = window.location.pathname.replace(/index\.html.*$/, '').replace(/\/+$/, '/') || '/';
    return {
      portal: {
        frameSrc: base + 'legacy-ui/index.html?$NAMESPACE=' + namespace + '&chrome=none'
                + '#/csp/healthshare/' + nsLower + '/EnsPortal.ProductionConfig.zen?$NAMESPACE=' + namespace,
        zenHash: '#/csp/healthshare/' + nsLower + '/EnsPortal.ProductionConfig.zen?$NAMESPACE=' + namespace
      },
      traces: {
        frameSrc: base + 'legacy-ui/index.html?$NAMESPACE=' + namespace + '&chrome=none'
                + '#/csp/healthshare/' + nsLower + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + namespace,
        zenHash: '#/csp/healthshare/' + nsLower + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + namespace
      },
      skills: {
        frameSrc: base + 'skills-editor/index.html?$NAMESPACE=' + namespace + '&chrome=none'
      }
    };
  }

  var sources = buildSources();
  var currentTab = DEFAULT_TAB;
  var legacyBase = sources.portal.frameSrc.split('#')[0]; // the wrapper URL sans zen hash

  // ── Eager iframe load ──
  // Preload both iframes. Portal comes up on ProductionConfig; Traces reuses
  // the same iframe (no separate preload needed).
  function preloadAllIframes() {
    var portal = document.getElementById('shell-iframe-portal');
    if (portal && !portal.src) portal.src = sources.portal.frameSrc;
    var skills = document.getElementById('shell-iframe-skills');
    if (skills && !skills.src) skills.src = sources.skills.frameSrc;
  }

  // Decide which tab is "active" based on the portal iframe's current URL.
  // MessageViewer / VisualTrace → traces; anything else zen → portal.
  function detectPortalTab() {
    var frame = document.getElementById('shell-iframe-portal');
    if (!frame) return 'portal';
    var href = '';
    try { href = frame.contentWindow.location.href || frame.src || ''; } catch (e) { href = frame.src || ''; }
    return (href.indexOf('MessageViewer') !== -1 || href.indexOf('VisualTrace') !== -1) ? 'traces' : 'portal';
  }

  function activateTab(tabId) {
    if (!isValidTab(tabId)) tabId = DEFAULT_TAB;
    currentTab = tabId;

    // Only two real frames. Show the one this tab maps to.
    var targetFrameId = TAB_TO_FRAME[tabId];
    var frames = document.querySelectorAll('.shell-iframe');
    for (var i = 0; i < frames.length; i++) {
      frames[i].classList.toggle('shell-iframe--active', frames[i].id === targetFrameId);
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

  // Navigate the Portal iframe to the given zen hash (e.g. MessageViewer or
  // a specific trace). Reused by the Traces tab click and by /goto.
  function navigatePortalIframe(zenHash) {
    var frame = document.getElementById('shell-iframe-portal');
    if (!frame) return false;
    var target = legacyBase + (zenHash.indexOf('#') === 0 ? zenHash : '#' + zenHash);
    // Setting .src always forces a reload. Prefer in-place hash navigation
    // so the legacy-ui wrapper's hashchange listener picks it up without a
    // full frame reboot (keeps Zen session state).
    try {
      var currentSrc = frame.contentWindow.location.href;
      // If the wrapper is already loaded, just poke the hash — legacy-ui
      // listens for hashchange and swaps its inner viewer-frame. If the
      // wrapper isn't loaded yet, fall back to setting src.
      if (currentSrc && currentSrc.indexOf(legacyBase) === 0) {
        frame.contentWindow.location.hash = zenHash;
        return true;
      }
    } catch (e) { /* cross-origin or not loaded yet — fall through */ }
    frame.src = target;
    return true;
  }

  // ── Intercept header tab clicks (window capture) ──
  window.addEventListener('click', function(e) {
    var tab = e.target.closest && e.target.closest('.ic-header-tab');
    if (!tab) return;
    var tabId = tab.dataset.tab;
    if (tabId === 'chat') return; // chat tab handled by interclaw-header
    if (!isValidTab(tabId)) return;
    e.preventDefault();
    e.stopImmediatePropagation();

    if (tabId === 'traces') {
      // Traces reuses the portal iframe — navigate it to MessageViewer and
      // activate 'traces' so the tab lights up.
      navigatePortalIframe(sources.traces.zenHash);
      activateTab('traces');
    } else if (tabId === 'portal') {
      // Only switch the iframe to ProductionConfig if we're coming from
      // Traces — otherwise let the user stay on whatever zen page they've
      // navigated to within the portal.
      var current = detectPortalTab();
      if (current === 'traces') navigatePortalIframe(sources.portal.zenHash);
      activateTab('portal');
    } else {
      activateTab(tabId);
    }
  }, true);

  // ── Public API for chatbot /goto ──
  window._interclawShell = {
    activateTab: activateTab,
    openInTab: function(tabId, url) {
      if (!isValidTab(tabId) || !url) return false;
      if (tabId === 'portal' || tabId === 'traces') {
        // `url` is expected to be a full legacy-ui URL (...legacy-ui/index.html#/csp/...).
        // Extract the zen hash and navigate the portal iframe in place.
        var hashIdx = url.indexOf('#');
        var zenHash = hashIdx !== -1 ? url.substring(hashIdx) : url;
        navigatePortalIframe(zenHash);
        activateTab(tabId);
        return true;
      }
      // Skills: set the iframe src directly.
      var frame = document.getElementById(TAB_TO_FRAME[tabId]);
      if (!frame) return false;
      frame.src = url;
      activateTab(tabId);
      return true;
    },
    currentTab: function() { return currentTab; }
  };

  // ── postMessage bridge: iframes → shell → chatbot ──
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
    // Portal iframe broadcasts its zen context as tab='portal' or tab='traces'
    // depending on the zen page loaded. Use that to keep the tab highlight in
    // sync with what the user is actually looking at.
    if (data.tab === 'portal' || data.tab === 'traces') {
      if (currentTab === 'portal' || currentTab === 'traces') {
        if (currentTab !== data.tab) syncHeaderTabs(data.tab);
        currentTab = data.tab;
      }
    }
  });

  // ── Auth gate ──
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
  // Outer URL shape: #/<tab>[<inner-hash-without-leading-slash>]?NAMESPACE=<ns>
  //   #/chat?NAMESPACE=INTERCLAW
  //   #/portal/csp/.../EnsPortal.ProductionConfig.zen?$NAMESPACE=INTERCLAW
  //   #/traces/csp/.../EnsPortal.MessageViewer.zen?$NAMESPACE=INTERCLAW
  //   #/skills?NAMESPACE=INTERCLAW
  function buildOuterHash(tabId, innerHash) {
    var h = '#/' + tabId;
    if (innerHash && innerHash.indexOf('#') === 0) innerHash = innerHash.substring(1);
    if (innerHash) h += innerHash;
    if (h.indexOf('NAMESPACE=') === -1) {
      h += (h.indexOf('?') !== -1 ? '&' : '?') + 'NAMESPACE=' + namespace;
    }
    return h;
  }

  var syncTimer = null;
  function syncOuterHashFromIframe() {
    clearTimeout(syncTimer);
    syncTimer = setTimeout(function() {
      var innerHash = '';
      if (currentTab === 'portal' || currentTab === 'traces') {
        // Re-derive tab from the iframe URL so deep state like VisualTrace
        // sub-pages end up with the right tab name in the outer URL.
        var detected = detectPortalTab();
        if (detected !== currentTab) {
          currentTab = detected;
          syncHeaderTabs(currentTab);
        }
        var frame = document.getElementById('shell-iframe-portal');
        if (frame && frame.contentWindow) {
          try { innerHash = frame.contentWindow.location.hash || ''; } catch (e) {}
        }
      } else if (currentTab === 'skills') {
        innerHash = ''; // skills has no meaningful zen hash
      }
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
          // Always sync when the portal iframe reloads — its zen hash might
          // have changed. Skills loads once.
          syncOuterHashFromIframe();
          try {
            frame.contentWindow.addEventListener('hashchange', function() {
              syncOuterHashFromIframe();
            });
          } catch (e) {}
        });
      })(frames[i]);
    }
  }

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
  //   Legacy bare `#/csp/...` → infer portal or traces.
  function restoreFromOuterHash() {
    var h = window.location.hash || '';
    if (!h) return false;

    if (h.indexOf('#/csp/') === 0 || h.indexOf('#/ui/') === 0) {
      var inferred = (h.indexOf('MessageViewer') !== -1 || h.indexOf('VisualTrace') !== -1) ? 'traces' : 'portal';
      var portalFrame = document.getElementById('shell-iframe-portal');
      if (portalFrame) {
        portalFrame.src = legacyBase + h;
        activateTab(inferred);
        return true;
      }
    }

    var m = h.match(/^#\/(chat|portal|traces|skills)(.*)$/);
    if (!m) return false;
    var tabId = m[1];
    var rest = m[2] || '';

    if (tabId === 'chat') {
      activateTab(DEFAULT_TAB);
      document.body.classList.add('ic-chat-mode');
      return true;
    }

    if (tabId === 'skills') {
      activateTab('skills');
      return true;
    }

    // portal or traces: portal iframe gets the zen hash.
    var portalFrame = document.getElementById('shell-iframe-portal');
    if (!portalFrame) return false;
    if (rest) {
      portalFrame.src = legacyBase + '#' + rest;
    } else {
      portalFrame.src = (tabId === 'traces' ? sources.traces : sources.portal).frameSrc;
    }
    activateTab(tabId);
    return true;
  }

  // ── Boot ──
  function boot() {
    preloadAllIframes();
    wireIframeHashSync();
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
