// chat-doc-render.js — canonical ChatDoc renderer (phase 1 of doc-based refactor).
//
// ChatDoc shape:
//   { chatId, rev, title, status, bridgeId,
//     turns: [
//       { id, role:'user'|'assistant'|'system'|'error'|'tool',
//         text, files?, steps?, usage?, status? } ] }
//
// This renderer is authoritative for rehydrated turns — it rebuilds
// #chatbot-content from scratch given a doc. Live turns still use the
// existing event-stream DOM mutations until phase 3 replaces that with
// a "render(doc) on every poll" loop.
(function(cc) {
  'use strict';

  function escapeHtml(s) {
    var d = document.createElement('div');
    d.textContent = s == null ? '' : String(s);
    return d.innerHTML;
  }

  // Renders a step row identical to the live reasoning-steps output so
  // live-streaming view and retrospect view are pixel-equivalent. Uses the
  // same `reasoning-tool-lines` / `reasoning-tool-line` structure for tool
  // bodies and `renderMarkdown` for thinking bodies, mirroring
  // reasoning-steps.js `toggleStepContent`. The step el gets a unique id
  // and we reuse `cc.toggleStepContent` so the expand/collapse behaves the
  // same way (auto-expanded tracking, chevron state).
  var _replayStepCounter = 0;
  function renderStepRow(step) {
    _replayStepCounter++;
    var stepId = step.id || ('replay-' + _replayStepCounter);
    var el = document.createElement('div');
    el.className = 'reasoning-step';
    el.id = 'reasoning-step-' + stepId;
    el.dataset.stepType = step.type || 'tool';
    el.dataset.content = step.body || '';
    el.dataset.rawOutput = step.rawOutput || '';
    var iconHtml = step.type === 'thinking'
      ? '<div class="reasoning-step-icon"><div class="reasoning-dot"></div></div>'
      : '<div class="reasoning-step-icon reasoning-tool-icon">' + cc.getToolIcon(step.toolName || 'wrench') + '</div>';
    var row = document.createElement('div');
    row.className = 'reasoning-step-row';
    // Humanize the title through the same function the live stream uses.
    // BP writes raw tool names (run_sql, put_class); live renders "Running
    // SQL", "Pushing class" via cc.getToolLabel. Keep the two paths in
    // sync by running the same mapping here.
    var displayTitle = step.title || '';
    if (step.type !== 'thinking' && cc.getToolLabel) {
      displayTitle = cc.getToolLabel(step.toolName || step.title || '', null);
    }
    row.innerHTML = iconHtml +
      '<button class="reasoning-step-label clickable">' +
        '<span style="flex:1">' + escapeHtml(displayTitle) + '</span>' +
        '<span class="reasoning-chevron-step' + (!step.body ? ' invisible' : '') + '">' + cc.CHEVRON_SVG + '</span>' +
      '</button>';
    el.appendChild(row);
    // Hook the same toggle function the live path uses. It handles the
    // tool-lines split, markdown for thinking, chevron state, etc.
    if (step.body) {
      row.querySelector('.reasoning-step-label').onclick = function(e) {
        e.stopPropagation();
        var isOpen = el.querySelector('.reasoning-step-content');
        if (isOpen) {
          isOpen.remove();
          var chev = el.querySelector('.reasoning-chevron-step');
          if (chev) chev.classList.remove('open');
        } else if (cc.toggleStepContent) {
          cc.toggleStepContent(stepId);
        }
      };
    }
    return el;
  }

  function renderSteps(steps) {
    if (!steps || !steps.length) return null;
    var wrap = document.createElement('div');
    wrap.className = 'reasoning-steps';
    var toggle = document.createElement('button');
    toggle.className = 'reasoning-toggle';
    toggle.innerHTML = '<span class="chevron-icon">' + cc.CHEVRON_SVG + '</span> Show steps';
    var list = document.createElement('div');
    list.className = 'reasoning-list';
    list.style.display = 'none';
    // Live adds a .reasoning-connector div as the first child of
    // .reasoning-list once a second step arrives. Match that here so the
    // retrospect view has the same vertical line between step rows.
    if (steps.length >= 2) {
      var connector = document.createElement('div');
      connector.className = 'reasoning-connector';
      list.appendChild(connector);
    }
    steps.forEach(function(s) { list.appendChild(renderStepRow(s)); });
    toggle.onclick = function(e) {
      e.stopPropagation();
      var hidden = list.style.display === 'none';
      list.style.display = hidden ? '' : 'none';
      toggle.innerHTML = '<span class="chevron-icon' + (hidden ? ' open' : '') + '">' + cc.CHEVRON_SVG + '</span> ' + (hidden ? 'Hide steps' : 'Show steps');
    };
    wrap.appendChild(toggle);
    wrap.appendChild(list);
    return wrap;
  }

  function renderUsage(u) {
    if (!u) return null;
    var bar = document.createElement('div');
    bar.className = 'bubble-usage-bar';
    var summary = u.summary;
    if (!summary) {
      var parts = [];
      if (u.elapsedMs != null) {
        var s = u.elapsedMs / 1000;
        parts.push(s >= 60 ? Math.floor(s / 60) + 'm ' + Math.round(s % 60) + 's' : s.toFixed(1) + 's');
      }
      if (u.costUsd != null) parts.push('$' + (+u.costUsd).toFixed(2));
      if (u.inputTokens != null) parts.push((u.inputTokens / 1000).toFixed(1) + 'k tokens in');
      if (u.outputTokens != null) parts.push((u.outputTokens / 1000).toFixed(1) + 'k tokens out');
      summary = parts.join(' \u00b7 ');
    }
    bar.innerHTML = '<svg class="usage-icon" width="16" height="16" viewBox="-18 0 57 57" stroke="none"><polygon fill="currentColor" points="7.2 8 0.2 4.5 0.2 49.3 14.3 56.3 14.3 48.5 7.2 44.9"/><polygon fill="currentColor" points="14.3 48.5 21.3 52 21.3 7.2 7.2 0.2 7.2 8 14.3 11.6"/></svg><span class="usage-text">' + escapeHtml(summary) + '</span>';
    return bar;
  }

  function renderTurn(turn) {
    var role = turn.role || 'assistant';
    if (role === 'system' || role === 'error' || role === 'tool') {
      var m = document.createElement('div');
      m.className = 'chatbot-message chatbot-message-' + role;
      if (role === 'error') {
        m.innerHTML = '<svg class="chatbot-error-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>' +
          '<span class="chatbot-error-text">' + escapeHtml(turn.text || '') + '</span>';
      } else {
        m.textContent = turn.text || '';
      }
      return m;
    }

    var wrap = document.createElement('div');
    wrap.className = 'chatbot-msg-wrap' + (role === 'user' ? ' chatbot-msg-wrap--user' : '');

    if (role === 'user') {
      if (turn.files && turn.files.length) {
        var chips = document.createElement('div');
        chips.className = 'sent-file-chips';
        turn.files.forEach(function(name) {
          chips.innerHTML += '<div class="sent-file-chip">' +
            '<div class="chip-icon">' + cc.getFileIcon(name) + '</div>' +
            '<div class="chip-info">' +
              '<span class="chip-name">' + escapeHtml(name) + '</span>' +
              '<span class="chip-label">' + cc.getFileLabel(name) + '</span>' +
            '</div></div>';
        });
        wrap.appendChild(chips);
      }
      if ((turn.text || '').trim()) {
        var um = document.createElement('div');
        um.className = 'chatbot-message chatbot-message-user';
        um.textContent = turn.text;
        wrap.appendChild(um);
      }
      return wrap;
    }

    // Assistant turn: build the bubble via the SAME live functions the
    // event stream uses (showTypingIndicator + addReasoningStep +
    // transformThinkingToUsage). No duplicate renderer — whatever changes
    // to the live path automatically apply to retrospect too.
    var content = document.getElementById('chatbot-content');
    // Live state the step functions expect. currentSteps is per-bubble
    // (fresh array) but cc.stepCounter KEEPS growing across turns so
    // step DOM ids stay unique — sharing an id across turns is how the
    // "click any tool opens the first tool" bug crept in.
    cc.currentStreamEl = null;
    cc.currentStreamWrap = null;
    cc.currentStepsEl = null;
    cc.currentStepsListEl = null;
    cc.currentSteps = [];
    cc._autoExpandedByType = {};
    if (typeof cc.stepCounter !== 'number') cc.stepCounter = 0;
    cc._finalAnswerStarted = false;
    // Mount the bubble the live way. showTypingIndicator appends it to
    // #chatbot-content and builds the bubble-thinking-bar we'll shortly
    // convert to the usage bar. This is the one small divergence from
    // live (we append immediately rather than when the user sends), but
    // the end DOM state is identical.
    cc.showTypingIndicator();
    // Populate reasoning steps by replaying through the live API.
    // Flag the live step fns to skip auto-expansion — matches post-`done`
    // state where all steps are collapsed and user opens what they want.
    cc._replayingSteps = true;
    try {
      (turn.steps || []).forEach(function(s) {
        cc.stepCounter++;
        var step = {
          id: s.id || ('replay-' + cc.stepCounter),
          type: s.type || 'tool',
          title: s.title || '',
          toolName: s.toolName,
          content: s.body || '',
          rawOutput: s.rawOutput || null,
          status: s.status || 'done',
          resultCount: s.resultCount || 0
        };
        if (step.type !== 'thinking' && cc.getToolLabel) {
          step.title = cc.getToolLabel(step.toolName || step.title || '', null);
        }
        cc.addReasoningStep(step);
      });
    } finally {
      cc._replayingSteps = false;
    }
    // Live's `done` handler calls collapseReasoningSteps() so the whole
    // list ends up hidden behind "Show steps". Replay has no done event,
    // so explicitly match that post-state here.
    if (cc.collapseReasoningSteps) cc.collapseReasoningSteps();
    // Write the final answer into msg-content the same way live's `done`
    // handler does. Prefer pre-rendered HTML from legacy records;
    // otherwise renderMarkdown the raw text.
    if (cc.currentStreamEl) {
      var mc = cc.currentStreamEl.querySelector('.msg-content');
      if (mc) {
        if (turn.html) mc.innerHTML = turn.html;
        else if (turn.text) mc.innerHTML = cc.renderMarkdown(turn.text);
      }
      // Transform the live thinking-bar into the post-turn usage-bar so
      // the same '.bubble-usage-bar' DOM exists as after live done.
      if (turn.usage) {
        var parts = [];
        var u = turn.usage;
        if (u.summary) {
          cc.lastUsageText = u.summary;
        } else {
          if (u.elapsedMs != null) {
            var s = u.elapsedMs / 1000;
            parts.push(s >= 60 ? Math.floor(s / 60) + 'm ' + Math.round(s % 60) + 's' : s.toFixed(1) + 's');
          }
          if (u.costUsd != null) parts.push('$' + (+u.costUsd).toFixed(2));
          if (u.inputTokens != null) parts.push((u.inputTokens / 1000).toFixed(1) + 'k tokens in');
          if (u.outputTokens != null) parts.push((u.outputTokens / 1000).toFixed(1) + 'k tokens out');
          cc.lastUsageText = parts.join(' \u00b7 ');
        }
        cc.transformThinkingToUsage();
      } else {
        // No usage on this turn — just drop the thinking-bar.
        cc.removeBubbleThinkingBar();
      }
    }
    // Detach from "current" state so the next live turn starts clean.
    var detachedWrap = cc.currentStreamWrap;
    cc.currentStreamEl = null;
    cc.currentStreamWrap = null;
    cc.currentStepsEl = null;
    cc.currentStepsListEl = null;
    cc.currentSteps = [];
    cc._autoExpandedByType = {};
    cc._finalAnswerStarted = false;
    // The caller's wrap is ignored — the live mount path already put the
    // bubble into #chatbot-content. Return null to skip re-appending.
    return null;
  }

  // Public: build the entire pane from a doc. Clears existing content first,
  // then prepends the welcome bubble (always at the top), then appends doc
  // turns. The welcome is idempotent and ephemeral, so multiple calls are
  // safe.
  cc.renderChatDoc = function(doc) {
    var content = document.getElementById('chatbot-content');
    if (!content) return;
    content.innerHTML = '';
    if (cc.showWelcomeMessage) {
      // Fire-and-forget — it prepends whenever the async command registry
      // resolves. Even if doc turns render first, the welcome still
      // lands at the top via insertBefore.
      try { cc.showWelcomeMessage(); } catch (_) {}
    }
    if (!doc || !Array.isArray(doc.turns)) return;
    doc.turns.forEach(function(t) {
      var node = renderTurn(t);
      if (node) content.appendChild(node);
    });
    content.scrollTop = content.scrollHeight;
  };

})(window._cc);
