// interclaw-chatbot/send.js — sendMessage (the big function with all /command handlers)
(function(cc) {

  cc.sendMessage = async function() {
    var input = document.getElementById('chatbot-input');
    var message = input.value.trim();
    if (!message && cc.attachedFiles.length === 0) return;

    // Handle local commands first (before sessionId check)
    if (message.startsWith('/goto ') || message === '/goto --trace') {
      var rest = message.substring(6).trim();
      var editorType = null;
      var componentName = rest;
      if (rest.startsWith('--dtl ')) { editorType = 'dtl'; componentName = rest.substring(6).trim(); }
      else if (rest.startsWith('--rule ')) { editorType = 'rule'; componentName = rest.substring(7).trim(); }
      else if (rest.startsWith('--bpl ')) { editorType = 'bpl'; componentName = rest.substring(6).trim(); }
      else if (rest.startsWith('--production ')) { editorType = 'production'; componentName = rest.substring(13).trim(); }
      else if (rest === '--trace' || rest.startsWith('--trace ')) { editorType = 'trace'; componentName = rest.substring(7).trim() || null; }
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; cc.updateSendButton(); var wrapper = document.getElementById('chatbot-input-wrapper'); if (wrapper) wrapper.classList.remove('expanded');
      cc.executeGoto(componentName, editorType);
      return;
    }

    if (message.startsWith('/goto-reload ')) {
      var rest = message.substring(13).trim();
      var editorType = null;
      var componentName = rest;
      if (rest.startsWith('--dtl '))  { editorType = 'dtl';   componentName = rest.substring(6).trim(); }
      else if (rest.startsWith('--rule ')) { editorType = 'rule';  componentName = rest.substring(7).trim(); }
      else if (rest.startsWith('--bpl '))  { editorType = 'bpl';   componentName = rest.substring(6).trim(); }
      else if (rest.startsWith('--production ')) { editorType = 'production'; componentName = rest.substring(13).trim(); }
      else if (rest === '--trace' || rest.startsWith('--trace ')) { editorType = 'trace'; componentName = rest.substring(7).trim() || null; }
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.executeGoto(componentName, editorType);
      return;
    }

    // Handle /trace-view
    if (message === '/trace-view' || message === '/trace-latest' || message.startsWith('/trace-view ')) {
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.executeGoto(null, 'trace');
      return;
    }


    // Handle /ns — namespace diagnostic
    if (message === '/ns') {
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; cc.updateSendButton();
      var diag = '**Namespace Diagnostic**\n';
      diag += '- `detectNamespace()` = `' + cc.detectNamespace() + '`\n';
      diag += '- `cc._apiNamespace` = `' + (cc._apiNamespace || 'null') + '`\n';
      diag += '- URL `$NAMESPACE` = `' + (new URLSearchParams(window.location.search).get('$NAMESPACE') || 'null') + '`\n';
      diag += '- `sessionStorage(interclaw-namespace)` = `' + (sessionStorage.getItem('interclaw-namespace') || 'null') + '`\n';
      diag += '- `window._interclawCspBase` = `' + (window._interclawCspBase || 'null') + '`\n';
      diag += '- `sessionStorage(interclaw-cspbase)` = `' + (sessionStorage.getItem('interclaw-cspbase') || 'null') + '`\n';
      diag += '- `cc.pathPrefix` = `' + (cc.pathPrefix || 'null') + '`\n';
      diag += '- Sample DTL link: `' + ((cc.buildPortalLink && cc.buildPortalLink('Test.DTL.Sample', 'dtl')) || {}).url + '`';
      cc.addMessage('system', diag);
      cc.saveState();
      return;
    }



    // Handle /find <query> — fuzzy search over namespace classes
    if (message.startsWith('/find ')) {
      var findQuery = message.substring(6).trim();
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; cc.updateSendButton(); var wrapper = document.getElementById('chatbot-input-wrapper'); if (wrapper) wrapper.classList.remove('expanded');
      if (!findQuery) { cc.addMessage('system', 'Usage: /find <class-name>'); cc.saveState(); return; }
      cc.findInNamespace(findQuery);
      return;
    }

    // Handle /skill <path> — navigate to a file in the Skills Editor
    if (message.startsWith('/skill ') || message.startsWith('/skill-goto ')) {
      var isGoto = message.startsWith('/skill-goto ');
      var skillPath = message.substring(isGoto ? 12 : 7).trim();
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; cc.updateSendButton(); var wrapper = document.getElementById('chatbot-input-wrapper'); if (wrapper) wrapper.classList.remove('expanded');
      if (!skillPath) { cc.addMessage('system', 'Usage: /skill <file-path>'); cc.saveState(); return; }
      cc.executeSkillGoto(skillPath);
      return;
    }

    // Handle /refresh and /reload
    if (message === '/refresh' || message === '/reload') {
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      sessionStorage.setItem('chatbot-programmatic-reload', 'true');
      cc.saveState();
      window.location.reload();
      return;
    }

    // Handle /model command — selects which Anthropic model tier is sent
    // in the `model` field of each /api/start request. No server-side
    // state; setSelectedModel persists locally and bridge/send always
    // picks up cc.currentModel on outbound.
    if (message.startsWith('/model')) {
      var modelArg = message.substring(6).trim().toLowerCase();
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.hideTypeahead();

      var validModels = { haiku: 1, sonnet: 1, opus: 1 };
      if (!modelArg) {
        cc.addMessage('assistant',
          'Current model: **' + (cc.modelLabels[cc.getSelectedModel()] || cc.getSelectedModel()) + '**.\n\n'
          + 'Options: `/model opus`, `/model sonnet`, `/model haiku`.');
      } else if (validModels[modelArg]) {
        cc.setSelectedModel(modelArg);
        cc.saveState();
        cc.addMessage('assistant', 'Model changed to **' + cc.modelLabels[modelArg] + '**.');
      } else {
        cc.addMessage('assistant',
          'Invalid model `' + modelArg + '`. Options: `opus` (most capable), `sonnet` (balanced), `haiku` (fast).');
      }
      return;
    }

    // Handle /effort command — controls the `effort` field on /api/start,
    // which the adapter forwards to Bedrock's adaptive thinking as
    // `output_config.effort`. Three levels: low, medium, high.
    if (message.startsWith('/effort')) {
      var effortArg = message.substring(7).trim().toLowerCase();
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.hideTypeahead();

      var validEfforts = { low: 1, medium: 1, high: 1, max: 1 };
      var currentEffort = cc.currentEffort || 'medium';
      if (!effortArg) {
        cc.addMessage('assistant',
          'Current effort: **' + currentEffort + '**.\n\n'
          + 'Options: `/effort low` (fastest), `/effort medium` (balanced, default), `/effort high` (extra reasoning), `/effort max` (deepest reasoning).');
      } else if (validEfforts[effortArg]) {
        cc.currentEffort = effortArg;
        try { sessionStorage.setItem('chatbot-effort', effortArg); } catch(e) {}
        cc.saveState();
        cc.addMessage('assistant', 'Effort changed to **' + effortArg + '**.');
      } else {
        cc.addMessage('assistant',
          'Invalid effort `' + effortArg + '`. Options: `low`, `medium`, `high`, `max`.');
      }
      return;
    }

    // Handle /feedback command
    if (message.startsWith('/feedback')) {
      var fbArgs = message.substring(9).trim();
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.hideTypeahead();
      cc.handleFeedbackCommand(fbArgs);
      cc.saveState();
      return;
    }

    // Handle /authenticate
    if (message.startsWith('/authenticate ')) {
      var authKey = message.substring(14).trim();
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.updateSendButton();
      cc.hideTypeahead();
      if (!authKey) {
        cc.addMessage('assistant', 'Usage: `/authenticate <BEDROCK_KEY>`');
        return;
      }
      if (!authKey.startsWith('ABSK')) {
        cc.addMessage('assistant', 'That does not look like a valid key. Bedrock API keys start with `ABSK`.');
        return;
      }
      cc.addMessage('assistant', 'Storing key...');
      cc.updateStatus('Authenticating...');
      try {
        var authResp = await fetch(cc.apiBase + '/api/authenticate', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ key: authKey }),
        });
        var authData = await authResp.json();
        if (authResp.ok && !authData.error) {
          // Verify the key actually works by checking auth-status
          var verifyResp = await fetch(cc.apiBase + '/api/auth-status');
          var verifyData = await verifyResp.json();
          if (verifyData.authenticated) {
            var msg = 'Authenticated as `' + (authData.key_prefix || '****') + '` in region `' + (verifyData.region || 'us-east-1') + '`.';
            if (authData.wallet_stored) msg += ' Key stored in the IRIS wallet and will persist across restarts.';
            cc.addMessage('assistant', msg);
            if (!verifyData.logged_in) {
              cc.showSetupPrompt({ needsLogin: true });
            } else {
              cc.updateStatus('Connected');
              cc.showWelcomeMessage();
            }
          } else {
            cc.addMessage('assistant', 'The key was stored but authentication could not be verified. Try sending a message to confirm it works.');
            cc.updateStatus('Connected');
          }
        } else {
          cc.addMessage('assistant', 'Authentication failed: ' + (authData.error || authData.message || 'Unknown error'));
          cc.updateStatus('Auth failed');
        }
      } catch (authErr) {
        cc.addMessage('assistant', 'Authentication failed: ' + authErr.message);
        cc.updateStatus('Auth failed');
      }
      cc.saveState();
      return;
    }

    // Handle /deauthenticate
    if (message === '/deauthenticate' || message === '/deauth') {
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.updateSendButton();
      cc.hideTypeahead();
      try {
        var deauthResp = await fetch(cc.apiBase + '/api/deauthenticate', { method: 'POST' });
        var deauthData = await deauthResp.json();
        if (deauthData.success) {
          cc.addMessage('assistant', 'API key removed.' + (deauthData.wallet_removed ? ' Wallet entry deleted.' : ''));
          cc.updateStatus('Not authenticated');
          cc.showSetupPrompt({});
        } else {
          cc.addMessage('error', 'Deauthentication failed: ' + (deauthData.error || deauthData.message || 'Unknown error'));
        }
      } catch (deauthErr) {
        cc.addMessage('error', 'Deauthentication failed: ' + deauthErr.message);
      }
      cc.saveState();
      return;
    }

    // Handle /login <username> <password>
    if (message.startsWith('/login ')) {
      var loginParts = message.substring(7).trim().split(/\s+/);
      cc.addMessage('user', '/login ' + (loginParts[0] || '') + ' ****');
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.updateSendButton();
      cc.hideTypeahead();
      if (loginParts.length < 2) {
        cc.addMessage('assistant', 'Usage: `/login <username> <password>`');
        cc.saveState();
        return;
      }
      cc.updateStatus('Logging in...');
      try {
        var loginResp = await fetch(cc.apiBase + '/api/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ username: loginParts[0], password: loginParts.slice(1).join(' ') }),
        });
        var loginData = await loginResp.json();
        if (loginResp.ok && loginData.success) {
          cc.addMessage('assistant', 'Logged in as `' + loginData.username + '`.');
          window.dispatchEvent(new CustomEvent('interclaw-auth-changed', { detail: { loggedIn: true, user: loginData.username } }));
          // Check if API key is also configured
          try {
            var checkResp = await fetch(cc.apiBase + '/api/auth-status');
            var checkData = await checkResp.json();
            if (!checkData.authenticated) {
              cc.showSetupPrompt({});
            } else {
              cc.updateStatus('Connected');
              cc.showWelcomeMessage();
            }
          } catch (_) {
            cc.updateStatus('Connected');
          }
        } else {
          cc.addMessage('assistant', 'Login failed: ' + (loginData.error || 'Unknown error'));
          cc.updateStatus('Login failed');
        }
      } catch (loginErr) {
        cc.addMessage('assistant', 'Login failed: ' + loginErr.message);
        cc.updateStatus('Login failed');
      }
      cc.saveState();
      return;
    }

    // Handle /logout
    if (message === '/logout') {
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.updateSendButton();
      cc.hideTypeahead();
      try {
        var logoutResp = await fetch(cc.apiBase + '/api/logout', { method: 'POST' });
        var logoutData = await logoutResp.json();
        if (logoutData.success) {
          cc.addMessage('assistant', 'Logged out.');
          cc.updateStatus('Not logged in');
          window.dispatchEvent(new CustomEvent('interclaw-auth-changed', { detail: { loggedIn: false } }));
          cc.showSetupPrompt({ needsLogin: true });
        } else {
          cc.addMessage('error', 'Logout failed.');
        }
      } catch (logoutErr) {
        cc.addMessage('error', 'Logout failed: ' + logoutErr.message);
      }
      cc.saveState();
      return;
    }

    // Handle /auth-status
    if (message === '/auth-status' || message === '/auth') {
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.updateSendButton();
      cc.hideTypeahead();
      try {
        var statusResp = await fetch(cc.apiBase + '/api/auth-status');
        var statusData = await statusResp.json();
        var statusMsg = '';
        if (statusData.logged_in) {
          statusMsg += 'Logged in as `' + statusData.user + '`.\n';
        } else {
          statusMsg += 'Not logged in. Use `/login <username> <password>` to sign in.\n';
        }
        if (statusData.authenticated) {
          statusMsg += 'API key: ' + statusData.provider + ' (' + statusData.key_prefix + ') in region ' + statusData.region;
        } else {
          statusMsg += 'API key not configured. Use `/authenticate <BEDROCK_KEY>` to connect.';
        }
        cc.addMessage('assistant', statusMsg);
      } catch (statusErr) {
        cc.addMessage('error', 'Could not check auth status: ' + statusErr.message);
      }
      cc.saveState();
      return;
    }

    // Handle /help
    if (message === '/help') {
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.updateSendButton();
      cc.hideTypeahead();
      if (cc.slashCommands.length === 0) {
        cc.addMessage('system', 'Command registry not loaded. Is the backend running?');
        cc.saveState();
        return;
      }
      var grouped = {};
      var catOrder = [];
      cc.slashCommands.forEach(function(c) {
        if (c.audience === 'maintainer') return;
        var cat = c.category || 'other';
        if (!grouped[cat]) { grouped[cat] = []; catOrder.push(cat); }
        grouped[cat].push(c);
      });
      var helpText = '**Available Commands**\n\n';
      catOrder.forEach(function(cat) {
        helpText += '**' + (cc.categoryLabels[cat] || cat) + '**\n';
        grouped[cat].forEach(function(c) {
          helpText += '`' + c.cmd + '` \u2014 ' + c.desc + '\n';
        });
        helpText += '\n';
      });
      cc.addMessage('system', helpText.trim());
      cc.saveState();
      return;
    }

    // Handle /clear
    if (message === '/clear') {
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.updateSendButton();
      cc.hideTypeahead();
      var chatContent = document.getElementById('chatbot-content');
      chatContent.innerHTML = '';
      cc.totalTokensAccum = 0;
      cc.lastTurnTokens = 0;
      cc.lastInputTokens = 0;
      cc.lastOutputTokens = 0;
      cc.lastUsageText = '';
      cc.updateTokenCounter(0);
      cc.addMessage('system', 'Chat cleared. Session preserved \u2014 you can continue chatting.');
      cc.saveState();
      return;
    }

    // Handle /cost
    if (message === '/cost' || message.startsWith('/cost ')) {
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.updateSendButton();
      cc.hideTypeahead();
      if (cc.totalTokensAccum === 0) {
        cc.addMessage('system', 'No token usage recorded yet. Send a message first.');
      } else {
        var totalK = (cc.totalTokensAccum / 1000).toFixed(1);
        var inK = (cc.lastInputTokens / 1000).toFixed(1);
        var outK = (cc.lastOutputTokens / 1000).toFixed(1);
        var costUsd = ((cc.lastInputTokens * 3 + cc.lastOutputTokens * 15) / 1000000).toFixed(2);
        var costText = '**Session Cost**\n\n';
        costText += '| Metric | Value |\n|--------|-------|\n';
        costText += '| Input tokens | ' + inK + 'k |\n';
        costText += '| Output tokens | ' + outK + 'k |\n';
        costText += '| Total tokens | ' + totalK + 'k |\n';
        costText += '| Estimated cost | $' + costUsd + ' |\n';
        costText += '| Model | ' + (cc.modelLabels[cc.getSelectedModel()] || cc.getSelectedModel()) + ' |\n';
        cc.addMessage('system', costText);
      }
      cc.saveState();
      return;
    }

    // Handle /permissions
    if (message === '/permissions' || message.startsWith('/permissions ')) {
      var permArg = message.substring(12).trim().toLowerCase();
      cc.addMessage('user', message);
      input.value = '';
      input.style.height = 'auto'; input.style.overflowY = 'hidden';
      cc.updateSendButton();
      cc.hideTypeahead();
      try {
        if (!permArg || permArg === '') {
          var permResp = await fetch(cc.apiBase + '/api/permissions');
          var permData = await permResp.json();
          var permText = '**Permission Mode:** ' + permData.mode + '\n\n';
          if (permData.available_modes) {
            permText += 'Available: ' + permData.available_modes.join(', ') + '\n';
            permText += 'Change with: `/permissions <mode>`';
          }
          cc.addMessage('system', permText);
        } else {
          var setResp = await fetch(cc.apiBase + '/api/permissions', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ mode: permArg }),
          });
          var setData = await setResp.json();
          if (setResp.ok) {
            cc.addMessage('system', 'Permission mode changed to **' + (setData.mode || permArg) + '**');
          } else {
            cc.addMessage('error', 'Failed to set permissions: ' + (setData.error || 'Unknown error'));
          }
        }
      } catch (permErr) {
        cc.addMessage('error', 'Could not reach permissions API: ' + permErr.message);
      }
      cc.saveState();
      return;
    }

    // --- Normal message send ---
    var sentFiles = cc.attachedFiles.map(function(f) { return f.name; });
    var hasFiles = cc.attachedFiles.length > 0;

    var fullMessage = message;
    if (hasFiles) {
      try {
        var fileContents = await cc.readAttachedFiles();
        fullMessage = fileContents + '\n\n' + (message || 'Please review the attached file(s).');
      } catch (fileErr) {
        console.error('[chatbot] File reading failed:', fileErr);
        cc.addMessage('system', 'Warning: Could not read attached files \u2014 sending message without them.');
      }
    }
    // Prepend tree selection context if available
    try {
      var treeSel = localStorage.getItem('interclaw-tree-selection');
      if (treeSel) {
        var sel = JSON.parse(treeSel);
        if (sel && sel.path) {
          var ctx = '';
          if (sel.type === 'file' && sel.content) {
            ctx = '[Context: file `' + sel.path + '`]\n```\n' + sel.content + '\n```\n\n';
          } else if (sel.type === 'file') {
            ctx = '[Context: file `' + sel.path + '`]\n\n';
          } else if (sel.listing) {
            ctx = '[Context: folder `' + sel.path + '` contents:]\n```\n' + sel.listing + '\n```\n\n';
          } else {
            ctx = '[Context: folder `' + sel.path + '`]\n\n';
          }
          fullMessage = ctx + fullMessage;
        }
      }
    } catch(e) {}
    if (!fullMessage) return;

    cc.addMessageWithFiles('user', message, sentFiles);

    input.value = '';
    input.style.height = 'auto'; input.style.overflowY = 'hidden';
    cc.attachedFiles = [];
    cc.updateAttachmentUI();
    cc.updateSendButton();
    var wrapper = document.getElementById('chatbot-input-wrapper'); if (wrapper) wrapper.classList.remove('expanded');

    if (cc.currentStreamEl && cc.currentStreamText) {
      clearTimeout(cc.renderTimeout);
      var contentEl = cc.currentStreamEl.querySelector('.msg-content');
      if (contentEl) contentEl.innerHTML = cc.renderMarkdown(cc.currentStreamText);
      cc.currentStreamEl = null;
      cc.currentStreamText = '';
      cc.currentThinkingEl = null;
      cc.currentThinkingText = '';
      cc.renderTimeout = null;
    }

    cc.suppressAssistant = false;
    cc.updateStatus('Thinking...');
    cc.startTimer();
    cc.startResponseTimeout();
    cc.showStopButton();

    cc.showTypingIndicator();
    // Auto-detect plan mode from prompt content (only if not already in plan mode)
    if (cc.currentMode !== 'plan' && cc.detectPlanMode && cc.detectPlanMode(fullMessage)) {
      console.log('[plan-detect] auto-switching to plan mode for prompt:', fullMessage.substring(0, 60));
      cc.switchToPlanMode();
    }
    var sdkMode = cc.SDK_PERMISSION_MODES[cc.currentMode] || 'bypassPermissions';
    var editorCtx = cc.getEditorContext();
    var sendPayload = { action: 'message', prompt: fullMessage, session_id: cc.sessionId, model: cc.getSelectedModel(), namespace: editorCtx.namespace, permission_mode: sdkMode, effort: cc.currentEffort || 'medium', editor_context: editorCtx };
    cc.bridgeSend(sendPayload).then(function(ok) {
      if (!ok) {
        cc.stopTimer();
        cc.clearResponseTimeout();
        cc.removeTypingIndicator();
        cc.hideStopButton();
        cc.updateStatus('Error');
      }
    });
  };

  // /feedback command handler
  cc.handleFeedbackCommand = async function(args) {
    var rating = null;
    var category = 'general';
    var comment = args;

    var ratingMatch = args.match(/^([1-5])\s+/);
    if (ratingMatch) {
      rating = parseInt(ratingMatch[1]);
      comment = args.substring(ratingMatch[0].length);
    }

    var validCategories = ['bug', 'feature-request', 'general', 'praise'];
    var firstWord = comment.split(/\s+/)[0].toLowerCase();
    if (validCategories.indexOf(firstWord) !== -1) {
      category = firstWord;
      comment = comment.substring(firstWord.length).trim();
    }

    if (!comment && !rating) {
      cc.addMessage('system', 'Usage: /feedback [1-5] [bug|feature-request|general|praise] <comment>\nExamples:\n  /feedback 4 bug The DTL editor crashes on empty fields\n  /feedback 5 praise Love the /poc command\n  /feedback Something feels off with routing');
      return;
    }

    var payload = {
      rating: rating,
      category: category,
      comment: comment || (rating ? 'Rating ' + rating + '/5' : ''),
      session_id: cc.sessionId,
      namespace: cc.detectNamespace(),
      model: cc.getSelectedModel(),
    };

    try {
      var resp = await fetch(cc.apiBase + '/api/feedback', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      var result = await resp.json();
      if (!resp.ok) {
        throw new Error(result.error || 'HTTP ' + resp.status);
      }
      var msg = 'Feedback submitted \u2014 thank you!';
      if (result.issue_url) {
        msg += ' [View on GitLab](' + result.issue_url + ')';
      }
      cc.addMessage('system', msg);
    } catch (e) {
      console.error('[feedback] Submit failed:', e);
      cc.addMessage('error', 'Feedback failed: ' + (e.message || 'Unknown error'));
    }
  };

})(window._cc);
