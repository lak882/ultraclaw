// interclaw-chatbot/config.js — Font size, model selector, config fetch
(function(cc) {

  cc.applyFontSizeConfig = function(size) {
    var valid = ['3xs','2xs','xs','sm','base'];
    if (valid.indexOf(size) === -1) size = 'xs';
    var sidebar = document.getElementById('chatbot-sidebar');
    sidebar.style.setProperty('--chatbot-font-size', 'var(--fr-styles-font-size-' + size + ')');
    var codeSize = cc.fontSizeCodeMap[size] || '3xs';
    sidebar.style.setProperty('--chatbot-font-size-code', 'var(--fr-styles-font-size-' + codeSize + ')');
  };

  cc.getSelectedModel = function() { return cc.currentModel; };

  cc.setSelectedModel = function(model) {
    var valid = ['haiku', 'sonnet', 'opus'];
    if (valid.indexOf(model) === -1) model = 'sonnet';
    cc.currentModel = model;
    document.getElementById('chatbot-model-label').textContent = cc.modelLabels[model] || model;
    var opts = document.querySelectorAll('#chatbot-model-dropdown .chatbot-model-option');
    opts.forEach(function(o) { o.classList.toggle('selected', o.dataset.value === model); });
    // Sync header model selector
    var hLabel = document.getElementById('ic-header-model-label');
    if (hLabel) hLabel.textContent = cc.modelLabels[model] || model;
    var hOpts = document.querySelectorAll('#ic-header-model-dropdown .ic-header-model-option');
    if (hOpts.length) hOpts.forEach(function(o) { o.classList.toggle('selected', o.dataset.value === model); });
    sessionStorage.setItem('chatbot-model', model);
  };

  cc.applyModelConfig = function(defaultModel) {
    var saved = sessionStorage.getItem('chatbot-model');
    cc.setSelectedModel(saved || defaultModel || 'sonnet');
  };

  // Custom model dropdown logic
  (function() {
    var btn = document.getElementById('chatbot-model-btn');
    var dropdown = document.getElementById('chatbot-model-dropdown');

    btn.addEventListener('click', function(e) {
      e.stopPropagation();
      dropdown.classList.toggle('open');
    });

    dropdown.addEventListener('click', function(e) {
      var opt = e.target.closest('.chatbot-model-option');
      if (opt && opt.dataset.value) {
        cc.setSelectedModel(opt.dataset.value);
        dropdown.classList.remove('open');
      }
    });

    document.addEventListener('click', function() {
      dropdown.classList.remove('open');
    });
  })();

  cc.fetchConfig = function() {
    return fetch(cc.apiBase + '/api/config')
      .then(function(resp) {
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        return resp.json();
      })
      .then(function(config) {
        var size = config.display && config.display.fontSize || 'xs';
        cc.applyFontSizeConfig(size);
        var defaultModel = config.display && config.display.defaultModel || 'sonnet';
        cc.applyModelConfig(defaultModel);
      })
      .catch(function(e) {
        console.log('[chatbot] Config fetch failed, using defaults:', e.message);
        cc.applyModelConfig('sonnet');
      });
  };

})(window._cc);
