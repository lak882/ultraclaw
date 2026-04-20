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
        frameSrc: base + 'legacy-ui/index.html?$NAMESPACE=' + namespace + '&chrome=none&v=2'
                + '#/csp/healthshare/' + nsLower + '/EnsPortal.ProductionConfig.zen?$NAMESPACE=' + namespace,
        zenHash: '#/csp/healthshare/' + nsLower + '/EnsPortal.ProductionConfig.zen?$NAMESPACE=' + namespace
      },
      traces: {
        frameSrc: base + 'legacy-ui/index.html?$NAMESPACE=' + namespace + '&chrome=none&v=2'
                + '#/csp/healthshare/' + nsLower + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + namespace,
        zenHash: '#/csp/healthshare/' + nsLower + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + namespace
      },
      skills: {
        // Cache-bust v: bump when skills-editor/index.html changes so the
        // iframe doesn't serve a stale copy out of the disk cache after a
        // deploy. The browser keyed cache on URL so this is the only knob.
        frameSrc: base + 'skills-editor/index.html?$NAMESPACE=' + namespace + '&chrome=none&v=9'
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

    // Clicking a workspace tab must exit chat mode — the header owns that
    // class toggle, but stopImmediatePropagation above keeps its handler
    // from running. We have to do it here or the user stays in expanded
    // chat view even though the URL says they're on Portal/Traces/Skills.
    document.body.classList.remove('ic-chat-mode');

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
    currentTab: function() { return currentTab; },

    // Refresh only the currently-active editor iframe. Used by the chatbot
    // /reload handler so a reload directive no longer blows away the shell
    // chrome (sidebar, header, chat pane) — it just re-fetches whatever
    // the user is looking at inside the iframe. Falls back to a plain
    // `src` reset if the cross-origin hash nudge isn't available.
    reloadActiveFrame: function() {
      var frameId = TAB_TO_FRAME[currentTab] || TAB_TO_FRAME[DEFAULT_TAB];
      var frame = document.getElementById(frameId);
      if (!frame) return false;
      try {
        if (frame.contentWindow && frame.contentWindow.location) {
          frame.contentWindow.location.reload();
          return true;
        }
      } catch (e) { /* cross-origin or unavailable — fall through */ }
      var src = frame.src;
      frame.src = 'about:blank';
      setTimeout(function() { frame.src = src; }, 0);
      return true;
    }
  };

  // ── Namespace change: update outer URL + reload Portal/Skills iframes ──
  // When the user picks a different namespace in the header dropdown (or
  // Angular internally switches namespaces), three things need to happen:
  //   (a) The outer URL should reflect the new namespace so reloading the
  //       tab or sharing the URL lands in the right place.
  //   (b) The Portal iframe must reload against the new namespace, ideally
  //       keeping whatever zen page the user was on (just swapping the NS
  //       in the path + query, not jumping back to ProductionConfig).
  //   (c) The Skills iframe must reload so its file tree reflects the new
  //       namespace.
  //
  // Without this, interclaw-header.js only updated the label and tab hrefs —
  // the user picked a new NS and nothing below the header actually changed.
  function swapNamespaceInUrl(url, newNs) {
    if (!url) return url;
    var lower = newNs.toLowerCase();
    url = url.replace(/(\$NAMESPACE=)[^&#]*/g, '$1' + newNs);
    url = url.replace(/(\bNAMESPACE=)[^&#]*/g, '$1' + newNs);
    url = url.replace(/(\/csp\/healthshare\/)[^\/?#]+/g, '$1' + lower);
    return url;
  }

  window.addEventListener('interclaw-namespace-change', function(e) {
    if (!e.detail || !e.detail.namespace) return;
    var newNs = e.detail.namespace.toUpperCase();
    if (newNs === namespace) return;
    namespace = newNs;
    nsLower = namespace.toLowerCase();
    sources = buildSources();
    legacyBase = sources.portal.frameSrc.split('#')[0];

    // Outer URL is driven by syncOuterHashFromIframe — it will pick up the
    // iframe's new zen hash on load and rewrite the outer hash. We don't
    // write the NS into the outer ?search because the inner zen hash
    // carries it natively and duplicating creates drift bugs.

    // (b) Portal iframe: swap NS in the current frame URL so the user stays
    // on whatever zen page they were viewing, just pointed at the new NS.
    // Fall back to the default ProductionConfig / MessageViewer URL if the
    // current src is empty or cross-origin.
    var portalFrame = document.getElementById('shell-iframe-portal');
    if (portalFrame) {
      var currentSrc = portalFrame.src || '';
      var newSrc = currentSrc ? swapNamespaceInUrl(currentSrc, namespace) : '';
      if (!newSrc || newSrc === currentSrc) {
        newSrc = (currentTab === 'traces') ? sources.traces.frameSrc : sources.portal.frameSrc;
      }
      // Force an actual reload — assigning the same-origin src with a changed
      // query triggers reload, but belt-and-braces the case where only a hash
      // differs (browsers skip reload on hash-only changes).
      if (newSrc === currentSrc) {
        portalFrame.src = 'about:blank';
        setTimeout(function() { portalFrame.src = newSrc; }, 0);
      } else {
        portalFrame.src = newSrc;
      }
    }

    // (c) Skills iframe: reload against the new namespace.
    var skillsFrame = document.getElementById('shell-iframe-skills');
    if (skillsFrame) skillsFrame.src = sources.skills.frameSrc;
  });

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
    // For the Skills tab: the iframe already wrote the full selection to
    // same-origin localStorage (including file content). Re-dispatch the
    // `interclaw-tree-selection` event on THIS window so the chatbot's
    // init.js listener, which only hears events in the parent frame,
    // updates its context-indicator pill. send.js still reads the content
    // from localStorage at send time.
    if (data.tab === 'skills' && data.context) {
      window.dispatchEvent(new CustomEvent('interclaw-tree-selection', {
        detail: data.context
      }));
    }
    // Portal iframe broadcasts its zen context as tab='portal' or tab='traces'
    // depending on the zen page loaded. Use that to keep the tab highlight in
    // sync with what the user is actually looking at.
    if (data.tab === 'portal' || data.tab === 'traces') {
      if (currentTab === 'portal' || currentTab === 'traces') {
        if (currentTab !== data.tab) syncHeaderTabs(data.tab);
        currentTab = data.tab;
      }
    }

    // Reverse namespace sync: the portal iframe tells us which NS it's
    // currently on (Angular may have internally switched). If that differs
    // from what the shell + header think, update the header label and the
    // outer URL — but do NOT reload the iframe (it's already on the new NS;
    // reloading would loop).
    if (data.context && data.context.namespace) {
      var iframeNs = String(data.context.namespace).toUpperCase();
      if (iframeNs && iframeNs !== namespace && /^[A-Z][A-Z0-9_-]*$/.test(iframeNs)) {
        namespace = iframeNs;
        nsLower = namespace.toLowerCase();
        sources = buildSources();
        legacyBase = sources.portal.frameSrc.split('#')[0];

        // Header label + tab hrefs (interclaw-header.js:724 listens for this).
        window.dispatchEvent(new CustomEvent('interclaw-namespace-silent', {
          detail: { namespace: namespace }
        }));

        // Update header label directly since we're skipping the main
        // namespace-change listener (which would trigger a reload loop).
        var nsEl = document.getElementById('ic-header-ns-label');
        if (nsEl) nsEl.textContent = namespace;
        if (window._cc) {
          window._cc.currentNamespace = namespace;
          window._cc._apiNamespace = namespace;
        }
        try { sessionStorage.setItem('interclaw-namespace', namespace); } catch(e) {}

        // Outer URL: let syncOuterHashFromIframe rebuild it from the
        // iframe's current zen hash (no separate $NAMESPACE= overlay).
        syncOuterHashFromIframe();

        // Rewrite every workspace tab href so switching tabs lands on the
        // new NS instead of the old one.
        var tabLinks = document.querySelectorAll('#interclaw-header .ic-header-tab');
        for (var i = 0; i < tabLinks.length; i++) {
          var href = tabLinks[i].getAttribute('href');
          if (href) {
            href = swapNamespaceInUrl(href, namespace);
            tabLinks[i].setAttribute('href', href);
          }
        }
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
  //   #/portal/csp/.../EnsPortal.MessageViewer.zen?$NAMESPACE=INTERCLAW   (Traces)
  //   #/skills?NAMESPACE=INTERCLAW
  // 'traces' is not a URL-level tab — it's a Zen page inside /portal.
  // The header highlight still shows "Traces" when the portal iframe is on
  // MessageViewer/VisualTrace, but the outer URL stays on /portal.
  function stripChatFromHash(h) {
    if (!h) return '';
    var qIdx = h.indexOf('?');
    if (qIdx === -1) return h;
    var before = h.substring(0, qIdx);
    var parts = h.substring(qIdx + 1).split('&').filter(function(p) {
      return p && p.indexOf('chat=') !== 0;
    });
    return parts.length ? before + '?' + parts.join('&') : before;
  }

  function buildOuterHash(tabId, innerHash) {
    // Collapse the traces alias for URL purposes.
    var outerTab = (tabId === 'traces') ? 'portal' : tabId;
    var h = '#/' + outerTab;
    if (innerHash && innerHash.indexOf('#') === 0) innerHash = innerHash.substring(1);
    if (innerHash) h += innerHash;
    // Strip any stray `chat=` that may have leaked in from the iframe
    // hash (or a previous buildOuterHash pass). Then append exactly one
    // if we have a session. Belt-and-suspenders: on every call the URL
    // ends up with at most one chat param.
    h = stripChatFromHash(h);
    var chatId = window._cc && window._cc.sessionId;
    if (chatId && outerTab !== 'chat') {
      var sep = h.indexOf('?') !== -1 ? '&' : '?';
      h += sep + 'chat=' + encodeURIComponent(chatId);
    }
    return h;
  }

  var syncTimer = null;
  function syncOuterHashFromIframe() {
    clearTimeout(syncTimer);
    syncTimer = setTimeout(function() {
      // Chat mode owns the URL — keep it at `#/chat?NAMESPACE=…` and
      // ignore any iframe hashchanges that would otherwise rewrite it
      // to `#/portal/…` (the portal iframe stays mounted behind the
      // chat but its hash must not leak into the outer URL).
      if (document.body.classList.contains('ic-chat-mode')) {
        // Preserve any chat id the chatbot appended as `#/chat/<id>` —
        // don't collapse back to `#/chat` and wipe the deep-link state.
        var currentHash = window.location.hash || '';
        var keep = /^#\/chat(?:\/[^?]+)?/.test(currentHash) ? currentHash : '#/chat';
        if (window.location.hash !== keep) {
          history.replaceState(null, '', window.location.pathname + window.location.search + keep);
        }
        return;
      }
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

  // ── Portal iframe URL watcher ──
  // We used to detect the active namespace by scraping `fr-topbar` and
  // poking fetch/XHR, but the only thing the shell really needs is the
  // iframe's CURRENT URL. Mirror that URL straight into the outer hash,
  // derive the namespace from the mirrored URL. Works for Angular SPA
  // navigation, zen hash changes, cross-NS links, SMP switcher — all of
  // them change the iframe's location.
  var _lastMirroredIframeUrl = null;

  function readPortalIframeUrl() {
    var frame = document.getElementById('shell-iframe-portal');
    if (!frame || !frame.contentWindow) return null;
    try {
      var iwin = frame.contentWindow;
      // iwin.location.href points at the actual current page (which may be
      // the legacy-ui wrapper OR, when window.open forwarded into the iframe,
      // the wrapped zen page directly).
      return iwin.location.pathname + iwin.location.search + iwin.location.hash;
    } catch (e) { return null; /* cross-origin */ }
  }

  function mirrorPortalUrlToOuter() {
    if (document.body.classList.contains('ic-chat-mode')) return;
    if (currentTab !== 'portal' && currentTab !== 'traces') return;
    var iframePath = readPortalIframeUrl();
    if (!iframePath) return;
    if (iframePath === _lastMirroredIframeUrl) return;
    _lastMirroredIframeUrl = iframePath;

    // Trim the legacy-ui wrapper prefix (we only want the zen/csp part).
    // The wrapper loads `/path/to/legacy-ui/index.html?chrome=none#/csp/...`
    // so iwin.location.pathname points at legacy-ui/index.html itself,
    // and the actual zen path lives in the hash. But the iframe CAN also
    // navigate to a zen page directly (see window.open override), in which
    // case the path IS /csp/... and the hash is the zen page's own hash.
    var outerHash;
    var hashIdx = iframePath.indexOf('#');
    var pathPart = hashIdx === -1 ? iframePath : iframePath.substring(0, hashIdx);
    var hashPart = hashIdx === -1 ? '' : iframePath.substring(hashIdx + 1);

    if (pathPart.indexOf('/legacy-ui/') !== -1 && hashPart) {
      // Normal wrapper case — the zen URL is in the hash.
      // Strip pathPrefix so the outer hash is `/csp/healthshare/...`.
      var displayPath = hashPart;
      if (displayPath.charAt(0) !== '/') displayPath = '/' + displayPath;
      // strip pathPrefix if present
      var pfxMatch = window.location.pathname.match(/^(\/[^/]+)\/ui\/interop\//);
      var pfx = pfxMatch ? pfxMatch[1] : '';
      if (pfx && displayPath.indexOf(pfx + '/') === 0) {
        displayPath = displayPath.substring(pfx.length);
      }
      try { displayPath = decodeURIComponent(displayPath); } catch (_) {}
      outerHash = '#/portal' + displayPath;
    } else if (pathPart.indexOf('/csp/') !== -1) {
      // Iframe landed directly on a /csp/ URL (e.g. SMP navigation).
      var direct = pathPart + (hashPart ? '#' + hashPart : '');
      var pfxMatch2 = window.location.pathname.match(/^(\/[^/]+)\/ui\/interop\//);
      var pfx2 = pfxMatch2 ? pfxMatch2[1] : '';
      if (pfx2 && direct.indexOf(pfx2 + '/') === 0) direct = direct.substring(pfx2.length);
      try { direct = decodeURIComponent(direct); } catch (_) {}
      outerHash = '#/portal' + direct;
    } else {
      // Unknown iframe state — fall through without rewriting.
      return;
    }

    // Guard: never mirror a URL that would make the shell load itself as
    // the inner page (which produces "InterClaw within InterClaw" on a
    // subsequent reload). Only `/portal/csp/...` is a valid zen target.
    if (!/^#\/portal\/csp\//.test(outerHash)) return;

    // Preserve any `&chat=<id>` suffix the chatbot wrote to the outer hash —
    // otherwise the iframe's zen-URL mirror would wipe the chat id and
    // reloads would start a fresh chat.
    var prevHash = window.location.hash || '';
    var prevChatMatch = prevHash.match(/[?&]chat=([^&]+)/);
    if (prevChatMatch && prevChatMatch[1] && outerHash.indexOf('chat=') === -1) {
      var sep = outerHash.indexOf('?') !== -1 ? '&' : '?';
      outerHash += sep + 'chat=' + prevChatMatch[1];
    }

    if (window.location.hash !== outerHash) {
      history.replaceState(null, '', window.location.pathname + window.location.search + outerHash);
    }

    // Derive namespace from the mirrored URL so the header label follows.
    var nsMatch = outerHash.match(/\/csp\/healthshare\/([^\/?#]+)/i);
    var qMatch = outerHash.match(/\$?NAMESPACE=([^&#]+)/i);
    var detectedNs = (nsMatch && nsMatch[1]) || (qMatch && qMatch[1]);
    if (detectedNs) {
      var nsUp = decodeURIComponent(detectedNs).toUpperCase();
      if (/^[A-Z][A-Z0-9_-]*$/.test(nsUp) && nsUp !== namespace) {
        namespace = nsUp;
        nsLower = namespace.toLowerCase();
        sources = buildSources();
        legacyBase = sources.portal.frameSrc.split('#')[0];
        var nsEl = document.getElementById('ic-header-ns-label');
        if (nsEl) nsEl.textContent = namespace;
        if (window._cc) {
          window._cc.currentNamespace = namespace;
          window._cc._apiNamespace = namespace;
        }
        try { sessionStorage.setItem('interclaw-namespace', namespace); } catch(_) {}
        var tabLinks = document.querySelectorAll('#interclaw-header .ic-header-tab');
        for (var i = 0; i < tabLinks.length; i++) {
          var href = tabLinks[i].getAttribute('href');
          if (href) tabLinks[i].setAttribute('href', swapNamespaceInUrl(href, namespace));
        }
      }
    }
  }

  // Fire on iframe load AND on every hashchange inside the iframe, plus
  // a fallback poll for Angular pushState/SMP cases we can't hook directly.
  function wirePortalUrlMirror() {
    var frame = document.getElementById('shell-iframe-portal');
    if (!frame) return;
    frame.addEventListener('load', function() {
      mirrorPortalUrlToOuter();
      try {
        var iwin = frame.contentWindow;
        iwin.addEventListener('hashchange', mirrorPortalUrlToOuter);
        iwin.addEventListener('popstate', mirrorPortalUrlToOuter);
      } catch (e) { /* cross-origin */ }
    });
  }

  // Belt-and-braces poll: catches Angular pushState (no event fires in the
  // parent) and cross-origin iframe states where we can't hook events.
  setInterval(mirrorPortalUrlToOuter, 400);
  wirePortalUrlMirror();

  // ── Chat-mode hash sync ──
  // When the user clicks the "Chat" tab the header toggles `body.ic-chat-mode`
  // (expands the chatbot sidebar to full width and hides the workspace). The
  // URL should reflect that so the expanded view is a real, shareable URL:
  //   #/chat[?NAMESPACE=...]   when expanded
  //   #/<previous-tab>...      when collapsed
  // We watch the class list on body and write the appropriate outer hash
  // instead of having to teach the header about the hash scheme.
  var lastChatModeHash = null;
  function writeChatModeHash() {
    var inChatMode = document.body.classList.contains('ic-chat-mode');
    if (inChatMode) {
      // Preserve any chat-id suffix the chatbot set via history.replaceState.
      // Without this, flipping into chat mode clobbers `#/chat/<id>` back
      // to `#/chat` and breaks deep-link reload.
      var curr = window.location.hash || '';
      var target = /^#\/chat(?:\/[^?]+)?$/.test(curr) ? curr : '#/chat';
      if (window.location.hash !== target) {
        history.replaceState(null, '', window.location.pathname + window.location.search + target);
      }
      lastChatModeHash = target;
    } else if (lastChatModeHash !== null) {
      // We owned the hash while chat mode was on; now re-derive it from the
      // actual tab state so collapsing returns the user to a URL that
      // matches what they're looking at.
      lastChatModeHash = null;
      syncOuterHashFromIframe();
    }
  }
  new MutationObserver(writeChatModeHash)
    .observe(document.body, { attributes: true, attributeFilter: ['class'] });

  // When the user edits the hash directly (bookmark, paste, back/forward),
  // re-run the restore logic so `#/chat` re-enters chat mode and `#/portal`
  // (etc.) leaves it. We guard against our own replaceState by only
  // reacting when the hash doesn't match what we'd write ourselves.
  window.addEventListener('hashchange', function() {
    var h = window.location.hash || '';
    var wantChat = /^#\/chat(\/[^?]+)?($|[?&])/.test(h);
    var isChat = document.body.classList.contains('ic-chat-mode');
    if (wantChat && !isChat) {
      document.body.classList.add('ic-chat-mode');
    } else if (!wantChat && isChat) {
      document.body.classList.remove('ic-chat-mode');
    }
    // If chat mode + hash carries a chat id, tell the chatbot to open it.
    // This makes paste/bookmark/back-forward navigate between chats
    // without a full page reload.
    if (wantChat) {
      var m = h.match(/^#\/chat\/([^?]+)/);
      if (m && window._cc && window._cc.openChat) {
        var id = decodeURIComponent(m[1]);
        if (window._cc.sessionId !== id) {
          try { window._cc.openChat(id); } catch (_) {}
        }
      }
    } else {
      restoreFromOuterHash();
    }
  });

  // ── Restore iframe hash from outer URL on load ──
  // Accepted forms:
  //   #/chat[?NAMESPACE=...]
  //   #/portal[/csp/.../EnsPortal....][?$NAMESPACE=...]         — Production, Traces,
  //                                                                anything in the portal
  //   #/skills[?NAMESPACE=...]
  //   Legacy: `#/traces/...` and bare `#/csp/...` still load into the portal
  //   iframe (the Traces tab is a zen page now, not its own URL segment).
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
      // Flip chat mode ON FIRST so the subsequent syncOuterHashFromIframe
      // fired by activateTab short-circuits and leaves `#/chat` intact.
      document.body.classList.add('ic-chat-mode');
      // Preload the default workspace iframe behind the chat pane so
      // switching off chat is instant, but DO NOT let activateTab switch
      // the header highlight to 'portal' — the Chat tab should stay lit.
      activateTab(DEFAULT_TAB);
      syncHeaderTabs('chat');
      return true;
    }

    if (tabId === 'skills') {
      activateTab('skills');
      return true;
    }

    // portal or traces: portal iframe gets the zen hash.
    var portalFrame = document.getElementById('shell-iframe-portal');
    if (!portalFrame) return false;
    // Only accept zen hashes that look like `/csp/...` — anything else
    // (e.g. a stale outer hash pointing at the shell's own page, or a
    // malformed URL after a double-wrap) gets replaced with the default
    // so we don't re-embed the shell into its own portal iframe.
    var restPath = rest.charAt(0) === '?' ? '' : rest;
    if (restPath && /^\/csp\//.test(restPath)) {
      portalFrame.src = legacyBase + '#' + restPath;
    } else {
      portalFrame.src = (tabId === 'traces' ? sources.traces : sources.portal).frameSrc;
    }
    activateTab(tabId);
    return true;
  }

  // ── Boot ──
  function boot() {
    // Set chat-mode BEFORE iframes start loading so the hash-sync that
    // fires on the first iframe `load` won't clobber `#/chat` with
    // `#/portal/…`. We only need a cheap regex here; the full restore
    // happens below.
    var h = window.location.hash || '';
    if (/^#\/chat($|[?&])/.test(h)) {
      document.body.classList.add('ic-chat-mode');
    }
    // Drop any `$NAMESPACE=` / `NAMESPACE=` query on the outer URL. The
    // zen hash inside carries it natively — keeping a duplicate on the
    // top-level search string only produces drift when namespaces change.
    try {
      var loc = window.location;
      if (/[?&]\$?NAMESPACE=/.test(loc.search)) {
        var cleaned = loc.search
          .replace(/[?&]\$?NAMESPACE=[^&#]*/g, '')
          .replace(/^&/, '?')
          .replace(/^$/, '');
        if (cleaned === '?' || cleaned === '&') cleaned = '';
        history.replaceState(null, '', loc.pathname + cleaned + loc.hash);
      }
    } catch (bootUrlErr) { /* non-critical */ }
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
