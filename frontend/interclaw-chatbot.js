// interclaw-chatbot.js — Thin loader for modular chatbot sidebar
// Editors load this file via <script src="../interclaw-chatbot.js">
// This bootstraps the modular system in interclaw-chatbot/
(function() {
  'use strict';
  if (document.getElementById('interclaw-chatbot-styles')) return; // already loaded

  var scripts = document.getElementsByTagName('script');
  for (var i = 0; i < scripts.length; i++) {
    if (scripts[i].src && scripts[i].src.indexOf('interclaw-chatbot.js') !== -1) {
      var s = document.createElement('script');
      s.src = scripts[i].src.replace(/interclaw-chatbot\.js.*$/, '') + 'interclaw-chatbot/index.js';
      document.head.appendChild(s);
      break;
    }
  }
})();
