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

    // Detect current page type from URL path — check own path first, then parent's
    // (chatbot runs as a sidebar iframe; the shell URL has the actual page type).
    var path = window.location.pathname;
    var parentPath = '';
    try {
      if (window.parent && window.parent !== window) parentPath = window.parent.location.pathname;
    } catch(e) {}
    var effectivePath = path + ' ' + parentPath;
    if (effectivePath.indexOf('/interop-editor/') !== -1) ctx.page = 'interop-editor';
    else if (effectivePath.indexOf('/dtl-editor/') !== -1) ctx.page = 'dtl-editor';
    else if (effectivePath.indexOf('/rule-editor/') !== -1) ctx.page = 'rule-editor';
    else if (effectivePath.indexOf('/bpl-editor/') !== -1) ctx.page = 'bpl-editor';
    else if (effectivePath.indexOf('/message-viewer/') !== -1) ctx.page = 'message-viewer';
    else if (effectivePath.indexOf('/skills-editor/') !== -1) ctx.page = 'skills-editor';
    else if (effectivePath.indexOf('/legacy-ui/') !== -1) ctx.page = 'legacy-ui';
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

    // Parse hash to extract the active Zen page and component.
    // Applies on legacy-ui pages (hash = #/csp/...) AND on the main shell
    // (hash = #/portal/csp/... or #/traces/csp/...) — both embed an EnsPortal path.
    var hash = window.location.hash;
    if (hash && hash.indexOf('EnsPortal') !== -1) {
      var zenMatch = hash.match(/EnsPortal\.([^.?&/#]+(?:\.[^.?&/#]+)?)\.zen/);
      if (zenMatch) ctx.zenPage = zenMatch[1];
      var dtMatch = hash.match(/[?&]DT=([^&#+]+)/);
      if (dtMatch) { ctx.active = decodeURIComponent(dtMatch[1]).replace(/\.cls$/, ''); ctx.activeType = 'dtl'; }
      var ruleMatch = hash.match(/[?&]RULE=([^&#+]+)/);
      if (ruleMatch) { ctx.active = decodeURIComponent(ruleMatch[1]); ctx.activeType = 'rule'; }
      var bpMatch = hash.match(/[?&]BP=([^&#+]+)/);
      if (bpMatch) { ctx.active = decodeURIComponent(bpMatch[1]).replace(/\.cls$/, ''); ctx.activeType = 'bpl'; }
      var prodMatch = hash.match(/[?&]PRODUCTION=([^&#+]+)/);
      if (prodMatch) { ctx.active = decodeURIComponent(prodMatch[1]); ctx.activeType = 'production'; }
      var msMatch = hash.match(/[?&]MS=([^&#+]+)/);
      if (msMatch) { ctx.active = decodeURIComponent(msMatch[1]); ctx.activeType = 'schema'; }
      var lutMatch = hash.match(/[?&]LookupTable=([^&#+]+)/);
      if (lutMatch) { ctx.active = decodeURIComponent(lutMatch[1]).replace(/\.lut$/, ''); ctx.activeType = 'lookup'; }
    }

    ctx.origin = window.location.origin;
    cc._editorContext = ctx;
    return ctx;
  }

  // Scrape the portal iframe DOM for context when the URL alone doesn't
  // tell us what the user is looking at. Works because legacy-ui and the
  // Zen pages are same-origin.
  //
  // Returns an object: { active, activeType, zenDetail } or null.
  function scrapeIframeContext() {
    try {
      // The chatbot runs as a sidebar inside the shell page — look in the
      // parent/top document for shell-iframe-portal, not our own document.
      var shellDoc = (window.parent && window.parent !== window)
        ? window.parent.document
        : document;
      var portalFrame = shellDoc.getElementById('shell-iframe-portal');
      if (!portalFrame || !portalFrame.contentWindow) return null;

      var portalHref = '';
      try { portalHref = portalFrame.contentWindow.location.href || ''; } catch(e) {}

      if (portalHref.indexOf('rule-editor') !== -1) {
        try {
          var ruleDoc = portalFrame.contentDocument;
          var ruleH2 = ruleDoc ? (ruleDoc.querySelector('h2.rule-name.ng-star-inserted') || ruleDoc.querySelector('h2.rule-name')) : null;
          if (ruleH2) {
            var ruleRawText = '';
            for (var ni = 0; ni < ruleH2.childNodes.length; ni++) {
              if (ruleH2.childNodes[ni].nodeType === 3) ruleRawText += ruleH2.childNodes[ni].nodeValue;
            }
            ruleRawText = ruleRawText.trim();
            if (ruleRawText) return { active: ruleRawText, activeType: 'rule', zenDetail: null };
          }
          return { active: null, activeType: 'rule', zenDetail: 'Rule Editor' };
        } catch(e) {}
        return { active: null, activeType: 'rule', zenDetail: 'Rule Editor' };
      }

      // The Zen page lives inside a nested #viewer-frame inside legacy-ui.
      var zenDoc = null;
      var zenHref = '';
      try {
        var viewerFrame = portalFrame.contentDocument
          ? portalFrame.contentDocument.getElementById('viewer-frame')
          : null;
        if (viewerFrame && viewerFrame.contentWindow) {
          zenDoc = viewerFrame.contentDocument;
          zenHref = viewerFrame.contentWindow.location.href || '';
        }
      } catch(e) {}

      // Fallback: the portal iframe itself may be the Zen page (no wrapper).
      if (!zenDoc) {
        try {
          zenDoc = portalFrame.contentDocument;
          zenHref = portalFrame.contentWindow.location.href || '';
        } catch(e) {}
      }

      if (!zenDoc) return null;

      // Re-parse URL from the actual iframe href — more reliable than outer hash.
      if (zenHref) {
        var urlActive = null, urlType = null;
        var dtM = zenHref.match(/[?&]DT=([^&#+]+)/);
        if (dtM) { urlActive = decodeURIComponent(dtM[1]).replace(/\.cls$/, ''); urlType = 'dtl'; }
        var ruM = zenHref.match(/[?&]RULE=([^&#+]+)/);
        if (ruM) { urlActive = decodeURIComponent(ruM[1]); urlType = 'rule'; }
        var ruM2 = zenHref.match(/[?&]rule=([^&#+]+)/);
        if (ruM2) { urlActive = decodeURIComponent(ruM2[1]); urlType = 'rule'; }
        var bpM = zenHref.match(/[?&]BP=([^&#+]+)/);
        if (bpM) { urlActive = decodeURIComponent(bpM[1]).replace(/\.cls$/, ''); urlType = 'bpl'; }
        var prM = zenHref.match(/[?&]PRODUCTION=([^&#+]+)/);
        if (prM) { urlActive = decodeURIComponent(prM[1]); urlType = 'production'; }
        var msM = zenHref.match(/[?&]MS=([^&#+]+)/);
        if (msM) { urlActive = decodeURIComponent(msM[1]); urlType = 'schema'; }
        var luM = zenHref.match(/[?&]LookupTable=([^&#+]+)/);
        if (luM) { urlActive = decodeURIComponent(luM[1]).replace(/\.lut$/, ''); urlType = 'lookup'; }
        if (urlActive && urlType) {
          return { active: urlActive, activeType: urlType, zenDetail: null };
        }
      }

      // DOM scraping for pages with no component in the URL.
      // Each Zen page renders its title/breadcrumb in well-known elements.

      // DTL Editor: try #pageTitleText and #target-class-name, then fall back to <title>.
      if (zenHref && zenHref.indexOf('DTLEditor') !== -1) {
        var dtlNameEl = zenDoc.getElementById('pageTitleText') || zenDoc.getElementById('target-class-name');
        if (dtlNameEl) {
          var dtlNameText = (dtlNameEl.textContent || dtlNameEl.innerText || '').trim();
          if (dtlNameText) return { active: dtlNameText.replace(/\.cls$/, ''), activeType: 'dtl', zenDetail: null };
        }
      }
      var title = zenDoc.title || '';
      var dtlMatch = title.match(/DTL[:\s]+([A-Za-z][A-Za-z0-9._]+)/);
      if (dtlMatch) return { active: dtlMatch[1].replace(/\.cls$/, ''), activeType: 'dtl', zenDetail: null };

      // Rule Editor (Angular): h2.rule-name present in zenDoc regardless of URL.
      var ruleH2 = zenDoc.querySelector('h2.rule-name.ng-star-inserted') || zenDoc.querySelector('h2.rule-name');
      if (ruleH2) {
        var ruleRawText = '';
        for (var ni = 0; ni < ruleH2.childNodes.length; ni++) {
          if (ruleH2.childNodes[ni].nodeType === 3) ruleRawText += ruleH2.childNodes[ni].nodeValue;
        }
        ruleRawText = ruleRawText.trim();
        if (ruleRawText) return { active: ruleRawText, activeType: 'rule', zenDetail: null };
        return { active: null, activeType: 'rule', zenDetail: 'Rule Editor' };
      }

      // Rule Editor (ZEN fallback): try #pageTitleText.
      if (zenHref && zenHref.indexOf('RuleEditor') !== -1) {
        var ruleNameEl = zenDoc.getElementById('pageTitleText');
        if (ruleNameEl) {
          var ruleNameText = (ruleNameEl.textContent || ruleNameEl.innerText || '').trim();
          if (ruleNameText) return { active: ruleNameText, activeType: 'rule', zenDetail: null };
        }
      }

      // BPL Editor: try #pageTitleText, then #top-class-name.
      if (zenHref && zenHref.indexOf('BPLEditor') !== -1) {
        var bplNameEl = zenDoc.getElementById('pageTitleText') || zenDoc.getElementById('top-class-name');
        if (bplNameEl) {
          var bplNameText = (bplNameEl.textContent || bplNameEl.innerText || '').trim();
          if (bplNameText) return { active: bplNameText.replace(/\.cls$/, ''), activeType: 'bpl', zenDetail: null };
        }
      }

      // Production Config: try #pageTitleText, then the element with class "align-self" or "alignSelf".
      if (zenHref && zenHref.indexOf('ProductionConfig') !== -1) {
        var prodNameEl = zenDoc.getElementById('pageTitleText');
        if (!prodNameEl) prodNameEl = zenDoc.querySelector('.align-self, [class*="alignSelf"]');
        if (prodNameEl) {
          var prodNameText = (prodNameEl.textContent || prodNameEl.innerText || '').trim();
          if (prodNameText) return { active: prodNameText.replace(/\.cls$/, ''), activeType: 'production', zenDetail: null };
        }
      }

      // Visual Trace: extract session ID + host names from the trace table.
      var traceTable = zenDoc.querySelector('table.TraceData, table[id*="trace"], .EnsTraceTable');
      var sessionEl = zenDoc.querySelector('[id*="SessionId"], .sessionId, td.sessionId');
      var sessionId = sessionEl ? (sessionEl.textContent || '').trim() : null;
      if (!sessionId) {
        var sessMatch = (zenHref || '').match(/[?&]SessionId=([0-9]+)/);
        if (sessMatch) sessionId = sessMatch[1];
      }
      if (sessionId && zenHref && zenHref.indexOf('VisualTrace') !== -1) {
        // Collect host names from the trace column headers.
        var hostEls = zenDoc.querySelectorAll('th.hostLabel, th[id*="host"], .traceHost');
        var hosts = [];
        for (var i = 0; i < hostEls.length; i++) {
          var h = (hostEls[i].textContent || '').trim();
          if (h) hosts.push(h);
        }
        var detail = 'Session ' + sessionId;
        if (hosts.length) detail += ', hosts: ' + hosts.slice(0, 4).join(', ');
        return { active: null, activeType: 'trace', zenDetail: detail };
      }

      // Message Viewer: selected message header row.
      var selectedRow = zenDoc.querySelector('tr.selected, tr.EnsSelectedRow, tr[selected]');
      if (!selectedRow && zenHref && zenHref.indexOf('MessageViewer') !== -1) {
        selectedRow = zenDoc.querySelector('tr.listItem:first-of-type, tbody tr:first-child');
      }
      if (selectedRow && zenHref && zenHref.indexOf('MessageViewer') !== -1) {
        var cells = selectedRow.querySelectorAll('td');
        var detail = '';
        // Typical columns: ID, TimeCreated, Session, Status, Error, Source, Target, ...
        if (cells.length >= 6) {
          var src = (cells[5] ? cells[5].textContent : '').trim();
          var tgt = (cells[6] ? cells[6].textContent : '').trim();
          if (src || tgt) detail = (src || '?') + ' → ' + (tgt || '?');
        }
        if (!detail) {
          var sessionCell = cells[2] ? (cells[2].textContent || '').trim() : '';
          if (sessionCell) detail = 'Session ' + sessionCell;
        }
        return { active: null, activeType: 'viewer', zenDetail: detail || null };
      }

      // Event Log: extract top error text from first visible row.
      if (zenHref && zenHref.indexOf('EventLog') !== -1) {
        var errRow = zenDoc.querySelector('tr.EnsErrRow, tr.listItem');
        if (errRow) {
          var errCells = errRow.querySelectorAll('td');
          var errText = errCells.length >= 5 ? (errCells[4] ? errCells[4].textContent : '').trim() : '';
          if (errText) return { active: null, activeType: 'eventlog', zenDetail: errText.substring(0, 120) };
        }
        return { active: null, activeType: 'eventlog', zenDetail: null };
      }

    } catch(e) {}
    return null;
  }

  cc.getEditorContext = function() {
    parseEditorContext();

    // Always scrape for DOM-only sources (rule editor class name comes from Angular DOM,
    // not the URL). For other pages, only scrape when URL parsing didn't yield a class.
    var needsScrape = !cc._editorContext.active;
    if (!needsScrape) {
      try {
        var ph = '';
        var pf = document.getElementById('shell-iframe-portal');
        if (pf && pf.contentWindow) try { ph = pf.contentWindow.location.href || ''; } catch(e) {}
        if (!ph) {
          var sd = (window.parent && window.parent !== window) ? window.parent.document : document;
          var pf2 = sd.getElementById('shell-iframe-portal');
          if (pf2 && pf2.contentWindow) try { ph = pf2.contentWindow.location.href || ''; } catch(e) {}
        }
        if (ph.indexOf('rule-editor') !== -1) needsScrape = true;
      } catch(e) {}
    }

    if (needsScrape) {
      try {
        var scraped = scrapeIframeContext();
        if (scraped) {
          if (scraped.active) {
            cc._editorContext.active = scraped.active;
            cc._editorContext.activeType = scraped.activeType;
          } else if (scraped.zenDetail) {
            cc._editorContext.zenDetail = scraped.zenDetail;
            if (scraped.activeType && !cc._editorContext.activeType) {
              cc._editorContext.activeType = scraped.activeType;
            }
          }
        }
      } catch(e) {}
    }

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

  // Build a human-readable page context string from an editor context object.
  // Returns empty string when nothing useful is open.
  cc.buildPageContext = function(ec) {
    if (!ec) return '';
    var labels = {
      dtl: 'DTL Editor', rule: 'Rule Editor', bpl: 'BPL Editor',
      production: 'Production Config', schema: 'HL7 Schema Browser',
      lookup: 'Lookup Table Editor', trace: 'Visual Trace',
      viewer: 'Message Viewer', eventlog: 'Event Log'
    };
    if (ec.active && ec.activeType) {
      return (labels[ec.activeType] || ec.activeType) + ': ' + ec.active;
    }
    if (ec.zenDetail && ec.activeType) {
      return (labels[ec.activeType] || ec.activeType) + ': ' + ec.zenDetail;
    }
    return '';
  };

})(window._cc);
