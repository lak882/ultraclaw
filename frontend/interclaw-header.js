// interclaw-header.js — Shared top navigation header for all InterClaw editors
// Editors load this via <script src="../interclaw-header.js"> BEFORE <app-root>
(function() {
  'use strict';
  if (document.getElementById('interclaw-header')) return; // already loaded

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
  else if (path.indexOf('message-viewer') !== -1) currentEditor = 'traces';
  else if (path.indexOf('rule-editor') !== -1) currentEditor = 'copilot';
  else currentEditor = 'copilot'; // interop-editor = copilot

  // Check for chat fullscreen mode
  var params = new URLSearchParams(loc.search);
  var viewMode = params.get('view');
  var currentTab = viewMode === 'chat' ? 'chat' : currentEditor;

  // ── Namespace: last opened > URL param > default IC-TESTING ──
  var urlNs = params.get('$NAMESPACE') || params.get('NAMESPACE') || '';
  var storedNs = localStorage.getItem('interclaw-namespace');
  var namespace = urlNs || storedNs || 'IC-TESTING';
  namespace = namespace.toUpperCase();
  localStorage.setItem('interclaw-namespace', namespace);

  // ── Build tab URLs (preserve namespace in query) ──
  function tabUrl(editor, extra) {
    var url = basePath + editor + '/index.html?$NAMESPACE=' + encodeURIComponent(namespace);
    if (extra) url += '&' + extra;
    return url;
  }

  var tabs = [
    {
      id: 'chat', label: 'Chat',
      url: tabUrl('interop-editor', 'view=chat'),
      icon: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>'
    },
    {
      id: 'copilot', label: 'Copilot',
      url: tabUrl('interop-editor'),
      icon: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m16 18 6-6-6-6"/><path d="m8 6-6 6 6 6"/></svg>'
    },
    {
      id: 'skills', label: 'Skill Editor',
      url: tabUrl('skills-editor'),
      icon: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>'
    },
    {
      id: 'traces', label: 'Traces',
      url: tabUrl('message-viewer'),
      icon: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>'
    }
  ];

  // ── Inject CSS ──
  var cssLink = document.createElement('link');
  cssLink.rel = 'stylesheet';
  cssLink.id = 'interclaw-header-styles';
  cssLink.href = basePath + 'interclaw-header.css';
  document.head.appendChild(cssLink);

  // ── Build header HTML ──
  var brandSvg = '<svg width="18" height="18" viewBox="0 0 512 512" stroke="none">'
    + '<path fill="#2F2A95" d="m175.656 22.375-48.47 82.094c-23.017 4.384-43.547 11.782-60.124 22.374-24.436 15.613-40.572 37.414-45.5 67.875-4.79 29.62 1.568 68.087 24.125 116.093 93.162 22.88 184.08-10.908 257.25-18.813 37.138-4.012 71.196-.898 96.344 22.97 22.33 21.19 36.21 56.808 41.908 113.436 29.246-35.682 44.538-69.065 49.343-99.594 5.543-35.207-2.526-66.97-20.31-95.593-8.52-13.708-19.368-26.618-32-38.626l14.217-33-41.218 10.625c-8.637-6.278-17.765-12.217-27.314-17.782l-7.03-59.782-38.157 37.406a423.505 423.505 0 0 0-38.158-13.812l-8.375-71.28-57.625 56.5c-9.344-1.316-18.625-2.333-27.812-2.97l-31.094-78.125z"/>'
    + '<path fill="#00B2A9" d="M222 325.345c-39.146 7.525-82.183 14.312-127.156 11.686 47.403 113.454 207.056 224.082 260.125 87-101.18 33.84-95.303-49.595-132.97-98.686z"/>'
    + '</svg>';

  var nsSvg = '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M3 5v14c0 1.66 4.03 3 9 3s9-1.34 9-3V5"/><path d="M3 12c0 1.66 4.03 3 9 3s9-1.34 9-3"/></svg>';

  var tabsHtml = tabs.map(function(t) {
    var cls = 'ic-header-tab' + (t.id === currentTab ? ' active' : '');
    return '<a class="' + cls + '" href="' + t.url + '" data-tab="' + t.id + '">'
      + t.icon + '<span>' + t.label + '</span></a>';
  }).join('');

  var header = document.createElement('div');
  header.id = 'interclaw-header';
  header.innerHTML =
    '<div class="ic-header-brand">' + brandSvg + '<span>InterClaw</span></div>'
    + '<nav class="ic-header-tabs">' + tabsHtml + '</nav>'
    + '<div class="ic-header-right">'
    + '<div class="ic-header-model-selector" id="ic-header-model-selector">'
    +   '<button class="ic-header-model-btn" id="ic-header-model-btn" type="button">'
    +     '<span id="ic-header-model-label">Claude Sonnet 4.5</span>'
    +     '<svg width="10" height="10" viewBox="0 0 10 10" fill="currentColor"><path d="M2 4l3 3 3-3"/></svg>'
    +   '</button>'
    +   '<div class="ic-header-model-dropdown" id="ic-header-model-dropdown">'
    +     '<div class="ic-header-model-option" data-value="opus"><span class="model-name">Claude Opus 4.6</span><span class="model-desc">Most capable for complex, ambitious work</span></div>'
    +     '<div class="ic-header-model-option selected" data-value="sonnet"><span class="model-name">Claude Sonnet 4.5</span><span class="model-desc">Best balance of speed and intelligence</span></div>'
    +     '<div class="ic-header-model-option" data-value="haiku"><span class="model-name">Claude Haiku 4.5</span><span class="model-desc">Fastest responses for simple tasks</span></div>'
    +   '</div>'
    + '</div>'
    + '</div>';

  // Insert at very top of body
  document.body.insertBefore(header, document.body.firstChild);
  document.body.classList.add('ic-header-active');

  // ── Header model selector (chat mode only) ──
  (function() {
    var modelBtn = document.getElementById('ic-header-model-btn');
    var modelDD = document.getElementById('ic-header-model-dropdown');
    var modelLabel = document.getElementById('ic-header-model-label');
    var modelLabels = { opus: 'Claude Opus 4.6', sonnet: 'Claude Sonnet 4.5', haiku: 'Claude Haiku 4.5' };

    modelBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      modelDD.classList.toggle('open');
    });

    modelDD.addEventListener('click', function(e) {
      var opt = e.target.closest('.ic-header-model-option');
      if (opt && opt.dataset.value) {
        var val = opt.dataset.value;
        modelLabel.textContent = modelLabels[val] || val;
        var allOpts = modelDD.querySelectorAll('.ic-header-model-option');
        for (var i = 0; i < allOpts.length; i++) {
          allOpts[i].classList.toggle('selected', allOpts[i].dataset.value === val);
        }
        modelDD.classList.remove('open');
        // Sync with chatbot model selector if available
        if (window._cc && window._cc.setSelectedModel) {
          window._cc.setSelectedModel(val);
        }
      }
    });

    document.addEventListener('click', function() {
      modelDD.classList.remove('open');
    });
  })();

  // ── Chat tab: chatbot fills below the shared header ──
  if (viewMode === 'chat') {
    document.body.classList.add('ic-chat-mode');
  }

  // ── Intercept "Back to standard UI" → wrap in message-viewer ──
  // Angular's goToZen() calls window.location.replace(zenUrl) with the
  // full Zen path (including production/DTL/BPL context). Monkey-patch
  // Location.prototype.replace so the navigation gets redirected to the
  // message-viewer wrapper, keeping the user inside InterClaw chrome.
  try {
    var _origReplace = Location.prototype.replace;
    Location.prototype.replace = function(url) {
      if (typeof url === 'string' && (url.indexOf('EnsPortal') !== -1 || url.indexOf('.zen') !== -1)) {
        var ns = (localStorage.getItem('interclaw-namespace') || namespace).toUpperCase();
        window.location.href = basePath + 'message-viewer/index.html?zen='
          + encodeURIComponent(url) + '&$NAMESPACE=' + encodeURIComponent(ns);
        return;
      }
      return _origReplace.call(this, url);
    };
  } catch (e) {
    // Fallback: capture-phase click interceptor for browsers that lock Location.prototype
    document.addEventListener('click', function(ev) {
      var btn = ev.target.closest('#back-to-zen, [name="BackToZen"]');
      if (!btn) return;
      ev.preventDefault();
      ev.stopImmediatePropagation();
      var ns = (localStorage.getItem('interclaw-namespace') || namespace).toUpperCase();
      window.location.href = basePath + 'message-viewer/index.html?$NAMESPACE=' + encodeURIComponent(ns);
    }, true);
  }

  // ── Sync namespace with chatbot if it changes ──
  // Listen for namespace changes from the chatbot module
  window.addEventListener('interclaw-namespace-change', function(e) {
    if (e.detail && e.detail.namespace) {
      var newNs = e.detail.namespace.toUpperCase();
      localStorage.setItem('interclaw-namespace', newNs);
      var nsEl = document.getElementById('ic-header-ns');
      if (nsEl) nsEl.textContent = newNs;
    }
  });

})();
