// interclaw-chatbot/namespace.js — detectNamespace, namespace change detection, MutationObserver, fetch interceptor
(function(cc) {

  // --- Fetch interceptor: capture namespace from Angular app's API calls ---
  // The Angular interop-editor calls /api/interop-editors/v{N}/{NAMESPACE}/...
  // and /api/atelier/v{N}/{NAMESPACE}/... — these are ground truth.
  // IMPORTANT: Skip updates during namespace bounces to avoid contamination.
  cc._apiNamespace = null;

  (function() {
    var originalFetch = window.fetch;
    window.fetch = function(input, init) {
      try {
        if (!cc._isBouncingNamespace) {
          var url = typeof input === 'string' ? input : (input && input.url ? input.url : '');
          var nsMatch = url.match(/\/api\/(?:interop-editors|atelier)\/v\d+\/([^\/]+)\//i);
          if (nsMatch) {
            var ns = decodeURIComponent(nsMatch[1]).toUpperCase();
            if (ns !== '%SYS' && ns !== '%25SYS' && /^[A-Z][A-Z0-9_-]*$/.test(ns)) {
              cc._apiNamespace = ns;
            }
          }
        }
      } catch (e) { /* never break fetch */ }
      return originalFetch.apply(this, arguments);
    };
  })();

  // --- XMLHttpRequest interceptor: catch non-fetch API calls from Angular ---
  (function() {
    var originalOpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function(method, url) {
      try {
        if (!cc._isBouncingNamespace) {
          var nsMatch = (url || '').match(/\/api\/(?:interop-editors|atelier)\/v\d+\/([^\/]+)\//i);
          if (nsMatch) {
            var ns = decodeURIComponent(nsMatch[1]).toUpperCase();
            if (ns !== '%SYS' && ns !== '%25SYS' && /^[A-Z][A-Z0-9_-]*$/.test(ns)) {
              cc._apiNamespace = ns;
            }
          }
        }
      } catch (e) { /* never break XHR */ }
      return originalOpen.apply(this, arguments);
    };
  })();

  // Install namespace is seeded into frontend/install-config.js by the installer
  // (see InterClaw.Installer.WriteInstallConfigJs). Hard-coded "INTERCLAW" is the
  // last-resort fallback used only if the file is missing.
  var _icCfg = (typeof window !== 'undefined' && window._interclawConfig) || {};
  var DEFAULT_NAMESPACE = (_icCfg.namespace || 'INTERCLAW').toUpperCase();

  cc.detectNamespace = function() {
    // 1. Header is the single source of truth — read from interclaw-header.js
    //    The header resolves: URL param > server global > fallback
    var headerLabel = document.getElementById('ic-header-ns-label');
    if (headerLabel && headerLabel.textContent) {
      var headerNs = headerLabel.textContent.trim().toUpperCase();
      if (headerNs) return headerNs;
    }

    // 2. API interceptor (Angular API calls) — secondary source
    if (cc._apiNamespace) return cc._apiNamespace;

    // 3. URL query params — for pages loaded without the header
    var params = new URLSearchParams(window.location.search);
    var ns = params.get('$NAMESPACE') || params.get('NAMESPACE');
    if (ns) return ns.toUpperCase();

    // 4. localStorage / fallback
    var stored = sessionStorage.getItem('interclaw-namespace');
    if (stored) return stored.toUpperCase();
    return DEFAULT_NAMESPACE;
  };

  // Set initial namespace now that detectNamespace is defined
  cc.currentNamespace = cc.detectNamespace();

  // --- Editor context: parse URL params to know what's currently open ---
  // Params the Angular editors use: DTL, BP, BPL, RULE, $PRODUCTION, $NAMESPACE
  var EDITOR_PARAMS = ['DTL', 'BP', 'BPL', 'RULE'];

  cc._editorContext = { namespace: null, production: null, active: null, activeType: null, components: {} };

  function parseEditorContext() {
    var params = new URLSearchParams(window.location.search);
    var ctx = { namespace: null, production: null, active: null, activeType: null, components: {}, page: null, pageUrl: null };
    ctx.namespace = cc.detectNamespace();
    ctx.production = params.get('$PRODUCTION') || params.get('PRODUCTION') || null;
    for (var i = 0; i < EDITOR_PARAMS.length; i++) {
      var key = EDITOR_PARAMS[i];
      var val = params.get(key);
      if (val) ctx.components[key.toLowerCase()] = val;
    }
    // The last param in the URL is the most recently opened (Angular appends to end)
    var search = window.location.search;
    var lastType = null, lastVal = null;
    for (var i = 0; i < EDITOR_PARAMS.length; i++) {
      var key = EDITOR_PARAMS[i];
      var idx = search.lastIndexOf(key + '=');
      if (idx !== -1) {
        var val = params.get(key);
        if (val && (lastType === null || idx > search.lastIndexOf(lastType + '='))) {
          lastType = key;
          lastVal = val;
        }
      }
    }
    if (lastType && lastVal) {
      ctx.active = lastVal;
      ctx.activeType = lastType.toLowerCase();
    }

    // Detect current page type from URL path
    var path = window.location.pathname;
    if (path.indexOf('/interop-editor/') !== -1) ctx.page = 'interop-editor';
    else if (path.indexOf('/dtl-editor/') !== -1) ctx.page = 'dtl-editor';
    else if (path.indexOf('/rule-editor/') !== -1) ctx.page = 'rule-editor';
    else if (path.indexOf('/bpl-editor/') !== -1) ctx.page = 'bpl-editor';
    else if (path.indexOf('/message-viewer/') !== -1) ctx.page = 'message-viewer';
    else if (path.indexOf('/skills-editor/') !== -1) ctx.page = 'skills-editor';
    else if (path.indexOf('/legacy-ui/') !== -1) ctx.page = 'legacy-ui';
    else ctx.page = 'other';

    // Full page URL (path + search + hash) for backend context
    ctx.pageUrl = path + window.location.search + window.location.hash;

    // For legacy-ui: capture the viewer-frame iframe URL (the actual Zen page being viewed)
    if (ctx.page === 'legacy-ui') {
      try {
        var frame = document.getElementById('viewer-frame');
        if (frame && frame.src) ctx.viewerFrame = frame.src;
      } catch(e) { /* cross-origin or no frame */ }
    }

    // For legacy-ui: parse hash to extract the Zen page class being viewed
    var hash = window.location.hash;
    if (hash && ctx.page === 'legacy-ui') {
      // Hash format: #/csp/healthshare/<ns>/EnsPortal.DTLEditor.zen?DT=Some.DTL.cls
      var zenMatch = hash.match(/EnsPortal\.(\w+)\.zen/);
      if (zenMatch) ctx.zenPage = zenMatch[1];
      var dtMatch = hash.match(/[?&]DT=([^&]+)/);
      if (dtMatch) { ctx.active = decodeURIComponent(dtMatch[1]).replace(/\.cls$/, ''); ctx.activeType = 'dtl'; }
      var ruleMatch = hash.match(/[?&]RULE=([^&]+)/);
      if (ruleMatch) { ctx.active = decodeURIComponent(ruleMatch[1]); ctx.activeType = 'rule'; }
      var bpMatch = hash.match(/[?&]BP=([^&]+)/);
      if (bpMatch) { ctx.active = decodeURIComponent(bpMatch[1]).replace(/\.cls$/, ''); ctx.activeType = 'bpl'; }
      var prodMatch = hash.match(/[?&]PRODUCTION=([^&]+)/);
      if (prodMatch) { ctx.active = decodeURIComponent(prodMatch[1]); ctx.activeType = 'production'; }
      var msMatch = hash.match(/[?&]MS=([^&]+)/);
      if (msMatch) { ctx.active = decodeURIComponent(msMatch[1]); ctx.activeType = 'schema'; }
    }

    ctx.origin = window.location.origin;
    cc._editorContext = ctx;
    return ctx;
  }

  cc.getEditorContext = function() {
    parseEditorContext();
    try {
      var sel = localStorage.getItem('interclaw-tree-selection');
      if (sel) {
        var parsed = JSON.parse(sel);
        if (parsed && parsed.path) {
          cc._editorContext.treeSelection = {
            type: parsed.type,
            name: parsed.name,
            path: parsed.path
          };
          if (parsed.type === 'file' && parsed.content) {
            cc._editorContext.treeSelection.content = parsed.content;
          }
          if (parsed.type === 'folder' && parsed.listing) {
            cc._editorContext.treeSelection.listing = parsed.listing;
          }
        }
      }
    } catch(e) {}
    return cc._editorContext;
  };

  // Parse on load
  parseEditorContext();

  function checkNamespaceChange() {
    if (cc._isBouncingNamespace) return;
    var newNamespace = cc.detectNamespace();
    if (newNamespace && newNamespace !== cc.currentNamespace) {
      cc.currentNamespace = newNamespace;
      // Notify the header + shell so the top-right label + tab hrefs
      // follow Angular's client-side namespace switches. The header's
      // own listener at interclaw-header.js:724 rewrites #ic-header-ns-label
      // and patches $NAMESPACE= in every tab link.
      try {
        window.dispatchEvent(new CustomEvent('interclaw-namespace-change', {
          detail: { namespace: newNamespace }
        }));
      } catch (e) { /* no-op */ }
    }
    parseEditorContext();
  }

  // Override history methods to catch Angular's client-side navigation
  (function() {
    var originalPushState = history.pushState;
    var originalReplaceState = history.replaceState;

    history.pushState = function() {
      originalPushState.apply(this, arguments);
      checkNamespaceChange();
    };

    history.replaceState = function() {
      originalReplaceState.apply(this, arguments);
      checkNamespaceChange();
    };

    window.addEventListener('popstate', checkNamespaceChange);
    setInterval(checkNamespaceChange, 2000);
  })();

  // MutationObserver for immediate namespace dropdown detection
  (function() {
    var observerStarted = false;
    function startNamespaceObserver() {
      if (observerStarted) return;
      var topbar = document.querySelector('fr-topbar') || document.querySelector('mat-toolbar');
      if (!topbar) return;
      observerStarted = true;
      var observer = new MutationObserver(function() {
        if (cc._isBouncingNamespace) return;
        checkNamespaceChange();
      });
      observer.observe(topbar, { childList: true, subtree: true, characterData: true });
    }
    startNamespaceObserver();
    var retryInterval = setInterval(function() {
      startNamespaceObserver();
      if (observerStarted) clearInterval(retryInterval);
    }, 1000);
    setTimeout(function() { clearInterval(retryInterval); }, 30000);
  })();

})(window._cc);
