// interclaw-chatbot/reasoning-steps.js — Steps container, add/update/toggle/collapse
(function(cc) {

  cc.ensureStepsContainer = function() {
    if (cc.currentStepsEl) return;
    if (!cc.currentStreamEl) return;
    cc.currentStepsEl = document.createElement('div');
    cc.currentStepsEl.className = 'reasoning-steps';

    cc.currentStepsListEl = document.createElement('div');
    cc.currentStepsListEl.className = 'reasoning-list';

    var toggle = document.createElement('button');
    toggle.className = 'reasoning-toggle';
    toggle.innerHTML = '<span class="chevron-icon open">' + cc.CHEVRON_SVG + '</span> Hide steps';
    cc.currentStepsListEl.style.display = '';
    (function(listEl, btn) {
      var visible = true;
      btn.onclick = function(e) {
        e.stopPropagation();
        visible = !visible;
        if (visible) {
          listEl.style.display = '';
          btn.innerHTML = '<span class="chevron-icon open">' + cc.CHEVRON_SVG + '</span> Hide steps';
        } else {
          listEl.style.display = 'none';
          btn.innerHTML = '<span class="chevron-icon">' + cc.CHEVRON_SVG + '</span> Show steps';
        }
      };
      btn._collapseSteps = function() {
        visible = false;
        listEl.style.display = 'none';
        btn.innerHTML = '<span class="chevron-icon">' + cc.CHEVRON_SVG + '</span> Show steps';
      };
    })(cc.currentStepsListEl, toggle);

    cc.currentStepsEl.appendChild(toggle);
    cc.currentStepsEl.appendChild(cc.currentStepsListEl);

    var msgContent = cc.currentStreamEl.querySelector('.msg-content');
    cc.currentStreamEl.insertBefore(cc.currentStepsEl, msgContent);
  };

  cc.addReasoningStep = function(step) {
    cc.ensureStepsContainer();
    cc.currentSteps.push(step);

    if (cc.currentSteps.length === 2 && cc.currentStepsListEl) {
      var existing = cc.currentStepsListEl.querySelector('.reasoning-connector');
      if (!existing) {
        var connector = document.createElement('div');
        connector.className = 'reasoning-connector';
        cc.currentStepsListEl.insertBefore(connector, cc.currentStepsListEl.firstChild);
      }
    }

    var stepEl = document.createElement('div');
    stepEl.className = 'reasoning-step';
    stepEl.id = 'reasoning-step-' + step.id;
    stepEl.dataset.stepType = step.type;
    stepEl.dataset.content = step.content || '';
    stepEl.dataset.rawOutput = step.rawOutput || '';

    var row = document.createElement('div');
    row.className = 'reasoning-step-row';

    if (step.type === 'thinking') {
      row.innerHTML =
        '<div class="reasoning-step-icon"><div class="reasoning-dot"></div></div>' +
        '<span class="reasoning-step-label' + (step.content ? ' clickable' : '') + '">' +
          '<span class="' + (step.status === 'running' ? 'reasoning-breathe' : '') + '">' + cc.escapeHtml(step.title) + '</span>' +
        '</span>';
    } else {
      row.innerHTML =
        '<div class="reasoning-step-icon reasoning-tool-icon">' + cc.getToolIcon(step.icon || step.toolName) + '</div>' +
        '<button class="reasoning-step-label clickable">' +
          '<span class="' + (step.status === 'running' ? 'reasoning-breathe' : '') + '" style="flex:1">' + cc.escapeHtml(step.title) + '</span>' +
          '<span class="reasoning-chevron-step' + (!step.content ? ' invisible' : '') + '">' + cc.CHEVRON_SVG + '</span>' +
        '</button>';
    }
    stepEl.appendChild(row);

    cc.currentStepsListEl.appendChild(stepEl);
    cc.updateStepsVisibility();
    return step;
  };

  cc.updateStepsVisibility = function() {
    if (!cc.currentStepsListEl) return;
    var steps = cc.currentStepsListEl.querySelectorAll('.reasoning-step');
    var total = steps.length;
    var connector = cc.currentStepsListEl.querySelector('.reasoning-connector');
    if (total <= cc.MAX_VISIBLE_STEPS || cc.stepsExpandedAll) {
      for (var i = 0; i < steps.length; i++) { steps[i].style.display = ''; steps[i].classList.remove('last-visible'); }
      var btn = cc.currentStepsListEl.querySelector('.reasoning-more-btn');
      if (btn) btn.remove();
      if (connector) connector.style.display = '';
      return;
    }
    for (var i = 0; i < steps.length; i++) {
      steps[i].style.display = i < cc.MAX_VISIBLE_STEPS ? '' : 'none';
      steps[i].classList.remove('last-visible');
    }
    steps[cc.MAX_VISIBLE_STEPS - 1].classList.add('last-visible');
    if (connector) connector.style.display = '';
    var hiddenCount = total - cc.MAX_VISIBLE_STEPS;
    var btn = cc.currentStepsListEl.querySelector('.reasoning-more-btn');
    if (!btn) {
      btn = document.createElement('button');
      btn.className = 'reasoning-more-btn';
      (function(b, listEl) {
        b.onclick = function(e) {
          e.stopPropagation();
          // Expand all steps in THIS list, not cc.currentStepsListEl
          var allSteps = listEl.querySelectorAll('.reasoning-step');
          for (var j = 0; j < allSteps.length; j++) { allSteps[j].style.display = ''; allSteps[j].classList.remove('last-visible'); }
          var connector = listEl.querySelector('.reasoning-connector');
          if (connector) connector.style.display = '';
          b.remove();
        };
      })(btn, cc.currentStepsListEl);
    }
    btn.textContent = '+' + hiddenCount + ' more';
    cc.currentStepsListEl.appendChild(btn);
  };

  cc.updateReasoningStep = function(stepId, updates) {
    var step = cc.currentSteps.find(function(s) { return s.id === stepId; });
    if (!step) return;
    Object.assign(step, updates);

    var stepEl = document.getElementById('reasoning-step-' + stepId);
    if (!stepEl) return;

    if (updates.content !== undefined) stepEl.dataset.content = updates.content;
    if (updates.rawOutput !== undefined) stepEl.dataset.rawOutput = updates.rawOutput;

    var label = stepEl.querySelector('.reasoning-step-label span');
    if (label) {
      if (step.status === 'running') label.classList.add('reasoning-breathe');
      else label.classList.remove('reasoning-breathe');
    }
    if (step.status && step.status !== 'running') {
      stepEl.classList.add('done');
    }

    if (step.type === 'tool' && step.resultCount && step.status === 'success') {
      var btn = stepEl.querySelector('.reasoning-step-label');
      var existingCount = btn.querySelector('.reasoning-result-count');
      if (!existingCount) {
        var countEl = document.createElement('span');
        countEl.className = 'reasoning-result-count';
        countEl.textContent = step.resultCount + ' results';
        var chevron = btn.querySelector('.reasoning-chevron-step');
        btn.insertBefore(countEl, chevron);
      }
    }

    if (step.content && step.type === 'tool') {
      var chevronEl = stepEl.querySelector('.reasoning-chevron-step');
      if (chevronEl) chevronEl.classList.remove('invisible');
    }
    if (step.content && step.type === 'thinking') {
      var labelEl = stepEl.querySelector('.reasoning-step-label');
      if (labelEl && !labelEl.classList.contains('clickable')) {
        labelEl.classList.add('clickable');
        labelEl.style.cursor = 'pointer';
      }
    }
  };

  cc.toggleStepContent = function(stepId) {
    var stepEl = document.getElementById('reasoning-step-' + stepId);
    if (!stepEl || !stepEl.dataset.content) return;

    var existing = stepEl.querySelector('.reasoning-step-content');
    if (existing) {
      stepEl.removeChild(existing);
      var chevron = stepEl.querySelector('.reasoning-chevron-step');
      if (chevron) chevron.classList.remove('open');
      return;
    }

    var stepType = stepEl.dataset.stepType;
    var stepContent = stepEl.dataset.content;

    var contentEl = document.createElement('div');
    contentEl.className = 'reasoning-step-content';

    if (stepType === 'thinking') {
      contentEl.classList.add('reasoning-thinking-content');
      contentEl.innerHTML = cc.renderMarkdown(stepContent);
    } else {
      var lines = stepContent.split('\n');
      var linesHtml = '<div class="reasoning-tool-lines">';
      for (var i = 0; i < lines.length; i++) {
        linesHtml += '<div class="reasoning-tool-line">' + cc.escapeHtml(lines[i]) + '</div>';
      }
      linesHtml += '</div>';
      contentEl.innerHTML = linesHtml;
    }

    stepEl.appendChild(contentEl);
    var chevron = stepEl.querySelector('.reasoning-chevron-step');
    if (chevron) chevron.classList.add('open');
  };

  cc.collapseReasoningSteps = function() {
    if (!cc.currentStepsEl) return;
    var toggle = cc.currentStepsEl.querySelector('.reasoning-toggle');
    if (toggle && toggle._collapseSteps) toggle._collapseSteps();
  };

  cc.resetReasoningSteps = function() {
    cc.currentSteps = [];
    cc.currentStepsEl = null;
    cc.currentStepsListEl = null;
    cc.stepsExpanded = {};
    cc.stepsVisible = true;
    cc.stepsExpandedAll = false;
  };

})(window._cc);
