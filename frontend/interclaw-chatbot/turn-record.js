// turn-record.js — typed per-turn record used for persistence.
//
// Each message in the pane is represented by a typed record rather than a
// snapshot of the bubble's innerHTML. Live event handlers (tool_use,
// tool_result, output, usage) mutate the record attached to the active
// bubble; serialize reads the record, rehydrate feeds it back through the
// canonical renderer. One source of truth, no strip-the-live-UI-before-save
// shenanigans.
//
// Record shapes:
//   user      { type:'user', text, files?:[string] }
//   assistant { type:'assistant', text, steps:[StepRecord], usage?:Usage }
//   system    { type:'system', text }
//   error     { type:'error', text }
//
// StepRecord (one per tool call or thinking step):
//   { id, type:'tool'|'thinking', title, toolName?, content, rawOutput?,
//     status:'running'|'success'|'error', resultCount? }
//
// Usage:
//   { inputTokens, outputTokens, cacheReadTokens, cacheWriteTokens,
//     elapsedMs, costUsd }
(function(cc) {
  'use strict';

  // Attach a fresh record to the bubble and return it. Called whenever
  // showTypingIndicator mounts a new assistant bubble. Mirrors the record
  // onto the parent .chatbot-msg-wrap too because that's what the
  // persistence walk over #chatbot-content.children actually sees — the
  // wrap, not the inner bubble.
  cc.attachTurnRecord = function(bubbleEl) {
    if (!bubbleEl) return null;
    var rec = { type: 'assistant', text: '', steps: [], usage: null };
    bubbleEl._ccRecord = rec;
    var wrap = bubbleEl.parentNode;
    if (wrap && wrap.classList && wrap.classList.contains('chatbot-msg-wrap')) {
      wrap._ccRecord = rec;
    }
    return rec;
  };

  // Read the record for the active bubble (or a specific one).
  cc.getTurnRecord = function(bubbleEl) {
    bubbleEl = bubbleEl || cc.currentStreamEl;
    return bubbleEl ? bubbleEl._ccRecord : null;
  };

  // Mutators used by event handlers.
  cc.recordSetText = function(bubbleEl, text) {
    var rec = cc.getTurnRecord(bubbleEl);
    if (rec) rec.text = text || '';
  };
  cc.recordAddStep = function(bubbleEl, step) {
    var rec = cc.getTurnRecord(bubbleEl);
    if (rec) rec.steps.push(step);
  };
  cc.recordUpdateStep = function(bubbleEl, stepId, updates) {
    var rec = cc.getTurnRecord(bubbleEl);
    if (!rec) return;
    for (var i = 0; i < rec.steps.length; i++) {
      if (rec.steps[i].id === stepId) {
        Object.assign(rec.steps[i], updates);
        return;
      }
    }
  };
  cc.recordSetUsage = function(bubbleEl, usage) {
    var rec = cc.getTurnRecord(bubbleEl);
    if (rec) rec.usage = usage;
  };

  // Render a record into a DOM node. Returns a .chatbot-msg-wrap for user/
  // assistant, or a bare .chatbot-message for system/error/tool. Called
  // from rehydrate; also used to re-render a completed assistant bubble
  // so live DOM and persisted DOM are byte-identical.
  cc.renderTurnRecord = function(rec) {
    if (!rec || !rec.type) return null;

    // System, error: simple div. No wrap.
    if (rec.type === 'system' || rec.type === 'error' || rec.type === 'tool') {
      var m = document.createElement('div');
      m.className = 'chatbot-message chatbot-message-' + rec.type;
      if (rec.type === 'error') {
        m.innerHTML = '<svg class="chatbot-error-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>'
               + '<span class="chatbot-error-text">' + cc.escapeHtml(rec.text || '') + '</span>';
      } else {
        m.textContent = rec.text || '';
      }
      m._ccRecord = rec;
      return m;
    }

    // User turn.
    if (rec.type === 'user') {
      var uwrap = document.createElement('div');
      uwrap.className = 'chatbot-msg-wrap chatbot-msg-wrap--user';
      if (rec.files && rec.files.length) {
        var chips = document.createElement('div');
        chips.className = 'sent-file-chips';
        rec.files.forEach(function(name) {
          chips.innerHTML += '<div class="sent-file-chip">' +
            '<div class="chip-icon">' + cc.getFileIcon(name) + '</div>' +
            '<div class="chip-info">' +
              '<span class="chip-name">' + cc.escapeHtml(name) + '</span>' +
              '<span class="chip-label">' + cc.getFileLabel(name) + '</span>' +
            '</div></div>';
        });
        uwrap.appendChild(chips);
      }
      if ((rec.text || '').trim()) {
        var um = document.createElement('div');
        um.className = 'chatbot-message chatbot-message-user';
        um.textContent = rec.text;
        uwrap.appendChild(um);
      }
      uwrap._ccRecord = rec;
      return uwrap;
    }

    // Assistant turn.
    var wrap = document.createElement('div');
    wrap.className = 'chatbot-msg-wrap';
    var bubble = document.createElement('div');
    bubble.className = 'chatbot-message';

    // Reasoning-steps container, if any populated steps.
    var populatedSteps = (rec.steps || []).filter(function(s) { return s && s.title; });
    if (populatedSteps.length) {
      var stepsEl = document.createElement('div');
      stepsEl.className = 'reasoning-steps';
      var toggle = document.createElement('button');
      toggle.className = 'reasoning-toggle';
      toggle.innerHTML = '<span class="chevron-icon open">' + cc.CHEVRON_SVG + '</span> Hide steps';
      var listEl = document.createElement('div');
      listEl.className = 'reasoning-list';
      (function(l, b) {
        var visible = true;
        b.onclick = function(e) {
          e.stopPropagation();
          visible = !visible;
          l.style.display = visible ? '' : 'none';
          b.innerHTML = '<span class="chevron-icon' + (visible ? ' open' : '') + '">' + cc.CHEVRON_SVG + '</span> ' + (visible ? 'Hide steps' : 'Show steps');
        };
      })(listEl, toggle);
      populatedSteps.forEach(function(step) {
        listEl.appendChild(renderStepRow(step));
      });
      stepsEl.appendChild(toggle);
      stepsEl.appendChild(listEl);
      bubble.appendChild(stepsEl);
    }

    // Answer content.
    var content = document.createElement('div');
    content.className = 'msg-content';
    if (rec.text) content.innerHTML = cc.renderMarkdown(rec.text);
    bubble.appendChild(content);

    // Usage bar (post-turn only — live thinking-bar isn't in the record).
    if (rec.usage) {
      var bar = document.createElement('div');
      bar.className = 'bubble-usage-bar';
      bar.innerHTML = '<svg class="usage-icon" width="16" height="16" viewBox="-18 0 57 57" stroke="none"><polygon fill="currentColor" points="7.2 8 0.2 4.5 0.2 49.3 14.3 56.3 14.3 48.5 7.2 44.9"/><polygon fill="currentColor" points="14.3 48.5 21.3 52 21.3 7.2 7.2 0.2 7.2 8 14.3 11.6"/></svg><span class="usage-text">' + cc.escapeHtml(formatUsage(rec.usage)) + '</span>';
      bubble.appendChild(bar);
    }

    wrap.appendChild(bubble);
    bubble._ccRecord = rec;
    wrap._ccRecord = rec;
    return wrap;
  };

  function renderStepRow(step) {
    var stepEl = document.createElement('div');
    stepEl.className = 'reasoning-step';
    stepEl.id = 'reasoning-step-' + (step.id || ('s-' + Math.random().toString(36).slice(2, 8)));
    stepEl.dataset.stepType = step.type;
    stepEl.dataset.content = step.content || '';
    stepEl.dataset.rawOutput = step.rawOutput || '';
    var row = document.createElement('div');
    row.className = 'reasoning-step-row';
    if (step.type === 'thinking') {
      row.innerHTML =
        '<div class="reasoning-step-icon"><div class="reasoning-dot"></div></div>' +
        '<span class="reasoning-step-label' + (step.content ? ' clickable' : '') + '">' +
          '<span>' + cc.escapeHtml(step.title) + '</span>' +
        '</span>';
    } else {
      row.innerHTML =
        '<div class="reasoning-step-icon reasoning-tool-icon">' + cc.getToolIcon(step.toolName || step.icon || 'wrench') + '</div>' +
        '<button class="reasoning-step-label clickable">' +
          '<span style="flex:1">' + cc.escapeHtml(step.title) + '</span>' +
          '<span class="reasoning-chevron-step' + (!step.content ? ' invisible' : '') + '">' + cc.CHEVRON_SVG + '</span>' +
        '</button>';
    }
    stepEl.appendChild(row);
    return stepEl;
  }

  function formatUsage(u) {
    if (!u) return '';
    var parts = [];
    if (u.elapsedMs != null) {
      var s = u.elapsedMs / 1000;
      parts.push(s >= 60 ? Math.floor(s / 60) + 'm ' + Math.round(s % 60) + 's' : s.toFixed(1) + 's');
    }
    if (u.costUsd != null) parts.push('$' + (+u.costUsd).toFixed(2));
    if (u.inputTokens != null) parts.push((u.inputTokens / 1000).toFixed(1) + 'k tokens in');
    if (u.outputTokens != null) parts.push((u.outputTokens / 1000).toFixed(1) + 'k tokens out');
    return parts.join(' \u00b7 ');
  }

})(window._cc);
