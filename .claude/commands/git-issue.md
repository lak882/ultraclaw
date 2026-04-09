Create a GitLab issue on the configured project.

Usage: /git-issue <title or description of the issue>

Examples:
- /git-issue The DTL editor crashes when opening transforms with repeating segments
- /git-issue feature request: add FHIR R4 support to /dtl
- /git-issue bug: /send fails silently when production is stopped

Steps:

1. **Check GitLab config** by running:
   ```bash
   cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/git/git_token.py --show
   ```
   If not configured, tell the user to run `/git-token` first.

2. **Parse the user's input** into a title and description:
   - If the input is short (under ~80 chars), use it as the title directly
   - If the input is longer, extract the first sentence as the title and the rest as the description
   - If the input starts with "bug:", "feature:", or "feature request:", use that as a label
   - Auto-detect labels from keywords: "bug" → `bug`, "feature" → `feature-request`, "question" → `question`

3. **Create the issue:**
   ```bash
   cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/git/git_issue.py --title "Issue title" --description "Detailed description" --labels "bug,interclaw"
   ```

   For confidential issues (if the user mentions sensitive data):
   ```bash
   cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/git/git_issue.py --title "..." --description "..." --confidential
   ```

4. **Display the result:**
   - On success: show the issue URL so the user can view it in GitLab
   - On error: show the error message

## Notes

- All issues get the default labels from config (typically `interclaw`)
- The description supports full GitLab Markdown
- Issues are created under the project configured via `/git-token`
