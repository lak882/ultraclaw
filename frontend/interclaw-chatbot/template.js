// interclaw-chatbot/template.js — HTML template injection (drag overlay, reload overlay, sidebar, toggle button)
(function(cc) {

  // Drag overlay (must be before app-root for z-index stacking)
  var dragOverlay = document.createElement('div');
  dragOverlay.className = 'drag-overlay';
  document.body.insertBefore(dragOverlay, document.body.firstChild);

  // Reload overlay
  var reloadOverlay = document.createElement('div');
  reloadOverlay.className = 'reload-overlay';
  reloadOverlay.id = 'reload-overlay';
  reloadOverlay.style.display = 'none';
  document.body.insertBefore(reloadOverlay, document.body.firstChild);

  if (sessionStorage.getItem('chatbot-programmatic-reload')) {
    reloadOverlay.style.display = 'block';
    document.documentElement.style.background = 'white';
    document.body.style.background = 'white';
  }

  // Sidebar + toggle button
  var _ccTmp = document.createElement('div');
  _ccTmp.innerHTML = `  <div id="chatbot-sidebar">
    <div class="chatbot-resize-handle" id="chatbot-resize-handle"></div>
    <div class="chatbot-toolbar">
      <div class="chatbot-toolbar-title">
        <span class="chatbot-brand"><svg class="chatbot-brand-icon" width="20" height="20" viewBox="0 0 512 512" stroke="none"><path fill="#2F2A95" d="m175.656 22.375-48.47 82.094c-23.017 4.384-43.547 11.782-60.124 22.374-24.436 15.613-40.572 37.414-45.5 67.875-4.79 29.62 1.568 68.087 24.125 116.093 93.162 22.88 184.08-10.908 257.25-18.813 37.138-4.012 71.196-.898 96.344 22.97 22.33 21.19 36.21 56.808 41.908 113.436 29.246-35.682 44.538-69.065 49.343-99.594 5.543-35.207-2.526-66.97-20.31-95.593-8.52-13.708-19.368-26.618-32-38.626l14.217-33-41.218 10.625c-8.637-6.278-17.765-12.217-27.314-17.782l-7.03-59.782-38.157 37.406a423.505 423.505 0 0 0-38.158-13.812l-8.375-71.28-57.625 56.5c-9.344-1.316-18.625-2.333-27.812-2.97l-31.094-78.125z"/><path fill="#00B2A9" d="M222 325.345c-39.146 7.525-82.183 14.312-127.156 11.686 47.403 113.454 207.056 224.082 260.125 87-101.18 33.84-95.303-49.595-132.97-98.686z"/></svg> InterClaw</span>
        <span class="chatbot-brand-sep"></span>
        <div class="chatbot-model-selector" id="chatbot-model-selector">
          <button class="chatbot-model-ghost" id="chatbot-model-btn" type="button">
            <span id="chatbot-model-label">Claude Sonnet 4.5</span>
            <svg width="10" height="10" viewBox="0 0 10 10" fill="currentColor"><path d="M2 4l3 3 3-3"/></svg>
          </button>
          <div class="chatbot-model-dropdown" id="chatbot-model-dropdown">
            <div class="chatbot-model-option" data-value="opus">
              <span class="model-name">Claude Opus 4.6</span>
              <span class="model-desc">Most capable for complex, ambitious work</span>
            </div>
            <div class="chatbot-model-option selected" data-value="sonnet">
              <span class="model-name">Claude Sonnet 4.5</span>
              <span class="model-desc">Best balance of speed and intelligence</span>
            </div>
            <div class="chatbot-model-option" data-value="haiku">
              <span class="model-name">Claude Haiku 4.5</span>
              <span class="model-desc">Fastest responses for simple tasks</span>
            </div>
          </div>
        </div>
      </div>
      <div style="display:flex;align-items:center;gap:2px">
      </div>
    </div>

    <div class="chatbot-status">
      <span class="chatbot-status-dot"></span>
      <span id="chatbot-status-text">Not connected</span>
    </div>

    <div class="chatbot-content" id="chatbot-content"><div id="chatbot-loading" style="display:flex;flex-direction:column;align-items:center;justify-content:center;flex:1;gap:16px;opacity:1;transition:opacity 0.4s ease"><div style="width:64px;height:64px;animation:ic-pulse 2s ease-in-out infinite"><style>@keyframes ic-pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:0.5;transform:scale(0.95)}}</style><svg width="64" height="64" viewBox="0 0 512 512" stroke="none"><path fill="#2F2A95" d="m175.656 22.375-48.47 82.094c-23.017 4.384-43.547 11.782-60.124 22.374-24.436 15.613-40.572 37.414-45.5 67.875-4.79 29.62 1.568 68.087 24.125 116.093 93.162 22.88 184.08-10.908 257.25-18.813 37.138-4.012 71.196-.898 96.344 22.97 22.33 21.19 36.21 56.808 41.908 113.436 29.246-35.682 44.538-69.065 49.343-99.594 5.543-35.207-2.526-66.97-20.31-95.593-8.52-13.708-19.368-26.618-32-38.626l14.217-33-41.218 10.625c-8.637-6.278-17.765-12.217-27.314-17.782l-7.03-59.782-38.157 37.406a423.505 423.505 0 0 0-38.158-13.812l-8.375-71.28-57.625 56.5c-9.344-1.316-18.625-2.333-27.812-2.97l-31.094-78.125z"/><path fill="#00B2A9" d="M222 325.345c-39.146 7.525-82.183 14.312-127.156 11.686 47.403 113.454 207.056 224.082 260.125 87-101.18 33.84-95.303-49.595-132.97-98.686z"/></svg></div><span style="font-size:var(--fr-styles-font-size-xs);color:var(--fr-styles-color-dark-grey)">Connecting...</span></div></div>

    <div class="chatbot-input-container">
      <div class="chatbot-typeahead" id="chatbot-typeahead"></div>
      <div class="chatbot-input-wrapper" id="chatbot-input-wrapper">
        <div class="chatbot-attachments" id="chatbot-attachments" style="display:none"></div>
        <div class="chatbot-attachments-divider" id="chatbot-attachments-divider"></div>
        <div class="chatbot-cmd-panel" id="chatbot-cmd-panel">
          <div class="chatbot-cmd-panel-body" id="chatbot-cmd-panel-body"></div>
        </div>
        <div class="chatbot-cmd-panel-divider" id="chatbot-cmd-panel-divider"></div>
        <div class="chatbot-mode-panel" id="chatbot-mode-panel">
          <div class="chatbot-cmd-panel-header">Modes</div>
          <div class="chatbot-mode-item selected" data-mode="edit">
            <div class="chatbot-mode-item-icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m16 18 6-6-6-6"/><path d="m8 6-6 6 6 6"/></svg></div>
            <div class="chatbot-mode-item-text"><div class="chatbot-mode-item-title">Edit automatically</div><div class="chatbot-mode-item-desc">Agent will edit files automatically</div></div>
          </div>
          <div class="chatbot-mode-item" data-mode="plan">
            <div class="chatbot-mode-item-icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 6h4"/><path d="M2 10h4"/><path d="M2 14h4"/><path d="M2 18h4"/><rect width="16" height="20" x="4" y="2" rx="2"/><path d="M9.5 8h5"/><path d="M9.5 12H16"/><path d="M9.5 16H14"/></svg></div>
            <div class="chatbot-mode-item-text"><div class="chatbot-mode-item-title">Plan mode</div><div class="chatbot-mode-item-desc">Agent will explore code and present a plan before editing</div></div>
          </div>
          <div class="chatbot-mode-item" data-mode="ask">
            <div class="chatbot-mode-item-icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2.992 16.342a2 2 0 0 1 .094 1.167l-1.065 3.29a1 1 0 0 0 1.236 1.168l3.413-.998a2 2 0 0 1 1.099.092 10 10 0 1 0-4.777-4.719"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><path d="M12 17h.01"/></svg></div>
            <div class="chatbot-mode-item-text"><div class="chatbot-mode-item-title">Manually approve edits</div><div class="chatbot-mode-item-desc">Agent will ask for approval before making edits</div></div>
          </div>
          <!-- bypass mode hidden — edit mode maps to bypassPermissions -->
          <!--
          <div class="chatbot-mode-item" data-mode="bypass">
            <div class="chatbot-mode-item-icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2 3 14h9l-1 8 10-12h-9l1-8z"/></svg></div>
            <div class="chatbot-mode-item-text"><div class="chatbot-mode-item-title">Bypass permissions</div><div class="chatbot-mode-item-desc">Agent uses all tools without asking for approval</div></div>
          </div>
          -->
          <div class="chatbot-effort-row">
            <div class="chatbot-effort-label">
              <div class="chatbot-mode-item-icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 14 4-4"/><path d="M3.34 19a10 10 0 1 1 17.32 0"/></svg></div>
              <span>Reasoning Effort</span>
            </div>
            <div class="chatbot-effort-switch" id="chatbot-effort-switch">
              <button class="chatbot-effort-opt" data-effort="low">Low</button>
              <button class="chatbot-effort-opt active" data-effort="medium">Medium</button>
              <button class="chatbot-effort-opt" data-effort="high">High</button>
              <button class="chatbot-effort-opt" data-effort="max">Max</button>
            </div>
          </div>
        </div>
        <div class="chatbot-mode-panel-divider" id="chatbot-mode-panel-divider"></div>
        <div class="chatbot-edit-accept" id="chatbot-edit-accept" style="display:none">
          <div class="chatbot-plan-accept-header">
            <div class="chatbot-plan-accept-title">Approve this action?</div>
            <div class="chatbot-plan-accept-subtitle">Review the proposed changes above</div>
          </div>
          <div class="chatbot-plan-accept-options">
            <button class="chatbot-plan-opt selected" data-edit="accept"><span class="chatbot-plan-opt-num">1</span>Yes</button>
            <button class="chatbot-plan-opt" data-edit="accept-all"><span class="chatbot-plan-opt-num">2</span>Yes, allow all edits during this session (shift+tab)</button>
            <button class="chatbot-plan-opt" data-edit="reject"><span class="chatbot-plan-opt-num">3</span>No</button>
          </div>
          <div class="chatbot-plan-accept-input">
            <textarea class="chatbot-input" id="chatbot-edit-input" placeholder="Tell Claude what to change instead" rows="1"></textarea>
          </div>
          <div class="chatbot-plan-accept-hint">Esc to cancel</div>
        </div>
        <div class="chatbot-plan-accept" id="chatbot-plan-accept" style="display:none">
          <div class="chatbot-plan-accept-header">
            <div class="chatbot-plan-accept-title">Accept this plan?</div>
            <div class="chatbot-plan-accept-subtitle">Review the plan above before deciding</div>
          </div>
          <div class="chatbot-plan-accept-options">
            <button class="chatbot-plan-opt selected" data-plan="auto"><span class="chatbot-plan-opt-num">1</span>Yes, and auto-accept</button>
            <button class="chatbot-plan-opt" data-plan="manual"><span class="chatbot-plan-opt-num">2</span>Yes, and manually approve edits</button>
            <button class="chatbot-plan-opt" data-plan="keep"><span class="chatbot-plan-opt-num">3</span>No, keep planning</button>
          </div>
          <div class="chatbot-plan-accept-input">
            <textarea class="chatbot-input" id="chatbot-plan-input" placeholder="Tell Claude what to do instead" rows="1"></textarea>
          </div>
          <div class="chatbot-plan-accept-hint">Esc to cancel</div>
        </div>
        <div class="chatbot-input-normal" id="chatbot-input-normal">
        <div class="chatbot-input-top">
          <textarea class="chatbot-input" id="chatbot-input" placeholder="Describe a task..." rows="1"></textarea>
          <input type="file" id="chatbot-file-input" multiple hidden>
        </div>
        <div class="chatbot-input-divider"></div>
        <div class="chatbot-input-bottom">
          <div class="chatbot-input-bottom-left">
            <label class="chatbot-upload-btn" for="chatbot-file-input" title="Attach file"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg></label>
            <button class="chatbot-cmd-btn" id="chatbot-cmd-btn" type="button" title="Commands"><svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M3.924 5.02a.75.75 0 011.056-.096l3 2.5a.75.75 0 010 1.152l-3 2.5a.75.75 0 11-.96-1.152L6.328 8 4.02 6.076a.75.75 0 01-.096-1.056zM8.25 10.5a.75.75 0 000 1.5h3a.75.75 0 000-1.5h-3z"/><path fill-rule="evenodd" d="M0 3.25A2.25 2.25 0 012.25 1h11.5A2.25 2.25 0 0116 3.25v9.5A2.25 2.25 0 0113.75 15H2.25A2.25 2.25 0 010 12.75v-9.5zm2.25-.75a.75.75 0 00-.75.75v9.5c0 .414.336.75.75.75h11.5a.75.75 0 00.75-.75v-9.5a.75.75 0 00-.75-.75H2.25z" clip-rule="evenodd"/></svg></button>
            <span class="chatbot-context-sep" id="chatbot-context-sep" style="display:none">|</span><span class="chatbot-context-body" id="chatbot-context-body" style="display:none"></span>
          </div>
          <div class="chatbot-input-bottom-right">
            <div class="chatbot-mode-label" id="chatbot-mode-label"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m16 18 6-6-6-6"/><path d="m8 6-6 6 6 6"/></svg><span>Edit automatically</span></div>
            <button class="chatbot-send-btn chatbot-stop-btn" id="chatbot-stop" onclick="stopGeneration()" title="Stop" style="display:none"><svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><rect x="4" y="4" width="16" height="16" rx="2"/></svg></button>
            <button class="chatbot-send-btn" id="chatbot-send" onclick="sendMessage()" title="Send" disabled><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="19" x2="12" y2="5"/><polyline points="5 12 12 5 19 12"/></svg></button>
          </div>
        </div>
        </div>
      </div>
    </div>
  </div>

  <button id="chatbot-toggle" onclick="toggleChatbot()" title="Open chat"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M15 3v18"/><path d="m10 15-3-3 3-3"/></svg></button>`;
  while (_ccTmp.firstChild) document.body.appendChild(_ccTmp.firstChild);

})(window._cc);
