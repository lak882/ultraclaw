---
allowed-tools: []
description: Toggle auto-navigation of chat links — when enabled, goto targets open in the Portal iframe automatically.
---

Toggle the "auto-navigate" mode: when ON, class-name links and `/goto` targets emitted by Claude are navigated to in the Portal iframe automatically (no click needed). When OFF, Claude just emits a link the user can click.

Usage: `/auto-navigate enable` or `/auto-navigate disable`

## Response

**Step 1.** One sentence confirming the new state, e.g. `Auto-navigation enabled.` or `Auto-navigation disabled.`

**Step 2.** On its own line, with nothing else on that line and no surrounding markdown, emit one of:

```
/auto-navigate enable
```

or

```
/auto-navigate disable
```

## How it works

The frontend's stream scanner in `frontend/interclaw-chatbot/stream.js` picks up the directive and writes `localStorage['interclaw-auto-navigate']` to `'on'` or `'off'`. When ON:
- `linkifyComponents` in `markdown.js` auto-fires the same handler as clicking the link (switches to Portal tab + navigates iframe) after the turn renders.
- Same for explicit `[text](legacy-ui...)` markdown links.

Do NOT output more than one `/auto-navigate` line per turn.
