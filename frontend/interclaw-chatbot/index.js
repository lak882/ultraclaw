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
  link.href = basePath + 'chatbot.css?v=3';
  document.head.appendChild(link);

  var chatsLink = document.createElement('link');
  chatsLink.rel = 'stylesheet';
  chatsLink.id = 'interclaw-chats-sidebar-styles';
  chatsLink.href = basePath + 'chats-sidebar.css?v=7';
  document.head.appendChild(chatsLink);

  // ChatGPT-inspired light theme — loaded LAST so it overrides chatbot.css
  // and chats-sidebar.css. To roll back: delete this block and the file.
  var themeLink = document.createElement('link');
  themeLink.rel = 'stylesheet';
  themeLink.id = 'interclaw-chatgpt-theme';
  themeLink.href = basePath + 'chatgpt-theme.css?v=34';
  document.head.appendChild(themeLink);

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
    'chats-sidebar.js',
    'init.js'
  ];

  // Cache-busting version — bump this to force-reload all modules
  var MODULE_VERSION = 26;

  function loadNext(i) {
    if (i >= modules.length) {
      if (window._cc && window._cc.init) {
        window._cc.init();
      }
      return;
    }
    var s = document.createElement('script');
    s.src = basePath + modules[i] + '?v=' + MODULE_VERSION;
    s.onload = function() { loadNext(i + 1); };
    s.onerror = function() {
      console.error('[interclaw] Failed to load module:', modules[i]);
      loadNext(i + 1);
    };
    document.head.appendChild(s);
  }

  loadNext(0);
})();
