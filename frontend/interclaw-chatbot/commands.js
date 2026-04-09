// interclaw-chatbot/commands.js — Slash command typeahead, loadCommandRegistry, fuzzy search
(function(cc) {

  // --- Debounce utility ---
  function debounce(fn, ms) {
    var timer = null;
    return function() {
      var args = arguments;
      var ctx = this;
      if (timer) clearTimeout(timer);
      timer = setTimeout(function() { timer = null; fn.apply(ctx, args); }, ms);
    };
  }

  // --- Search scoring ---
  // Returns { score, indices } or null if no match.
  // Three tiers only: prefix > word-start > substring. No subsequence.
  function searchScore(query, text) {
    if (!query) return { score: 0, indices: [] };
    var q = query.toLowerCase();
    var t = text.toLowerCase();

    // 1. Exact prefix — best score
    if (t.indexOf(q) === 0) {
      var idx = [];
      for (var i = 0; i < q.length; i++) idx.push(i);
      return { score: 100, indices: idx };
    }

    // 2. Word-start match — each query char matches at the start of a word
    var words = [];
    for (var i = 0; i < t.length; i++) {
      if (i === 0 || t[i - 1] === ' ' || t[i - 1] === '-' || t[i - 1] === '/' || t[i - 1] === '.') {
        words.push(i);
      }
    }
    var wsIndices = [];
    var wi = 0;
    var matched = true;
    for (var qi = 0; qi < q.length; qi++) {
      var found = false;
      while (wi < words.length) {
        if (t[words[wi]] === q[qi]) {
          wsIndices.push(words[wi]);
          wi++;
          found = true;
          break;
        }
        wi++;
      }
      if (!found) { matched = false; break; }
    }
    if (matched && wsIndices.length === q.length) {
      return { score: 80 - wsIndices[0], indices: wsIndices };
    }

    // 3. Substring match anywhere
    var subIdx = t.indexOf(q);
    if (subIdx !== -1) {
      var idx = [];
      for (var i = 0; i < q.length; i++) idx.push(subIdx + i);
      return { score: 50 - subIdx, indices: idx };
    }

    return null;
  }

  // Score a command against a query, checking both cmd and desc
  function scoreCommand(query, cmd) {
    var cmdResult = searchScore(query, cmd.cmd);
    var descResult = searchScore(query, cmd.desc);
    if (cmdResult && descResult) {
      return cmdResult.score >= descResult.score
        ? { score: cmdResult.score, cmdIndices: cmdResult.indices, descIndices: [] }
        : { score: descResult.score - 5, cmdIndices: [], descIndices: descResult.indices };
    }
    if (cmdResult) return { score: cmdResult.score, cmdIndices: cmdResult.indices, descIndices: [] };
    if (descResult) return { score: descResult.score - 10, cmdIndices: [], descIndices: descResult.indices };
    return null;
  }

  // Highlight matched characters
  function highlightText(text, indices) {
    if (!indices || indices.length === 0) return cc.escapeHtml(text);
    var set = {};
    for (var i = 0; i < indices.length; i++) set[indices[i]] = true;
    var result = '';
    var inMark = false;
    for (var i = 0; i < text.length; i++) {
      if (set[i]) {
        if (!inMark) { result += '<mark>'; inMark = true; }
        result += cc.escapeHtml(text[i]);
      } else {
        if (inMark) { result += '</mark>'; inMark = false; }
        result += cc.escapeHtml(text[i]);
      }
    }
    if (inMark) result += '</mark>';
    return result;
  }

  // --- Shared filter + sort ---
  function fuzzyFilter(query, commands) {
    var q = (query || '').replace(/^\//, '').toLowerCase();
    if (!q) {
      return commands.filter(function(c) { return c.audience !== 'maintainer'; })
        .map(function(c) { return { cmd: c, score: 0, cmdIndices: [], descIndices: [] }; });
    }
    var results = [];
    for (var i = 0; i < commands.length; i++) {
      var c = commands[i];
      if (c.audience === 'maintainer') continue;
      var m = scoreCommand(q, c);
      if (m) results.push({ cmd: c, score: m.score, cmdIndices: m.cmdIndices, descIndices: m.descIndices });
    }
    results.sort(function(a, b) {
      if (b.score !== a.score) return b.score - a.score;
      return a.cmd.cmd.localeCompare(b.cmd.cmd);
    });
    return results;
  }

  cc.slashCommands = [];
  cc.categoryLabels = {};
  cc.commandsReady = null;

  cc.loadCommandRegistry = function() {
    cc.commandsReady = fetch(cc.apiBase + '/api/commands')
      .then(function(r) { return r.json(); })
      .then(function(data) {
        cc.slashCommands = (data.commands || []).map(function(c) {
          return { cmd: '/' + c.name, desc: c.description, category: c.category, handler: c.handler, audience: c.audience || null };
        });
        cc.categoryLabels = data.categories || {};
        console.log('[commands] loaded ' + cc.slashCommands.length + ' commands from registry');
      })
      .catch(function(err) {
        console.warn('[commands] failed to load registry:', err);
        cc.slashCommands = [];
        cc.categoryLabels = {};
      });
    return cc.commandsReady;
  };
  cc.loadCommandRegistry();

  var typeaheadEl = document.getElementById('chatbot-typeahead');
  var typeaheadIndex = -1;
  var filteredCommands = [];

  cc.showTypeahead = function(results) {
    if (results.length === 0) {
      cc.hideTypeahead();
      return;
    }
    typeaheadIndex = -1;
    filteredCommands = results.map(function(r) { return r.cmd; });
    typeaheadEl.innerHTML = results.map(function(r, i) {
      return '<div class="chatbot-typeahead-item" data-index="' + i + '">' +
        '<span class="chatbot-typeahead-cmd">' + highlightText(r.cmd.cmd, r.cmdIndices) + '</span>' +
        '<span class="chatbot-typeahead-desc">' + highlightText(r.cmd.desc, r.descIndices) + '</span>' +
        '</div>';
    }).join('');
    typeaheadEl.style.display = 'block';

    var items = typeaheadEl.querySelectorAll('.chatbot-typeahead-item');
    items.forEach(function(item) {
      item.addEventListener('mousedown', function(e) {
        e.preventDefault();
        var idx = parseInt(this.dataset.index);
        selectTypeahead(idx);
      });
    });
  };

  cc.hideTypeahead = function() {
    typeaheadEl.style.display = 'none';
    typeaheadIndex = -1;
    filteredCommands = [];
  };

  function selectTypeahead(index) {
    var chatInput = document.getElementById('chatbot-input');
    if (index >= 0 && index < filteredCommands.length) {
      chatInput.value = filteredCommands[index].cmd + ' ';
      chatInput.focus();
      cc.hideTypeahead();
      chatInput.dispatchEvent(new Event('input'));
    }
  }

  function updateTypeaheadHighlight() {
    var items = typeaheadEl.querySelectorAll('.chatbot-typeahead-item');
    items.forEach(function(item, i) {
      item.classList.toggle('active', i === typeaheadIndex);
    });
    if (typeaheadIndex >= 0 && items[typeaheadIndex]) {
      items[typeaheadIndex].scrollIntoView({ block: 'nearest' });
    }
  }

  // Auto-resize textarea, typeahead, and Enter/Shift+Enter handling
  (function() {
    var chatInput = document.getElementById('chatbot-input');
    chatInput.addEventListener('input', function() {
      var wrapper = document.getElementById('chatbot-input-wrapper');
      this.style.transition = 'none';
      this.style.height = 'auto';
      var scrollH = Math.min(this.scrollHeight, 120);
      var lineH = parseInt(getComputedStyle(this).lineHeight) || 20;
      var isMulti = this.scrollHeight > lineH * 1.5;
      if (wrapper) {
        if (isMulti) wrapper.classList.add('expanded');
        else wrapper.classList.remove('expanded');
      }
      this.style.height = scrollH + 'px';
      this.style.overflowY = this.scrollHeight > 120 ? 'auto' : 'hidden';
      cc.updateSendButton();

    });
    chatInput.addEventListener('keydown', function(e) {
      // Shift+Tab: cycle modes (edit → plan → ask)
      if (e.key === 'Tab' && e.shiftKey) {
        e.preventDefault();
        var modes = ['edit', 'plan', 'ask'];
        var idx = modes.indexOf(cc.currentMode);
        var nextMode = modes[(idx + 1) % modes.length];
        if (nextMode === 'plan' && cc.currentMode !== 'plan') {
          cc._prePlanMode = cc.currentMode;
        }
        cc.currentMode = nextMode;
        updateModeLabel();
        updateModeSelection();
        return;
      }

      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        if (cc.isCmdPanelOpen && cc.isCmdPanelOpen()) {
          cc.toggleCmdPanel();
        } else if (cc.isGenerating) {
          cc.stopGeneration();
        } else {
          cc.sendMessage();
        }
      }
      if (e.key === 'Escape' && cc.isCmdPanelOpen && cc.isCmdPanelOpen()) {
        e.preventDefault();
        cc.toggleCmdPanel();
      }
    });
  })();

  // Command panel state
  var _savedInput = '';
  var _cmdPanelOpen = false;
  var _noMatchClosed = false; // prevent auto-reopen after no-match close

  function renderCmdList(filter) {
    var body = document.getElementById('chatbot-cmd-panel-body');
    if (!body) return;
    var results = fuzzyFilter(filter, cc.slashCommands);
    if (results.length === 0) {
      if (filter && _cmdPanelOpen) {
        _noMatchClosed = true;
        cc.toggleCmdPanel();
      }
      return;
    }
    body.innerHTML = '<div class="chatbot-cmd-panel-header">Commands</div>' +
    results.map(function(r) {
      return '<div class="chatbot-cmd-item" data-cmd="' + r.cmd.cmd + '">' +
        '<span class="chatbot-cmd-item-name">' + highlightText(r.cmd.cmd, r.cmdIndices) + '</span>' +
        '<span class="chatbot-cmd-item-desc">' + highlightText(r.cmd.desc, r.descIndices) + '</span>' +
      '</div>';
    }).join('');
  }

  cc.toggleCmdPanel = function() {
    var panel = document.getElementById('chatbot-cmd-panel');
    var divider = document.getElementById('chatbot-cmd-panel-divider');
    var btn = document.getElementById('chatbot-cmd-btn');
    var input = document.getElementById('chatbot-input');

    if (_cmdPanelOpen) {
      // Close: keep current input text as-is (includes the "/")
      _cmdPanelOpen = false;
      panel.classList.remove('visible');
      divider.classList.remove('visible');
      btn.classList.remove('active');
      input.placeholder = MODE_PLACEHOLDERS[cc.currentMode];
      cc.updateSendButton();
    } else {
      // Open: keep "/" visible in input, show command panel
      _cmdPanelOpen = true;
      _noMatchClosed = false;
      if (!input.value.startsWith('/')) input.value = '/' + input.value;
      panel.classList.add('visible');
      divider.classList.add('visible');
      btn.classList.add('active');
      renderCmdList('');
      input.focus();
    }
  };

  cc.isCmdPanelOpen = function() { return _cmdPanelOpen; };

  // Filter on input when panel is open (debounced)
  var debouncedPanelFilter = debounce(function(val) {
    renderCmdList(val);
  }, 50);

  document.getElementById('chatbot-input').addEventListener('input', function() {
    // Reset no-match flag when "/" is removed (fresh start next time)
    if (!this.value.startsWith('/')) _noMatchClosed = false;
    // Auto-open command panel when user types "/" as first character (no space yet)
    if (!_cmdPanelOpen && !_noMatchClosed && this.value.startsWith('/') && this.value.indexOf(' ') === -1) {
      cc.toggleCmdPanel();
      return;
    }
    // Close panel when "/" is deleted or a space is typed (commands are single words)
    if (_cmdPanelOpen && (!this.value.startsWith('/') || this.value.indexOf(' ') !== -1)) {
      cc.toggleCmdPanel();
      return;
    }
    if (!_cmdPanelOpen) return;
    // Strip leading "/" for search filter
    var searchText = this.value.startsWith('/') ? this.value.substring(1) : this.value;
    debouncedPanelFilter(searchText);
  });

  // Click to select a command
  document.getElementById('chatbot-cmd-panel-body').addEventListener('click', function(e) {
    var item = e.target.closest('.chatbot-cmd-item');
    if (!item) return;
    var cmd = item.dataset.cmd;
    var input = document.getElementById('chatbot-input');
    // Close panel, put command in textarea
    _cmdPanelOpen = false;
    document.getElementById('chatbot-cmd-panel').classList.remove('visible');
    document.getElementById('chatbot-cmd-panel-divider').classList.remove('visible');
    document.getElementById('chatbot-cmd-btn').classList.remove('active');
    input.value = cmd + ' ';
    input.placeholder = MODE_PLACEHOLDERS[cc.currentMode];
    input.focus();
    cc.updateSendButton();
  });

  document.getElementById('chatbot-cmd-btn').addEventListener('click', function() {
    // Close mode panel if open
    if (_modePanelOpen) cc.toggleModePanel();
    cc.toggleCmdPanel();
  });

  // --- Mode panel ---
  var _modePanelOpen = false;

  var _ms = 'width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"';
  var MODE_ICONS = {
    ask: '<svg ' + _ms + '><path d="M2.992 16.342a2 2 0 0 1 .094 1.167l-1.065 3.29a1 1 0 0 0 1.236 1.168l3.413-.998a2 2 0 0 1 1.099.092 10 10 0 1 0-4.777-4.719"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><path d="M12 17h.01"/></svg>',
    edit: '<svg ' + _ms + '><path d="m16 18 6-6-6-6"/><path d="m8 6-6 6 6 6"/></svg>',
    plan: '<svg ' + _ms + '><path d="M2 6h4"/><path d="M2 10h4"/><path d="M2 14h4"/><path d="M2 18h4"/><rect width="16" height="20" x="4" y="2" rx="2"/><path d="M9.5 8h5"/><path d="M9.5 12H16"/><path d="M9.5 16H14"/></svg>',
    bypass: '<svg ' + _ms + '><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>'
  };

  var MODE_LABELS = {
    edit: 'Edit automatically',
    plan: 'Plan mode',
    ask: 'Manually approve edits',
    bypass: 'Bypass permissions'
  };

  // Map frontend modes to Claude Agent SDK permission_mode values
  cc.SDK_PERMISSION_MODES = {
    ask: 'default',
    edit: 'bypassPermissions',
    plan: 'plan',
    bypass: 'bypassPermissions'
  };

  cc.currentMode = 'edit';
  cc._prePlanMode = null; // saved mode before entering plan

  var MODE_PLACEHOLDERS = {
    ask: 'Describe a task...',
    edit: 'Describe a task...',
    plan: 'Describe a plan...',
    bypass: 'Describe a task...'
  };

  // --- Plan mode auto-detection ---
  // Patterns that indicate the user wants to plan, not execute
  var PLAN_PATTERNS = [
    /^plan\b/i,
    /^design\b/i,
    /^how (?:should|would|could|can|do) (?:we|i|you)\b/i,
    /^what(?:'s| is) the best (?:way|approach)\b/i,
    /^let(?:'s| us) (?:plan|think|figure|map|sketch|outline)\b/i,
    /^outline\b/i,
    /^sketch out\b/i,
    /^think through\b/i,
    /^what(?:'s| is) (?:the|our) (?:plan|strategy|approach)\b/i,
  ];

  cc.detectPlanMode = function(text) {
    var trimmed = (text || '').trim();
    for (var i = 0; i < PLAN_PATTERNS.length; i++) {
      if (PLAN_PATTERNS[i].test(trimmed)) return true;
    }
    return false;
  };

  // Switch to plan mode programmatically (used by auto-detect and /plan directive)
  cc.switchToPlanMode = function() {
    if (cc.currentMode === 'plan') return; // already in plan mode
    cc._prePlanMode = cc.currentMode;
    cc.currentMode = 'plan';
    updateModeLabel();
    updateModeSelection();
  };

  function updateModeLabel() {
    var label = document.getElementById('chatbot-mode-label');
    if (!label) return;
    label.innerHTML = MODE_ICONS[cc.currentMode] + '<span>' + MODE_LABELS[cc.currentMode] + '</span>';
    var input = document.getElementById('chatbot-input');
    if (input && !cc.isCmdPanelOpen()) input.placeholder = MODE_PLACEHOLDERS[cc.currentMode];
  }

  function updateModeSelection() {
    var items = document.querySelectorAll('.chatbot-mode-item');
    items.forEach(function(item) {
      item.classList.toggle('selected', item.dataset.mode === cc.currentMode);
    });
  }

  cc.toggleModePanel = function() {
    var panel = document.getElementById('chatbot-mode-panel');
    var divider = document.getElementById('chatbot-mode-panel-divider');
    var label = document.getElementById('chatbot-mode-label');
    if (_modePanelOpen) {
      _modePanelOpen = false;
      panel.classList.remove('visible');
      divider.classList.remove('visible');
      label.classList.remove('active');
    } else {
      _modePanelOpen = true;
      panel.classList.add('visible');
      divider.classList.add('visible');
      label.classList.add('active');
    }
  };

  document.getElementById('chatbot-mode-label').addEventListener('click', function() {
    // Close command panel if open
    if (_cmdPanelOpen) cc.toggleCmdPanel();
    cc.toggleModePanel();
  });

  document.getElementById('chatbot-mode-panel').addEventListener('click', function(e) {
    var item = e.target.closest('.chatbot-mode-item');
    if (!item) return;
    if (item.dataset.mode === 'plan' && cc.currentMode !== 'plan') {
      cc._prePlanMode = cc.currentMode;
    }
    cc.currentMode = item.dataset.mode;
    updateModeLabel();
    updateModeSelection();
    cc.toggleModePanel();
  });

  // Effort switch
  cc.currentEffort = 'medium';

  document.getElementById('chatbot-effort-switch').addEventListener('click', function(e) {
    var opt = e.target.closest('.chatbot-effort-opt');
    if (!opt) return;
    cc.currentEffort = opt.dataset.effort;
    var opts = this.querySelectorAll('.chatbot-effort-opt');
    opts.forEach(function(o) { o.classList.toggle('active', o.dataset.effort === cc.currentEffort); });
  });

  // --- Plan acceptance UI ---
  var _planAcceptOpen = false;
  var _planSelectedIdx = 0;

  // Deselect options when focusing plan textarea
  document.getElementById('chatbot-plan-input').addEventListener('focus', function() {
    _planSelectedIdx = -1;
    updatePlanSelection();
  });

  // Auto-resize plan textarea
  document.getElementById('chatbot-plan-input').addEventListener('input', function() {
    this.style.transition = 'none';
    this.style.height = 'auto';
    var scrollH = Math.min(this.scrollHeight, 120);
    this.style.height = scrollH + 'px';
    this.style.overflowY = this.scrollHeight > 120 ? 'auto' : 'hidden';
  });


  var _wrapper = document.getElementById('chatbot-input-wrapper');

  // Callback hooks — set before calling show, called with { choice, feedback, context }
  cc.onPlanChoice = null;
  cc.onEditChoice = null;
  var _planContext = null;
  var _editContext = null;

  // Pending permission request from SDK canUseTool callback
  // When set, edit_accept responses go to /api/approve instead of bridgeSend
  cc._pendingPermission = null; // { bridge_id, tool, input }

  cc.showPlanAccept = function(context) {
    _planAcceptOpen = true;
    _planSelectedIdx = 0;
    _planContext = context || null;
    document.getElementById('chatbot-plan-accept').style.display = 'flex';
    document.getElementById('chatbot-input-normal').style.display = 'none';
    document.getElementById('chatbot-edit-accept').style.display = 'none';
    _wrapper.classList.add('active');
    updatePlanSelection();
    var planInput = document.getElementById('chatbot-plan-input');
    if (planInput) planInput.value = '';
    if (document.activeElement) document.activeElement.blur();
    // Scroll chat to bottom so user sees the plan + approval options
    var chatMessages = document.getElementById('chatbot-content');
    if (chatMessages) chatMessages.scrollTop = chatMessages.scrollHeight;
  };

  cc.hidePlanAccept = function() {
    _planAcceptOpen = false;
    document.getElementById('chatbot-plan-accept').style.display = 'none';
    document.getElementById('chatbot-input-normal').style.display = '';
    _wrapper.classList.remove('active');
    document.getElementById('chatbot-input').focus();
  };

  cc.isPlanAcceptOpen = function() { return _planAcceptOpen; };

  function updatePlanSelection() {
    var opts = document.getElementById('chatbot-plan-accept').querySelectorAll('.chatbot-plan-opt');
    opts.forEach(function(o, i) { o.classList.toggle('selected', i === _planSelectedIdx); });
  }

  // Click to select option
  document.getElementById('chatbot-plan-accept').addEventListener('click', function(e) {
    var opt = e.target.closest('.chatbot-plan-opt');
    if (!opt) return;
    var opts = Array.from(document.getElementById('chatbot-plan-accept').querySelectorAll('.chatbot-plan-opt'));
    _planSelectedIdx = opts.indexOf(opt);
    updatePlanSelection();
    executePlanChoice(opt.dataset.plan);
  });

  function executePlanChoice(choice, feedback) {
    var result = { choice: choice, feedback: feedback || null, context: _planContext };
    cc.hidePlanAccept();

    if (cc.onPlanChoice) { cc.onPlanChoice(result); cc.onPlanChoice = null; }

    // Plan-done approval: send follow-up to execute the plan
    if (cc._planDoneApproval) {
      cc._planDoneApproval = false;
      if (choice === 'auto' || choice === 'manual') {
        // auto = bypass permissions, manual = ask (Bash-only approval)
        cc.currentMode = choice === 'auto' ? 'edit' : 'ask';
        cc._prePlanMode = null;
        updateModeLabel();
        updateModeSelection();
        var followUp = feedback ? feedback : 'Proceed with the plan.';
        cc.sendCommandToBackend(followUp);
      }
      // 'keep' = stay in plan mode, do nothing
      cc.saveState();
      return;
    }

    // Legacy: route to /api/approve if SDK permission request
    if (cc._pendingPermission) {
      var permChoice = 'deny';
      if (choice === 'auto') permChoice = 'accept-all';
      else if (choice === 'manual') permChoice = 'allow';
      var approvePayload = {
        bridge_id: cc._pendingPermission.bridge_id,
        choice: permChoice,
        feedback: feedback || null,
        message: feedback || null,
      };
      cc._pendingPermission = null;
      fetch(cc.chatApiBase + '/api/approve', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(approvePayload),
      }).catch(function(e) {
        console.error('[approve] failed:', e);
      });
    }
    cc.saveState();
  }

  // Keyboard: 1/2/3 to select, Enter to confirm, Esc to cancel, arrow keys to navigate
  document.addEventListener('keydown', function(e) {
    if (!_planAcceptOpen) return;
    var planInput = document.getElementById('chatbot-plan-input');
    // If typing in the plan input textarea, only handle Esc
    if (document.activeElement === planInput) {
      if (e.key === 'Escape') {
        e.preventDefault();
        cc.hidePlanAccept();
      }
      if (e.key === 'Enter' && !e.shiftKey && planInput.value.trim()) {
        e.preventDefault();
        executePlanChoice('feedback', planInput.value.trim());
      }
      if (e.key === 'ArrowUp' && !planInput.value) {
        e.preventDefault();
        planInput.blur();
        _planSelectedIdx = 2;
        updatePlanSelection();
      }
      return;
    }
    if (e.key === '1') { _planSelectedIdx = 0; updatePlanSelection(); }
    if (e.key === '2') { _planSelectedIdx = 1; updatePlanSelection(); }
    if (e.key === '3') { _planSelectedIdx = 2; updatePlanSelection(); }
    if (e.key === '4') { _planSelectedIdx = -1; updatePlanSelection(); document.getElementById('chatbot-plan-input').focus(); return; }
    if (e.key === 'ArrowUp') { e.preventDefault(); _planSelectedIdx = Math.max(0, _planSelectedIdx - 1); updatePlanSelection(); }
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (_planSelectedIdx >= 2) {
        _planSelectedIdx = -1;
        updatePlanSelection();
        document.getElementById('chatbot-plan-input').focus();
      } else {
        _planSelectedIdx++;
        updatePlanSelection();
      }
    }
    if (e.key === 'Enter') {
      e.preventDefault();
      var opts = document.getElementById('chatbot-plan-accept').querySelectorAll('.chatbot-plan-opt');
      if (_planSelectedIdx >= 0 && opts[_planSelectedIdx]) executePlanChoice(opts[_planSelectedIdx].dataset.plan);
    }
    if (e.key === 'Escape') {
      e.preventDefault();
      cc.hidePlanAccept();
    }
  });

  // --- Edit acceptance UI ---
  var _editAcceptOpen = false;
  var _editSelectedIdx = 0;

  cc.showEditAccept = function(context) {
    _editAcceptOpen = true;
    _editSelectedIdx = 0;
    _editContext = context || null;
    document.getElementById('chatbot-edit-accept').style.display = 'flex';
    document.getElementById('chatbot-input-normal').style.display = 'none';
    document.getElementById('chatbot-plan-accept').style.display = 'none';
    _wrapper.classList.add('active');
    // Show what tool is being requested
    var titleEl = document.querySelector('#chatbot-edit-accept .chatbot-plan-accept-title');
    var subtitleEl = document.querySelector('#chatbot-edit-accept .chatbot-plan-accept-subtitle');
    if (titleEl && context && context.tool) {
      titleEl.textContent = 'Allow ' + context.tool + '?';
    } else if (titleEl) {
      titleEl.textContent = 'Approve this action?';
    }
    if (subtitleEl && context && context.input) {
      var display = context.input.length > 120 ? context.input.substring(0, 120) + '...' : context.input;
      subtitleEl.textContent = display;
    } else if (subtitleEl) {
      subtitleEl.textContent = '';
    }
    updateEditSelection();
    var editInput = document.getElementById('chatbot-edit-input');
    if (editInput) editInput.value = '';
    if (document.activeElement) document.activeElement.blur();
    // Scroll chat to bottom so user sees latest content + approval panel
    var chatMessages = document.getElementById('chatbot-content');
    if (chatMessages) chatMessages.scrollTop = chatMessages.scrollHeight;
  };

  cc.hideEditAccept = function() {
    _editAcceptOpen = false;
    document.getElementById('chatbot-edit-accept').style.display = 'none';
    document.getElementById('chatbot-input-normal').style.display = '';
    _wrapper.classList.remove('active');
    document.getElementById('chatbot-input').focus();
  };

  cc.isEditAcceptOpen = function() { return _editAcceptOpen; };

  function updateEditSelection() {
    var opts = document.getElementById('chatbot-edit-accept').querySelectorAll('.chatbot-plan-opt');
    opts.forEach(function(o, i) { o.classList.toggle('selected', i === _editSelectedIdx); });
  }


  function executeEditChoice(choice, feedback) {
    var result = { choice: choice, feedback: feedback || null, context: _editContext };
    cc.hideEditAccept();

    // Map edit choices to permission choices for the SDK
    var permChoice = choice;
    if (choice === 'accept') permChoice = 'allow';
    else if (choice === 'accept-all') permChoice = 'accept-all';
    else if (choice === 'reject') permChoice = 'deny';
    else if (choice === 'feedback') permChoice = 'deny';

    if (cc.onEditChoice) { cc.onEditChoice(result); cc.onEditChoice = null; }

    // Route to /api/approve if this is an SDK permission request (canUseTool)
    if (cc._pendingPermission) {
      var approvePayload = {
        bridge_id: cc._pendingPermission.bridge_id,
        choice: permChoice,
        feedback: feedback || null,
        message: feedback || null,
      };
      cc._pendingPermission = null;
      fetch(cc.chatApiBase + '/api/approve', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(approvePayload),
      }).catch(function(e) {
        console.error('[approve] failed:', e);
      });
    } else {
      cc.wsSend({ action: 'edit_response', choice: choice, feedback: feedback || null, session_id: cc.sessionId });
    }
    cc.saveState();
  }

  // Click to select
  document.getElementById('chatbot-edit-accept').addEventListener('click', function(e) {
    var opt = e.target.closest('.chatbot-plan-opt');
    if (!opt) return;
    var opts = Array.from(this.querySelectorAll('.chatbot-plan-opt'));
    _editSelectedIdx = opts.indexOf(opt);
    updateEditSelection();
    executeEditChoice(opt.dataset.edit);
  });

  // Auto-resize edit textarea
  document.getElementById('chatbot-edit-input').addEventListener('focus', function() {
    _editSelectedIdx = -1;
    updateEditSelection();
  });
  document.getElementById('chatbot-edit-input').addEventListener('input', function() {
    this.style.transition = 'none';
    this.style.height = 'auto';
    var scrollH = Math.min(this.scrollHeight, 120);
    this.style.height = scrollH + 'px';
    this.style.overflowY = this.scrollHeight > 120 ? 'auto' : 'hidden';
  });

  // Keyboard for edit accept
  document.addEventListener('keydown', function(e) {
    if (!_editAcceptOpen) return;
    var editInput = document.getElementById('chatbot-edit-input');
    if (document.activeElement === editInput) {
      if (e.key === 'Escape') { e.preventDefault(); cc.hideEditAccept(); }
      if (e.key === 'Enter' && !e.shiftKey && editInput.value.trim()) {
        e.preventDefault();
        executeEditChoice('feedback', editInput.value.trim());
      }
      if (e.key === 'ArrowUp' && !editInput.value) {
        e.preventDefault();
        editInput.blur();
        _editSelectedIdx = 2;
        updateEditSelection();
      }
      return;
    }
    if (e.key === '1') { _editSelectedIdx = 0; updateEditSelection(); }
    if (e.key === '2') { _editSelectedIdx = 1; updateEditSelection(); }
    if (e.key === '3') { _editSelectedIdx = 2; updateEditSelection(); }
    if (e.key === '4') { _editSelectedIdx = -1; updateEditSelection(); document.getElementById('chatbot-edit-input').focus(); return; }
    if (e.key === 'ArrowUp') { e.preventDefault(); _editSelectedIdx = Math.max(0, _editSelectedIdx - 1); updateEditSelection(); }
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (_editSelectedIdx >= 2) {
        _editSelectedIdx = -1;
        updateEditSelection();
        document.getElementById('chatbot-edit-input').focus();
      } else {
        _editSelectedIdx++;
        updateEditSelection();
      }
    }
    if (e.key === 'Enter') {
      e.preventDefault();
      var opts = document.getElementById('chatbot-edit-accept').querySelectorAll('.chatbot-plan-opt');
      if (_editSelectedIdx >= 0 && opts[_editSelectedIdx]) executeEditChoice(opts[_editSelectedIdx].dataset.edit);
    }
    if (e.key === 'Escape') { e.preventDefault(); cc.hideEditAccept(); }
  });


  // Shift+Tab cycles modes even when input is not focused (edit → plan → ask)
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Tab' && e.shiftKey) {
      var chatInput = document.getElementById('chatbot-input');
      if (document.activeElement === chatInput) return; // handled by input listener
      e.preventDefault();
      var modes = ['edit', 'plan', 'ask'];
      var idx = modes.indexOf(cc.currentMode);
      var nextMode = modes[(idx + 1) % modes.length];
      if (nextMode === 'plan' && cc.currentMode !== 'plan') {
        cc._prePlanMode = cc.currentMode;
      }
      cc.currentMode = nextMode;
      updateModeLabel();
      updateModeSelection();
    }
  });

})(window._cc);
