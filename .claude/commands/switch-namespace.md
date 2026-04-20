---
allowed-tools: []
description: Switch the active working namespace by emitting a directive the frontend detects.
---

Switch the active namespace that the UI, the next prompt's `[Context: ...]` line, and the Portal iframe all use.

Usage: `/switch-namespace <NAMESPACE>`

## How it works

The UI reads the namespace from the top-right selector and injects it into every subsequent prompt as `Namespace=<NS>` on the `[Context: ...]` line. The frontend also listens on assistant output for a directive line starting with `/namespace ` and updates the selector, the Portal/Skills iframes, sessionStorage, and all tab hrefs accordingly.

## Response

**Step 1.** Respond with a single sentence confirming the switch, e.g. `Switching namespace to {NS}.`

**Step 2.** On its own line, with nothing else on that line, emit:

```
/namespace {NS}
```

Uppercase the namespace name. `{NS}` should match `^[A-Z][A-Z0-9_-]*$`. Do not wrap the directive in backticks, a code fence, or any markdown formatting — it must be a raw line.

**Step 3.** Do not claim you cannot switch the namespace from your side. You can — the `/namespace` directive IS the mechanism.

The next prompt the user sends will arrive with `Namespace={NS}` on the context line, so you can immediately run namespace-scoped tools (e.g. `run_query.py --namespace {NS}`) without asking the user to switch manually.
