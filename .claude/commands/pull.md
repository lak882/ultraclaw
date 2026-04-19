---
allowed-tools: Bash, Read
description: Pull a class or document from the IRIS server and display its source code.
---

Pull a class or document from the IRIS server and display its source code.

Usage: /pull <classname>

## Argument parsing

Parse "$ARGUMENTS": the document name. If it doesn't end with .cls/.mac/.inc/.csp, append .cls.

## Execution

```bash
<python> .claude/skills/interclaw/scripts/documents/get_doc.py --server <server> --namespace <namespace> --doc <name>
```

## Output

Display the full source code. Offer to save locally to `src/<Namespace>/<Package>/<ClassName>.cls`.
