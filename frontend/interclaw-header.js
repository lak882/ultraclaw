// interclaw-header.js — Shared top navigation header for all InterClaw editors
// Editors load this via <script src="../interclaw-header.js"> BEFORE <app-root>
(function() {
  'use strict';
  if (document.getElementById('interclaw-header')) return; // already loaded

  // ── Clean encoded query params from URL bar (e.g. %24NAMESPACE → $NAMESPACE) ──
  if (location.search.indexOf('%') !== -1) {
    try {
      var clean = location.pathname + decodeURIComponent(location.search) + location.hash;
      if (clean !== location.pathname + location.search + location.hash) {
        history.replaceState(null, '', clean);
      }
    } catch (e) { /* malformed URI — leave as-is */ }
  }

  // ── Resolve base path (one level up from current editor folder) ──
  var loc = window.location;
  var pathParts = loc.pathname.split('/');
  // Find the interclaw root: everything before the editor folder
  var interclawIdx = pathParts.indexOf('interclaw');
  var basePath = interclawIdx >= 0
    ? pathParts.slice(0, interclawIdx + 1).join('/') + '/'
    : pathParts.slice(0, -2).join('/') + '/';

  // ── Detect current page ──
  var currentEditor = '';
  var path = loc.pathname;
  if (path.indexOf('skills-editor') !== -1) currentEditor = 'skills';
  else if (path.indexOf('legacy-ui') !== -1 || path.indexOf('message-viewer') !== -1) {
    var _p = new URLSearchParams(loc.search);
    var _h = loc.hash || '';
    currentEditor = (_p.get('page') === 'messages' || _h.indexOf('MessageViewer') !== -1) ? 'traces' : 'portal';
  }
  else if (path.indexOf('rule-editor') !== -1) currentEditor = 'copilot';
  else currentEditor = 'copilot'; // interop-editor = copilot

  // Check for chat fullscreen mode
  var params = new URLSearchParams(loc.search);
  var viewMode = params.get('view');
  var currentTab = viewMode === 'chat' ? 'chat' : currentEditor;

  // ── Namespace: URL param > install-config global > fallback INTERCLAW ──
  // Server global ^InterClaw.Config("Namespace") is the single source of truth.
  // The installer serialises it into frontend/install-config.js so every page
  // has the install namespace before the first render.
  // URL param overrides for deep links; result is always persisted back to server.
  var _icCfg = (typeof window !== 'undefined' && window._interclawConfig) || {};
  var _installNs = (_icCfg.namespace || 'INTERCLAW').toUpperCase();
  var urlNs = params.get('$NAMESPACE') || params.get('NAMESPACE') || '';
  var namespace = (urlNs || _installNs).toUpperCase();

  // API base for namespace endpoints (pathPrefix resolved below)
  var _nsApiBase = ''; // set after pathPrefix is computed

  // ── Build tab URLs (preserve namespace in query) ──
  function tabUrl(editor, extra) {
    var url = basePath + editor + '/index.html?$NAMESPACE=' + namespace;
    if (extra) url += '&' + extra;
    return url;
  }

  // Compute pathPrefix (strip /ui/interop/interclaw/ from basePath)
  var icPath = '/ui/interop/interclaw/';
  var icPos = basePath.indexOf(icPath);
  var pathPrefix = icPos > 0 ? basePath.substring(0, icPos) : '';

  // ── Namespace API ──
  _nsApiBase = pathPrefix + '/api/interclaw/api/namespace';

  // Fetch server-stored namespace (async). If URL param was provided, persist it
  // to server; otherwise adopt whatever the server returns.
  (function() {
    if (urlNs) {
      // URL param takes priority — store in session only
      sessionStorage.setItem('interclaw-namespace', namespace);
    } else {
      // No URL override — fetch server value
      fetch(_nsApiBase, {
        credentials: 'include',
        headers: { 'Authorization': 'Basic ' + btoa('superuser:SYS') }
      })
        .then(function(r) { return r.ok ? r.json() : null; })
        .then(function(data) {
          if (data && data.namespace && data.namespace.toUpperCase() !== namespace) {
            var serverNs = data.namespace.toUpperCase();
            namespace = serverNs;
            // Update header label
            var lbl = document.getElementById('ic-header-ns-label');
            if (lbl) lbl.textContent = serverNs;
            // Update CSP base
            var newCsp = pathPrefix + '/csp/healthshare/' + serverNs.toLowerCase();
            window._interclawCspBase = newCsp;
            sessionStorage.setItem('interclaw-cspbase', newCsp);
            sessionStorage.setItem('interclaw-namespace', serverNs);
            // Update tab hrefs
            var tLinks = document.querySelectorAll('#interclaw-header .ic-header-tab');
            for (var i = 0; i < tLinks.length; i++) {
              var h = tLinks[i].getAttribute('href');
              if (h) tLinks[i].setAttribute('href', h.replace(/\$NAMESPACE=[^&]*/, '$NAMESPACE=' + serverNs));
            }
            // Broadcast to other components
            if (window._cc) { window._cc.currentNamespace = serverNs; window._cc._apiNamespace = serverNs; }
            window.dispatchEvent(new CustomEvent('interclaw-namespace-change', { detail: { namespace: serverNs } }));
          }
        })
        .catch(function() {});
    }
  })();

  // ── Expose CSP base for chatbot /goto — this is the ground truth ──
  var cspBase = pathPrefix + '/csp/healthshare/' + namespace.toLowerCase();
  window._interclawCspBase = cspBase;
  sessionStorage.setItem('interclaw-cspbase', cspBase);

  var tabs = [
    {
      id: 'chat', label: 'Chat',
      url: tabUrl('interop-editor', 'view=chat'),
      icon: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>'
    },
    {
      id: 'portal', label: 'Portal',
      url: basePath + 'legacy-ui/index.html?$NAMESPACE=' + namespace + '#/csp/healthshare/' + namespace.toLowerCase() + '/EnsPortal.ProductionConfig.zen?$NAMESPACE=' + namespace,
      icon: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>'
    },
    {
      id: 'traces', label: 'Traces',
      url: basePath + 'legacy-ui/index.html?$NAMESPACE=' + namespace + '#/csp/healthshare/' + namespace.toLowerCase() + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + namespace,
      icon: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>'
    },
    {
      id: 'skills', label: 'Skill Editor',
      url: tabUrl('skills-editor'),
      icon: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>'
    }
  ];

  // ── Inject CSS ──
  var cssLink = document.createElement('link');
  cssLink.rel = 'stylesheet';
  cssLink.id = 'interclaw-header-styles';
  cssLink.href = basePath + 'interclaw-header.css?v=7';
  document.head.appendChild(cssLink);

  // ── Build header HTML ──
  var brandImg = '<img src="' + basePath + 'interclaw-logo.png" width="24" height="24" alt="InterClaw" style="border-radius:4px">';

  var nsSvg = '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M3 5v14c0 1.66 4.03 3 9 3s9-1.34 9-3V5"/><path d="M3 12c0 1.66 4.03 3 9 3s9-1.34 9-3"/></svg>';

  var tabsHtml = tabs.map(function(t) {
    var cls = 'ic-header-tab' + (t.id === currentTab ? ' active' : '');
    return '<a class="' + cls + '" href="' + t.url + '" data-tab="' + t.id + '">'
      + t.icon + '<span>' + t.label + '</span></a>';
  }).join('');

  var header = document.createElement('div');
  header.id = 'interclaw-header';
  header.innerHTML =
    '<div class="ic-header-brand">' + brandImg + '<span>InterClaw</span></div>'
    + '<nav class="ic-header-tabs">' + tabsHtml + '</nav>'
    + '<div class="ic-header-settings" id="ic-header-settings">'
    +   '<button class="ic-header-settings-btn" id="ic-header-settings-btn" type="button" title="Settings" disabled>'
    +     '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>'
    +     '<span>Settings</span>'
    +   '</button>'
    +   '<div class="ic-header-settings-dropdown" id="ic-header-settings-dropdown">'
    +     '<label class="ic-settings-toggle">'
    +       '<span class="ic-settings-label">Auto-navigate in the New Production UI</span>'
    +       '<input type="checkbox" id="ic-setting-auto-navigate"' + (localStorage.getItem('interclaw-auto-navigate') !== 'false' ? ' checked' : '') + '>'
    +       '<span class="ic-settings-switch"></span>'
    +     '</label>'
    +     '<div class="ic-settings-divider"></div>'
    +     '<div class="ic-settings-row">'
    +       '<span class="ic-settings-label">Default Namespace</span>'
    +       '<select class="ic-settings-select" id="ic-setting-default-ns">'
    +         '<option value="' + namespace + '">' + namespace + '</option>'
    +       '</select>'
    +     '</div>'
    +   '</div>'
    + '</div>'
    + '<div class="ic-header-right">'
    + (function() {
        var _ml = {opus:'Claude Opus 4.7',sonnet:'Claude Sonnet 4.6',haiku:'Claude Haiku 4.5'};
        var _sm = sessionStorage.getItem('chatbot-model') || 'sonnet';
        var _lbl = _ml[_sm] || _sm;
        return '<div class="ic-header-model-selector" id="ic-header-model-selector">'
        + '<button class="ic-header-model-btn" id="ic-header-model-btn" type="button">'
        + '<span id="ic-header-model-label">' + _lbl + '</span>';
      })()
    +     '<svg width="10" height="10" viewBox="0 0 10 10" fill="currentColor"><path d="M2 4l3 3 3-3"/></svg>'
    +   '</button>'
    +   '<div class="ic-header-model-dropdown" id="ic-header-model-dropdown">'
    +     '<div class="ic-header-model-option" data-value="opus"><span class="model-name">Claude Opus 4.7</span><span class="model-desc">Most capable for complex, ambitious work</span></div>'
    +     '<div class="ic-header-model-option" data-value="sonnet"><span class="model-name">Claude Sonnet 4.6</span><span class="model-desc">Best balance of speed and intelligence</span></div>'
    +     '<div class="ic-header-model-option" data-value="haiku"><span class="model-name">Claude Haiku 4.5</span><span class="model-desc">Fastest responses for simple tasks</span></div>'
    +   '</div>'
    + '</div>'
    + '<button class="ic-header-reload-btn" id="ic-header-reload-btn" type="button" title="Reload current view">'
    +   '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>'
    + '</button>'
    + '<span class="ic-header-sep"></span>'
    + '<div class="ic-header-ns-selector" id="ic-header-ns-selector">'
    +   '<button class="ic-header-ns-btn" id="ic-header-ns-btn" type="button">'
    +     nsSvg
    +     '<span id="ic-header-ns-label">' + namespace + '</span>'
    +     '<svg width="10" height="10" viewBox="0 0 10 10" fill="currentColor"><path d="M2 4l3 3 3-3"/></svg>'
    +   '</button>'
    +   '<div class="ic-header-ns-dropdown" id="ic-header-ns-dropdown"></div>'
    + '</div>'
    + '<span class="ic-header-sep"></span>'
    + '<span id="ic-header-toggle-slot"></span>'
    + '</div>';

  // Insert at very top of body
  document.body.insertBefore(header, document.body.firstChild);
  document.body.classList.add('ic-header-active');


  // ── Model: server global is source of truth, fetched on every load ──
  (function() {
    var _ml = {opus:'Claude Opus 4.7',sonnet:'Claude Sonnet 4.6',haiku:'Claude Haiku 4.5'};
    fetch(pathPrefix + '/api/interclaw/api/model', {
      credentials: 'include',
      headers: { 'Authorization': 'Basic ' + btoa('superuser:SYS') }
    })
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(data) {
        if (data && data.model) {
          sessionStorage.setItem('chatbot-model', data.model);
          // Update header label
          var lbl = document.getElementById('ic-header-model-label');
          if (lbl) lbl.textContent = _ml[data.model] || data.model;
          // Update selected state in dropdown
          var opts = document.querySelectorAll('#ic-header-model-dropdown .ic-header-model-option');
          opts.forEach(function(o) { o.classList.toggle('selected', o.dataset.value === data.model); });
          // Sync chatbot
          if (window._cc && window._cc.setSelectedModel) {
            window._cc.setSelectedModel(data.model);
          }
        }
      })
      .catch(function() {});
  })();

  // ── Model selector dropdown ──
  (function() {
    var modelBtn = document.getElementById('ic-header-model-btn');
    var modelDD = document.getElementById('ic-header-model-dropdown');

    modelBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      // Close other dropdowns
      var nsDD = document.getElementById('ic-header-ns-dropdown');
      if (nsDD) nsDD.classList.remove('open');
      var settingsDD = document.getElementById('ic-header-settings-dropdown');
      if (settingsDD) settingsDD.classList.remove('open');
      modelDD.classList.toggle('open');
    });

    modelDD.addEventListener('click', function(e) {
      var opt = e.target.closest('.ic-header-model-option');
      if (!opt || !opt.dataset.value) return;
      var model = opt.dataset.value;
      // Persist to server global
      fetch(pathPrefix + '/api/interclaw/api/model', {
        method: 'PUT',
        credentials: 'include',
        headers: {
          'Authorization': 'Basic ' + btoa('superuser:SYS'),
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({model: model})
      }).catch(function() {});
      // Update UI
      if (window._cc && window._cc.setSelectedModel) {
        window._cc.setSelectedModel(model);
      } else {
        sessionStorage.setItem('chatbot-model', model);
        var _ml = {opus:'Claude Opus 4.7',sonnet:'Claude Sonnet 4.6',haiku:'Claude Haiku 4.5'};
        document.getElementById('ic-header-model-label').textContent = _ml[model] || model;
        var opts = modelDD.querySelectorAll('.ic-header-model-option');
        opts.forEach(function(o) { o.classList.toggle('selected', o.dataset.value === model); });
      }
      modelDD.classList.remove('open');
    });

    document.addEventListener('click', function() {
      modelDD.classList.remove('open');
    });
  })();

  // ── Reload button: reload the active shell iframe when inside the shell,
  //    otherwise reload the current page. Spin the icon briefly on click. ──
  (function() {
    var reloadBtn = document.getElementById('ic-header-reload-btn');
    if (!reloadBtn) return;
    reloadBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      reloadBtn.classList.add('spinning');
      setTimeout(function() { reloadBtn.classList.remove('spinning'); }, 600);

      // Shell context: reload the currently active iframe.
      var activeIframe = document.querySelector('.shell-iframe.shell-iframe--active');
      if (activeIframe) {
        try {
          // contentWindow.location.reload() preserves the iframe's current URL
          // (including any in-iframe navigation the user has done), whereas
          // reassigning src would reset to the initial src.
          activeIframe.contentWindow.location.reload();
          return;
        } catch (err) {
          // Cross-origin — fall back to re-assigning src
          var s = activeIframe.src;
          activeIframe.src = 'about:blank';
          setTimeout(function() { activeIframe.src = s; }, 0);
          return;
        }
      }

      // Standalone page (legacy-ui wrapper has its own viewer-frame, chat editor, etc.)
      // Prefer reloading a known inner iframe so state outside (chatbot) is preserved.
      var viewerFrame = document.getElementById('viewer-frame');
      if (viewerFrame) {
        try { viewerFrame.contentWindow.location.reload(); }
        catch (err) {
          var s2 = viewerFrame.src;
          viewerFrame.src = 'about:blank';
          setTimeout(function() { viewerFrame.src = s2; }, 0);
        }
        return;
      }

      // Last resort: full page reload.
      window.location.reload();
    });
  })();

  // ── Namespace selector dropdown ──
  (function() {
    var nsBtn = document.getElementById('ic-header-ns-btn');
    var nsDD = document.getElementById('ic-header-ns-dropdown');
    var nsLabel = document.getElementById('ic-header-ns-label');
    var nsState = 'idle'; // idle | loading | loaded | error

    function loadNamespaceList() {
      if (nsState === 'loaded' || nsState === 'loading') return;
      nsState = 'loading';
      nsDD.innerHTML = '<div class="ic-header-ns-status">Loading namespaces...</div>';

      var url = pathPrefix + '/api/atelier/';
      fetch(url, { credentials: 'include', headers: { 'Authorization': 'Basic ' + btoa('superuser:SYS') } })
        .then(function(r) {
          if (!r.ok) throw new Error('HTTP ' + r.status);
          return r.json();
        })
        .then(function(data) {
          var namespaces = [];
          if (data && data.result && data.result.content && data.result.content.namespaces) {
            var nsList = data.result.content.namespaces;
            for (var i = 0; i < nsList.length; i++) {
              var ns = nsList[i];
              if (ns === '%SYS') continue;
              namespaces.push(ns);
            }
          }
          if (namespaces.length === 0) {
            nsState = 'error';
            nsDD.innerHTML = '<div class="ic-header-ns-status">No namespaces found</div>';
          } else {
            nsState = 'loaded';
            renderNamespaceDropdown(namespaces);
          }
        })
        .catch(function(e) {
          console.warn('[ns-selector] Failed to load namespace list:', e);
          nsState = 'error';
          nsDD.innerHTML = '<div class="ic-header-ns-status">Could not load namespaces<br><span class="ic-header-ns-hint">Type a namespace name in the chat instead</span></div>';
        });
    }

    function renderNamespaceDropdown(namespaces) {
      var currentNs = namespace.toUpperCase();
      var html = '';
      for (var i = 0; i < namespaces.length; i++) {
        var ns = namespaces[i];
        var sel = ns.toUpperCase() === currentNs ? ' selected' : '';
        html += '<div class="ic-header-ns-option' + sel + '" data-ns="' + ns + '">' + ns + '</div>';
      }
      nsDD.innerHTML = html;
    }

    nsBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      // Close model dropdown if open
      var modelDD = document.getElementById('ic-header-model-dropdown');
      if (modelDD) modelDD.classList.remove('open');
      var settingsDD = document.getElementById('ic-header-settings-dropdown');
      if (settingsDD) settingsDD.classList.remove('open');

      nsDD.classList.toggle('open');
      if (nsState === 'error') nsState = 'idle'; // retry on reopen after error
      loadNamespaceList();
    });

    nsDD.addEventListener('click', function(e) {
      var opt = e.target.closest('.ic-header-ns-option');
      if (!opt) return;
      var ns = opt.dataset.ns;
      var nsUp = ns.toUpperCase();
      namespace = nsUp;
      nsLabel.textContent = ns;
      sessionStorage.setItem('interclaw-namespace', nsUp);

      // Update CSP base
      var newCspBase = pathPrefix + '/csp/healthshare/' + nsUp.toLowerCase();
      window._interclawCspBase = newCspBase;
      sessionStorage.setItem('interclaw-cspbase', newCspBase);

      // Sync with chatbot
      if (window._cc) {
        window._cc.currentNamespace = nsUp;
        window._cc._apiNamespace = nsUp;
      }
      window.dispatchEvent(new CustomEvent('interclaw-namespace-change', { detail: { namespace: nsUp } }));

      // Update selected state
      var opts = nsDD.querySelectorAll('.ic-header-ns-option');
      for (var i = 0; i < opts.length; i++) {
        opts[i].classList.toggle('selected', opts[i].dataset.ns === ns);
      }
      nsDD.classList.remove('open');
    });

    document.addEventListener('click', function() {
      nsDD.classList.remove('open');
    });
  })();

  // ── Settings gear dropdown ──
  (function() {
    var settingsBtn = document.getElementById('ic-header-settings-btn');
    var settingsDD = document.getElementById('ic-header-settings-dropdown');
    var autoNavCheckbox = document.getElementById('ic-setting-auto-navigate');
    var defaultNsSelect = document.getElementById('ic-setting-default-ns');
    var nsLoaded = false;

    function loadSettingsNamespaces() {
      if (nsLoaded) return;
      nsLoaded = true;
      var url = pathPrefix + '/api/atelier/';
      fetch(url, { credentials: 'include', headers: { 'Authorization': 'Basic ' + btoa('superuser:SYS') } })
        .then(function(r) {
          if (!r.ok) throw new Error('HTTP ' + r.status);
          return r.json();
        })
        .then(function(data) {
          var namespaces = [];
          if (data && data.result && data.result.content && data.result.content.namespaces) {
            var nsList = data.result.content.namespaces;
            for (var i = 0; i < nsList.length; i++) {
              var ns = nsList[i];
              if (ns === '%SYS') continue;
              namespaces.push(ns);
            }
          }
          if (namespaces.length > 0) {
            var currentDefault = (localStorage.getItem('interclaw-default-namespace') || namespace).toUpperCase();
            var html = '';
            for (var j = 0; j < namespaces.length; j++) {
              var sel = namespaces[j].toUpperCase() === currentDefault ? ' selected' : '';
              html += '<option value="' + namespaces[j] + '"' + sel + '>' + namespaces[j] + '</option>';
            }
            defaultNsSelect.innerHTML = html;
          }
        })
        .catch(function() {
          nsLoaded = false; // allow retry
        });
    }

    settingsBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      // Close other dropdowns
      var modelDD = document.getElementById('ic-header-model-dropdown');
      if (modelDD) modelDD.classList.remove('open');
      var nsDD = document.getElementById('ic-header-ns-dropdown');
      if (nsDD) nsDD.classList.remove('open');

      settingsDD.classList.toggle('open');
      if (settingsDD.classList.contains('open')) {
        loadSettingsNamespaces();
      }
    });

    settingsDD.addEventListener('click', function(e) {
      e.stopPropagation();
    });

    autoNavCheckbox.addEventListener('change', function() {
      localStorage.setItem('interclaw-auto-navigate', autoNavCheckbox.checked ? 'true' : 'false');
    });

    defaultNsSelect.addEventListener('change', function() {
      var newNs = defaultNsSelect.value.toUpperCase();
      namespace = newNs;
      localStorage.setItem('interclaw-default-namespace', newNs);
      sessionStorage.setItem('interclaw-namespace', newNs);

      // Update CSP base
      var newCspBase = pathPrefix + '/csp/healthshare/' + newNs.toLowerCase();
      window._interclawCspBase = newCspBase;
      sessionStorage.setItem('interclaw-cspbase', newCspBase);

      // Update header namespace label
      var nsLabel = document.getElementById('ic-header-ns-label');
      if (nsLabel) nsLabel.textContent = newNs;

      // Update all tab hrefs to use the new namespace
      var tabLinks = document.querySelectorAll('#interclaw-header .ic-header-tab');
      for (var t = 0; t < tabLinks.length; t++) {
        var href = tabLinks[t].getAttribute('href');
        if (href) {
          tabLinks[t].setAttribute('href', href.replace(/\$NAMESPACE=[^&]*/, '$NAMESPACE=' + newNs));
        }
      }

      // Sync with chatbot
      if (window._cc) {
        window._cc.currentNamespace = newNs;
        window._cc._apiNamespace = newNs;
      }
      window.dispatchEvent(new CustomEvent('interclaw-namespace-change', { detail: { namespace: newNs } }));
    });

    document.addEventListener('click', function() {
      settingsDD.classList.remove('open');
    });
  })();

  // ── Chat mode: expand sidebar to full width ──
  // ?view=chat on the dedicated chat page still works as a fallback for direct links.
  if (viewMode === 'chat') {
    document.body.classList.add('ic-chat-mode');
  }

  // Chat tab toggles chat mode on the current page instead of navigating.
  // Other tabs exit chat mode and navigate only if needed.
  var _isChatPage = path.indexOf('interop-editor') !== -1 && viewMode === 'chat';
  var headerNav = document.querySelector('#interclaw-header .ic-header-tabs');
  if (headerNav) {
    headerNav.addEventListener('click', function(e) {
      var tab = e.target.closest('.ic-header-tab');
      if (!tab) return;
      var tabId = tab.dataset.tab;
      var inChatMode = document.body.classList.contains('ic-chat-mode');

      // Shell-aware path: when this header is rendered inside the InterClaw
      // shell (index.html top-level), Portal/Traces/Skills tabs must swap
      // the active iframe in place rather than navigate the whole window.
      // The shell exposes window._interclawShell.activateTab for exactly
      // this. We only handle the three workspace tabs here; 'chat' still
      // falls through to the chat-mode toggle below.
      var shell = window._interclawShell;
      if (shell && tabId !== 'chat' && (tabId === 'portal' || tabId === 'traces' || tabId === 'skills')) {
        e.preventDefault();
        shell.activateTab(tabId);
        return;
      }

      if (tabId === 'chat') {
        // On the dedicated chat page, chat tab is a no-op
        if (_isChatPage) { e.preventDefault(); return; }
        e.preventDefault();
        if (inChatMode) {
          // Already in chat mode — collapse back to sidebar
          document.body.classList.remove('ic-chat-mode');
          document.body.classList.remove('chatbot-closed');
        } else {
          // Enter chat mode — expand sidebar to full width
          document.body.classList.add('ic-chat-mode');
          document.body.classList.remove('chatbot-closed');
        }
        // Update tab active states
        var allTabs = headerNav.querySelectorAll('.ic-header-tab');
        for (var ti = 0; ti < allTabs.length; ti++) {
          allTabs[ti].classList.toggle('active', allTabs[ti].dataset.tab === (document.body.classList.contains('ic-chat-mode') ? 'chat' : currentEditor));
        }
        return;
      }

      // Non-chat tab clicked while in chat mode
      if (inChatMode) {
        document.body.classList.remove('ic-chat-mode');
        // Update tab states immediately so active highlight switches
        var allTabs = headerNav.querySelectorAll('.ic-header-tab');
        for (var ti = 0; ti < allTabs.length; ti++) {
          allTabs[ti].classList.toggle('active', allTabs[ti].dataset.tab === tabId);
        }
        // If this tab matches the current page, just exit chat mode (no navigation)
        if (!_isChatPage && tabId === currentEditor) {
          e.preventDefault();
          return;
        }
        // Otherwise let the navigation proceed
      }

      // Already on legacy-ui: switch between Portal and Traces via hash only
      if (path.indexOf('legacy-ui') !== -1 && (tabId === 'traces' || tabId === 'portal')) {
        var href = tab.getAttribute('href');
        if (href) {
          var hashIdx = href.indexOf('#');
          if (hashIdx !== -1) {
            e.preventDefault();
            window.location.hash = href.substring(hashIdx + 1);
          }
        }
      }
    });
  }

  // ── Legacy-ui: update active tab when iframe navigates ──
  // The legacy-ui page updates the hash on every iframe load. If the hash
  // no longer contains MessageViewer, switch the active tab back to Portal.
  if (path.indexOf('legacy-ui') !== -1) {
    function updateLegacyTab() {
      var h = window.location.hash || '';
      var isTraces = h.indexOf('MessageViewer') !== -1;
      var activeId = isTraces ? 'traces' : 'portal';
      var allTabs = document.querySelectorAll('#interclaw-header .ic-header-tab');
      for (var i = 0; i < allTabs.length; i++) {
        allTabs[i].classList.toggle('active', allTabs[i].dataset.tab === activeId);
      }
    }
    window.addEventListener('hashchange', updateLegacyTab);
    // Also run on a short interval to catch history.replaceState (no hashchange event)
    var _lastHash = window.location.hash;
    setInterval(function() {
      if (window.location.hash !== _lastHash) {
        _lastHash = window.location.hash;
        updateLegacyTab();
      }
    }, 500);
  }

  // ── Intercept "Back to standard UI" → wrap in legacy-ui ──
  // Angular's goToZen() calls window.location.replace(zenUrl) with the
  // full Zen path (including production/DTL/BPL context). Monkey-patch
  // Location.prototype.replace so the navigation gets redirected to the
  // legacy-ui wrapper, keeping the user inside InterClaw chrome.
  function zenToLegacy(url) {
    var displayUrl = url;
    if (pathPrefix && displayUrl.indexOf(pathPrefix) === 0) displayUrl = displayUrl.substring(pathPrefix.length);
    // Use the namespace from the browser URL (already resolved by interclaw-header)
    try { displayUrl = decodeURIComponent(displayUrl); } catch (e) {}
    return basePath + 'legacy-ui/index.html?$NAMESPACE=' + namespace + '#' + displayUrl;
  }

  try {
    var _origReplace = Location.prototype.replace;
    Location.prototype.replace = function(url) {
      if (typeof url === 'string' && (url.indexOf('EnsPortal') !== -1 || url.indexOf('.zen') !== -1 || url.indexOf('.cls') !== -1)) {
        window.location.href = zenToLegacy(url);
        return;
      }
      return _origReplace.call(this, url);
    };
  } catch (e) {}

  // Belt-and-suspenders: capture-phase click handler on the #back-to-zen button.
  // Works even if Location.prototype.replace patch fails.
  document.addEventListener('click', function(ev) {
    var btn = ev.target.closest('#back-to-zen, [id="back-to-zen"]');
    if (!btn) return;
    ev.preventDefault();
    ev.stopImmediatePropagation();
    // Build the production config URL directly
    var prodUrl = pathPrefix + '/csp/healthshare/' + namespace.toLowerCase()
      + '/EnsPortal.ProductionConfig.zen?$NAMESPACE=' + namespace;
    window.location.href = zenToLegacy(prodUrl);
  }, true);

  // ── Sync namespace with chatbot if it changes ──
  // Listen for namespace changes from the chatbot module
  window.addEventListener('interclaw-namespace-change', function(e) {
    if (e.detail && e.detail.namespace) {
      var newNs = e.detail.namespace.toUpperCase();
      // Update CSP base to match new namespace
      var newCspBase = pathPrefix + '/csp/healthshare/' + newNs.toLowerCase();
      window._interclawCspBase = newCspBase;
      sessionStorage.setItem('interclaw-cspbase', newCspBase);
      var nsEl = document.getElementById('ic-header-ns-label');
      if (nsEl) nsEl.textContent = newNs;
      // Update tab hrefs (both $NAMESPACE= params and /csp/healthshare/{ns}/ paths)
      var tabLinks = document.querySelectorAll('#interclaw-header .ic-header-tab');
      for (var i = 0; i < tabLinks.length; i++) {
        var href = tabLinks[i].getAttribute('href');
        if (href) {
          href = href.replace(/\$NAMESPACE=[^&#]*/g, '$NAMESPACE=' + newNs);
          href = href.replace(/\/csp\/healthshare\/[^\/]+\//g, '/csp/healthshare/' + newNs.toLowerCase() + '/');
          tabLinks[i].setAttribute('href', href);
        }
      }
    }
  });

})();
