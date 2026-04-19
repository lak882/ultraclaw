// interclaw-chatbot/auth.js — Auth gate (no-op in chat-only mode)
(function(cc) {
  // Chat mode has no Angular app to gate on. Legacy-ui and skills-editor
  // pages use data-no-auth-gate to bypass. Nothing to do here.
})(window._cc);
