// interclaw-chatbot/goto.js — executeGoto, navigation, and search
(function(cc) {

  // Extract CSP base directly from the full page URL (query params, hash, or iframe).
  function getCspBase() {
    var hash = window.location.hash;
    if (hash) {
      var hashMatch = hash.match(/\/csp\/healthshare\/([^\/]+)\//i);
      if (hashMatch) {
        return window.location.origin + (cc.pathPrefix || '') + '/csp/healthshare/' + hashMatch[1].toLowerCase();
      }
    }
    var params = new URLSearchParams(window.location.search);
    var ns = params.get('$NAMESPACE') || params.get('NAMESPACE') || '';
    if (!ns && hash && hash.indexOf('$NAMESPACE=') !== -1) {
      var hashQ = hash.substring(hash.indexOf('?'));
      var hashParams = new URLSearchParams(hashQ);
      ns = hashParams.get('$NAMESPACE') || hashParams.get('NAMESPACE') || '';
    }
    if (!ns) {
      var _icCfg = window._interclawConfig || {};
      ns = sessionStorage.getItem('interclaw-namespace') || _icCfg.namespace || 'INTERCLAW';
    }
    return window.location.origin + (cc.pathPrefix || '') + '/csp/healthshare/' + ns.toLowerCase();
  }

  // Build a portal URL for a class. Returns {url, label} or null.
  cc.buildPortalLink = function(className, editorType) {
    if (!className) return null;
    var cspBase = getCspBase();
    var ns = cc.detectNamespace();
    var edt = editorType || cc.inferEditorType(className);
    if (edt === 'dtl') return { url: cspBase + '/EnsPortal.DTLEditor.zen?DT=' + className + '.cls', label: 'DTL Editor' };
    if (edt === 'rule') return { url: cspBase + '/EnsPortal.RuleEditor.zen?RULE=' + className, label: 'Rule Editor' };
    if (edt === 'bpl') return { url: cspBase + '/EnsPortal.BPLEditor.zen?BP=' + className + '.cls', label: 'BPL Editor' };
    if (edt === 'production') return { url: cspBase + '/EnsPortal.ProductionConfig.zen?PRODUCTION=' + className, label: 'Production' };
    if (edt === 'schema') return { url: cspBase + '/EnsPortal.HL7.SchemaDocumentStructure.zen?MS=' + className, label: 'HL7 Schema' };
    if (edt === 'bs' || edt === 'bo' || edt === 'bp' || edt === 'msg') {
      return { url: cspBase + '/EnsPortal.ProductionConfig.zen?$NAMESPACE=' + ns.toUpperCase(), label: 'Production Config' };
    }
    return null;
  };

  // Navigate to a ZEN page from a legacy-ui URL.
  // On Portal page (viewer-frame exists): updates the iframe src.
  // On Chat (no viewer-frame): navigates the browser to the legacy-ui page.
  cc.navigateLegacyUi = function(legacyUrl) {
    var hashIdx = legacyUrl.indexOf('#');
    if (hashIdx === -1) return false;
    var hashPath = legacyUrl.substring(hashIdx + 1);
    var pfx = cc.pathPrefix || '';
    var frame = document.getElementById('viewer-frame');
    if (frame) {
      frame.src = pfx + hashPath;
      return true;
    }
    window.location.href = pfx + '/ui/interop/interclaw/legacy-ui/index.html#' + hashPath;
    return true;
  };

  // addNavLink — no-op. Navigation links were removed from the chat UI.
  // Kept as a stub so callers (stream.js, send.js) do not throw.
  cc.addNavLink = function() {};

  // Determine class type by querying %Dictionary.ClassDefinition on the server.
  function lookupClassType(className, callback) {
    var ns = cc.detectNamespace();
    var pfxMatch = window.location.pathname.match(/^(\/[^/]+)\/ui\/interop\/interclaw\//);
    var pathPrefix = pfxMatch ? pfxMatch[1] : '';
    var atelierBase = pathPrefix + '/api/atelier/v8/' + ns.toLowerCase();

    var sql = "SELECT Super FROM %Dictionary.ClassDefinition WHERE Name = '" + className.replace(/'/g, "''") + "'";
    fetch(atelierBase + '?action=query', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify({ query: sql })
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
      var rows = (data.result || {}).content || [];
      if (rows.length === 0) { callback(null); return; }
      var superStr = rows[0].Super || '';
      callback(classifyFromSuper(superStr));
    })
    .catch(function() { callback(null); });
  }

  function classifyFromSuper(superStr) {
    if (!superStr) return null;
    var supers = superStr.split(',');
    for (var i = 0; i < supers.length; i++) {
      var s = supers[i].trim().toLowerCase();
      if (s === 'ens.datatransformdtl' || s === 'ens.datatransform') return 'dtl';
      if (s === 'ens.rule.definition' || s === 'ens.rule.router.routingrule') return 'rule';
      if (s === 'ens.businessprocessbpl') return 'bpl';
      if (s === 'ens.production') return 'production';
    }
    return null;
  }

  // Navigate to a component. Handles traces (opens new window) and everything
  // else (renders a clickable nav link in chat).
  cc.executeGoto = function(componentName, editorType, _typeResolved) {
    // Resolve editor type: explicit flag > server %Dictionary lookup > name heuristic
    if (!editorType && componentName && !_typeResolved) {
      lookupClassType(componentName, function(serverType) {
        var resolved = serverType || cc.inferEditorType(componentName);
        cc.executeGoto(componentName, resolved, true);
      });
      return;
    }

    // Traces: open in new window
    if (editorType === 'trace') {
      var ns = cc.detectNamespace();
      var cspBase = getCspBase();
      if (componentName) {
        window.open(cspBase + '/EnsPortal.VisualTrace.zen?SESSIONID=' + componentName + '&$NAMESPACE=' + ns, '_blank');
      } else {
        var atelierBase = window.location.origin + (cc.pathPrefix || '') + '/api/atelier/v8/' + ns.toLowerCase();
        fetch(atelierBase + '?action=query', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': 'Basic ' + btoa('superuser:SYS') },
          body: JSON.stringify({ query: 'SELECT TOP 1 SessionId FROM Ens.MessageHeader ORDER BY ID DESC' })
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
          var rows = (data.result || {}).content || [];
          if (rows.length > 0 && rows[0].SessionId) {
            window.open(cspBase + '/EnsPortal.VisualTrace.zen?SESSIONID=' + rows[0].SessionId + '&$NAMESPACE=' + ns, '_blank');
          } else {
            window.open(cspBase + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + ns, '_blank');
          }
        })
        .catch(function() {
          window.open(cspBase + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + ns, '_blank');
        });
      }
      return;
    }

    // Non-trace gotos: nothing to do (navigation links removed from chat UI)
  };

  // ===== /find — fuzzy search over all classes in the namespace =====
  function trigrams(str) {
    str = str.toLowerCase();
    var t = {};
    for (var i = 0; i <= str.length - 3; i++) {
      var tri = str.substring(i, i + 3);
      t[tri] = (t[tri] || 0) + 1;
    }
    return t;
  }

  function trigramSimilarity(a, b) {
    var ta = trigrams(a);
    var tb = trigrams(b);
    var shared = 0, totalA = 0, totalB = 0;
    for (var k in ta) { totalA += ta[k]; if (tb[k]) shared += Math.min(ta[k], tb[k]); }
    for (var k in tb) { totalB += tb[k]; }
    if (totalA + totalB === 0) return 0;
    return (2 * shared) / (totalA + totalB);
  }

  cc.findInNamespace = function(query) {
    var ns = cc.detectNamespace();
    var pfxMatch = window.location.pathname.match(/^(\/[^/]+)\/ui\/interop\/interclaw\//);
    var pathPrefix = pfxMatch ? pfxMatch[1] : '';
    var atelierBase = pathPrefix + '/api/atelier/v8/' + ns.toLowerCase();

    cc.addMessage('system', 'Searching for "' + query + '" in ' + ns + '...');
    cc.updateStatus('Searching...');

    fetch(atelierBase + '/docnames/cls', { credentials: 'include' })
    .then(function(r) { return r.json(); })
    .then(function(data) {
      var docs = (data.result || {}).content || [];
      if (docs.length === 0) {
        cc.addMessage('system', 'No classes found in ' + ns);
        cc.updateStatus('Connected');
        cc.saveState();
        return;
      }

      var classes = [];
      for (var i = 0; i < docs.length; i++) {
        var name = docs[i].name || docs[i];
        if (typeof name === 'string') classes.push(name.replace(/\.cls$/i, ''));
      }

      var queryLower = query.toLowerCase();
      var queryParts = queryLower.split('.');
      var queryShort = queryParts[queryParts.length - 1];

      var scored = [];
      for (var ci = 0; ci < classes.length; ci++) {
        var cls = classes[ci];
        var clsLower = cls.toLowerCase();
        var clsParts = clsLower.split('.');
        var clsShort = clsParts[clsParts.length - 1];

        if (clsLower === queryLower) { scored.push({ name: cls, score: 1.0 }); continue; }

        var containsBonus = clsLower.indexOf(queryLower) !== -1 ? 0.3 : 0;
        var shortBonus = clsShort === queryShort ? 0.25 : (clsShort.indexOf(queryShort) !== -1 ? 0.1 : 0);
        var fullSim = trigramSimilarity(queryLower, clsLower);
        var shortSim = trigramSimilarity(queryShort, clsShort);
        var score = Math.max(fullSim, shortSim * 0.9) + containsBonus + shortBonus;
        if (score > 0.15) scored.push({ name: cls, score: score });
      }

      scored.sort(function(a, b) { return b.score - a.score; });
      var top = scored.slice(0, 10);
      if (top.length === 0) {
        cc.addMessage('system', 'No matches for "' + query + '" in ' + ns + ' (' + classes.length + ' classes searched).');
      } else {
        var msg = '**Search results for "' + query + '"** (' + classes.length + ' classes)\n\n';
        for (var ti = 0; ti < top.length; ti++) {
          msg += (ti + 1) + '. ' + top[ti].name + ' (' + Math.round(top[ti].score * 100) + '% match)\n';
        }
        msg += '\nUse `/goto <class>` to navigate.';
        cc.addMessage('system', msg);
      }
      cc.updateStatus('Connected');
      cc.saveState();
    })
    .catch(function(e) {
      cc.addMessage('error', 'Search failed: ' + e.message);
      cc.updateStatus('Connected');
      cc.saveState();
    });
  };

  // ===== /skill — navigate to a file in the Skills Editor =====
  cc.executeSkillGoto = function(filePath) {
    if (!filePath) { cc.addMessage('system', 'Usage: /skill <file-path>'); cc.saveState(); return; }

    var onSkillsEditor = window.location.pathname.indexOf('/skills-editor/') !== -1;

    if (onSkillsEditor && window._skillsEditor) {
      cc.addMessage('system', 'Opening: ' + filePath);
      if (window._skillsEditor.isReady()) {
        window._skillsEditor.openFile(filePath);
      } else {
        var poll = setInterval(function() {
          if (window._skillsEditor.isReady()) {
            clearInterval(poll);
            window._skillsEditor.openFile(filePath);
          }
        }, 200);
        setTimeout(function() { clearInterval(poll); }, 5000);
      }
    } else {
      var pfxMatch = window.location.pathname.match(/^(.*\/ui\/interop\/interclaw)\//);
      var base = pfxMatch ? pfxMatch[1] : (cc.pathPrefix + '/ui/interop/interclaw');
      var targetUrl = base + '/skills-editor/index.html?open=' + encodeURIComponent(filePath);
      cc.addMessage('system', 'Opening Skills Editor: ' + filePath);
      cc.saveState();
      window.location.href = targetUrl;
    }
    cc.saveState();
  };

})(window._cc);
