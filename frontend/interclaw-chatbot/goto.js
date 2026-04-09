// interclaw-chatbot/goto.js — executeGoto, findAndClickComponent, all goto/navigation strategies
(function(cc) {

  // Build a portal URL for a class. Returns {url, label} or null.
  cc.buildPortalLink = function(className, editorType) {
    if (!className) return null;
    var ns = cc.detectNamespace() || 'HSLIB';
    var cspBase = window.location.origin + (cc.pathPrefix || '') + '/csp/healthshare/' + ns.toLowerCase();
    var edt = editorType || cc.inferEditorType(className);
    if (edt === 'dtl') return { url: cspBase + '/EnsPortal.DTLEditor.zen?DT=' + className + '.cls', label: 'DTL Editor' };
    if (edt === 'rule') return { url: cspBase + '/EnsPortal.RuleEditor.zen?RULE=' + className, label: 'Rule Editor' };
    if (edt === 'bpl') return { url: cspBase + '/EnsPortal.BPLEditor.zen?BP=' + className + '.cls', label: 'BPL Editor' };
    if (edt === 'production') return { url: cspBase + '/EnsPortal.ProductionConfig.zen?PRODUCTION=' + className, label: 'Production' };
    if (edt === 'bs' || edt === 'bo' || edt === 'bp' || edt === 'msg') {
      return { url: cspBase + '/EnsPortal.ProductionConfig.zen?$NAMESPACE=' + ns.toUpperCase(), label: 'Production Config' };
    }
    return null;
  };

  // ===== /goto-test: test multiple strategies =====
  cc.runGotoTest = function(strategiesStr, targetComponent) {
    var allStrategies = [1, 2, 3, 4, 5, 6];
    var strategies;
    if (strategiesStr === 'all') {
      strategies = allStrategies;
    } else {
      strategies = strategiesStr.split(',').map(function(s) { return parseInt(s.trim(), 10); }).filter(function(n) { return n >= 1 && n <= 6; });
    }
    if (strategies.length === 0) {
      cc.addMessage('system', 'No valid strategies. Use 1-6 or "all". Example: /goto-test 1,3,5 Demo.Hello');
      return;
    }

    var editorType = cc.inferEditorType(targetComponent);
    cc.addMessage('system', 'Testing ' + strategies.length + ' strategies for: ' + targetComponent + ' (editor: ' + (editorType || 'auto') + ')');

    var strategyIndex = 0;

    function tryNext() {
      if (strategyIndex >= strategies.length) {
        cc.addMessage('system', 'All strategies exhausted. Component not found: ' + targetComponent);
        cc.saveState();
        return;
      }
      var strat = strategies[strategyIndex];
      strategyIndex++;
      cc.addMessage('system', 'Strategy ' + strat + ': ' + strategyDesc(strat) + '...');

      runStrategy(strat, targetComponent, editorType, function(found) {
        if (found) {
          cc.addMessage('system', 'SUCCESS with strategy ' + strat + ': ' + strategyDesc(strat));
          if (shouldExpandOnGoto(targetComponent)) {
            setTimeout(function() { clickExpandIcon(); }, 100);
          }
          cc.saveState();
        } else {
          cc.addMessage('system', 'Strategy ' + strat + ' failed \u2014 component not in DOM');
          tryNext();
        }
      });
    }

    tryNext();
  };

  function strategyDesc(n) {
    switch(n) {
      case 1: return 'Direct DOM click (no refresh)';
      case 2: return 'Toggle sidebar panel (collapse/expand)';
      case 3: return 'Namespace bounce v2 (querySelector-based)';
      case 4: return 'PopState event (trigger Angular router)';
      case 5: return 'Open panel menu click (close/reopen editor)';
      case 6: return 'Full page reload with overlay';
      default: return 'Unknown';
    }
  }

  function runStrategy(stratNum, target, editorType, callback) {
    var panelMap = { 'production': 1, 'rule': 2, 'dtl': 3, 'bpl': 4 };
    var panelIndex = panelMap[editorType] || 3;

    switch(stratNum) {
      case 1:
        var found = cc.findAndClickComponent(target);
        callback(found);
        break;

      case 2:
        (function() {
          var iconXpath = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + panelIndex + ']/div[1]/div[2]/mat-icon/svg';
          xpathClick(iconXpath);
          setTimeout(function() {
            xpathClick(iconXpath);
            setTimeout(function() {
              var dropdownBase = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + panelIndex + ']/div[2]';
              var dropdownEl = null;
              try {
                var r = document.evaluate(dropdownBase, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
                dropdownEl = r.singleNodeValue;
              } catch(e) {}
              if (dropdownEl) {
                var items = dropdownEl.children;
                for (var di = 0; di < items.length; di++) {
                  if (items[di].textContent.trim().toLowerCase() === 'open full') {
                    items[di].click();
                    break;
                  }
                }
              }
              setTimeout(function() {
                var found = cc.findAndClickComponent(target);
                callback(found);
              }, 1500);
            }, 500);
          }, 500);
        })();
        break;

      case 3:
        namespaceBounce(function(bounced) {
          if (!bounced) { callback(false); return; }
          var attempts = 0;
          var poll = setInterval(function() {
            attempts++;
            if (attempts === 1) cc.executeGoto(target, editorType);
            var found = cc.findAndClickComponent(target);
            if (found || attempts >= 20) {
              clearInterval(poll);
              callback(found);
            }
          }, 250);
        });
        break;

      case 4:
        (function() {
          var url = new URL(window.location.href);
          url.searchParams.set('_refresh', Date.now());
          history.pushState({ refresh: true }, '', url.toString());
          window.dispatchEvent(new PopStateEvent('popstate', { state: { refresh: true } }));

          setTimeout(function() {
            history.back();
            setTimeout(function() {
              cc.executeGoto(target, editorType);
              setTimeout(function() {
                var found = cc.findAndClickComponent(target);
                callback(found);
              }, 1500);
            }, 1500);
          }, 1500);
        })();
        break;

      case 5:
        (function() {
          var otherPanelIndex = (panelIndex === 3) ? 2 : 3;
          var otherIconXpath = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + otherPanelIndex + ']/div[1]/div[2]/mat-icon/svg';
          var targetIconXpath = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + panelIndex + ']/div[1]/div[2]/mat-icon/svg';

          xpathClick(otherIconXpath);
          setTimeout(function() {
            var otherDropdown = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + otherPanelIndex + ']/div[2]';
            var otherDropdownEl = null;
            try {
              var r = document.evaluate(otherDropdown, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
              otherDropdownEl = r.singleNodeValue;
            } catch(e) {}
            if (otherDropdownEl) {
              var items = otherDropdownEl.children;
              for (var di = 0; di < items.length; di++) {
                if (items[di].textContent.trim().toLowerCase() === 'open full') {
                  items[di].click();
                  break;
                }
              }
            }

            setTimeout(function() {
              xpathClick(targetIconXpath);
              setTimeout(function() {
                var targetDropdown = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + panelIndex + ']/div[2]';
                var targetDropdownEl = null;
                try {
                  var r = document.evaluate(targetDropdown, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
                  targetDropdownEl = r.singleNodeValue;
                } catch(e) {}
                if (targetDropdownEl) {
                  var items = targetDropdownEl.children;
                  for (var di = 0; di < items.length; di++) {
                    if (items[di].textContent.trim().toLowerCase() === 'open full') {
                      items[di].click();
                      break;
                    }
                  }
                }

                setTimeout(function() {
                  var found = cc.findAndClickComponent(target);
                  callback(found);
                }, 2000);
              }, 500);
            }, 2000);
          }, 500);
        })();
        break;

      case 6:
        (function() {
          cc.addMessage('system', '  Reloading page...');
          softReloadAndClick(target, editorType);
        })();
        break;

      default:
        callback(false);
    }
  }

  function refreshApp() {
    cc.isReloading = true;
    cc.saveState();
    sessionStorage.setItem('chatbot-programmatic-reload', 'true');
    var overlay = document.getElementById('reload-overlay');
    if (overlay) overlay.style.display = 'block';
    window.location.reload();
  }

  function softReloadAndClick(componentName, editorType) {
    console.log('[goto] Soft reload for:', componentName);
    cc.isReloading = true;
    sessionStorage.setItem('chatbot-click-target', componentName);
    if (editorType) sessionStorage.setItem('chatbot-click-editor', editorType);
    else sessionStorage.removeItem('chatbot-click-editor');
    cc.saveState();
    sessionStorage.setItem('chatbot-programmatic-reload', 'true');

    var appRoot = document.querySelector('app-root');
    if (appRoot) {
      var clone = appRoot.cloneNode(true);
      clone.id = 'reload-snapshot';
      clone.style.cssText = 'position:fixed;top:0;left:0;right:var(--chatbot-width,25vw);bottom:0;z-index:99999;pointer-events:none;overflow:hidden;background:white;';
      document.body.appendChild(clone);
    }
    document.body.style.background = 'white';

    var overlay = document.getElementById('reload-overlay');
    if (overlay) {
      overlay.style.display = 'block';
      overlay.classList.remove('fade-out');
    }

    window.location.reload();
  }

  // ===== /ns — single-hop namespace switch =====
  cc.switchNamespace = function(targetNs) {
    targetNs = targetNs.toUpperCase();
    var currentNs = (cc.detectNamespace() || '').toUpperCase();
    if (targetNs === currentNs) {
      cc.addMessage('system', 'Already in ' + targetNs);
      cc.saveState();
      return;
    }

    cc._isBouncingNamespace = true;

    var toolbarBtns = document.querySelectorAll('fr-topbar button, mat-toolbar button, header button');
    var nsBtn = null;
    for (var i = 0; i < toolbarBtns.length; i++) {
      if (toolbarBtns[i].textContent.trim().toUpperCase().indexOf(currentNs) !== -1) { nsBtn = toolbarBtns[i]; break; }
    }
    if (!nsBtn) { cc._isBouncingNamespace = false; cc.addMessage('system', 'Could not find namespace button'); cc.saveState(); return; }

    // Freeze UI
    var blocker = document.createElement('div');
    blocker.id = 'ns-switch-blocker';
    blocker.style.cssText = 'position:fixed;top:0;left:0;right:var(--chatbot-width,25vw);bottom:0;z-index:99998;background:white;';
    document.body.appendChild(blocker);
    var appRoot = document.querySelector('app-root');
    if (appRoot) {
      var clone = appRoot.cloneNode(true);
      clone.id = 'ns-switch-snapshot';
      clone.style.cssText = appRoot.style.cssText + ';position:fixed;top:0;left:0;right:var(--chatbot-width,25vw);bottom:0;z-index:99999;pointer-events:none;overflow:hidden;';
      document.body.appendChild(clone);
    }
    var cdkOverlay = document.querySelector('.cdk-overlay-container');
    if (cdkOverlay) cdkOverlay.style.display = 'none';
    var snackEls = document.querySelectorAll('mat-snack-bar-container, simple-snack-bar');
    snackEls.forEach(function(el) { el.style.display = 'none'; });

    // Click namespace button to open picker
    nsBtn.click();
    setTimeout(function() {
      var overlayBtns = document.querySelectorAll('.cdk-overlay-container button, .cdk-overlay-pane button');
      var targetBtn = null;
      for (var j = 0; j < overlayBtns.length; j++) {
        if (overlayBtns[j].textContent.trim().toUpperCase() === targetNs) { targetBtn = overlayBtns[j]; break; }
      }
      if (!targetBtn) {
        var snap = document.getElementById('ns-switch-snapshot'); if (snap) snap.remove();
        var blk = document.getElementById('ns-switch-blocker'); if (blk) blk.remove();
        if (cdkOverlay) cdkOverlay.style.display = '';
        cc._isBouncingNamespace = false;
        cc.addMessage('system', 'Namespace "' + targetNs + '" not found in picker');
        cc.saveState();
        return;
      }
      targetBtn.click();
      setTimeout(function() {
        // Unfreeze
        var snap = document.getElementById('ns-switch-snapshot'); if (snap) snap.remove();
        var blk = document.getElementById('ns-switch-blocker'); if (blk) blk.remove();
        if (cdkOverlay) cdkOverlay.style.display = '';
        var snacks = document.querySelectorAll('mat-snack-bar-container, simple-snack-bar');
        snacks.forEach(function(el) { el.remove(); });
        cc._isBouncingNamespace = false;
        // Let the namespace change detection pick up the new namespace and reinit session
        cc.currentNamespace = targetNs;
        cc.addMessage('system', 'Switched to ' + targetNs);
        cc.sessionId = null;
        cc.sessionReady = false;
        cc.initSession({ skipWelcome: true });
        cc.saveState();
        var chatInput = document.getElementById('chatbot-input');
        if (chatInput) chatInput.focus();
      }, BOUNCE_PAUSE);
    }, BOUNCE_PAUSE);
  };

  // ===== Page Freeze — covers the entire goto flow end-to-end =====
  var _freezeState = null;

  function freezePage() {
    if (_freezeState) return; // already frozen
    var cdkOverlay = document.querySelector('.cdk-overlay-container');
    var blocker = document.createElement('div');
    blocker.id = 'ns-bounce-blocker';
    blocker.style.cssText = 'position:fixed;top:0;left:0;right:var(--chatbot-width,25vw);bottom:0;z-index:99998;background:white;';
    document.body.appendChild(blocker);
    var appRoot = document.querySelector('app-root');
    if (appRoot) {
      var clone = appRoot.cloneNode(true);
      clone.id = 'ns-bounce-snapshot';
      clone.style.cssText = appRoot.style.cssText + ';position:fixed;top:0;left:0;right:var(--chatbot-width,25vw);bottom:0;z-index:99999;pointer-events:none;overflow:hidden;';
      document.body.appendChild(clone);
    }
    // NOTE: Do NOT hide CDK overlay — the bounce needs it alive for namespace picker clicks
    var snackEls = document.querySelectorAll('mat-snack-bar-container, simple-snack-bar');
    snackEls.forEach(function(el) { el.style.display = 'none'; });
    var snackParents = document.querySelectorAll('.cdk-global-overlay-wrapper');
    snackParents.forEach(function(el) { el.dataset.bounceHidden = el.style.display; el.style.display = 'none'; });
    _freezeState = {};
  }

  function unfreezePage() {
    if (!_freezeState) return;
    var snap = document.getElementById('ns-bounce-snapshot');
    if (snap) snap.remove();
    var blk = document.getElementById('ns-bounce-blocker');
    if (blk) blk.remove();
    // CDK overlay was never hidden — no restore needed
    var snacks = document.querySelectorAll('mat-snack-bar-container, simple-snack-bar');
    snacks.forEach(function(el) { el.remove(); });
    var wrappers = document.querySelectorAll('.cdk-global-overlay-wrapper');
    wrappers.forEach(function(el) { if (el.dataset.bounceHidden !== undefined) { el.style.display = el.dataset.bounceHidden; delete el.dataset.bounceHidden; } });
    _freezeState = null;
  }

  // ===== Namespace Bounce v3 =====
  // Re-queries DOM at every step (elements go stale after Angular re-renders on ns switch).
  // Uses 200ms pauses (50ms was too fast for Angular to process).
  var BOUNCE_PAUSE = 200;
  var BOUNCE_TARGET = 'HSLIB';

  function findNsButton(ns) {
    var btns = document.querySelectorAll('fr-topbar button, mat-toolbar button, header button');
    for (var i = 0; i < btns.length; i++) {
      if (btns[i].textContent.trim().toUpperCase().indexOf(ns) !== -1) return btns[i];
    }
    return null;
  }

  function findOverlayButton(targetNs, excludeNs) {
    var btns = document.querySelectorAll('.cdk-overlay-container button, .cdk-overlay-pane button');
    for (var j = 0; j < btns.length; j++) {
      var t = btns[j].textContent.trim().toUpperCase();
      if (targetNs && t === targetNs) return { btn: btns[j], ns: targetNs };
      if (!targetNs && t && t !== excludeNs && t.length < 30) return { btn: btns[j], ns: t };
    }
    return null;
  }

  function namespaceBounce(callback) {
    cc._isBouncingNamespace = true;
    var _origCallback = callback;
    callback = function(result) {
      cc._isBouncingNamespace = false;
      cc.currentNamespace = cc.detectNamespace();
      _origCallback(result);
    };

    var ns = (cc.detectNamespace() || '').toUpperCase();
    if (!ns) { console.log('[bounce] No namespace'); callback(false); return; }

    var nsBtn = findNsButton(ns);
    if (!nsBtn) { console.log('[bounce] No ns button for', ns); callback(false); return; }

    var bounceNs = (ns === BOUNCE_TARGET) ? null : BOUNCE_TARGET;

    // Freeze if not already frozen
    if (!_freezeState) freezePage();

    // Step 1: Open namespace dropdown
    console.log('[bounce] Step 1: clicking ns button for', ns);
    nsBtn.click();
    setTimeout(function() {
      // Step 2: Click the other namespace (e.g. HSLIB)
      var other = findOverlayButton(bounceNs, ns);
      if (!other) { unfreezePage(); console.log('[bounce] No bounce target in overlay'); callback(false); return; }
      bounceNs = other.ns;
      console.log('[bounce] Step 2: switching', ns, '->', bounceNs);
      other.btn.click();

      setTimeout(function() {
        // Step 3: Re-find the ns button (DOM was replaced by Angular after ns switch)
        var nsBtn2 = findNsButton(bounceNs);
        if (!nsBtn2) { unfreezePage(); console.log('[bounce] Step 3: lost ns button after switch to', bounceNs); callback(false); return; }
        console.log('[bounce] Step 3: re-opening dropdown on', bounceNs);
        nsBtn2.click();

        setTimeout(function() {
          // Step 4: Click back to original namespace
          var orig = findOverlayButton(ns, bounceNs);
          if (!orig) { unfreezePage(); console.log('[bounce] Step 4: cant find', ns, 'in overlay'); callback(false); return; }
          console.log('[bounce] Step 4: switching back', bounceNs, '->', ns);
          orig.btn.click();

          setTimeout(function() {
            // Remove highlight/focus from namespace button after bounce
            var finalBtn = findNsButton(ns);
            if (finalBtn) finalBtn.blur();
            document.activeElement && document.activeElement.blur();
            console.log('[bounce] Done:', ns, '->', bounceNs, '->', ns);
            callback(true);
          }, BOUNCE_PAUSE);
        }, BOUNCE_PAUSE);
      }, BOUNCE_PAUSE * 3);
    }, BOUNCE_PAUSE);
  }

  function xpathClick(xpath) {
    try {
      var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
      var el = result.singleNodeValue;
      if (el) { el.click(); return true; }
    } catch(e) { console.log('[goto] XPath failed:', xpath, e); }
    return false;
  }

  // Module-level panel opener — used by both executeGoto and bounce-test.
  // Matches the proven dom-test openPanel approach: click icon first, wait, then "Open Full".
  function openEditorPanel(pi, callback) {
    var iconXpath = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + pi + ']/div[1]/div[2]/mat-icon/svg';
    var ddXpath = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + pi + ']/div[2]';

    function tryClickOpenFull(el) {
      if (!el || !el.children.length) return false;
      for (var di = 0; di < el.children.length; di++) {
        if (el.children[di].textContent.trim().toLowerCase() === 'open full') {
          el.children[di].click();
          console.log('[openEditorPanel] pi=' + pi + ' clicked Open Full');
          return true;
        }
      }
      return false;
    }

    // Step 1: Click the panel header icon to reveal the dropdown
    console.log('[openEditorPanel] pi=' + pi + ' clicking header icon');
    try {
      var ir = document.evaluate(iconXpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
      if (ir.singleNodeValue) ir.singleNodeValue.click();
      else console.log('[openEditorPanel] pi=' + pi + ' icon NOT FOUND');
    } catch(e) {}

    // Step 2: Wait for dropdown to appear, then click "Open Full"
    setTimeout(function() {
      try {
        var r = document.evaluate(ddXpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
        var el = r.singleNodeValue;
        console.log('[openEditorPanel] pi=' + pi + ' dropdown:', el ? ('found, ' + el.children.length + ' children') : 'NOT FOUND');
        if (tryClickOpenFull(el)) { setTimeout(callback, 300); return; }
      } catch(e) {}

      console.log('[openEditorPanel] pi=' + pi + ' Open Full not found, proceeding');
      setTimeout(callback, 300);
    }, 300);
  }

  // Determine class type by querying %Dictionary.ClassDefinition on the server.
  // Reads the actual Extends clause — always more reliable than name heuristics.
  // callback(type) where type is 'dtl', 'rule', 'bpl', 'production', or null.
  function lookupClassType(className, callback) {
    var ns = cc.detectNamespace() || 'HSLIB';
    var pfxMatch = window.location.pathname.match(/^(\/[^/]+)\/ui\/interop\/interclaw\//);
    var pathPrefix = pfxMatch ? pfxMatch[1] : '';
    var atelierBase = pathPrefix + '/api/atelier/v8/' + ns.toLowerCase();

    var sql = "SELECT Super FROM %Dictionary.ClassDefinition WHERE Name = '" + className.replace(/'/g, "''") + "'";
    console.log('[goto] %Dictionary query:', sql);

    fetch(atelierBase + '?action=query', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify({ query: sql })
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
      var rows = (data.result || {}).content || [];
      if (rows.length === 0) { console.log('[goto] %Dictionary: class not found'); callback(null); return; }
      var superStr = rows[0].Super || '';
      console.log('[goto] %Dictionary Super:', superStr);
      callback(classifyFromSuper(superStr));
    })
    .catch(function(e) {
      console.log('[goto] %Dictionary lookup failed:', e);
      callback(null);
    });
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

  cc.executeGoto = function(componentName, editorType, _typeResolved) {
    var panelMap = { 'production': 1, 'rule': 2, 'dtl': 3, 'bpl': 4, 'trace': 5 };

    // Resolve editor type: explicit flag > server %Dictionary lookup > name heuristic
    if (!editorType && componentName && !_typeResolved) {
      console.log('[goto] No explicit type for', componentName, '— querying %Dictionary...');
      lookupClassType(componentName, function(serverType) {
        var resolved = serverType || cc.inferEditorType(componentName);
        console.log('[goto] Resolved type:', resolved, serverType ? '(from %Dictionary)' : '(name heuristic fallback)');
        cc.executeGoto(componentName, resolved, true);
      });
      return;
    }

    // Chat mode: app-root is hidden — open in new tab to preserve chat view
    if (document.body.classList.contains('ic-chat-mode')) {
      if (editorType === 'trace') {
        var chatTrNs = cc.detectNamespace() || 'HSLIB';
        var chatTrBase = window.location.origin + (cc.pathPrefix || '') + '/csp/healthshare/' + chatTrNs.toLowerCase();
        var chatTrUrl = componentName
          ? chatTrBase + '/EnsPortal.VisualTrace.zen?SESSIONID=' + encodeURIComponent(componentName) + '&$NAMESPACE=' + chatTrNs
          : chatTrBase + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + chatTrNs;
        window.open(chatTrUrl, '_blank');
        cc.addMessage('system', 'Opened ' + (componentName ? 'trace ' + componentName : 'Message Viewer') + ' in new tab');
        cc.saveState();
        return;
      }
      var chatLink = cc.buildPortalLink(componentName, editorType);
      if (chatLink) {
        window.open(chatLink.url, '_blank');
        cc.addMessage('system', 'Opened ' + chatLink.label + ' in new tab');
      } else {
        cc.addMessage('system', 'Pushed ' + componentName + ' (no editor page for this type)');
      }
      cc.saveState();
      return;
    }

    // Zen page: no Angular app-root — navigate directly via portal URL
    // If a content iframe exists (message-viewer wrapper), navigate it instead of the full page
    if (!document.querySelector('app-root')) {
      var contentFrame = document.getElementById('viewer-frame');
      if (editorType === 'trace') {
        var trNs = cc.detectNamespace() || 'HSLIB';
        var trBase = window.location.origin + (cc.pathPrefix || '') + '/csp/healthshare/' + trNs.toLowerCase();
        var trUrl = componentName
          ? trBase + '/EnsPortal.VisualTrace.zen?SESSIONID=' + encodeURIComponent(componentName) + '&$NAMESPACE=' + trNs
          : trBase + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + trNs;
        cc.addMessage('system', 'Opening ' + (componentName ? 'trace ' + componentName : 'Message Viewer') + '...');
        cc.saveState();
        if (contentFrame) { contentFrame.src = trUrl; } else { window.location.href = trUrl; }
        return;
      }
      var portalLink = cc.buildPortalLink(componentName, editorType);
      if (portalLink) {
        console.log('[goto] Zen page detected — navigating to', portalLink.label, portalLink.url);
        cc.addMessage('system', 'Opening ' + portalLink.label + '...');
        cc.saveState();
        if (contentFrame) { contentFrame.src = portalLink.url; } else { window.location.href = portalLink.url; }
      } else {
        cc.addMessage('system', 'Pushed ' + componentName + ' (no editor page for this type)');
        cc.saveState();
      }
      return;
    }

    // Handle --trace
    if (editorType === 'trace') {
      var ns = cc.detectNamespace() || 'HSLIB';
      var cspBase = window.location.origin + (cc.pathPrefix || '') + '/csp/healthshare/' + ns.toLowerCase();
      if (componentName) {
        window.open(cspBase + '/EnsPortal.VisualTrace.zen?SESSIONID=' + encodeURIComponent(componentName) + '&$NAMESPACE=' + ns, '_blank');
        cc.addMessage('system', 'Opened trace for session ' + componentName);
      } else {
        cc.addMessage('system', 'Fetching latest trace...');
        var atelierBase = window.location.origin + '/irishealth/api/atelier/v8/' + ns.toLowerCase();
        fetch(atelierBase + '?action=query', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': 'Basic ' + btoa('superuser:SYS') },
          body: JSON.stringify({ query: 'SELECT TOP 1 SessionId FROM Ens.MessageHeader ORDER BY ID DESC' })
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
          var rows = (data.result || {}).content || [];
          if (rows.length > 0 && rows[0].SessionId) {
            var sid = rows[0].SessionId;
            window.open(cspBase + '/EnsPortal.VisualTrace.zen?SESSIONID=' + sid + '&$NAMESPACE=' + ns, '_blank');
            cc.addMessage('system', 'Opened trace for session ' + sid);
          } else {
            window.open(cspBase + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + ns, '_blank');
            cc.addMessage('system', 'No messages found \u2014 opened Message Viewer');
          }
          cc.saveState();
        })
        .catch(function() {
          window.open(cspBase + '/EnsPortal.MessageViewer.zen?$NAMESPACE=' + ns, '_blank');
          cc.addMessage('system', 'Opened Message Viewer in new tab');
          cc.saveState();
        });
      }
      return;
    }

    // Handle --production
    if (editorType === 'production') {
      var prodIconXpath = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[1]/div/div[2]/mat-icon/svg';
      xpathClick(prodIconXpath);
      var prodDropdown = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[1]/div[2]';
      var prodDropdownEl = null;
      try {
        var r = document.evaluate(prodDropdown, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
        prodDropdownEl = r.singleNodeValue;
      } catch(e) {}
      var opened = false;
      if (prodDropdownEl) {
        var items = prodDropdownEl.children;
        for (var di = 0; di < items.length; di++) {
          if (items[di].textContent.trim().toLowerCase() === 'open full') {
            items[di].click();
            opened = true;
            break;
          }
        }
      }
      if (opened) {
        cc.addMessage('system', 'Opened production' + (componentName ? ' ' + componentName : ''));
      } else if (componentName) {
        var url = new URL(window.location.href);
        url.searchParams.set('$PRODUCTION', componentName);
        cc.addMessage('system', 'New production \u2014 reloading with ' + componentName + '...');
        cc.saveState();
        sessionStorage.setItem('chatbot-programmatic-reload', 'true');
        window.location.href = url.toString();
        return;
      }
      cc.saveState();
      return;
    }

    // --- Main goto flow: bounce → open panel → poll → click ---
    // Same proven flow as /bounce-test (without create/delete phases)
    var panelIndex = editorType ? (panelMap[editorType] || null) : null;
    console.log('[goto] Starting for', componentName, 'editor=' + editorType, 'panel=' + panelIndex);

    // Always bounce — even if component is in DOM, we need the panel to go full
    // var preCheck = cc.findAndClickComponent(componentName);
    // if (preCheck) {
    //   console.log('[goto] Found in DOM without bounce');
    //   cc.saveState();
    //   return;
    // }

    // Step 1: Bounce to refresh Angular's component list
    console.log('[goto] Not in DOM, bouncing...');
    namespaceBounce(function(bounced) {
      unfreezePage();
      if (!bounced) {
        console.log('[goto] Bounce failed');
        cc.addMessage('system', 'Bounce failed for: ' + componentName);
        cc.saveState();
        return;
      }

      // Step 2: Let Angular settle after unfreeze before touching panels
      console.log('[goto] Bounce done, waiting for Angular to settle...');
      setTimeout(function() {

      // Step 3: Open the correct editor panel (if type known), then poll
      function startPoll() {
        var attempts = 0;
        var poll = setInterval(function() {
          attempts++;
          var found = cc.findAndClickComponent(componentName);
          if (found || attempts >= 30) {
            clearInterval(poll);
            if (found) {
              console.log('[goto] Found', componentName, 'after', attempts, 'polls');
              // Append portal link as system message
              var link = cc.buildPortalLink(componentName, editorType);
              if (link) {
                cc.addMessage('system', '[' + componentName + ' — ' + link.label + '](' + link.url + ')');
              }
            } else {
              cc.addMessage('system', 'Component not found: ' + componentName);
            }
            cc.saveState();
          }
        }, 300);
      }

      if (panelIndex) {
        console.log('[goto] Opening panel', panelIndex, 'type=' + editorType);
        openEditorPanel(panelIndex, startPoll);
      } else {
        console.log('[goto] Unknown editor type, polling without panel open');
        startPoll();
      }

      }, 300); // Angular settle delay after unfreeze
    });
  };

  function shouldExpandOnGoto(componentName) {
    if (!componentName) return false;
    var name = componentName.toLowerCase();
    if (name.endsWith('.production') || name.indexOf('.production.') !== -1) return false;
    return true;
  }

  function clickExpandIcon() {
    var panelIcon = null;

    try {
      var result = document.evaluate(
        '/html/body/app-root/div[2]/app-dashboard/div[2]/interop-grid-cell/div/div/interop-grid-cell[2]/div/div/interop-grid-cell[2]/div/div[1]/div/div/mat-icon',
        document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null
      );
      panelIcon = result.singleNodeValue;
    } catch(e) {
      console.log('[goto] XPath lookup for panel icon failed:', e);
    }

    if (!panelIcon) {
      panelIcon = document.querySelector('mat-icon[svgicon="panel"]');
    }

    if (!panelIcon) {
      console.log('[goto] Panel icon not found');
      return false;
    }
    console.log('[goto] Clicking panel icon to open menu');
    panelIcon.click();

    setTimeout(function() {
      var openFullItem = null;

      try {
        var result = document.evaluate(
          '/html/body/app-root/div[2]/app-dashboard/div[1]/div[3]/div[2]/div[3]',
          document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null
        );
        openFullItem = result.singleNodeValue;
      } catch(e) {
        console.log('[goto] XPath lookup for Open Full failed:', e);
      }

      if (!openFullItem) {
        var openFullIcon = document.querySelector('mat-icon[svgicon="openFull"]');
        if (openFullIcon) {
          openFullItem = openFullIcon.closest('.paneMenuItem') || openFullIcon.parentElement;
        }
      }

      if (!openFullItem) {
        var items = document.querySelectorAll('.paneMenuItem');
        for (var i = 0; i < items.length; i++) {
          if (items[i].textContent.trim().indexOf('Open Full') !== -1) {
            openFullItem = items[i];
            break;
          }
        }
      }

      if (openFullItem) {
        console.log('[goto] Clicking "Open Full" menu item');
        openFullItem.click();
      } else {
        console.log('[goto] "Open Full" menu not found \u2014 clicking panel icon again to undo toggle');
        panelIcon.click();
      }
    }, 25);

    return true;
  }

  // ===== /find — fuzzy search over all classes in the namespace =====
  // Uses trigram similarity scoring to find closest matches

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
    var ns = cc.detectNamespace() || 'HSLIB';
    var pfxMatch = window.location.pathname.match(/^(\/[^/]+)\/ui\/interop\/interclaw\//);
    var pathPrefix = pfxMatch ? pfxMatch[1] : '';
    var atelierBase = pathPrefix + '/api/atelier/v8/' + ns.toLowerCase();

    cc.addMessage('system', 'Searching for "' + query + '" in ' + ns + '...');
    cc.updateStatus('Searching...');

    // Fetch class list from Atelier API
    fetch(atelierBase + '/docnames/cls', {
      credentials: 'include'
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
      var docs = (data.result || {}).content || [];
      if (docs.length === 0) {
        cc.addMessage('system', 'No classes found in ' + ns);
        cc.updateStatus('Connected');
        cc.saveState();
        return;
      }

      // Extract class names (strip .cls suffix)
      var classes = [];
      for (var i = 0; i < docs.length; i++) {
        var name = docs[i].name || docs[i];
        if (typeof name === 'string') {
          classes.push(name.replace(/\.cls$/i, ''));
        }
      }

      var queryLower = query.toLowerCase();
      var queryParts = queryLower.split('.');
      var queryShort = queryParts[queryParts.length - 1];

      // Score each class
      var scored = [];
      for (var ci = 0; ci < classes.length; ci++) {
        var cls = classes[ci];
        var clsLower = cls.toLowerCase();
        var clsParts = clsLower.split('.');
        var clsShort = clsParts[clsParts.length - 1];

        // Exact match
        if (clsLower === queryLower) {
          scored.push({ name: cls, score: 1.0 });
          continue;
        }

        // Contains query as substring
        var containsBonus = clsLower.indexOf(queryLower) !== -1 ? 0.3 : 0;

        // Short name match
        var shortBonus = clsShort === queryShort ? 0.25 : (clsShort.indexOf(queryShort) !== -1 ? 0.1 : 0);

        // Trigram similarity on full name and short name
        var fullSim = trigramSimilarity(queryLower, clsLower);
        var shortSim = trigramSimilarity(queryShort, clsShort);

        var score = Math.max(fullSim, shortSim * 0.9) + containsBonus + shortBonus;
        if (score > 0.15) {
          scored.push({ name: cls, score: score });
        }
      }

      // Sort by score descending
      scored.sort(function(a, b) { return b.score - a.score; });

      // Show top 10
      var top = scored.slice(0, 10);
      if (top.length === 0) {
        cc.addMessage('system', 'No matches for "' + query + '" in ' + ns + ' (' + classes.length + ' classes searched).');
      } else {
        var msg = '**Search results for "' + query + '"** (' + classes.length + ' classes)\n\n';
        for (var ti = 0; ti < top.length; ti++) {
          var pct = Math.round(top[ti].score * 100);
          msg += (ti + 1) + '. ' + top[ti].name + ' (' + pct + '% match)\n';
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

  cc.checkPendingClick = function() {
    var target = sessionStorage.getItem('chatbot-click-target');
    if (!target) return;
    sessionStorage.removeItem('chatbot-click-target');
    var editorType = sessionStorage.getItem('chatbot-click-editor') || null;
    sessionStorage.removeItem('chatbot-click-editor');

    console.log('[goto] Looking for component after reload:', target);
    var attempts = 0;
    var maxAttempts = 30;

    var interval = setInterval(function() {
      attempts++;

      var dashboard = document.querySelector('app-dashboard');
      var valueDivs = document.querySelectorAll('div[id$="_value"]');
      var listItems = document.querySelectorAll('.cdk-virtual-scroll-content-wrapper > *, interop-collection-list-item');
      var domReady = valueDivs.length > 0 || listItems.length > 0 || (dashboard && dashboard.children.length > 2);

      if (domReady || attempts >= maxAttempts) {
        clearInterval(interval);
        document.body.classList.remove('reloading-bg');
        var overlay = document.getElementById('reload-overlay');
        if (overlay) {
          overlay.classList.add('fade-out');
          setTimeout(function() {
            overlay.style.display = 'none';
            overlay.classList.remove('fade-out');
          }, 400);
        }
        cc.executeGoto(target, editorType);
      }
    }, 300);
  };

  cc.findAndClickComponent = function(name) {
    var shortName = name.indexOf('.') !== -1 ? name.split('.').pop() : name;
    var candidates = [name, shortName];

    for (var c = 0; c < candidates.length; c++) {
      var searchName = candidates[c];

      var valueDivs = document.querySelectorAll('div[id$="_value"]');
      for (var i = 0; i < valueDivs.length; i++) {
        var text = valueDivs[i].textContent.trim();
        if (text === searchName || text.indexOf(searchName) !== -1) {
          console.log('[goto] Found in value div:', valueDivs[i].id, text);
          valueDivs[i].click();
          return true;
        }
      }

      var listItems = document.querySelectorAll(
        'mat-list-item, mat-nav-list-item, .mat-list-item, ' +
        '.collection-list-item, [class*="list-item"], ' +
        '.cdk-virtual-scroll-content-wrapper > *, ' +
        'interop-collection-list-item, app-collection-list *'
      );
      for (var i = 0; i < listItems.length; i++) {
        var text = listItems[i].textContent.trim();
        if (text === searchName || text.indexOf(searchName) !== -1) {
          console.log('[goto] Found in list item:', listItems[i].tagName, text);
          listItems[i].click();
          return true;
        }
      }

      var allEls = document.querySelectorAll('span, div, a, td, li, p, button');
      for (var i = 0; i < allEls.length; i++) {
        var el = allEls[i];
        if (el.children.length > 2) continue;
        var text = el.textContent.trim();
        if (text === searchName) {
          console.log('[goto] Found leaf match:', el.tagName, el.className, text);
          el.click();
          return true;
        }
      }
    }

    console.log('[goto] Could not find:', name);
    var allValueDivs = document.querySelectorAll('div[id$="_value"]');
    console.log('[goto] Available value divs:', Array.from(allValueDivs).map(function(d) { return d.textContent.trim(); }));

    return false;
  };

  // ===== /bounce-test — end-to-end goto test with ephemeral class =====
  // Usage: /bounce-test [--type rule|dtl|bpl] [--dry-run] [--pause N] [--keep] [--fix 1|2|3|4]
  //   --type T    Class type to test (rule, dtl, bpl). Default: rule
  //   --dry-run   Log every step but don't click or create anything
  //   --pause N   Milliseconds between steps (default 200)
  //   --keep      Don't delete the test class after (for manual inspection)
  //   --fix 1     Skip pre-bounce DOM search — straight to bounce
  //   --fix 2     Open panel first, then bounce, then search
  //   --fix 3     Bounce + delay cdk-overlay restore until panel loaded
  //   --fix 4     Bounce without any freeze (visible namespace switch)
  cc.runBounceTest = function(args) {
    var dryRun = args.indexOf('--dry-run') !== -1;
    var keep = args.indexOf('--keep') !== -1;
    var pauseMatch = args.match(/--pause\s+(\d+)/);
    var pause = pauseMatch ? parseInt(pauseMatch[1]) : 200;
    var fixMatch = args.match(/--fix\s+(\d)/);
    var fix = fixMatch ? parseInt(fixMatch[1]) : 0;
    var typeMatch = args.match(/--type\s+(rule|dtl|bpl)/i);
    var testType = typeMatch ? typeMatch[1].toLowerCase() : 'rule';
    var step = 0;

    var panelForType = { 'rule': 2, 'dtl': 3, 'bpl': 4 };
    var panelIndex = panelForType[testType] || 2;

    function log(msg) {
      step++;
      var prefix = '[bounce-test ' + step + ']';
      console.log(prefix, msg);
      cc.addMessage('system', prefix + ' ' + msg);
      cc.saveState();
    }

    // Derive API base from page URL
    var pfxMatch = window.location.pathname.match(/^(\/[^/]+)\/ui\/interop\/interclaw\//);
    var pathPrefix = pfxMatch ? pfxMatch[1] : '';
    var ns = (cc.detectNamespace() || '').toUpperCase();
    if (!ns) { log('ABORT — no namespace detected'); return; }
    var atelierBase = pathPrefix + '/api/atelier/v8/' + ns.toLowerCase();

    // Generate random class name and source based on type
    var rnd = Math.random().toString(36).substring(2, 7).toUpperCase();
    var className, classSource;

    if (testType === 'dtl') {
      className = 'BounceTest.DTL.Test' + rnd + 'Passthrough';
      classSource = [
        '/// Bounce test DTL — auto-generated, will be deleted',
        'Class ' + className + ' Extends Ens.DataTransformDTL',
        '{',
        '',
        'Parameter IGNOREMISSINGSOURCE = 1;',
        'Parameter REPORTERRORS = 1;',
        'Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;',
        '',
        'XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]',
        '{',
        '<transform sourceClass=\'EnsLib.HL7.Message\' targetClass=\'EnsLib.HL7.Message\' sourceDocType=\'2.5.1:ADT_A01\' targetDocType=\'2.5.1:ADT_A01\' create=\'copy\' language=\'objectscript\' >',
        '</transform>',
        '}',
        '',
        '}'
      ];
    } else if (testType === 'bpl') {
      className = 'BounceTest.BPL.Test' + rnd + 'Process';
      classSource = [
        '/// Bounce test BPL — auto-generated, will be deleted',
        'Class ' + className + ' Extends Ens.BusinessProcessBPL',
        '{',
        '',
        'XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]',
        '{',
        '<process language=\'objectscript\' request=\'Ens.Request\' response=\'Ens.Response\' >',
        '<sequence>',
        '<trace value=\'"BounceTest"\' />',
        '</sequence>',
        '</process>',
        '}',
        '',
        '}'
      ];
    } else {
      className = 'BounceTest.Rule.Test' + rnd + 'RoutingRule';
      classSource = [
        '/// Bounce test routing rule — auto-generated, will be deleted',
        'Class ' + className + ' Extends Ens.Rule.Definition',
        '{',
        '',
        'Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";',
        '',
        'XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]',
        '{',
        '<ruleDefinition alias="' + className + '" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="">',
        '<ruleSet name="BounceTest Routing" effectiveBegin="" effectiveEnd="">',
        '  <rule name="BounceTestRoute" disabled="false">',
        '    <constraint name="docCategory" value="2.5.1"/>',
        '    <constraint name="docName" value="ADT_A01"/>',
        '    <when condition="1">',
        '      <send transform="" target="BounceTestTarget"/>',
        '      <return/>',
        '    </when>',
        '  </rule>',
        '</ruleSet>',
        '</ruleDefinition>',
        '}',
        '',
        '}'
      ];
    }

    var docName = className + '.cls';

    var fixDescs = { 1: 'skip pre-check', 2: 'panel first then bounce', 3: 'delayed overlay restore', 4: 'no freeze' };
    log('Starting bounce test [' + testType.toUpperCase() + ']' + (dryRun ? ' (DRY RUN)' : '') + (keep ? ' (KEEP class)' : '') + (fix ? ' FIX ' + fix + ': ' + fixDescs[fix] : '') + ' pause=' + pause + 'ms');
    log('Namespace: ' + ns + ', API: ' + atelierBase);
    log('Test class: ' + className + ' (panel ' + panelIndex + ')');

    // --- Phase 1: Create and compile the test class ---
    function phase1_create() {
      log('Phase 1: Creating test rule class on server...');
      if (dryRun) { log('DRY RUN — skipping create'); phase2_bounce(); return; }

      var putData = { enc: false, content: classSource };
      fetch(atelierBase + '/doc/' + docName, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify(putData)
      })
      .then(function(r) {
        log('PUT response: ' + r.status);
        if (r.status === 401) { log('FAIL — 401 auth error on PUT'); return; }
        if (r.status !== 200 && r.status !== 201) {
          return r.text().then(function(t) { log('FAIL — status ' + r.status + ': ' + t.substring(0, 200)); });
        }
        return r.json().then(function() {
          log('Class created. Compiling...');
          return fetch(atelierBase + '/action/compile', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify([docName])
          });
        });
      })
      .then(function(r) {
        if (!r) return;
        log('Compile response: ' + r.status);
        if (r.status === 200) {
          log('Phase 1 COMPLETE — ' + className + ' created and compiled');
          setTimeout(phase2_bounce, pause);
        } else {
          r.text().then(function(t) { log('FAIL — compile error: ' + t.substring(0, 200)); });
        }
      })
      .catch(function(e) {
        log('FAIL — network error: ' + e.message);
      });
    }

    // --- Shared helpers ---
    function findNsButton() {
      var toolbarBtns = document.querySelectorAll('fr-topbar button, mat-toolbar button, header button');
      for (var i = 0; i < toolbarBtns.length; i++) {
        if (toolbarBtns[i].textContent.trim().toUpperCase().indexOf(ns) !== -1) return toolbarBtns[i];
      }
      return null;
    }

    var BOUNCE_TARGET = 'HSLIB';

    function openTestPanel(callback) {
      log('Opening ' + testType + ' panel (index ' + panelIndex + ')...');
      openEditorPanel(panelIndex, function() {
        log(testType.toUpperCase() + ' panel opened');
        callback();
      });
    }

    function pollForNav(callback) {
      var attempts = 0;
      var maxAttempts = 30;
      log('Polling for ' + className + '...');
      var poll = setInterval(function() {
        attempts++;
        var found = cc.findAndClickComponent(className);
        if (found) {
          clearInterval(poll);
          log('FOUND ' + className + ' (attempt ' + attempts + '/' + maxAttempts + ')');
          callback(true);
        } else if (attempts >= maxAttempts) {
          clearInterval(poll);
          log('NOT FOUND after ' + maxAttempts + ' attempts');
          callback(false);
        }
      }, 300);
    }

    // Standard bounce — delegates to the module-level namespaceBounce (ONE function for everything)
    function standardBounce(callback) {
      log('Auth before bounce — cookies: ' + document.cookie.length + ' chars');
      namespaceBounce(function(ok) {
        unfreezePage();
        log('After bounce — cookies: ' + document.cookie.length + ' chars');
        if (ok) log('Bounce complete');
        else log('Bounce FAILED');
        callback(ok);
      });
    }

    // --- Phase 2: Namespace bounce (with fix variants) ---
    function phase2_bounce() {
      log('Phase 2: Namespace bounce...');

      if (dryRun) { log('DRY RUN — skipping bounce'); phase3_navigate(); return; }

      // === FIX 1: Skip pre-check, straight to bounce ===
      if (fix === 1) {
        log('FIX 1: Skipping pre-bounce DOM search');
        standardBounce(function(ok) {
          log('Phase 2 ' + (ok ? 'COMPLETE' : 'FAILED'));
          phase3_navigate();
        });
        return;
      }

      // === FIX 2: Open panel first, wait, then bounce ===
      if (fix === 2) {
        log('FIX 2: Opening panel BEFORE bounce');
        openTestPanel(function() {
          log('Panel open. Waiting 1s for list to load...');
          setTimeout(function() {
            standardBounce(function(ok) {
              log('Phase 2 ' + (ok ? 'COMPLETE' : 'FAILED'));
              // Skip phase3 panel open — already open
              pollForNav(function() { setTimeout(phase4_cleanup, pause * 5); });
            });
          }, 1000);
        });
        return;
      }

      // === FIX 3: Bounce + delayed cdk-overlay restore ===
      if (fix === 3) {
        log('FIX 3: Bounce with delayed overlay restore');
        var nsBtn = findNsButton();
        if (!nsBtn) { log('ABORT — ns button not found'); phase4_cleanup(); return; }
        var bounceNs = (ns === BOUNCE_TARGET) ? null : BOUNCE_TARGET;

        // Freeze
        var blocker = document.createElement('div');
        blocker.id = 'ns-bounce-blocker';
        blocker.style.cssText = 'position:fixed;top:0;left:0;right:var(--chatbot-width,25vw);bottom:0;z-index:99998;background:white;';
        document.body.appendChild(blocker);
        var appRoot = document.querySelector('app-root');
        if (appRoot) {
          var clone = appRoot.cloneNode(true);
          clone.id = 'ns-bounce-snapshot';
          clone.style.cssText = appRoot.style.cssText + ';position:fixed;top:0;left:0;right:var(--chatbot-width,25vw);bottom:0;z-index:99999;pointer-events:none;overflow:hidden;';
          document.body.appendChild(clone);
        }
        var cdkOverlay = document.querySelector('.cdk-overlay-container');
        if (cdkOverlay) cdkOverlay.style.display = 'none';
        var snackEls3 = document.querySelectorAll('mat-snack-bar-container, simple-snack-bar');
        snackEls3.forEach(function(el) { el.style.display = 'none'; });
        var snackParents3 = document.querySelectorAll('.cdk-global-overlay-wrapper');
        snackParents3.forEach(function(el) { el.dataset.bounceHidden = el.style.display; el.style.display = 'none'; });
        log('UI frozen');

        nsBtn.click();
        setTimeout(function() {
          var overlayBtns = document.querySelectorAll('.cdk-overlay-container button, .cdk-overlay-pane button');
          var otherBtn = null;
          for (var j = 0; j < overlayBtns.length; j++) {
            var t = overlayBtns[j].textContent.trim().toUpperCase();
            if (bounceNs && t === bounceNs) { otherBtn = overlayBtns[j]; break; }
            if (!bounceNs && t && t !== ns && t.length < 30) { otherBtn = overlayBtns[j]; bounceNs = t; break; }
          }
          if (!otherBtn) { log('ABORT'); phase4_cleanup(); return; }
          log('Bouncing ' + ns + ' -> ' + bounceNs);
          otherBtn.click();
          setTimeout(function() {
            nsBtn.click();
            setTimeout(function() {
              var backBtns = document.querySelectorAll('.cdk-overlay-container button, .cdk-overlay-pane button');
              var origBtn = null;
              for (var j = 0; j < backBtns.length; j++) {
                if (backBtns[j].textContent.trim().toUpperCase() === ns) { origBtn = backBtns[j]; break; }
              }
              if (!origBtn) { log('FAIL'); phase4_cleanup(); return; }
              origBtn.click();
              setTimeout(function() {
                // Remove blocker + snapshot but KEEP cdk hidden
                var snap = document.getElementById('ns-bounce-snapshot');
                if (snap) snap.remove();
                var blk = document.getElementById('ns-bounce-blocker');
                if (blk) blk.remove();
                log('Blocker removed. cdk-overlay STILL HIDDEN. Waiting 2s...');

                setTimeout(function() {
                  if (cdkOverlay) cdkOverlay.style.display = '';
                  // Remove any snackbars that appeared during bounce
                  var snacks3 = document.querySelectorAll('mat-snack-bar-container, simple-snack-bar');
                  snacks3.forEach(function(el) { el.remove(); });
                  var wrappers3 = document.querySelectorAll('.cdk-global-overlay-wrapper');
                  wrappers3.forEach(function(el) { if (el.dataset.bounceHidden !== undefined) { el.style.display = el.dataset.bounceHidden; delete el.dataset.bounceHidden; } });
                  log('cdk-overlay restored after 2s delay');
                  log('Phase 2 COMPLETE');
                  phase3_navigate();
                }, 2000);
              }, pause);
            }, pause);
          }, pause * 3);
        }, pause);
        return;
      }

      // === FIX 4: Bounce without any freeze ===
      if (fix === 4) {
        log('FIX 4: Bounce WITHOUT freeze (visible switch)');
        var nsBtn = findNsButton();
        if (!nsBtn) { log('ABORT — ns button not found'); phase4_cleanup(); return; }
        var bounceNs = (ns === BOUNCE_TARGET) ? null : BOUNCE_TARGET;

        log('NO FREEZE — you will see the switch');
        nsBtn.click();
        setTimeout(function() {
          var overlayBtns = document.querySelectorAll('.cdk-overlay-container button, .cdk-overlay-pane button');
          var otherBtn = null;
          for (var j = 0; j < overlayBtns.length; j++) {
            var t = overlayBtns[j].textContent.trim().toUpperCase();
            if (bounceNs && t === bounceNs) { otherBtn = overlayBtns[j]; break; }
            if (!bounceNs && t && t !== ns && t.length < 30) { otherBtn = overlayBtns[j]; bounceNs = t; break; }
          }
          if (!otherBtn) { log('ABORT'); phase4_cleanup(); return; }
          log('Bouncing ' + ns + ' -> ' + bounceNs);
          otherBtn.click();
          setTimeout(function() {
            log('Bouncing ' + bounceNs + ' -> ' + ns);
            nsBtn.click();
            setTimeout(function() {
              var backBtns = document.querySelectorAll('.cdk-overlay-container button, .cdk-overlay-pane button');
              var origBtn = null;
              for (var j = 0; j < backBtns.length; j++) {
                if (backBtns[j].textContent.trim().toUpperCase() === ns) { origBtn = backBtns[j]; break; }
              }
              if (!origBtn) { log('FAIL'); phase4_cleanup(); return; }
              origBtn.click();
              setTimeout(function() {
                log('Phase 2 COMPLETE (no freeze)');
                phase3_navigate();
              }, pause);
            }, pause);
          }, pause * 3);
        }, pause);
        return;
      }

      // === DEFAULT: original flow with pre-check ===
      var preCheck = cc.findAndClickComponent(className);
      log('Pre-bounce DOM search: ' + (preCheck ? 'FOUND (unexpected!)' : 'not found (expected — need bounce)'));
      if (preCheck) {
        log('Phase 2 SKIPPED — already in DOM');
        setTimeout(function() { phase3_navigate(true); }, pause);
        return;
      }

      standardBounce(function(ok) {
        log('Phase 2 ' + (ok ? 'COMPLETE' : 'FAILED'));
        phase3_navigate();
      });
    }

    // --- Phase 3: Navigate to the new class ---
    function phase3_navigate(alreadyFound) {
      log('Phase 3: Finding ' + className + ' in sidebar...');
      if (dryRun) { log('DRY RUN — skipping'); phase4_cleanup(); return; }
      if (alreadyFound) { log('Phase 3 COMPLETE — already clicked'); setTimeout(phase4_cleanup, pause * 5); return; }

      openTestPanel(function() {
        pollForNav(function(found) {
          if (found) log('Phase 3 COMPLETE');
          else log('Phase 3 FAIL');
          setTimeout(phase4_cleanup, pause * 5);
        });
      });
    }

    // --- Phase 4: Cleanup ---
    function phase4_cleanup() {
      if (keep) {
        log('Phase 4: SKIPPED (--keep). Class ' + className + ' left on server.');
        log('BOUNCE TEST COMPLETE');
        return;
      }
      log('Phase 4: Deleting ' + docName + '...');

      if (dryRun) { log('DRY RUN — skipping delete'); log('BOUNCE TEST COMPLETE'); return; }

      fetch(atelierBase + '/doc/' + docName, {
        method: 'DELETE',
        credentials: 'include'
      })
      .then(function(r) {
        log('DELETE response: ' + r.status);
        if (r.status === 200) {
          log('Phase 4 COMPLETE — test class deleted');
        } else {
          log('Phase 4 WARNING — delete returned ' + r.status);
        }
        log('BOUNCE TEST COMPLETE');
      })
      .catch(function(e) {
        log('Phase 4 WARNING — delete failed: ' + e.message);
        log('BOUNCE TEST COMPLETE');
      });
    }

    // Start
    phase1_create();
  };



  // ===== /dom-test — create ephemeral class + DOM search =====
  // Usage: /dom-test [--keep] [--bounce] [--type rule|dtl|bpl] [--fix 1|2|3|4]
  //   --keep     Don't delete the test class after
  //   --bounce   Include a namespace bounce before searching
  //   --type X   Class type to create (default: rule)
  //   --fix 1    Skip pre-bounce DOM search — straight to bounce
  //   --fix 2    Open panel first, then bounce, then search
  //   --fix 3    Bounce + delay cdk-overlay restore until panel loaded
  //   --fix 4    Bounce without any freeze (visible namespace switch)
  cc.runDomTest = function(args) {
    var keep = args.indexOf('--keep') !== -1;
    var doBounce = args.indexOf('--bounce') !== -1;
    var fixMatch = args.match(/--fix\s+(\d)/);
    var fix = fixMatch ? parseInt(fixMatch[1]) : 0;
    if (fix >= 1 && fix <= 4) doBounce = true; // --fix implies bounce
    var typeMatch = args.match(/--type\s+(rule|dtl|bpl)/i);
    var classType = typeMatch ? typeMatch[1].toLowerCase() : 'rule';
    var step = 0;

    function log(msg) {
      step++;
      var prefix = '[dom-test ' + step + ']';
      console.log(prefix, msg);
      cc.addMessage('system', prefix + ' ' + msg);
      cc.saveState();
    }

    var pfxMatch = window.location.pathname.match(/^(\/[^/]+)\/ui\/interop\/interclaw\//);
    var pathPrefix = pfxMatch ? pfxMatch[1] : '';
    var ns = (cc.detectNamespace() || '').toUpperCase();
    if (!ns) { log('ABORT — no namespace detected'); return; }
    var atelierBase = pathPrefix + '/api/atelier/v8/' + ns.toLowerCase();

    var rnd = Math.random().toString(36).substring(2, 7).toUpperCase();
    var className, classSource, panelIndex;

    if (classType === 'dtl') {
      className = 'DomTest.DTL.Test' + rnd + 'Transform';
      panelIndex = 3;
      classSource = [
        '/// DOM test DTL — auto-generated, will be deleted',
        'Class ' + className + ' Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]',
        '{',
        '',
        'Parameter IGNOREMISSINGSOURCE = 1;',
        'Parameter REPORTERRORS = 1;',
        'Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;',
        '',
        'XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]',
        '{',
        '<transform sourceClass=\'EnsLib.HL7.Message\' targetClass=\'EnsLib.HL7.Message\' sourceDocType=\'2.5.1:ADT_A01\' targetDocType=\'2.5.1:ADT_A01\' create=\'new\' language=\'objectscript\' >',
        '<assign value=\'source.{MSH:SendingFacility}\' property=\'target.{MSH:SendingFacility}\' action=\'set\' />',
        '</transform>',
        '}',
        '',
        '}'
      ];
    } else if (classType === 'bpl') {
      className = 'DomTest.BPL.Test' + rnd + 'Process';
      panelIndex = 4;
      classSource = [
        '/// DOM test BPL — auto-generated, will be deleted',
        'Class ' + className + ' Extends Ens.BusinessProcessBPL [ ClassType = persistent ]',
        '{',
        '',
        'XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]',
        '{',
        '<process language=\'objectscript\' request=\'Ens.Request\' response=\'Ens.Response\' >',
        '<sequence>',
        '<trace value=\'"DomTest BPL executed"\' />',
        '</sequence>',
        '</process>',
        '}',
        '',
        '}'
      ];
    } else {
      className = 'DomTest.Rule.Test' + rnd + 'RoutingRule';
      panelIndex = 2;
      classSource = [
        '/// DOM test routing rule — auto-generated, will be deleted',
        'Class ' + className + ' Extends Ens.Rule.Definition',
        '{',
        '',
        'Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";',
        '',
        'XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]',
        '{',
        '<ruleDefinition alias="' + className + '" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="">',
        '<ruleSet name="DomTest Routing" effectiveBegin="" effectiveEnd="">',
        '  <rule name="DomTestRoute" disabled="false">',
        '    <constraint name="docCategory" value="2.5.1"/>',
        '    <constraint name="docName" value="ADT_A01"/>',
        '    <when condition="1">',
        '      <send transform="" target="DomTestTarget"/>',
        '      <return/>',
        '    </when>',
        '  </rule>',
        '</ruleSet>',
        '</ruleDefinition>',
        '}',
        '',
        '}'
      ];
    }

    var docName = className + '.cls';
    var editorNames = { 2: 'rule', 3: 'dtl', 4: 'bpl' };

    var fixDesc = { 1: 'skip pre-check, straight to bounce', 2: 'panel first, then bounce', 3: 'bounce + delayed overlay restore', 4: 'bounce without freeze' };
    log('DOM Test — type: ' + classType + ', class: ' + className + (fix ? ', FIX ' + fix + ': ' + fixDesc[fix] : (doBounce ? ', with bounce' : ', no bounce')) + (keep ? ', keep' : ''));

    // Phase 1: Create
    function phase1_create() {
      log('Creating ' + docName + ' on server...');
      var putData = { enc: false, content: classSource };
      fetch(atelierBase + '/doc/' + docName, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify(putData)
      })
      .then(function(r) {
        if (r.status === 401) { log('FAIL — 401 auth error'); return; }
        if (r.status !== 200 && r.status !== 201) {
          return r.text().then(function(t) { log('FAIL — PUT ' + r.status + ': ' + t.substring(0, 200)); });
        }
        return r.json().then(function() {
          log('Created. Compiling...');
          return fetch(atelierBase + '/action/compile', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify([docName])
          });
        });
      })
      .then(function(r) {
        if (!r) return;
        if (r.status === 200) {
          log('Compiled OK');
          setTimeout(phase2_search, 500);
        } else {
          r.text().then(function(t) { log('FAIL — compile: ' + t.substring(0, 200)); });
        }
      })
      .catch(function(e) { log('FAIL — network: ' + e.message); });
    }

    // Phase 2: DOM search (with --fix variations)
    function phase2_search() {
      log('Searching DOM for ' + className + '...');

      // --- FIX 1: Skip pre-check, go straight to bounce ---
      if (fix === 1) {
        log('FIX 1: Skipping pre-panel search, straight to bounce');
        openPanel(function() {
          namespaceBounce(function(bounced) {
            log('Bounce result: ' + (bounced ? 'OK' : 'FAILED'));
            pollForComponent();
          });
        });
        return;
      }

      // --- FIX 2: Open panel first, then bounce, then search ---
      if (fix === 2) {
        log('FIX 2: Opening panel FIRST, then bouncing');
        openPanel(function() {
          log('Panel open. Waiting 1s for Angular to fetch list...');
          setTimeout(function() {
            namespaceBounce(function(bounced) {
              log('Bounce result: ' + (bounced ? 'OK' : 'FAILED'));
              pollForComponent();
            });
          }, 1000);
        });
        return;
      }

      // --- FIX 3: Bounce + delayed cdk-overlay restore ---
      if (fix === 3) {
        log('FIX 3: Bounce with delayed overlay restore');
        bounceWithDelayedOverlay(function() {
          openPanel(function() {
            pollForComponent();
          });
        });
        return;
      }

      // --- FIX 4: Bounce without any freeze ---
      if (fix === 4) {
        log('FIX 4: Bounce WITHOUT freeze (visible switch)');
        bounceNoFreeze(function(bounced) {
          log('Bounce result: ' + (bounced ? 'OK' : 'FAILED'));
          openPanel(function() {
            pollForComponent();
          });
        });
        return;
      }

      // --- Default: original dom-test flow ---
      var found0 = cc.findAndClickComponent(className);
      log('Pre-panel search: ' + (found0 ? 'FOUND' : 'not found'));

      if (found0 && !doBounce) {
        log('DOM SEARCH PASSED — found without panel open');
        setTimeout(phase3_cleanup, 1000);
        return;
      }

      openPanel(function() {
        if (doBounce) {
          log('Namespace bounce requested...');
          namespaceBounce(function(bounced) {
            log('Bounce result: ' + (bounced ? 'OK' : 'FAILED'));
            pollForComponent();
          });
        } else {
          setTimeout(pollForComponent, 500);
        }
      });
    }

    // Helper: open the correct editor panel
    function openPanel(callback) {
      var expandXpath = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + panelIndex + ']/div[1]/div[2]/mat-icon/svg';
      try {
        var r = document.evaluate(expandXpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
        if (r.singleNodeValue) { r.singleNodeValue.click(); log('Clicked ' + editorNames[panelIndex] + ' panel icon'); }
        else { log('Panel icon not found at index ' + panelIndex); }
      } catch(e) { log('Panel icon XPath error'); }

      setTimeout(function() {
        var dropdownBase = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + panelIndex + ']/div[2]';
        try {
          var r2 = document.evaluate(dropdownBase, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
          var dd = r2.singleNodeValue;
          if (dd) {
            for (var di = 0; di < dd.children.length; di++) {
              if (dd.children[di].textContent.trim().toLowerCase() === 'open full') { dd.children[di].click(); log('Clicked "Open Full"'); break; }
            }
          }
        } catch(e) {}
        setTimeout(callback, 300);
      }, 300);
    }

    // Helper: bounce but delay cdk-overlay restore (fix 3)
    function bounceWithDelayedOverlay(callback) {
      var ns2 = ns;
      var toolbarBtns = document.querySelectorAll('fr-topbar button, mat-toolbar button, header button');
      var nsBtn = null;
      for (var i = 0; i < toolbarBtns.length; i++) {
        if (toolbarBtns[i].textContent.trim().toUpperCase().indexOf(ns2) !== -1) { nsBtn = toolbarBtns[i]; break; }
      }
      if (!nsBtn) { log('ABORT — namespace button not found'); phase3_cleanup(); return; }

      var BOUNCE_TARGET = 'HSLIB';
      var bounceNs = (ns2 === BOUNCE_TARGET) ? null : BOUNCE_TARGET;

      // Freeze (same as normal bounce)
      var blocker = document.createElement('div');
      blocker.id = 'ns-bounce-blocker';
      blocker.style.cssText = 'position:fixed;top:0;left:0;right:var(--chatbot-width,25vw);bottom:0;z-index:99998;background:white;';
      document.body.appendChild(blocker);

      var appRoot = document.querySelector('app-root');
      if (appRoot) {
        var clone = appRoot.cloneNode(true);
        clone.id = 'ns-bounce-snapshot';
        clone.style.cssText = appRoot.style.cssText + ';position:fixed;top:0;left:0;right:var(--chatbot-width,25vw);bottom:0;z-index:99999;pointer-events:none;overflow:hidden;';
        document.body.appendChild(clone);
      }

      var cdkOverlay = document.querySelector('.cdk-overlay-container');
      if (cdkOverlay) cdkOverlay.style.display = 'none';

      log('UI frozen (overlay will be restored LATE)');

      nsBtn.click();
      setTimeout(function() {
        var overlayBtns = document.querySelectorAll('.cdk-overlay-container button, .cdk-overlay-pane button');
        var otherBtn = null;
        for (var j = 0; j < overlayBtns.length; j++) {
          var t = overlayBtns[j].textContent.trim().toUpperCase();
          if (bounceNs && t === bounceNs) { otherBtn = overlayBtns[j]; break; }
          if (!bounceNs && t && t !== ns2 && t.length < 30) { otherBtn = overlayBtns[j]; bounceNs = t; break; }
        }
        if (!otherBtn) { log('ABORT — no bounce target'); callback(); return; }
        log('Bouncing ' + ns2 + ' -> ' + bounceNs);
        otherBtn.click();

        setTimeout(function() {
          nsBtn.click();
          setTimeout(function() {
            var backBtns = document.querySelectorAll('.cdk-overlay-container button, .cdk-overlay-pane button');
            var origBtn = null;
            for (var j = 0; j < backBtns.length; j++) {
              if (backBtns[j].textContent.trim().toUpperCase() === ns2) { origBtn = backBtns[j]; break; }
            }
            if (!origBtn) { log('FAIL — cannot find ' + ns2); callback(); return; }
            origBtn.click();

            setTimeout(function() {
              // Remove blocker + snapshot but KEEP cdk hidden
              var snap = document.getElementById('ns-bounce-snapshot');
              if (snap) snap.remove();
              var blk = document.getElementById('ns-bounce-blocker');
              if (blk) blk.remove();
              log('Blocker removed. cdk-overlay still hidden. Waiting 2s for Angular to load...');

              // Delayed overlay restore — give Angular time to populate lists
              setTimeout(function() {
                if (cdkOverlay) cdkOverlay.style.display = '';
                log('cdk-overlay restored after delay');
                callback();
              }, 2000);
            }, 200);
          }, 200);
        }, 600);
      }, 200);
    }

    // Helper: bounce without any freeze at all (fix 4)
    function bounceNoFreeze(callback) {
      var ns2 = ns;
      var toolbarBtns = document.querySelectorAll('fr-topbar button, mat-toolbar button, header button');
      var nsBtn = null;
      for (var i = 0; i < toolbarBtns.length; i++) {
        if (toolbarBtns[i].textContent.trim().toUpperCase().indexOf(ns2) !== -1) { nsBtn = toolbarBtns[i]; break; }
      }
      if (!nsBtn) { log('ABORT — namespace button not found'); callback(false); return; }

      var BOUNCE_TARGET = 'HSLIB';
      var bounceNs = (ns2 === BOUNCE_TARGET) ? null : BOUNCE_TARGET;

      log('NO FREEZE — you will see the namespace switch');

      nsBtn.click();
      setTimeout(function() {
        var overlayBtns = document.querySelectorAll('.cdk-overlay-container button, .cdk-overlay-pane button');
        var otherBtn = null;
        for (var j = 0; j < overlayBtns.length; j++) {
          var t = overlayBtns[j].textContent.trim().toUpperCase();
          if (bounceNs && t === bounceNs) { otherBtn = overlayBtns[j]; break; }
          if (!bounceNs && t && t !== ns2 && t.length < 30) { otherBtn = overlayBtns[j]; bounceNs = t; break; }
        }
        if (!otherBtn) { log('ABORT — no bounce target'); callback(false); return; }
        log('Bouncing ' + ns2 + ' -> ' + bounceNs);
        otherBtn.click();

        setTimeout(function() {
          log('Bouncing ' + bounceNs + ' -> ' + ns2);
          nsBtn.click();
          setTimeout(function() {
            var backBtns = document.querySelectorAll('.cdk-overlay-container button, .cdk-overlay-pane button');
            var origBtn = null;
            for (var j = 0; j < backBtns.length; j++) {
              if (backBtns[j].textContent.trim().toUpperCase() === ns2) { origBtn = backBtns[j]; break; }
            }
            if (!origBtn) { log('FAIL — cannot find ' + ns2); callback(false); return; }
            origBtn.click();
            setTimeout(function() {
              log('Bounce complete (no freeze)');
              callback(true);
            }, 200);
          }, 200);
        }, 600);
      }, 200);
    }

    function pollForComponent() {
      var attempts = 0;
      var maxAttempts = 30;
      log('Polling DOM for ' + className + ' (max ' + maxAttempts + ' attempts)...');
      var poll = setInterval(function() {
        attempts++;
        var found = cc.findAndClickComponent(className);
        if (found) {
          clearInterval(poll);
          log('DOM SEARCH PASSED — found on attempt ' + attempts + '/' + maxAttempts);
          setTimeout(phase3_cleanup, 1000);
        } else if (attempts >= maxAttempts) {
          clearInterval(poll);
          log('DOM SEARCH FAILED — not found after ' + maxAttempts + ' attempts');

          var valueDivs = document.querySelectorAll('div[id$="_value"]');
          var domItems = [];
          for (var v = 0; v < valueDivs.length && v < 10; v++) {
            domItems.push(valueDivs[v].textContent.trim());
          }
          log('DOM has ' + valueDivs.length + ' value divs. First 10: ' + domItems.join(', '));

          phase3_cleanup();
        }
      }, 300);
    }

    // Phase 3: Cleanup
    function phase3_cleanup() {
      if (keep) {
        log('DONE (--keep). Class: ' + className);
        return;
      }
      log('Deleting ' + docName + '...');
      fetch(atelierBase + '/doc/' + docName, {
        method: 'DELETE',
        credentials: 'include'
      })
      .then(function(r) {
        if (r.status === 200) { log('Deleted OK'); }
        else { log('Delete returned ' + r.status); }
        log('DOM TEST COMPLETE');
      })
      .catch(function(e) {
        log('Delete failed: ' + e.message);
        log('DOM TEST COMPLETE');
      });
    }

    phase1_create();
  };

  // ===== /skill — navigate to a file in the Skills Editor =====
  cc.executeSkillGoto = function(filePath) {
    if (!filePath) { cc.addMessage('system', 'Usage: /skill <file-path>'); cc.saveState(); return; }

    // Detect if we're on the skills-editor page
    var onSkillsEditor = window.location.pathname.indexOf('/skills-editor/') !== -1;

    if (onSkillsEditor && window._skillsEditor) {
      // Already on skills-editor — just open the file
      cc.addMessage('system', 'Opening: ' + filePath);
      if (window._skillsEditor.isReady()) {
        window._skillsEditor.openFile(filePath);
      } else {
        // Tree still loading — poll until ready
        var poll = setInterval(function() {
          if (window._skillsEditor.isReady()) {
            clearInterval(poll);
            window._skillsEditor.openFile(filePath);
          }
        }, 200);
        setTimeout(function() { clearInterval(poll); }, 5000);
      }
    } else {
      // On a different editor — navigate to skills-editor with ?open= param
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
