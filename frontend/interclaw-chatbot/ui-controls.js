// interclaw-chatbot/ui-controls.js — Stop/send button, thinking toggle, fullscreen, resize handle
(function(cc) {

  cc.showStopButton = function() {
    cc.isGenerating = true;
    document.getElementById('chatbot-stop').style.display = '';
    document.getElementById('chatbot-send').style.display = 'none';
  };

  cc.hideStopButton = function() {
    cc.isGenerating = false;
    document.getElementById('chatbot-stop').style.display = 'none';
    document.getElementById('chatbot-send').style.display = '';
    cc.updateSendButton();
  };

  cc.stopGeneration = function() {
    if (cc.currentAbortController) {
      cc.currentAbortController.abort();
      cc.currentAbortController = null;
    }
    cc.stopTimer();
    cc.clearResponseTimeout();
    cc.updateStatus('Cancelled');
    cc.finalizeCurrentBubble();
    cc.hideStopButton();
  };

  cc.toggleThinking = function() {
    cc.showThinking = !cc.showThinking;
    sessionStorage.setItem('chatbot-show-thinking', cc.showThinking ? 'true' : 'false');
    cc.updateThinkingToggle();
  };

  cc.updateThinkingToggle = function() {
    var btn = document.getElementById('chatbot-thinking-btn');
    var content = document.getElementById('chatbot-content');
    if (!btn) return;
    if (cc.showThinking) {
      btn.classList.add('thinking-toggle-active');
      btn.title = 'Hide thinking';
      btn.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>';
      if (content) content.classList.remove('thinking-hidden');
    } else {
      btn.classList.remove('thinking-toggle-active');
      btn.title = 'Show thinking';
      btn.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19m-6.72-1.07a3 3 0 11-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>';
      if (content) content.classList.add('thinking-hidden');
    }
  };

  cc.toggleChatbot = function() {
    var isClosing = !document.body.classList.contains('chatbot-closed');
    var wasFullscreen = document.body.classList.contains('chatbot-fullscreen');

    if (isClosing && wasFullscreen) {
      cc.isReloading = true;
      cc.saveState();
      sessionStorage.setItem('chatbot-programmatic-reload', '1');
      sessionStorage.setItem('chatbot-close-after-reload', '1');
      window.location.reload();
      return;
    }

    document.body.classList.toggle('chatbot-closed');
    cc.updateToggleIcon();
  };

  cc.toggleFullscreen = function() {
    document.body.classList.toggle('chatbot-fullscreen');
  };

  // Swap toggle icon: chat bubble (closed) vs chat bubble with X (open)
  cc.updateToggleIcon = function() {
    var btn = document.getElementById('chatbot-toggle');
    if (!btn) return;
    var isClosed = document.body.classList.contains('chatbot-closed');
    if (isClosed) {
      btn.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M15 3v18"/><path d="m10 15-3-3 3-3"/></svg>';
      btn.title = 'Open chat';
    } else {
      btn.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M15 3v18"/><path d="m8 9 3 3-3 3"/></svg>';
      btn.title = 'Close chat';
    }
  };
  // Set initial icon state
  cc.updateToggleIcon();

  // Resize handle drag logic (GPU-accelerated)
  // Default compressed width (25vw from CSS --chatbot-width) is the absolute minimum.
  // The sidebar cannot be dragged narrower than this default.
  (function() {
    var handle = document.getElementById('chatbot-resize-handle');
    var isDragging = false;
    var rafId = null;
    var pendingWidth = null;
    var startX, startWidth;
    // Compute the default --chatbot-width (25vw) in pixels as the minimum drag width.
    // This prevents the user from compressing the sidebar below its default size.
    var DEFAULT_WIDTH = Math.round(window.innerWidth * 0.25);
    var MIN_WIDTH = DEFAULT_WIDTH;
    var minContentWidth = 0; // read from --min-content-width at drag start

    // Recalculate on window resize so the floor stays at 25vw
    window.addEventListener('resize', function() {
      DEFAULT_WIDTH = Math.round(window.innerWidth * 0.25);
      MIN_WIDTH = DEFAULT_WIDTH;
    });

    handle.addEventListener('mousedown', function(e) {
      e.preventDefault();
      isDragging = true;
      startX = e.clientX;
      startWidth = document.getElementById('chatbot-sidebar').offsetWidth || 400;
      // Read minimum content width (set by pages like message-viewer for Zen iframes)
      var mcw = getComputedStyle(document.documentElement).getPropertyValue('--min-content-width');
      minContentWidth = parseInt(mcw) || 0;
      document.body.classList.add('chatbot-dragging');
    });

    document.addEventListener('mousemove', function(e) {
      if (!isDragging) return;
      var delta = startX - e.clientX;
      var newWidth = startWidth + delta;
      if (newWidth < MIN_WIDTH) newWidth = MIN_WIDTH;
      // Enforce minimum content area width (Zen pages have hard layout limits)
      var maxWidth = minContentWidth > 0
        ? Math.max(window.innerWidth - minContentWidth, MIN_WIDTH)
        : window.innerWidth * 0.9;
      if (newWidth > maxWidth) newWidth = maxWidth;
      pendingWidth = newWidth;
      if (!rafId) {
        rafId = requestAnimationFrame(function() {
          if (pendingWidth !== null) {
            document.documentElement.style.setProperty('--chatbot-width', pendingWidth + 'px');
            pendingWidth = null;
          }
          rafId = null;
        });
      }
    });

    document.addEventListener('mouseup', function() {
      if (!isDragging) return;
      isDragging = false;
      document.body.classList.remove('chatbot-dragging');
      if (rafId) { cancelAnimationFrame(rafId); rafId = null; }
      if (pendingWidth !== null) {
        document.documentElement.style.setProperty('--chatbot-width', pendingWidth + 'px');
        pendingWidth = null;
      }
    });
  })();

  cc.updateSendButton = function() {
    var input = document.getElementById('chatbot-input');
    var sendBtn = document.getElementById('chatbot-send');
    if (!input || !sendBtn) return;
    if (input.value.trim() || cc.attachedFiles.length > 0) {
      sendBtn.classList.add('active');
      sendBtn.disabled = false;
    } else {
      sendBtn.classList.remove('active');
      sendBtn.disabled = true;
    }
  };
  cc.updateSendButton();

  cc.setInputDisabled = function(disabled) {
    var input = document.getElementById('chatbot-input');
    var sendBtn = document.getElementById('chatbot-send');
    var uploadBtn = document.querySelector('.chatbot-upload-btn');
    if (input) input.disabled = disabled;
    if (sendBtn) sendBtn.disabled = disabled;
    if (uploadBtn) { uploadBtn.style.pointerEvents = disabled ? 'none' : ''; uploadBtn.style.opacity = disabled ? '0.5' : ''; }
  };

})(window._cc);
