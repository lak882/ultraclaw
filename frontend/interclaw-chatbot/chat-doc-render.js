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

  function renderStepRow(step) {
    var el = document.createElement('div');
    el.className = 'reasoning-step';
    el.dataset.stepType = step.type || 'tool';
    el.dataset.content = step.body || '';
    var iconHtml = step.type === 'thinking'
      ? '<div class="reasoning-step-icon"><div class="reasoning-dot"></div></div>'
      : '<div class="reasoning-step-icon reasoning-tool-icon">' + cc.getToolIcon(step.toolName || 'wrench') + '</div>';
    var row = document.createElement('div');
    row.className = 'reasoning-step-row';
    row.innerHTML = iconHtml +
      '<button class="reasoning-step-label clickable">' +
        '<span style="flex:1">' + escapeHtml(step.title || '') + '</span>' +
        '<span class="reasoning-chevron-step' + (!step.body ? ' invisible' : '') + '">' + cc.CHEVRON_SVG + '</span>' +
      '</button>';
    el.appendChild(row);
    if (step.body) {
      // Inline expand-on-click: shows the body below the row.
      var bodyEl = null;
      row.querySelector('.reasoning-step-label').onclick = function(e) {
        e.stopPropagation();
        if (bodyEl && bodyEl.parentNode) {
          bodyEl.parentNode.removeChild(bodyEl);
          bodyEl = null;
          return;
        }
        bodyEl = document.createElement('div');
        bodyEl.className = 'reasoning-step-content';
        var pre = document.createElement('pre');
        pre.style.whiteSpace = 'pre-wrap';
        pre.textContent = step.body;
        bodyEl.appendChild(pre);
        el.appendChild(bodyEl);
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

    // Assistant
    var bubble = document.createElement('div');
    bubble.className = 'chatbot-message';
    var stepsEl = renderSteps(turn.steps);
    if (stepsEl) bubble.appendChild(stepsEl);
    var content = document.createElement('div');
    content.className = 'msg-content';
    // Prefer pre-rendered HTML from legacy records (preserves tables,
    // code blocks, lists). Fall back to renderMarkdown for doc-native
    // turns that only carry text.
    if (turn.html) {
      content.innerHTML = turn.html;
    } else if (turn.text) {
      content.innerHTML = cc.renderMarkdown(turn.text);
    }
    bubble.appendChild(content);
    var usageEl = renderUsage(turn.usage);
    if (usageEl) bubble.appendChild(usageEl);
    wrap.appendChild(bubble);
    return wrap;
  }

  // Public: build the entire pane from a doc. Clears existing content first.
  // Does NOT render the welcome bubble — when a user opens a specific
  // chat they want to see that chat, not a greeting. Welcome belongs on
  // empty panes only and is handled by initSession.
  cc.renderChatDoc = function(doc) {
    var content = document.getElementById('chatbot-content');
    if (!content) return;
    content.innerHTML = '';
    if (!doc || !Array.isArray(doc.turns)) return;
    doc.turns.forEach(function(t) {
      var node = renderTurn(t);
      if (node) content.appendChild(node);
    });
    content.scrollTop = content.scrollHeight;
  };

})(window._cc);
