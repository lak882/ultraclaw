**Deprecated** — Playwright auto-open has been replaced by the chatbot sidebar navigation commands.

Use instead:
- `/goto <name>` — navigate to a component in the current page (no reload)
- `/goto-reload <name>` — reload the page first, then navigate (use after pushing new code)
- `/trace-view [sessionID]` — view a message trace

These are typed into the chatbot sidebar, which handles navigation directly.

If the user runs `/playwright enable` or `/playwright disable`, inform them that Playwright is deprecated and suggest the `/goto` commands instead.
