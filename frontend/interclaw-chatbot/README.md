# cc-chatbot Input States

The input component has three states, switchable depending on what the agent is doing.

## States

### 1. Normal Input (default)
Standard textarea with file attach, command menu, mode selector, and send button.

### 2. Edit Accept
Shown when the agent proposes a file edit in "Ask before edits" mode.

Options:
- **1** — Yes (accept this edit)
- **2** — Yes, allow all edits during this session
- **3** — No (reject)
- **4** / Arrow Down past 3 — Focus the feedback textarea
- **Enter** — Confirm selected option
- **Esc** — Cancel (return to normal input)

### 3. Plan Accept
Shown when the agent presents a plan in "Plan mode".

Options:
- **1** — Yes, and auto-accept
- **2** — Yes, and manually approve edits
- **3** — No, keep planning
- **4** / Arrow Down past 3 — Focus the feedback textarea
- **Enter** — Confirm selected option
- **Esc** — Cancel (return to normal input)

## API

### Showing the UI

```js
// Show edit approval (from JS)
_cc.showEditAccept({ file: 'Some.Class.cls', summary: 'Add new method' });

// Show plan approval (from JS)
_cc.showPlanAccept({ planFile: 'plan.md' });

// Hide (return to normal input)
_cc.hideEditAccept();
_cc.hidePlanAccept();
```

### Backend Stream Events

The backend can trigger these via the event stream:

```json
{ "type": "edit_accept", "context": { "file": "Some.Class.cls", "summary": "Add method" } }
{ "type": "plan_accept", "context": { "planFile": "plan.md" } }
```

### Receiving User Choices

**Option A — Callback:**

```js
_cc.onEditChoice = function(result) {
  console.log(result);
  // { choice: 'accept'|'accept-all'|'reject'|'feedback', feedback: '...', context: {...} }
};
_cc.showEditAccept({ file: 'Foo.cls' });

_cc.onPlanChoice = function(result) {
  console.log(result);
  // { choice: 'auto'|'manual'|'keep'|'feedback', feedback: '...', context: {...} }
};
_cc.showPlanAccept({ planFile: 'plan.md' });
```

Callbacks are one-shot — cleared after firing.

**Option B — Backend auto-receive:**

When the user makes a choice, a message is automatically sent to the backend:

```json
{ "action": "edit_response", "choice": "accept", "feedback": null, "session_id": "..." }
{ "action": "plan_response", "choice": "auto", "feedback": null, "session_id": "..." }
```

If the user types feedback instead of selecting an option:

```json
{ "action": "edit_response", "choice": "feedback", "feedback": "Change the method name to X", "session_id": "..." }
```

Both the callback and the backend message fire — use whichever suits your integration.
