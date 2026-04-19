// interclaw-chatbot/welcome.js — Welcome message, quick categories, suggestions
(function(cc) {

  cc.quickCategories = [
    { label: 'List Classes', examples: [
      { text: 'List all classes in this namespace', cmd: '/list cls' },
      { text: 'List all data transformations', cmd: '/list cls *.DTL.*' },
      { text: 'List all routing rules', cmd: '/list cls *.Rule.*' },
    ]},
    { label: 'Create Production', examples: [
      { text: 'Create a production with an HL7 HTTP service and file operation', cmd: '/production Create a production with an HL7 HTTP service that routes to a file operation' },
      { text: 'Show the current production status', cmd: '/production Show the current production status' },
    ]},
    { label: 'Build POC', examples: [
      { text: 'Build a POC from a requirements document', cmd: '/poc docs/requirements.md' },
      { text: 'Interview me to gather requirements first', cmd: '/interview' },
    ]},
    { label: 'Create DTL', examples: [
      { text: 'Create an ORU to ORU transform that truncates long lab order names and standardizes LOINC codes', cmd: '/dtl Create an ORU to ORU transform that will truncate any lab order names that are longer than 20 characters. Put in the Demo package. Make sure that the code system name is always LN for LOINC.' },
      { text: 'Transform ADT_A01 to map facility codes using a lookup table', cmd: '/dtl Transform ADT_A01 to map facility codes using a lookup table' },
    ]},
    { label: 'Create Rule', examples: [
      { text: 'Route ADT messages by message type to different targets', cmd: '/rule Route ADT messages: A01 to AdmitProcess, A08 to UpdateProcess, all others to DefaultProcess' },
      { text: 'Route messages by facility code', cmd: '/rule Route messages to different operations based on facility code in MSH:SendingFacility' },
    ]},
    { label: 'Create BPL', examples: [
      { text: 'Validate HL7, transform via DTL, then route to operation', cmd: '/bpl Create a process that validates an HL7 message, transforms it via DTL, then routes to an operation' },
      { text: 'Process with conditional branching on patient class', cmd: '/bpl Create a process that checks patient class and routes inpatients to one target, outpatients to another' },
    ]},
    { label: 'Send Test Message', examples: [
      { text: 'Generate and send a test ADT_A01 message', cmd: '/send Generate and send a test ADT_A01 message to the HTTP service' },
      { text: 'Generate and send a test VXU_V04 message', cmd: '/send Generate and send a test VXU_V04 message to the HTTP service' },
    ]},
  ];

  cc.showSuggestions = function(catIndex) {
    var cat = cc.quickCategories[catIndex];
    if (!cat) return;
    var content = document.getElementById('chatbot-content');

    if (cc._activeSuggestionEl && cc._activeSuggestionEl.parentNode) {
      cc._activeSuggestionEl.parentNode.removeChild(cc._activeSuggestionEl);
    }

    var wrapper = document.createElement('div');
    wrapper.className = 'chatbot-message';
    var mc = document.createElement('div');
    mc.className = 'msg-content';
    wrapper.appendChild(mc);

    var wrap = document.createElement('div');
    wrap.className = 'chatbot-msg-wrap';
    wrap.appendChild(wrapper);
    content.appendChild(wrap);
    cc._activeSuggestionEl = wrap;

    var introSpan = document.createElement('span');
    mc.appendChild(introSpan);
    var introText = 'For example, you could:';
    var charIdx = 0;

    function typeIntro() {
      return new Promise(function(resolve) {
        var iv = setInterval(function() {
          charIdx += 8;
          introSpan.textContent = introText.substring(0, charIdx);
          content.scrollTop = content.scrollHeight;
          if (charIdx >= introText.length) {
            clearInterval(iv);
            resolve();
          }
        }, 4);
      });
    }

    typeIntro().then(function() {
      var ul = document.createElement('ul');
      ul.style.cssText = 'margin-top:10px;padding-left:20px;';
      mc.appendChild(ul);

      var i = 0;
      function addNext() {
        if (i >= cat.examples.length) return;
        var ex = cat.examples[i];
        var li = document.createElement('li');
        li.style.cssText = 'color:#333694;cursor:pointer;margin-bottom:6px;opacity:0;transform:translateY(8px);transition:opacity 0.25s,transform 0.25s;';
        li.textContent = ex.text;
        li.onclick = (function(cmd) {
          return function() { cc.sendSuggestion(cmd); };
        })(ex.cmd);
        ul.appendChild(li);
        requestAnimationFrame(function() {
          li.style.opacity = '1';
          li.style.transform = 'translateY(0)';
        });
        content.scrollTop = content.scrollHeight;
        i++;
        if (i < cat.examples.length) {
          setTimeout(addNext, 80);
        }
      }
      addNext();
    });
  };

  cc.sendSuggestion = function(cmd) {
    if (cc._activeSuggestionEl && cc._activeSuggestionEl.parentNode) {
      cc._activeSuggestionEl.parentNode.removeChild(cc._activeSuggestionEl);
      cc._activeSuggestionEl = null;
    }
    var input = document.getElementById('chatbot-input');
    input.value = cmd;
    cc.updateSendButton();
    cc.sendMessage();
  };

  cc.sendQuickReply = function(label) {
    for (var i = 0; i < cc.quickCategories.length; i++) {
      if (cc.quickCategories[i].label === label) {
        cc.showSuggestions(i);
        return;
      }
    }
  };

  cc.buildWelcomeMessage = function() {
    var labels = cc.quickCategories.map(function(c) { return c.label; });
    return 'Welcome! I can help you build and manage interoperability productions. What would you like to do?\n\n:::quick_replies\n' + JSON.stringify(labels) + '\n:::';
  };

  cc.showSetupPrompt = function(opts) {
    opts = opts || {};
    var loader = document.getElementById('chatbot-loading');
    if (loader) loader.remove();

    if (opts.needsLogin) {
      cc.addMessage('assistant', 'Please log in with your IRIS credentials to get started.\n\nEnter your IRIS username and password separated by a space:\n`/login <username> <password>`\n\nExample: `/login superuser SYS`');
      var input = document.getElementById('chatbot-input');
      if (input) {
        input.value = '/login ';
        input.focus();
        cc.updateSendButton();
      }
    } else {
      cc.addMessage('assistant', 'To connect to Claude, paste your Amazon Bedrock API key below and press Enter.\n\nYour key starts with `ABSK` and can be found in your AWS Bedrock console under Model Access.\n`/authenticate <BEDROCK_KEY>`');
      var input = document.getElementById('chatbot-input');
      if (input) {
        input.value = '/authenticate ';
        input.focus();
        cc.updateSendButton();
      }
    }
  };

  cc.showWelcomeMessage = async function() {
    var loader = document.getElementById('chatbot-loading');
    if (loader) loader.remove();
    if (cc.commandsReady) {
      try { await cc.commandsReady; } catch (_) {}
    }
    var chatMessages = document.getElementById('chatbot-content');
    var msgEl = document.createElement('div');
    msgEl.className = 'chatbot-message';
    msgEl.innerHTML = '<div class="msg-content"></div>';
    var wrap = document.createElement('div');
    wrap.className = 'chatbot-msg-wrap';
    // Ephemeral: the welcome bubble is rebuilt on every page load and
    // carries interactive quick-reply buttons that don't survive a JSON
    // round-trip. Tag both the wrap and the bubble so serialize skips
    // them — otherwise the persisted record would be textContent and
    // the rehydrated view would flatten "List Classes Create Production…"
    // into one unreadable line.
    wrap._ccEphemeral = true;
    msgEl._ccEphemeral = true;
    wrap.appendChild(msgEl);
    chatMessages.appendChild(wrap);
    var msgContent = msgEl.querySelector('.msg-content');
    msgContent.innerHTML = cc.renderMarkdownWithQuickReplies(cc.buildWelcomeMessage());
    chatMessages.scrollTop = chatMessages.scrollHeight;
  };

})(window._cc);
