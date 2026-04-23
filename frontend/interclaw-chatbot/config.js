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
    if (valid.indexOf(model) === -1) return;
    cc.currentModel = model;
    var hLabel = document.getElementById('ic-header-model-label');
    if (hLabel) hLabel.textContent = cc.modelLabels[model] || model;
    sessionStorage.setItem('chatbot-model', model);
  };

  // Cycle haiku → sonnet → opus → haiku on click
  document.addEventListener('click', function(e) {
    if (e.target.id !== 'ic-header-model-label') return;
    var order = ['haiku', 'sonnet', 'opus'];
    var idx = order.indexOf(cc.currentModel);
    cc.setSelectedModel(order[(idx + 1) % order.length]);
  });

  cc.applyModelConfig = function(defaultModel) {
    var saved = sessionStorage.getItem('chatbot-model');
    if (saved || defaultModel) cc.setSelectedModel(saved || defaultModel);
  };



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
