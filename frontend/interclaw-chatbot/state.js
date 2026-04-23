// interclaw-chatbot/state.js — Shared state initialization and constants
(function(cc) {
  console.log('[interclaw] chatbot build 2026-04-08 (Rendering Cleanup)');

  // Session and connection state
  cc.sessionId = null;

  // API base: derive from current page URL path prefix.
  // Page is at /{pathPrefix}/ui/interop/{cc|interclaw}/... -> REST dispatch is at /{pathPrefix}/api/interclaw
  var _pathMatch = window.location.pathname.match(/^(\/[^/]+)\/ui\/interop\/(?:interclaw|cc)\//);
  cc.apiBase = _pathMatch ? _pathMatch[1] + '/api/interclaw' : '/api/interclaw';
  // Production pipeline API for chat init/message (routes through IRIS production)
  cc.chatApiBase = _pathMatch ? _pathMatch[1] + '/api/interclaw/production' : '/api/interclaw/production';
  cc.pathPrefix = _pathMatch ? _pathMatch[1] : '';

  cc.bridgeConnected = false;
  cc.currentBridgeId = null;
  cc.bridgePolling = false;
  cc.bridgeAbort = null; // AbortController for current poll

  cc.attachedFiles = [];
  cc.messageQueue = [];
  cc.sessionReady = false;
  cc.isReloading = false;

  // Font size configuration
  cc.fontSizeCodeMap = {'3xs':'3xs','2xs':'3xs','xs':'3xs','sm':'2xs','base':'xs'};

  // Model state — labels match the actual Bedrock inference profiles
  // resolved in InterClaw.REST.Chat.ResolveModelAlias.
  cc.modelLabels = { opus: 'Claude Opus 4.7', sonnet: 'Claude Sonnet 4.6', haiku: 'Claude Haiku 4.5' };
  cc.currentModel = 'sonnet';

  // Effort state — low/medium/high. Sent as the `effort` field on
  // /api/start, mapped to Bedrock adaptive-thinking output_config.effort.
  try { cc.currentEffort = sessionStorage.getItem('chatbot-effort') || 'medium'; } catch(e) { cc.currentEffort = 'medium'; }

  // Abort controller for current request
  cc.currentAbortController = null;

  // Streaming state
  cc.currentStreamEl = null;
  cc.currentStreamWrap = null;
  cc.currentStreamText = '';
  cc.currentThinkingEl = null;
  cc.currentThinkingText = '';
  cc.renderTimeout = null;
  cc.showThinking = sessionStorage.getItem('chatbot-show-thinking') !== 'false';

  // Reasoning steps state
  cc.currentSteps = [];
  cc.currentStepsEl = null;
  cc.currentStepsListEl = null;
  cc.stepsExpanded = {};
  cc.stepsVisible = true;
  cc.stepCounter = 0;
  cc.MAX_VISIBLE_STEPS = 6;
  cc.stepsExpandedAll = false;

  // Thinking status words
  cc.thinkingWords = ['Interoperating', 'Thinking', 'Making Connections', 'Dragging-And-Dropping', 'Operating', 'Servicing', 'Processing', 'Integrating'];
  cc.currentThinkingWord = 'Thinking';
  cc.isStreamingThinking = false;

  // Timer, usage tracking, and response timeout
  cc.queryStartTime = null;
  cc.timerInterval = null;
  cc.usageShown = false;
  cc.lastUsageText = '';
  cc.totalTokensAccum = 0;
  cc.lastTurnTokens = 0;
  cc.lastInputTokens = 0;
  cc.lastOutputTokens = 0;
  cc.responseTimeout = null;
  cc.lastStatusBase = '';

  // Generation state
  cc.isGenerating = false;

  // Assistant message state
  cc.lastAssistantMsg = null;
  cc.suppressAssistant = false;

  // Resolve collector for /goto resolution
  cc._resolveCollector = null;

  // Namespace state
  cc.currentNamespace = null; // set after detectNamespace is defined
  cc._isBouncingNamespace = false;

  // Suggestions
  cc._activeSuggestionEl = null;

  // SVG constants
  cc.CHEVRON_SVG = '<svg viewBox="0 0 24 24" width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>';

  var _s = 'viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2"';
  cc.TOOL_ICONS = {
    Bash: '<svg ' + _s + '><polyline points="4 17 10 11 4 5"/><line x1="12" y1="19" x2="20" y2="19"/></svg>',
    Read: '<svg ' + _s + '><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>',
    Write: '<svg ' + _s + '><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>',
    Edit: '<svg ' + _s + '><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>',
    Glob: '<svg ' + _s + '><path d="M22 19a2 2 0 01-2 2H4a2 2 0 01-2-2V5a2 2 0 012-2h5l2 3h9a2 2 0 012 2z"/><circle cx="14" cy="14" r="3"/><line x1="18" y1="18" x2="16.1" y2="16.1"/></svg>',
    Grep: '<svg ' + _s + '><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>',
    Skill: '<svg ' + _s + '><path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/></svg>',
    Agent: '<svg ' + _s + '><rect x="4" y="4" width="16" height="16" rx="2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/><path d="M8 13a4 4 0 008 0"/></svg>',
    WebFetch: '<svg ' + _s + '><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>',
    WebSearch: '<svg ' + _s + '><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>',
    TaskCreate: '<svg ' + _s + '><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/></svg>',
    TodoWrite: '<svg ' + _s + '><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/></svg>',
    NotebookEdit: '<svg ' + _s + '><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>',
    database: '<svg ' + _s + '><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg>',
    search: '<svg ' + _s + '><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>',
    wrench: '<svg ' + _s + '><path d="M14.7 6.3a1 1 0 000 1.4l1.6 1.6a1 1 0 001.4 0l3.77-3.77a6 6 0 01-7.94 7.94l-6.91 6.91a2.12 2.12 0 01-3-3l6.91-6.91a6 6 0 017.94-7.94l-3.76 3.76z"/></svg>'
  };

  // Utility functions used everywhere
  cc.getToolIcon = function(toolName) {
    if (cc.TOOL_ICONS[toolName]) return cc.TOOL_ICONS[toolName];
    return cc.TOOL_ICONS.wrench;
  };

  // Descriptive tool labels — fallback when backend doesn't send data.label
  cc.TOOL_LABELS = {
    // Skill + Agent (kept — slash commands and sub-agent dispatch map to these)
    Skill: 'Using skill',
    Agent: 'Running agent task',
    // InterClaw IRIS-native tools
    put_class: 'Pushing class',
    compile_class: 'Compiling class',
    test_dtl: 'Testing DTL',
    exec: 'Running Python',
    spawn_agent: 'Spawning sub-agents',
    enter_plan_mode: 'Entering plan mode',
    exit_plan_mode: 'Exiting plan mode',
    run_sql: 'Running SQL',
    get_doc: 'Pulling class',
    get_schema: 'Fetching HL7 schema',
    list_docs: 'Listing classes',
    list_skill_files: 'Listing skill files',
    read_skill_file: 'Reading skill file',
    production_status: 'Checking production',
    echo: 'Echo'
  };

  cc.getToolLabel = function(toolName, inputStr) {
    if (toolName === 'Bash' && inputStr) {
      try {
        var parsed = JSON.parse(inputStr);
        if (parsed.description) return parsed.description;
      } catch(e) {}
    }
    if ((toolName === 'Read' || toolName === 'Write' || toolName === 'Edit') && inputStr) {
      try {
        var parsed = JSON.parse(inputStr);
        var path = parsed.file_path || '';
        var fname = path.split('/').pop();
        if (fname) return (toolName === 'Read' ? 'Reading ' : toolName === 'Write' ? 'Writing ' : 'Editing ') + fname;
      } catch(e) {}
    }
    if (toolName === 'Skill' && inputStr) {
      try {
        var parsed = JSON.parse(inputStr);
        if (parsed.skill) return '/' + parsed.skill;
      } catch(e) {}
    }
    return cc.TOOL_LABELS[toolName] || ('Using ' + toolName);
  };

  // Script name → approval title (frontend fallback when backend label is missing)
  var _SCRIPT_TITLES = {
    manage_production: { status: 'Check production status', start: 'Start production',
      stop: 'Stop production', list: 'List productions', _default: 'Manage production' },
    get_doc: 'Pull class from server', put_doc: 'Push and compile class',
    get_schema: 'Fetch HL7 schema', list_docs: 'List classes',
    send_hl7: 'Send HL7 message', send_json: 'Send JSON message',
    test_dtl: 'Test data transformation', trace: 'Pull message trace',
    get_errors: 'Check event log', run_query: 'Run SQL query',
    manage_namespace: 'Manage namespace', manage_lookup: 'Manage lookup table',
    diagram_production: 'Generate production diagram',
    validate_package: 'Validate package', test_suite: 'Run test suite',
    route_test: 'Run route coverage test', compile: 'Compile class',
    search_code: 'Search code', class_inspect: 'Inspect class',
    permissions: 'Check permissions', manage_webapp: 'Manage web application',
    reset_package: 'Reset package', register_schema: 'Register HL7 schema'
  };

  cc.getBashApprovalTitle = function(input) {
    if (!input) return 'Run command';
    // If input is already a descriptive label (no path separators), use it directly
    if (!/[\/\\]/.test(input)) return input;
    // Try to extract InterClaw script name from the command
    var m = input.match(/\/scripts\/\w+\/(\w+)\.py/);
    if (m) {
      var script = m[1];
      var entry = _SCRIPT_TITLES[script];
      if (typeof entry === 'string') return entry;
      if (entry) {
        var am = input.match(/--action\s+(\w+)/);
        if (am && entry[am[1]]) return entry[am[1]];
        if (entry._default) return entry._default;
      }
      // Fallback: humanize script name
      return script.replace(/_/g, ' ').replace(/\b\w/g, function(c) { return c.toUpperCase(); });
    }
    // Non-InterClaw command: show first meaningful word
    var parts = input.replace(/^[^\s]*irispython\s+/, '').split(/\s+/);
    var last = parts[0] ? parts[0].split('/').pop().replace(/\.py$/, '') : '';
    if (last) return 'Run ' + last.replace(/_/g, ' ');
    return 'Run command';
  };

  cc.escapeHtml = function(str) {
    var div = document.createElement('div');
    div.textContent = str || '';
    return div.innerHTML;
  };

})(window._cc);
