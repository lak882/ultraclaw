// interclaw-chatbot/template.js — HTML template injection (drag overlay, sidebar, toggle button)
(function(cc) {

  // Drag overlay (captures mouse events during resize)
  var dragOverlay = document.createElement('div');
  dragOverlay.className = 'drag-overlay';
  document.body.insertBefore(dragOverlay, document.body.firstChild);


  // Sidebar + toggle button
  var _ccTmp = document.createElement('div');
  _ccTmp.innerHTML = `  <div id="chatbot-sidebar">
    <div class="chatbot-resize-handle" id="chatbot-resize-handle"></div>
    <div class="chatbot-toolbar">
      <div class="chatbot-toolbar-title">
        <span class="chatbot-brand"><svg class="chatbot-brand-icon" width="16" height="16" viewBox="-18 0 57 57" stroke="none"><polygon fill="#2F2A95" points="7.2 8 0.2 4.5 0.2 49.3 14.3 56.3 14.3 48.5 7.2 44.9"/><polygon fill="#00B2A9" points="14.3 48.5 21.3 52 21.3 7.2 7.2 0.2 7.2 8 14.3 11.6"/></svg> InterClaw</span>
        <span class="chatbot-brand-sep"></span>

      </div>
      <div style="display:flex;align-items:center;gap:2px">
      </div>
    </div>

    <div class="chatbot-status">
      <span class="chatbot-status-dot"></span>
      <span id="chatbot-status-text">Not connected</span>
    </div>

    <div class="chatbot-content" id="chatbot-content"><div id="chatbot-loading" style="display:flex;flex-direction:column;align-items:center;justify-content:center;flex:1;gap:16px;opacity:1;transition:opacity 0.4s ease"><svg viewBox="0 0 22 57" style="width:80px;height:80px;animation:chatbot-logo-pulse 2s ease-in-out infinite"><polygon fill="#2F2A95" points="7.2 8 0.2 4.5 0.2 49.3 14.3 56.3 14.3 48.5 7.2 44.9"/><polygon fill="#00B2A9" points="14.3 48.5 21.3 52 21.3 7.2 7.2 0.2 7.2 8 14.3 11.6"/></svg><span style="font-size:var(--fr-styles-font-size-xs);color:var(--fr-styles-color-dark-grey)">Connecting...</span></div></div>

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
          <div class="chatbot-mode-separator"></div>
          <div class="chatbot-effort-row">
            <div class="chatbot-effort-label">
              <div class="chatbot-mode-item-icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 14 4-4"/><path d="M3.34 19a10 10 0 1 1 17.32 0"/></svg></div>
              <span>Effort</span>
            </div>
            <div class="chatbot-effort-switch" id="chatbot-effort-switch">
              <button class="chatbot-effort-opt" data-effort="low">Low</button>
              <button class="chatbot-effort-opt active" data-effort="medium">Med</button>
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
            <textarea class="chatbot-input" id="chatbot-edit-input" placeholder="Tell InterClaw what to change instead" rows="1"></textarea>
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
            <textarea class="chatbot-input" id="chatbot-plan-input" placeholder="Tell InterClaw what to do instead" rows="1"></textarea>
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

  <button id="chatbot-toggle" onclick="toggleChatbot()" title="Open chat"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M15 3v18"/><path d="m8 9 3 3-3 3"/></svg></button>`;
  while (_ccTmp.firstChild) document.body.appendChild(_ccTmp.firstChild);

  // Move toggle button into the header bar (flex child, not fixed-positioned)
  var _toggleSlot = document.getElementById('ic-header-toggle-slot');
  var _toggle = document.getElementById('chatbot-toggle');
  if (_toggleSlot && _toggle) _toggleSlot.appendChild(_toggle);

})(window._cc);
