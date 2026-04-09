// interclaw-chatbot/auth.js — Auth gate: hide chatbot until logged in
(function(cc) {

  (function() {
    function checkAuth() {
      // Pages with data-no-auth-gate bypass Angular login detection (e.g., skills-editor)
      if (document.body.hasAttribute('data-no-auth-gate')) {
        document.body.classList.remove('chatbot-auth-gate');
        return;
      }
      var postLogin = document.querySelector('app-root app-dashboard')
        || document.querySelector('app-root app-dtl')
        || document.querySelector('app-root app-rule')
        || document.querySelector('app-root app-bpl')
        || document.querySelector('app-root app-message-viewer');
      if (postLogin) {
        var ar = document.querySelector('app-root');
        if (ar) ar.style.transition = 'none';
        document.body.classList.remove('chatbot-auth-gate');
        requestAnimationFrame(function() {
          requestAnimationFrame(function() { if (ar) ar.style.transition = ''; });
        });
      } else {
        document.body.classList.add('chatbot-auth-gate');
      }
    }
    new MutationObserver(checkAuth).observe(document.body, { childList: true, subtree: true });
    setInterval(checkAuth, 500);
  })();

})(window._cc);
