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

  cc.animateText = async function(targetEl, text, scrollEl, prefix) {
    var parts = text.split(/(\n(?:\|.*\|(?:\n|$))+|:::[\s\S]*?:::)/g);
    var accumulated = prefix ? prefix + '\n\n' : '';
    for (var pi = 0; pi < parts.length; pi++) {
      var part = parts[pi];
      if (!part) continue;
      if (part.startsWith('|') || part.startsWith(':::')) {
        accumulated += part;
        targetEl.innerHTML = cc.renderMarkdownWithQuickReplies(accumulated);
        if (scrollEl) scrollEl.scrollTop = scrollEl.scrollHeight;
        await new Promise(function(r) { setTimeout(r, 50); });
      } else {
        var chunks = part.match(/[\s\S]{1,12}/g) || [];
        for (var ci = 0; ci < chunks.length; ci++) {
          accumulated += chunks[ci];
          targetEl.innerHTML = cc.renderMarkdownWithQuickReplies(accumulated);
          if (scrollEl) scrollEl.scrollTop = scrollEl.scrollHeight;
          await new Promise(function(r) { setTimeout(r, 4); });
        }
      }
    }
    targetEl.innerHTML = cc.renderMarkdownWithQuickReplies(accumulated);
    if (scrollEl) scrollEl.scrollTop = scrollEl.scrollHeight;
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
        if (cc.isStreamingThinking) {
          cc.isStreamingThinking = false;
          var contentEl = cc.currentStreamEl.querySelector('.msg-content');
          if (contentEl) contentEl.innerHTML = '';
          cc.currentStreamText = '';
        }
        if (!cc.timerInterval) {
          cc.updateStatus('Generating...');
        }
        cc.currentStreamText += data.text;
        if (!cc.renderTimeout) {
          cc.renderTimeout = setTimeout(function() {
            var contentEl = cc.currentStreamEl.querySelector('.msg-content');
            if (contentEl) contentEl.innerHTML = cc.renderMarkdown(cc.currentStreamText);
            chatMessages.scrollTop = chatMessages.scrollHeight;
            cc.renderTimeout = null;
          }, 80);
        }
        break;
      case 'thinking':
        if (cc.suppressAssistant) break;
        if (!cc.currentStreamEl) break;
        cc.isStreamingThinking = true;
        cc.currentThinkingText = data.text;
        if (!cc.renderTimeout) {
          cc.renderTimeout = setTimeout(function() {
            var contentEl = cc.currentStreamEl.querySelector('.msg-content');
            if (contentEl) contentEl.innerHTML = cc.renderMarkdown(cc.currentThinkingText);
            chatMessages.scrollTop = chatMessages.scrollHeight;
            cc.renderTimeout = null;
          }, 80);
        }
        break;
      case 'output':
        if (cc.suppressAssistant) break;
        var outputText = (data.text || '').trim();
        if (!outputText) break;
        if (!cc.currentStreamEl) break;
        if (cc.isStreamingThinking) {
          cc.isStreamingThinking = false;
          var ce = cc.currentStreamEl.querySelector('.msg-content');
          if (ce) ce.innerHTML = '';
          cc.currentStreamText = '';
        }
        var prevText = cc.currentStreamText;
        cc.currentStreamText += (cc.currentStreamText ? '\n\n' : '') + outputText;
        var mc = cc.currentStreamEl.querySelector('.msg-content');
        if (mc) {
          if (prevText) mc.innerHTML = cc.renderMarkdownWithQuickReplies(prevText);
          (function(el, prev, added, scroll) {
            cc.animateText(el, added, scroll, prev);
          })(mc, prevText, outputText, chatMessages);
        }
        break;
      case 'session':
        cc.sessionId = data.session_id;
        cc.sessionReady = true;
        cc.saveState();
        cc.processQueue();
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
        var toolLabel = data.label || ('Using ' + data.tool);
        cc.updateStatus(toolLabel + '...');
        if (!cc.currentStreamEl) break;
        if (cc.currentThinkingEl) {
          cc.updateReasoningStep(cc.currentThinkingEl.id, { status: 'success' });
          cc.currentThinkingEl = null;
          cc.currentThinkingText = '';
        }
        cc.stepCounter++;
        var toolStep = {
          id: 'tool-' + cc.stepCounter,
          type: 'tool',
          title: toolLabel,
          toolName: data.tool,
          content: data.input ? data.input.substring(0, 2000) : '',
          rawOutput: null,
          status: 'running',
          resultCount: 0
        };
        cc.addReasoningStep(toolStep);
        chatMessages.scrollTop = chatMessages.scrollHeight;
        break;
      case 'tool_result':
        cc.updateStatus('Thinking...');
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
          cc.updateReasoningStep(lastToolStep.id, {
            status: 'success',
            content: resultText.split('\n').slice(0, 10).join('\n'),
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
        cc.showEditAccept({ tool: data.tool, input: data.input });
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
        if (data.target) {
          console.log('[goto-detect] backend detected /goto-reload (legacy):', data.target);
          (function(t, e) { setTimeout(function() { cc.executeGoto(t, e); }, 500); })(data.target, data.editor || null);
        }
        break;
      case 'goto':
        if (data.target) {
          console.log('[goto-detect] backend detected /goto:', data.target, 'editor:', data.editor);
          (function(t, e) { setTimeout(function() { cc.executeGoto(t, e); }, 500); })(data.target, data.editor || null);
        }
        break;
      case 'reload':
        console.log('[goto-detect] backend detected /reload');
        sessionStorage.setItem('chatbot-programmatic-reload', 'true');
        cc.saveState();
        setTimeout(function() { window.location.reload(); }, 500);
        break;
      case 'usage':
        var elapsed = cc.queryStartTime ? ((Date.now() - cc.queryStartTime) / 1000).toFixed(1) : '?';
        cc.usageShown = true;
        var inTok = data.input_tokens || 0;
        var outTok = data.output_tokens || 0;
        if (!cc.suppressAssistant) {
          cc.lastTurnTokens += inTok + outTok;
          cc.lastInputTokens += inTok;
          cc.lastOutputTokens += outTok;
        }
        var elSec = parseFloat(elapsed);
        var durStr = elSec >= 60 ? Math.floor(elSec/60) + 'm ' + Math.round(elSec%60) + 's' : elapsed + 's';
        var inK = (cc.lastInputTokens / 1000).toFixed(1);
        var outK = (cc.lastOutputTokens / 1000).toFixed(1);
        var costUsd = data.cost != null ? data.cost.toFixed(2) : ((cc.lastInputTokens * 3 + cc.lastOutputTokens * 15) / 1000000).toFixed(2);
        cc.lastUsageText = durStr + ' \u00b7 $' + costUsd + ' \u00b7 ' + inK + 'k tokens in \u00b7 ' + outK + 'k tokens out';
        break;
      case 'done':
        cc.stopTimer();
        cc.clearResponseTimeout();
        cc.currentAbortController = null;
        cc.hideStopButton();
        if (data.session_id && data.session_id !== '') {
          cc.sessionId = data.session_id;
          cc.sessionReady = true;
          cc.saveState();
        }
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
          var contentEl = cc.currentStreamEl.querySelector('.msg-content');
          if (contentEl) contentEl.innerHTML = cc.renderMarkdown(cc.currentStreamText);
          chatMessages.scrollTop = chatMessages.scrollHeight;
        }
        // Auto-execute /goto commands found in assistant response or tool results
        // This runs outside the stream text check so tool-only responses still trigger /goto
        (function() {
          var allTextsToScan = [];
          if (cc.currentStreamText) allTextsToScan.push(cc.currentStreamText);
          // Scan tool result rawOutput (where put_doc.py /goto lines appear)
          for (var si = 0; si < cc.currentSteps.length; si++) {
            if (cc.currentSteps[si].rawOutput) allTextsToScan.push(cc.currentSteps[si].rawOutput);
          }
          var allMsgs = chatMessages.querySelectorAll('.chatbot-message:not(.chatbot-message-user)');
          console.log('[goto-detect] scanning', allMsgs.length, 'messages,', cc.currentSteps.length, 'tool results, currentStreamText length:', (cc.currentStreamText || '').length);
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
              if (doneLine.startsWith('/')) console.log('[goto-detect] found command line:', JSON.stringify(doneLine));
              if (doneLine.startsWith('/goto-reload ') || doneLine.startsWith('/goto ')) {
                var isReloadVariant = doneLine.startsWith('/goto-reload ');
                var gotoRest = doneLine.substring(isReloadVariant ? 13 : 6).trim().replace(/`/g, '').replace(/[.,;:!?`]+$/, '').trim();
                var gotoEditor = null;
                var gotoTarget = gotoRest;
                if (gotoRest.startsWith('--dtl ')) { gotoEditor = 'dtl'; gotoTarget = gotoRest.substring(6).trim(); }
                else if (gotoRest.startsWith('--rule ')) { gotoEditor = 'rule'; gotoTarget = gotoRest.substring(7).trim(); }
                else if (gotoRest.startsWith('--bpl ')) { gotoEditor = 'bpl'; gotoTarget = gotoRest.substring(6).trim(); }
                else if (gotoRest.startsWith('--production ')) { gotoEditor = 'production'; gotoTarget = gotoRest.substring(13).trim(); }
                else if (gotoRest === '--trace' || gotoRest.startsWith('--trace ')) { gotoEditor = 'trace'; gotoTarget = gotoRest.substring(7).trim() || null; }
                if (gotoTarget || gotoEditor === 'trace') {
                  console.log('[goto-detect] executing goto:', gotoTarget, 'editor:', gotoEditor);
                  (function(t, e) {
                    setTimeout(function() { cc.executeGoto(t, e); }, 500);
                  })(gotoTarget, gotoEditor);
                }
                found = true;
                break;
              } else if (doneLine.startsWith('/skill-goto ') || doneLine.startsWith('/skill ')) {
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
              }
            }
          }
        })();
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
        // Plan mode: show plan approval panel after response finishes
        if (cc.currentMode === 'plan' && !cc._pendingPermission) {
          cc._planDoneApproval = true;
          cc.showPlanAccept({ tool: 'Plan' });
        }
        cc.processQueue();
        break;
    }
  };

})(window._cc);
