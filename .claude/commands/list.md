---
allowed-tools: Bash
description: List documents (classes, routines, includes) in a namespace on an IRIS server.
---

Run `list_docs.py` and display the output. Parse `$ARGUMENTS`: first word = type if cls/mac/inc/csp, rest = filter.

```bash
<python> .claude/skills/interclaw/scripts/documents/list_docs.py --server myserver --namespace <ns> --type <type> --filter "<filter>" --links
```
