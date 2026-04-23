// interclaw-chatbot/stream.js — handleEvent, readSSE, finalizeCurrentBubble, animateText
(function(cc) {

  cc.readSSE = async function(response) {
    var reader = response.body.getReader();
    var decoder = new TextDecoder();
    var buffer = '';

    while (true) {
      var result = await reader.read();
      if (result.done) break;
      buffer += decoder.decode(result.value, { stream: true });

      var lines = buffer.split('\n');
      buffer = lines.pop();

      for (var i = 0; i < lines.length; i++) {
        var line = lines[i].trim();
        if (line.indexOf('data: ') !== 0) continue;
        try {
          var data = JSON.parse(line.substring(6));
          cc.handleEvent(data);
        } catch (e) { /* skip malformed */ }
      }
    }
  };

  cc.finalizeCurrentBubble = function() {
    cc.removeTypingIndicator();
    cc.removeBubbleThinkingBar();
    if (cc.currentStreamEl && cc.currentStreamText) {
      clearTimeout(cc.renderTimeout);
      cc.renderTimeout = null;
      var trimmed = cc.currentStreamText.trim();
      var contentEl = cc.currentStreamEl.querySelector('.msg-content');
      if (contentEl && trimmed) contentEl.innerHTML = cc.renderMarkdown(trimmed);
      if (!trimmed && cc.currentStreamWrap && cc.currentStreamWrap.parentNode) {
        cc.currentStreamWrap.parentNode.removeChild(cc.currentStreamWrap);
      }
    }
    cc.currentStreamEl = null;
    cc.currentStreamWrap = null;
    cc.currentStreamText = '';
    cc.currentThinkingEl = null;
    cc.currentThinkingText = '';
    cc.collapseReasoningSteps();
    cc.resetReasoningSteps();
  };

  cc._animGeneration = 0;

  cc.animateText = async function(targetEl, text, scrollEl, prefix) {
    var gen = ++cc._animGeneration;
    var parts = text.split(/(\n(?:\|.*\|(?:\n|$))+|:::[\s\S]*?:::)/g);
    var accumulated = prefix ? prefix + '\n\n' : '';
    for (var pi = 0; pi < parts.length; pi++) {
      if (cc._animGeneration !== gen) return;
      var part = parts[pi];
      if (!part) continue;
      if (/^\n?\|/.test(part) || part.startsWith(':::')) {
        accumulated += part;
        targetEl.innerHTML = cc.renderMarkdownWithQuickReplies(accumulated);
        if (scrollEl) scrollEl.scrollTop = scrollEl.scrollHeight;
        await new Promise(function(r) { setTimeout(r, 50); });
      } else {
        var chunks = part.match(/[\s\S]{1,12}/g) || [];
        for (var ci = 0; ci < chunks.length; ci++) {
          if (cc._animGeneration !== gen) return;
          accumulated += chunks[ci];
          targetEl.innerHTML = cc.renderMarkdownWithQuickReplies(accumulated);
          if (scrollEl) scrollEl.scrollTop = scrollEl.scrollHeight;
          await new Promise(function(r) { setTimeout(r, 4); });
        }
      }
    }
    if (cc._animGeneration === gen) {
      targetEl.innerHTML = cc.renderMarkdownWithQuickReplies(accumulated);
      if (scrollEl) scrollEl.scrollTop = scrollEl.scrollHeight;
    }
  };

  cc.handleEvent = function(data) {
    var chatMessages = document.getElementById('chatbot-content');
    cc.resetResponseTimeout();

    // Resolve collector: intercept output/delta/done for goto resolution
    if (cc._resolveCollector) {
      if (data.type === 'output' || data.type === 'delta') {
        cc._resolveCollector.onText(data.text || '');
        return;
      }
      if (data.type === 'done') {
        cc._resolveCollector.onDone();
        return;
      }
    }

    switch (data.type) {
      case 'status':
        cc.updateStatus(data.text);
        if (data.text === 'Ready') {
          cc.updateStatus('Connected');
          cc.clearResponseTimeout();
          cc.saveState();
        }
        break;
      case 'delta':
        if (cc.suppressAssistant) break;
        if (!cc.currentStreamEl) break;
        // Thinking step is finished once answer text starts streaming.
        if (cc._currentThinkingStepId) {
          cc.updateReasoningStep(cc._currentThinkingStepId, { status: 'success' });
          cc._currentThinkingStepId = null;
          cc._currentThinkingStepText = '';
        }
        // Note: don't collapse reasoning steps here — text deltas can arrive
        // while thinking is still streaming (mixed thinking+text content
        // blocks). Collapse only when the terminal `output` event fires.
        if (cc.isStreamingThinking) {
          cc.isStreamingThinking = false;
          var contentEl = cc.currentStreamEl.querySelector('.msg-content');
          if (contentEl) contentEl.innerHTML = '';
          cc.currentStreamText = '';
        }
        if (!cc.timerInterval) {
          cc.updateStatus('Generating...');
        }
        // Main-bubble streaming disabled — mid-stream plain text without
        // markdown formatting was ugly and long responses could crash the
        // tab. Tool_use and thinking cards still stream live via their
        // own handlers; the final answer lands via `animateText` when the
        // terminal `output` event arrives (formatted markdown, character-
        // level typing reveal). Deltas just accumulate state here.
        cc.currentStreamText += data.text;
        break;
      case 'reclassify_as_thinking':
        // Mid-stream: a tool call just started, so the text we already
        // streamed into the main bubble was preamble narrative. Move it
        // into a thinking-step card and clear the bubble for the next
        // block (final answer or next preamble).
        if (cc.suppressAssistant) break;
        var reclassText = data.text || cc.currentStreamText || '';
        if (reclassText && cc.currentStreamEl) {
          cc.stepCounter++;
          var stepId = 'think-' + cc.stepCounter;
          cc.addReasoningStep({
            id: stepId,
            type: 'thinking',
            title: 'Thinking',
            content: reclassText,
            status: 'success'
          });
          // Clear the main bubble.
          var contentEl2 = cc.currentStreamEl.querySelector('.msg-content');
          if (contentEl2) contentEl2.innerHTML = '';
          cc.currentStreamText = '';
        }
        break;
      case 'thinking':
        if (cc.suppressAssistant) break;
        if (!data.text) break;
        // Render thinking as a collapsible reasoning step card above the
        // main bubble. Update the current step if one exists, else create a
        // new one. Matches the tool_use step UX.
        if (!cc._currentThinkingStepId) {
          cc.stepCounter++;
          cc._currentThinkingStepId = 'think-' + cc.stepCounter;
          cc._currentThinkingStepText = '';
          cc.addReasoningStep({
            id: cc._currentThinkingStepId,
            type: 'thinking',
            title: 'Thinking',
            content: '',
            status: 'running'
          });
        }
        cc._currentThinkingStepText += data.text;
        cc.updateReasoningStep(cc._currentThinkingStepId, {
          content: cc._currentThinkingStepText
        });
        if (chatMessages) chatMessages.scrollTop = chatMessages.scrollHeight;
        break;
      case 'output':
        if (cc.suppressAssistant) break;
        var outputText = (data.text || '').trim();
        if (!outputText) break;
        if (!cc.currentStreamEl) break;
        // Finalize any open thinking step when the answer text arrives.
        if (cc._currentThinkingStepId) {
          cc.updateReasoningStep(cc._currentThinkingStepId, { status: 'success' });
          cc._currentThinkingStepId = null;
          cc._currentThinkingStepText = '';
        }
        // When the final answer starts, collapse any still-expanded step
        // bodies (so the answer has the stage) but keep the step rows
        // visible above the answer so the user retains the reasoning
        // history. Don't hide the whole steps list.
        if (!cc._finalAnswerStarted && cc.currentSteps && cc.currentSteps.length > 0) {
          cc._finalAnswerStarted = true;
          if (cc._autoExpandedByType) {
            for (var slotKey in cc._autoExpandedByType) {
              if (cc._autoExpandedByType[slotKey]) {
                cc.toggleStepContent(cc._autoExpandedByType[slotKey]);
                cc._autoExpandedByType[slotKey] = null;
              }
            }
          }
        }
        if (cc.isStreamingThinking) {
          cc.isStreamingThinking = false;
          var ce = cc.currentStreamEl.querySelector('.msg-content');
          if (ce) ce.innerHTML = '';
          cc.currentStreamText = '';
        }
        // `output` is the authoritative final answer. Replace the accumulated
        // delta stream (which is raw unformatted markdown) with it, then run
        // animateText for the typing reveal on the formatted content. The
        // `done` handler will later overwrite .msg-content with a clean
        // renderMarkdown(currentStreamText) render, so even if animateText
        // races or fails silently, the final bubble is guaranteed populated.
        cc.currentStreamText = outputText;
        var mc = cc.currentStreamEl.querySelector('.msg-content');
        if (mc) {
          mc.innerHTML = '';
          cc.animateText(mc, outputText, chatMessages, '');
        }
        break;
      case 'session':
        // Keep an existing chat id rather than overwriting with the backend
        // session id. The chat id is our persistence key — swapping it here
        // would orphan the file we already wrote on the first user turn.
        // Backend session id is informational only at this point; the bridge
        // is bound by chat_id (set on /api/start).
        if (!cc.sessionId) cc.sessionId = data.chat_id || data.session_id;
        cc.sessionReady = true;
        cc.saveState();
        // Don't drain the queue here — `session` fires mid-turn and the
        // bridge is still streaming. Draining now would spin up a second
        // typing indicator inside the live bubble, producing duplicate
        // `.reasoning-steps` containers. Wait for `done` instead.
        break;
      case 'error':
        cc.stopTimer();
        cc.clearResponseTimeout();
        if (cc.currentStreamWrap && cc.currentStreamWrap.parentNode) {
          cc.currentStreamWrap.parentNode.removeChild(cc.currentStreamWrap);
        }
        cc.currentStreamEl = null;
        cc.currentStreamWrap = null;
        cc.currentStreamText = '';
        cc.currentThinkingEl = null;
        cc.currentThinkingText = '';
        cc.isStreamingThinking = false;
        cc.removeTypingIndicator();
        cc.hideStopButton();
        cc.addMessage('error', data.text);
        cc.updateStatus('Error');
        if (data.text && data.text.indexOf('Invalid session') !== -1) {
          sessionStorage.removeItem('chatbot-state');
          cc.sessionId = null;
          cc.sessionReady = false;
          cc.initSession();
        }
        break;
      case 'tool_use':
        var toolLabel = data.label || cc.getToolLabel(data.tool, data.input);
        cc.updateStatus(toolLabel + '...');
        if (!cc.currentStreamEl) break;
        // Thinking step ends when a tool call starts.
        if (cc._currentThinkingStepId) {
          cc.updateReasoningStep(cc._currentThinkingStepId, { status: 'success' });
          cc._currentThinkingStepId = null;
          cc._currentThinkingStepText = '';
        }

        if (!cc._hiddenToolCount) cc._hiddenToolCount = 0;

        if (cc.currentThinkingEl) {
          cc.updateReasoningStep(cc.currentThinkingEl.id, { status: 'success' });
          cc.currentThinkingEl = null;
          cc.currentThinkingText = '';
        }
        cc.stepCounter++;
        // Pull a readable summary from common input fields (class source,
        // python code, sql query, tool-specific payload). Fall back to the
        // raw JSON, truncated.
        var toolContent = data.input ? data.input.substring(0, 2000) : '';
        if (data.input) {
          try {
            var _parsed = JSON.parse(data.input);
            if (_parsed.code) toolContent = _parsed.code;
            else if (_parsed.sql) toolContent = _parsed.sql;
            else if (_parsed.source) toolContent = _parsed.source.substring(0, 2000);
            else if (_parsed.dtl) toolContent = _parsed.dtl + (_parsed.message ? '\n' + _parsed.message.substring(0, 500) : '');
            else if (_parsed.plan) toolContent = _parsed.plan;
          } catch(e) {}
        }
        var toolStep = {
          id: 'tool-' + cc.stepCounter,
          type: 'tool',
          title: toolLabel,
          toolName: data.tool,
          content: toolContent,
          rawOutput: null,
          status: 'running',
          resultCount: 0
        };
        cc.addReasoningStep(toolStep);
        chatMessages.scrollTop = chatMessages.scrollHeight;
        break;
      case 'tool_result':
        cc.updateStatus('Thinking...');
        // Skip results for hidden tool calls
        if (cc._hiddenToolCount && cc._hiddenToolCount > 0) {
          cc._hiddenToolCount--;
          break;
        }
        var lastToolStep = null;
        for (var si = 0; si < cc.currentSteps.length; si++) {
          if (cc.currentSteps[si].type === 'tool' && cc.currentSteps[si].status === 'running') { lastToolStep = cc.currentSteps[si]; break; }
        }
        if (lastToolStep) {
          var resultText = (data.text || '').substring(0, 4000);
          var resultCount = 0;
          try {
            var parsed = JSON.parse(data.text || '');
            if (Array.isArray(parsed)) resultCount = parsed.length;
          } catch(e) {}
          // Preserve the input (e.g. SQL query, Python code, class source)
          // as `content` and append the result underneath with a separator
          // so the expanded card shows both.
          var priorContent = lastToolStep.content || '';
          var combined = priorContent
            ? priorContent + '\n\n--- Result ---\n' + resultText.split('\n').slice(0, 20).join('\n')
            : resultText.split('\n').slice(0, 20).join('\n');
          cc.updateReasoningStep(lastToolStep.id, {
            status: 'success',
            content: combined,
            rawOutput: data.text || '',
            resultCount: resultCount
          });
        }
        chatMessages.scrollTop = chatMessages.scrollHeight;
        break;
      case 'permission_request':
        // SDK canUseTool callback — Claude wants to use a tool that needs approval
        cc._pendingPermission = {
          bridge_id: data.bridge_id || cc.currentBridgeId,
          tool: data.tool,
          input: data.input,
        };
        // Render tool details in the chat so the user can see what they're approving
        if (cc.currentStreamEl) {
          var detailHtml = '';
          if (data.tool === 'Edit' && data.file_path) {
            detailHtml = '<div class="permission-detail"><div class="permission-file">' + cc.escapeHtml(data.file_path) + '</div>';
            if (data.old_string) {
              detailHtml += '<div class="permission-diff"><div class="permission-diff-old"><div class="permission-diff-label">Remove</div><pre>' + cc.escapeHtml(data.old_string) + '</pre></div>';
              detailHtml += '<div class="permission-diff-new"><div class="permission-diff-label">Add</div><pre>' + cc.escapeHtml(data.new_string || '') + '</pre></div></div>';
            }
            detailHtml += '</div>';
          } else if (data.tool === 'Write' && data.file_path) {
            detailHtml = '<div class="permission-detail"><div class="permission-file">Write: ' + cc.escapeHtml(data.file_path) + '</div>';
            if (data.content) detailHtml += '<pre class="permission-code">' + cc.escapeHtml(data.content) + '</pre>';
            detailHtml += '</div>';
          } else if (data.tool === 'Bash') {
            // Show descriptive label if available, otherwise nothing
          }
          if (detailHtml) {
            var contentEl = cc.currentStreamEl.querySelector('.msg-content');
            if (contentEl) {
              contentEl.innerHTML = (contentEl.innerHTML || '') + detailHtml;
            }
          }
          chatMessages.scrollTop = chatMessages.scrollHeight;
        }
        // Use the reasoning step's title and content for the approval panel
        var lastStep = null;
        for (var _si = cc.currentSteps.length - 1; _si >= 0; _si--) {
          if (cc.currentSteps[_si].type === 'tool' && cc.currentSteps[_si].status === 'running') {
            lastStep = cc.currentSteps[_si]; break;
          }
        }
        var editCtx = { tool: data.tool, input: data.label || data.input };
        if (lastStep) {
          editCtx.input = lastStep.title;
          if (lastStep.content) editCtx.command = lastStep.content;
        } else if (data.tool === 'Bash' && data.command) {
          editCtx.command = data.command;
        }
        cc.showEditAccept(editCtx);
        break;
      case 'ask_user':
        // Claude is asking the user a question - display it nicely
        if (data.questions && data.questions.length > 0) {
          var questionHtml = '<div class="ask-user-questions">';
          data.questions.forEach(function(q) {
            questionHtml += '<div class="ask-user-question">';
            if (q.header) questionHtml += '<strong>' + cc.escapeHtml(q.header) + '</strong><br>';
            questionHtml += cc.escapeHtml(q.question);
            if (q.options && q.options.length > 0) {
              questionHtml += '<ul class="ask-user-options">';
              q.options.forEach(function(opt) {
                var label = (typeof opt === 'string') ? opt
                  : (opt.label || opt.text || opt.value || JSON.stringify(opt));
                questionHtml += '<li>' + cc.escapeHtml(label) + '</li>';
              });
              questionHtml += '</ul>';
            }
            questionHtml += '</div>';
          });
          questionHtml += '</div>';
          if (cc.currentStreamEl) { var qEl = cc.currentStreamEl.querySelector(".msg-content"); if (qEl) qEl.innerHTML = (qEl.innerHTML || "") + questionHtml; chatMessages.scrollTop = chatMessages.scrollHeight; }
        }
        break;
      case 'edit_accept':
        // Backend requests edit approval — show the edit accept UI
        cc.showEditAccept(data.context || null);
        break;
      case 'plan_accept':
        // Legacy — route to edit accept panel
        cc._pendingPermission = {
          bridge_id: data.bridge_id || cc.currentBridgeId,
          tool: data.tool,
          input: data.input,
        };
        cc.showEditAccept({ tool: data.tool, input: data.input });
        break;
      case 'goto-reload':
      case 'goto':
        // Traces open in new window; all other gotos are no-ops (nav links removed)
        if (data.target && data.editor === 'trace') {
          (function(t) { setTimeout(function() { cc.executeGoto(t, 'trace'); }, 500); })(data.target);
        }
        break;
      case 'reload':
        console.log('[goto-detect] backend detected /reload');
        sessionStorage.setItem('chatbot-programmatic-reload', 'true');
        cc.saveState();
        setTimeout(function() { window.location.reload(); }, 500);
        break;
      case 'usage':
        // Prefer the server's authoritative elapsed_ms. Falls back to the
        // client timer when absent; the old '?' fallback was triggered on
        // resumed streams where queryStartTime hadn't been set yet.
        var elapsed;
        if (typeof data.elapsed_ms === 'number' && data.elapsed_ms >= 0) {
          elapsed = (data.elapsed_ms / 1000).toFixed(1);
        } else if (cc.queryStartTime) {
          elapsed = ((Date.now() - cc.queryStartTime) / 1000).toFixed(1);
        } else {
          elapsed = '0.0';
        }
        cc.usageShown = true;
        var inTok = data.input_tokens || 0;
        var outTok = data.output_tokens || 0;
        var cacheRead = data.cache_read_tokens || 0;
        var cacheWrite = data.cache_write_tokens || 0;
        if (!cc.suppressAssistant) {
          // Exclude cache_write from the running counter — it inflates the
          // first-turn display by the full system prompt size even though
          // subsequent turns read from cache at 10% cost.
          cc.lastTurnTokens += inTok + outTok + cacheRead;
          cc.lastInputTokens += inTok;
          cc.lastOutputTokens += outTok;
          cc.lastCacheReadTokens = (cc.lastCacheReadTokens || 0) + cacheRead;
          cc.lastCacheWriteTokens = (cc.lastCacheWriteTokens || 0) + cacheWrite;
        }
        var elSec = parseFloat(elapsed);
        var durStr = elSec >= 60 ? Math.floor(elSec/60) + 'm ' + Math.round(elSec%60) + 's' : elapsed + 's';
        var MODEL_RATES = {
          opus:   { input: 15,   output: 75,   cacheRead: 1.5,   cacheWrite: 18.75 },
          sonnet: { input:  3,   output: 15,   cacheRead: 0.3,   cacheWrite:  3.75 },
          haiku:  { input:  0.8, output:  4,   cacheRead: 0.08,  cacheWrite:  1.0 }
        };
        var activeModel = (cc.currentModel && MODEL_RATES[cc.currentModel]) ? cc.currentModel : 'sonnet';
        var r = MODEL_RATES[activeModel];
        var costUsd = data.cost != null ? data.cost.toFixed(2) : (
          (cc.lastInputTokens * r.input +
           cc.lastOutputTokens * r.output +
           (cc.lastCacheReadTokens || 0) * r.cacheRead +
           (cc.lastCacheWriteTokens || 0) * r.cacheWrite) / 1000000
        ).toFixed(2);
        // tokens in = new input + cache reads; cache writes excluded so the
        // first-turn counter doesn't inflate by the system prompt write cost.
        var totalIn = cc.lastInputTokens + (cc.lastCacheReadTokens || 0);
        var inK = (totalIn / 1000).toFixed(1);
        var outK = (cc.lastOutputTokens / 1000).toFixed(1);
        cc.lastUsageText = durStr + ' \u00b7 $' + costUsd + ' \u00b7 ' + inK + 'k in \u00b7 ' + outK + 'k out';
        break;
      case 'done':
        cc.stopTimer();
        cc.clearResponseTimeout();
        cc.currentAbortController = null;
        cc.hideStopButton();
        var _doneId = data.chat_id || data.session_id;
        if (_doneId && _doneId !== '' && !cc.sessionId) {
          cc.sessionId = _doneId;
        }
        cc.sessionReady = true;
        // Clear bridgePolling BEFORE saveState so persistChat doesn't bail
        // out (persistChat returns early while bridgePolling is true).
        // bridge.js will set it to false again when its poll loop exits;
        // the double-assign is a harmless no-op.
        cc.bridgePolling = false;
        cc.saveState();
        cc.totalTokensAccum += cc.lastTurnTokens;
        if (cc.lastTurnTokens > 0) cc.updateTokenCounter(cc.totalTokensAccum);
        cc.transformThinkingToUsage();
        cc.removeTypingIndicator();
        for (var di = 0; di < cc.currentSteps.length; di++) {
          if (cc.currentSteps[di].status === 'running') {
            cc.updateReasoningStep(cc.currentSteps[di].id, { status: 'success' });
          }
        }
        cc.currentStreamText = (cc.currentStreamText || '').trim();
        if (cc.currentStreamEl && cc.currentStreamText) {
          clearTimeout(cc.renderTimeout);
          cc.renderTimeout = null;
          // Cancel any in-flight animateText pass so its deferred innerHTML
          // write can't race with the renderMarkdown below and re-inject
          // raw markdown after we've just cleaned it up.
          cc._animGeneration++;
          var contentEl = cc.currentStreamEl.querySelector('.msg-content');
          var finalText = cc.currentStreamText.replace(/\n?\{"allowedPrompts"[\s\S]*$/, '');
          if (contentEl) contentEl.innerHTML = cc.renderMarkdown(finalText);
          chatMessages.scrollTop = chatMessages.scrollHeight;
        }
        // Detect navigation directives in assistant response or tool results.
        // Context-aware: Angular interop-editor uses /goto (auto-navigate),
        // legacy-ui uses OPEN: lines (clickable link).
        (function() {
          var allTextsToScan = [];
          if (cc.currentStreamText) allTextsToScan.push(cc.currentStreamText);
          // Scan tool result rawOutput (where put_doc.py /goto and OPEN: lines appear)
          for (var si = 0; si < cc.currentSteps.length; si++) {
            if (cc.currentSteps[si].rawOutput) allTextsToScan.push(cc.currentSteps[si].rawOutput);
          }
          var allMsgs = chatMessages.querySelectorAll('.chatbot-message:not(.chatbot-message-user)');
          console.log('[goto-detect] scanning', allMsgs.length, 'messages,', cc.currentSteps.length, 'tool results');
          for (var mi = allMsgs.length - 1; mi >= Math.max(0, allMsgs.length - 5); mi--) {
            var msgContent = allMsgs[mi].querySelector('.msg-content');
            var msgText = msgContent ? msgContent.textContent || '' : allMsgs[mi].textContent || '';
            allTextsToScan.push(msgText);
          }
          var found = false;
          for (var ti = 0; ti < allTextsToScan.length && !found; ti++) {
            var scanText = allTextsToScan[ti];
            var msgLines = scanText.split('\n');
            for (var dli = msgLines.length - 1; dli >= 0; dli--) {
              var doneLine = msgLines[dli].replace(/[^\x20-\x7E]/g, '').trim().replace(/^`+|`+$/g, '').trim();
              if (doneLine.startsWith('/') || doneLine.startsWith('OPEN:')) console.log('[goto-detect] found command line:', JSON.stringify(doneLine));

              if (doneLine.startsWith('/skill-goto ') || doneLine.startsWith('/skill ')) {
                var isSkillGoto = doneLine.startsWith('/skill-goto ');
                var skillPath = doneLine.substring(isSkillGoto ? 12 : 7).trim().replace(/`/g, '').replace(/[.,;:!?`]+$/, '').trim();
                if (skillPath) {
                  console.log('[skill-goto-detect] executing skill-goto:', skillPath);
                  (function(p) {
                    setTimeout(function() { cc.executeSkillGoto(p); }, 500);
                  })(skillPath);
                }
                found = true;
                break;
              } else if (doneLine === '/plan') {
                // Claude can output /plan to switch UI to plan mode
                console.log('[plan-detect] /plan directive found in output');
                cc.switchToPlanMode();
                // Don't set found=true — let other directives still be scanned
              } else if (doneLine === '/reload' || doneLine === '/refresh') {
                sessionStorage.setItem('chatbot-programmatic-reload', 'true');
                cc.saveState();
                setTimeout(function() { window.location.reload(); }, 500);
                found = true;
                break;
              } else if (doneLine.indexOf('/auto-navigate ') === 0) {
                // Toggle the auto-nav flag. When ON, the post-render block
                // below auto-clicks the first Portal link in the bubble,
                // taking the user straight to the target. Uses the same
                // `'true' | 'false'` key the settings-gear checkbox has
                // always used (localStorage['interclaw-auto-navigate']),
                // so the directive and the existing UI toggle stay in sync.
                var navArg = doneLine.substring(15).trim().toLowerCase().replace(/[.,;:!?`]+$/, '');
                var navOn = (navArg === 'enable' || navArg === 'on' || navArg === 'true');
                try { localStorage.setItem('interclaw-auto-navigate', navOn ? 'true' : 'false'); } catch (_) {}
                var checkbox = document.getElementById('ic-setting-auto-navigate');
                if (checkbox) checkbox.checked = navOn;
                window.dispatchEvent(new CustomEvent('interclaw-auto-navigate-change', {
                  detail: { enabled: navOn }
                }));
                console.log('[auto-navigate] set to', navOn ? 'true' : 'false');
                // Don't set found=true — other directives on later lines
                // should still be processed.
              } else if (doneLine.indexOf('/namespace ') === 0 || doneLine.indexOf('/switch-namespace ') === 0) {
                // Backend tells us the working namespace has changed (e.g.
                // after a /connect or terminal-level $Namespace switch).
                // Dispatch the same event interclaw-header.js + shell.js
                // already listen for — they'll update the label + reload
                // iframes under the new namespace.
                var nsTok = doneLine.indexOf('/namespace ') === 0
                  ? doneLine.substring(11)
                  : doneLine.substring(18);
                var newNs = nsTok.trim().replace(/`/g, '').replace(/[.,;:!?`]+$/, '').toUpperCase();
                if (newNs && /^[A-Z][A-Z0-9_-]*$/.test(newNs)) {
                  console.log('[namespace-directive] switching to', newNs);
                  try { sessionStorage.setItem('interclaw-namespace', newNs); } catch (_) {}
                  if (cc) { cc.currentNamespace = newNs; cc._apiNamespace = newNs; }
                  window.dispatchEvent(new CustomEvent('interclaw-namespace-change', { detail: { namespace: newNs } }));
                }
                // Don't set found=true — other directives on later lines
                // should still be processed.
              }
            }
          }
        })();
        // Auto-navigation: if the flag is on, click the first Portal link in
        // the just-rendered bubble. The link's onclick already routes through
        // cc.openInPortalTab, which exits chat mode + swaps the Portal iframe.
        try {
          // Match the same key/value the settings-gear checkbox has always
          // used: `'true'` for on, anything else (including `null` on first
          // load, matching the checkbox's default-checked behavior) for off.
          // The checkbox defaults to CHECKED when the key is absent, so we
          // treat `null` as on too to match that behavior.
          var autoNavRaw = localStorage.getItem('interclaw-auto-navigate');
          var autoNavOn = (autoNavRaw === null || autoNavRaw === 'true');
          if (autoNavOn && cc.currentStreamEl) {
            var firstLink = cc.currentStreamEl.querySelector('.chatbot-link');
            if (firstLink) {
              setTimeout(function() {
                if (cc.openInPortalTab && firstLink.href) {
                  cc.openInPortalTab(firstLink.href);
                }
              }, 400);
            }
          }
        } catch (_) {}
        // Capture response text before clearing (needed for plan detection)
        var _doneResponseText = cc.currentStreamText || '';
        cc.currentStreamEl = null;
        cc.currentStreamWrap = null;
        cc.currentStreamText = '';
        cc.currentThinkingEl = null;
        cc.currentThinkingText = '';
        cc.lastAssistantMsg = null;
        cc.queryStartTime = null;
        cc.collapseReasoningSteps();
        cc.resetReasoningSteps();
        cc.saveState();
        // Plan mode: show plan approval panel only if response looks like a plan
        // (has numbered steps). Skip for questions/clarifications.
        if (cc.currentMode === 'plan' && !cc._pendingPermission) {
          var _planLines = _doneResponseText.split('\n');
          var _numberedCount = 0;
          for (var _pi = 0; _pi < _planLines.length; _pi++) {
            if (/^\s*\d+[\.\)]\s/.test(_planLines[_pi])) _numberedCount++;
          }
          if (_numberedCount >= 2) {
            cc._planDoneApproval = true;
            cc.showPlanAccept({ tool: 'Plan' });
          }
        }
        cc.processQueue();
        break;
    }
  };

})(window._cc);
