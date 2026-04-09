// interclaw-chatbot/index.js — Bootstrap: creates _cc namespace, injects CSS, loads modules in order
(function() {
  'use strict';

  // Determine base path (path to interclaw-chatbot/ folder)
  var scripts = document.getElementsByTagName('script');
  var basePath = '';
  for (var i = 0; i < scripts.length; i++) {
    if (scripts[i].src && scripts[i].src.indexOf('interclaw-chatbot/index.js') !== -1) {
      basePath = scripts[i].src.replace(/index\.js.*$/, '');
      break;
    }
  }

  // Create shared state namespace
  window._cc = { basePath: basePath };

  // Inject CSS
  var link = document.createElement('link');
  link.rel = 'stylesheet';
  link.id = 'interclaw-chatbot-styles';
  link.href = basePath + 'chatbot.css';
  document.head.appendChild(link);

  // Load marked.js for markdown rendering
  if (typeof marked === 'undefined') {
    var markedScript = document.createElement('script');
    markedScript.src = 'https://cdnjs.cloudflare.com/ajax/libs/marked/12.0.2/marked.min.js';
    document.head.appendChild(markedScript);
  }

  // Load modules in order, call _cc.init() when done
  var modules = [
    'template.js',
    'state.js',
    'config.js',
    'reasoning-steps.js',
    'timer-usage.js',
    'ui-controls.js',
    'attachments.js',
    'markdown.js',
    'messages.js',
    'stream.js',
    'bridge.js',
    'send.js',
    'commands.js',
    'welcome.js',
    'namespace.js',
    'auth.js',
    'goto.js',
    'init.js'
  ];

  function loadNext(i) {
    if (i >= modules.length) {
      if (window._cc && window._cc.init) {
        window._cc.init();
      }
      return;
    }
    var s = document.createElement('script');
    s.src = basePath + modules[i];
    s.onload = function() { loadNext(i + 1); };
    s.onerror = function() {
      console.error('[interclaw] Failed to load module:', modules[i]);
      loadNext(i + 1);
    };
    document.head.appendChild(s);
  }

  loadNext(0);
})();
