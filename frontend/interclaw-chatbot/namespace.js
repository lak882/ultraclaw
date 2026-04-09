// interclaw-chatbot/namespace.js — detectNamespace, namespace change detection, MutationObserver, fetch interceptor
(function(cc) {

  // --- Fetch interceptor: capture namespace from Angular app's API calls ---
  // The Angular interop-editor calls /api/interop-editors/v{N}/{NAMESPACE}/...
  // and /api/atelier/v{N}/{NAMESPACE}/... — these are ground truth.
  cc._apiNamespace = null;

  (function() {
    var originalFetch = window.fetch;
    window.fetch = function(input, init) {
      try {
        var url = typeof input === 'string' ? input : (input && input.url ? input.url : '');
        var nsMatch = url.match(/\/api\/(?:interop-editors|atelier)\/v\d+\/([^\/]+)\//i);
        if (nsMatch) {
          var ns = decodeURIComponent(nsMatch[1]).toUpperCase();
          // Ignore %SYS / %25SYS — not a user namespace
          if (ns !== '%SYS' && ns !== '%25SYS' && /^[A-Z][A-Z0-9_-]*$/.test(ns)) {
            cc._apiNamespace = ns;
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
        var nsMatch = (url || '').match(/\/api\/(?:interop-editors|atelier)\/v\d+\/([^\/]+)\//i);
        if (nsMatch) {
          var ns = decodeURIComponent(nsMatch[1]).toUpperCase();
          if (ns !== '%SYS' && ns !== '%25SYS' && /^[A-Z][A-Z0-9_-]*$/.test(ns)) {
            cc._apiNamespace = ns;
          }
        }
      } catch (e) { /* never break XHR */ }
      return originalOpen.apply(this, arguments);
    };
  })();

  cc.detectNamespace = function() {
    // Priority 1: Namespace captured from Angular's own API calls (most reliable)
    if (cc._apiNamespace) return cc._apiNamespace;

    // Priority 2: URL path — /healthshare/{NAMESPACE}/
    var path = window.location.pathname;
    var match = path.match(/\/healthshare\/([^\/]+)/i);
    if (match) return match[1].toUpperCase();

    // Priority 3: URL query parameters — ?$NAMESPACE= or ?NAMESPACE=
    var params = new URLSearchParams(window.location.search);
    var ns = params.get('$NAMESPACE') || params.get('NAMESPACE');
    if (ns) return ns.toUpperCase();

    // Priority 4: DOM element with namespace class (least reliable)
    var nsEl = document.querySelector('[class*="namespace"]');
    if (nsEl) {
      var text = nsEl.textContent.trim().toUpperCase();
      if (text && /^[A-Z][A-Z0-9_-]*$/.test(text)) return text;
    }
    return null;
  };

  // Set initial namespace now that detectNamespace is defined
  cc.currentNamespace = cc.detectNamespace();

  // --- Editor context: parse URL params to know what's currently open ---
  // Params the Angular editors use: DTL, BP, BPL, RULE, $PRODUCTION, $NAMESPACE
  var EDITOR_PARAMS = ['DTL', 'BP', 'BPL', 'RULE'];

  cc._editorContext = { namespace: null, production: null, active: null, activeType: null, components: {} };

  function parseEditorContext() {
    var params = new URLSearchParams(window.location.search);
    var ctx = { namespace: null, production: null, active: null, activeType: null, components: {} };
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
