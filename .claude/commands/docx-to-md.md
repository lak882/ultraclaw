Convert a .docx document to Markdown for use with production-building commands.

Usage: /docx-to-md <path-to-docx>

Steps:
1. Parse "$ARGUMENTS" — extract input file path. If none, ask the user.
2. Run:
   ```bash
   cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/docs/docx_to_md.py --input "<input-path>" --output "docs/<filename>.md"
   ```
3. Show the output file path and a brief summary of extracted content.
