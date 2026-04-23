// interclaw-chatbot/goto.js — executeGoto, navigation, and search
(function(cc) {

  // ── Portal URL catalog (M4) ─────────────────────────────────────────────
  // Loaded once per page from GET /api/portal-urls, which serves the
  // hand-curated config/portal-urls.json. Used as a fallback matcher when
  // /goto <query> does not resolve to an ObjectScript class: "goto audit",
  // "goto queues", "goto message viewer" all land here.
  cc._portalCatalog = null;
  cc._portalCatalogPromise = null;

  cc.loadPortalCatalog = function() {
    if (cc._portalCatalog) return Promise.resolve(cc._portalCatalog);
    if (cc._portalCatalogPromise) return cc._portalCatalogPromise;
    var url = (cc.chatApiBase || '/api/interclaw/production') + '/api/portal-urls';
    cc._portalCatalogPromise = fetch(url, { credentials: 'same-origin' })
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(data) {
        cc._portalCatalog = (data && data.entries) ? data : { entries: [] };
        return cc._portalCatalog;
      })
      .catch(function(err) {
        console.warn('[interclaw] portal catalog fetch failed:', err);
        cc._portalCatalog = { entries: [] };
        return cc._portalCatalog;
      });
    return cc._portalCatalogPromise;
  };

  // Score one catalog entry against the query. Exact slug/title/alias
  // matches return immediately with a very high score so "type a slug,
  // get that slug" is reliable even when sibling entries share keywords
  // (e.g. "production" vs "production-list"). Below that floor, title
  // contains and trigram similarity add fractional weight so loose
  // queries still rank the right entry on top.
  function scoreEntry(entry, queryLower) {
    if (entry.slug && entry.slug.toLowerCase() === queryLower) return 10;
    if (entry.title && entry.title.toLowerCase() === queryLower) return 9;
    var aliases = entry.aliases || [];
    for (var ai = 0; ai < aliases.length; ai++) {
      if (aliases[ai].toLowerCase() === queryLower) return 8;
    }

    var score = 0;
    var fields = [entry.slug, entry.title, entry.description];
    aliases.forEach(function(a) { fields.push(a); });
    (entry.keywords || []).forEach(function(k) { fields.push(k); });

    (entry.keywords || []).forEach(function(k) {
      if (k.toLowerCase() === queryLower) score += 1.2;
    });

    // Cap per-field containment/trigram contributions so an entry with
    // many keyword-heavy aliases can't runaway past a more specific hit.
    var containsFieldsScored = 0;
    for (var i = 0; i < fields.length; i++) {
      if (!fields[i]) continue;
      var f = fields[i].toLowerCase();
      if (f === queryLower) continue;
      if (f.indexOf(queryLower) !== -1 && containsFieldsScored < 2) {
        score += 0.4;
        containsFieldsScored++;
      }
      var sim = trigramSimilarity(queryLower, f);
      if (sim > 0.3) score += sim * 0.6;
    }
    return score;
  }

  cc.findPortalEntries = function(query, maxResults) {
    if (!cc._portalCatalog) return [];
    var q = (query || '').trim().toLowerCase();
    if (!q) return [];
    var entries = cc._portalCatalog.entries || [];
    var scored = [];
    for (var i = 0; i < entries.length; i++) {
      var s = scoreEntry(entries[i], q);
      if (s > 0.4) scored.push({ entry: entries[i], score: s });
    }
    scored.sort(function(a, b) { return b.score - a.score; });
    return scored.slice(0, maxResults || 5);
  };

  function expandTemplate(tpl, ns, extraName) {
    var ctx = cc.getEditorContext ? cc.getEditorContext() : {};
    var nsUpper = (ns || ctx.namespace || cc.detectNamespace() || 'INTERCLAW').toUpperCase();
    var nsLower = nsUpper.toLowerCase();
    // Keep the origin/pathPrefix relative — the browser already fills them
    // when the resulting URL starts with /, so we leave {origin} collapsed
    // to '' and {pathPrefix} to cc.pathPrefix. That way rendered links stay
    // on the same host and prefix the user is currently browsing.
    return tpl
      .replace(/\{origin\}/g, '')
      .replace(/\{pathPrefix\}/g, cc.pathPrefix || '')
      .replace(/\{namespace\}/g, nsUpper)
      .replace(/\{namespaceLower\}/g, nsLower)
      .replace(/\{name\}/g, extraName || '');
  }

  cc.resolvePortalUrl = function(entry, extraName) {
    return expandTemplate(entry.url, null, extraName);
  };

  // Kick off the catalog fetch early so the first /goto is snappy.
  // Fire-and-forget; resolution is awaited inside executeGoto's fallback.
  try { cc.loadPortalCatalog(); } catch (e) {}


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
  // Preference order:
  //   1. Shell context (top window is the /ui/interop/interclaw shell):
  //      swap the Portal or Traces iframe in place.
  //   2. Legacy-ui context (we ARE the legacy-ui page, with #viewer-frame):
  //      swap our own iframe.
  //   3. No frame context: navigate the whole browser.
  // openInPortalTab — single entry point used by every inline chat link.
  // Routes a legacy-ui URL into the Portal (or Traces) iframe AND makes sure
  // the user leaves chat mode so the iframe is actually visible. Returns
  // false so the inline onclick handler can use `return cc.openInPortalTab(...)`
  // to cancel the anchor's default navigation.
  cc.openInPortalTab = function(legacyUrl) {
    // Exit chat mode if we're in it — otherwise the portal iframe is hidden
    // behind the full-width chat pane and nothing the user can see changes.
    if (document.body.classList.contains('ic-chat-mode')) {
      document.body.classList.remove('ic-chat-mode');
      // Nudge the shell URL back to the right tab hash so reloads land on
      // the portal instead of reopening chat.
      try {
        var shell = (window.top && window.top._interclawShell) || window._interclawShell;
        var tabId = (legacyUrl && legacyUrl.indexOf('MessageViewer') !== -1) ? 'traces' : 'portal';
        if (shell && typeof shell.activateTab === 'function') shell.activateTab(tabId);
      } catch (e) { /* non-shell context — harmless */ }
    }
    cc.navigateLegacyUi(legacyUrl);
    return false;
  };

  cc.navigateLegacyUi = function(legacyUrl) {
    var hashIdx = legacyUrl.indexOf('#');
    if (hashIdx === -1) return false;
    var hashPath = legacyUrl.substring(hashIdx + 1);
    var pfx = cc.pathPrefix || '';

    // Navigate directly to the portal URL — bypass the legacy-ui wrapper entirely.
    var shell = (window.top && window.top._interclawShell) || window._interclawShell;
    if (shell && typeof shell.openInTab === 'function') {
      var tabId = (hashPath.indexOf('MessageViewer') !== -1) ? 'traces' : 'portal';
      if (shell.openInTab(tabId, pfx + hashPath)) return true;
    }

    // Inside-legacy-ui case (the wrapper's own iframe exists here).
    var frame = document.getElementById('viewer-frame');
    if (frame) {
      frame.src = pfx + hashPath;
      return true;
    }
    window.location.href = pfx + hashPath;
    return true;
  };

  // Navigate to a full (non-legacy-ui) portal URL — e.g. /csp/sys/* pages
  // that live outside the HealthShare namespace wrapper. We still try to
  // show these inside the Portal iframe first by wrapping the path in the
  // legacy-ui chrome, because opening new tabs from /goto feels bad. If
  // the URL is truly not Zen (no .zen, no .cls), fall back to window.open.
  cc.navigatePortalUrl = function(url) {
    if (!url) return false;
    var shell = (window.top && window.top._interclawShell) || window._interclawShell;
    if (shell && typeof shell.openInTab === 'function') {
      // SMP-style /csp/sys/* URLs can be embedded directly in the iframe;
      // no legacy-ui wrapper needed since the toolbar-border override in
      // legacy-ui already applies to those via its own MutationObserver.
      return shell.openInTab('portal', url);
    }
    window.open(url, '_blank');
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
    // Resolve editor type: explicit flag > server %Dictionary lookup > name heuristic > portal catalog
    if (!editorType && componentName && !_typeResolved) {
      lookupClassType(componentName, function(serverType) {
        var resolved = serverType || cc.inferEditorType(componentName);
        if (!resolved) {
          // Not a known class. Fall back to the Management Portal catalog:
          // fuzzy-match the query against slug/alias/keyword and open the
          // best hit. This is what makes `/goto audit`, `/goto queues`,
          // `/goto message viewer` work without the user knowing class names.
          cc.loadPortalCatalog().then(function() {
            var hits = cc.findPortalEntries(componentName, 5);
            if (!hits.length) {
              cc.addMessage('system', 'Could not resolve `' + componentName + '` as a class or portal page. Try `/find ' + componentName + '` to search class names.');
              cc.saveState();
              return;
            }
            var top = hits[0];
            // Require name-bearing templates (like DTL editor) to also be given a component name.
            var needsName = (top.entry.requires || []).indexOf('name') !== -1;
            if (needsName) {
              var alt = hits.filter(function(h) { return (h.entry.requires || []).indexOf('name') === -1; })[0];
              if (alt) top = alt;
            }
            var url = cc.resolvePortalUrl(top.entry);
            // If the top hit still needs a name (no other candidates), we
            // can't meaningfully navigate — tell the user what's missing.
            if ((top.entry.requires || []).indexOf('name') !== -1) {
              cc.addMessage('system', '`' + top.entry.title + '` needs a target name. Example: `/goto --dtl My.DTL.Name`.');
              cc.saveState();
              return;
            }
            var lines = ['Opening **' + top.entry.title + '** (' + top.entry.slug + ').'];
            if (hits.length > 1) {
              lines.push('');
              lines.push('Other matches:');
              for (var i = 1; i < Math.min(hits.length, 4); i++) {
                lines.push('- `/goto ' + hits[i].entry.slug + '` \u2014 ' + hits[i].entry.title);
              }
            }
            cc.addMessage('system', lines.join('\n'));
            cc.saveState();
            if (url.indexOf('/legacy-ui/') !== -1) {
              if (!cc.navigateLegacyUi(url)) cc.navigatePortalUrl(url);
            } else {
              cc.navigatePortalUrl(url);
            }
          });
          return;
        }
        cc.executeGoto(componentName, resolved, true);
      });
      return;
    }

    // Class match: build a portal URL and route it into the shell's iframe.
    // Previously this path was a no-op (the "Navigation links removed from
    // chat UI" era) which meant /goto DTL.MyTransform did nothing on the
    // Navigate directly to the portal URL without the legacy-ui wrapper.
    if (componentName && editorType && editorType !== 'trace') {
      var portalLink = cc.buildPortalLink(componentName, editorType);
      if (portalLink) {
        var pfx = cc.pathPrefix || '';
        var zenPath = portalLink.url;
        if (pfx && zenPath.indexOf(pfx) === 0) zenPath = zenPath.substring(pfx.length);
        cc.addMessage('system', 'Opening `' + componentName + '` in ' + portalLink.label + '.');
        cc.saveState();
        cc.navigateLegacyUi(pfx + '/ui/interop/interclaw/legacy-ui/index.html#' + zenPath);
        return;
      }
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
