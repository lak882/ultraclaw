# /goto Navigation — DOM Logic Reference

The chatbot sidebar navigates the InterSystems interop editor by directly manipulating the Angular DOM. No Playwright or browser automation is needed — all navigation happens synchronously via XPath clicks and `querySelector` within the same page.

## Architecture

The interop editor sidebar has 5 panels (1-indexed):

| Panel Index | Editor Type | Angular Component |
|-------------|-------------|-------------------|
| 1 | production | (special — no app component) |
| 2 | rule | `app-rule` |
| 3 | dtl | `app-dtl` |
| 4 | bpl | `app-bpl` |
| 5 | trace | (opens old UI in new tab) |

## Navigation Flow (DTL, Rule, BPL)

All three follow the same synchronous flow:

### Step 1: Click sidebar icon to expand the panel

```javascript
var panelIndex = panelMap[editorType]; // { production: 1, rule: 2, dtl: 3, bpl: 4, trace: 5 }
var expandXpath = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + panelIndex + ']/div[1]/div[2]/mat-icon/svg';
xpathClick(expandXpath);
```

### Step 2: Click "Open Full" from the dropdown

The dropdown items vary per panel — **always search by text**, never hardcode a div index. Never click bare "Open" (that opens the package browser modal).

```javascript
var dropdownBase = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[' + panelIndex + ']/div[2]';
// Evaluate XPath to get dropdown element, then:
for (var di = 0; di < items.length; di++) {
  if (items[di].textContent.trim().toLowerCase() === 'open full') {
    items[di].click();
    break;
  }
}
```

### Step 3: Find and click the component directly in the DOM

Use `findAndClickComponent(componentName)` which searches the DOM for the component by name — no package browser modal needed.

The function searches:
1. `div[id$="_value"]` elements (production config value divs)
2. List items in the active editor
3. Any leaf element matching the component name

```javascript
var found = findAndClickComponent(componentName);
```

### Key lesson: Do NOT open the package browser modal

Earlier iterations opened the "Open" button in the top banner (which triggers the Angular Material `MatDialog` package browser). This caused persistent issues:

- The modal overlay div index under `<body>` varies (`div[5]`, `div[6]`, `div[7]`, etc.)
- Different editor panels have different dropdown item orders — clicking `div[3]` in the sidebar dropdown opens "Open" for some panels and "Open Full" for others
- Closing the modal is unreliable — XPath close buttons fail when the overlay index shifts, Escape keypress doesn't always trigger Angular's change detection
- Multiple modals can stack if /goto runs twice

**The working approach skips the modal entirely** and uses `findAndClickComponent` to locate elements directly in the rendered DOM.

## Production Navigation

Productions have a unique panel structure:

```javascript
// Sidebar icon
var prodIconXpath = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[1]/div/div[2]/mat-icon/svg';
xpathClick(prodIconXpath);

// Open Full from dropdown (search by text)
var prodDropdown = '/html/body/app-root/div[2]/app-dashboard/div[1]/div[1]/div[2]';
// ... search children for "Open Full" by text

// Net-new productions: reload with $PRODUCTION param
var url = new URL(window.location.href);
url.searchParams.set('$PRODUCTION', componentName);
window.location.href = url.toString();
```

For existing productions, "Open Full" opens the production canvas directly. For net-new productions that aren't in the sidebar yet, redirect with `$PRODUCTION` query param to load it.

## Trace Navigation

Traces open in the old UI (EnsPortal) in a new tab:

```javascript
var ns = detectNamespace() || 'HSLIB';
var cspBase = window.location.origin + '/csp/healthshare/' + ns.toLowerCase();

// With session ID:
window.open(cspBase + '/EnsPortal.VisualTrace.zen?SESSIONID=' + sessionId + '&$NAMESPACE=' + ns, '_blank');

// Without session ID — fetch latest via Atelier SQL:
// SELECT TOP 1 SessionId FROM Ens.MessageHeader ORDER BY ID DESC
```

## Helper: xpathClick

```javascript
function xpathClick(xpath) {
  try {
    var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
    var el = result.singleNodeValue;
    if (el) { el.click(); return true; }
  } catch(e) {}
  return false;
}
```

## Auto-detection of Editor Type

When no `--dtl`/`--rule`/`--bpl`/`--production`/`--trace` flag is specified, the editor type is inferred from the class name:

```javascript
// Check the immediate parent package segment, not substring match.
// This avoids false matches like Demo.Rule.Utils.Helper → rule editor.
var parts = className.split('.');
var parent = parts.length >= 2 ? parts[parts.length - 2].toLowerCase() : '';
if (parent === 'dtl') editorType = 'dtl';
else if (parent === 'rule' || nameLower.endsWith('routingrule')) editorType = 'rule';
else if (parent === 'bpl') editorType = 'bpl';
else if (nameLower.endsWith('.production')) editorType = 'production';
```

The backend (`rest_server.py`) also infers editor type from push output and command name, sending it as the `editor` field in the SSE `goto` event.

## Performance

The entire /goto chain is **fully synchronous** — no `setTimeout` delays. Steps 1→2→3 execute in a single call stack, making navigation nearly instant.
