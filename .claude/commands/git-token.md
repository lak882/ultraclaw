Configure GitLab integration for `/git-issue` and `/git-push`.

Usage: /git-token <token> --url <gitlab-url> --project <project-id>

Examples:
- /git-token glpat-xxxxxxxxxxxxxxxxxxxx --url https://gitlab.example.com --project 123
- /git-token --show
- /git-token --test
- /git-token --clear

Steps:

1. **Parse arguments** from the user's input:
   - If a token is provided inline (e.g., `glpat-...`), pass it as `--token`
   - If `--url` and `--project` are also provided, pass them through
   - If the user says "show", "status", or "check", use `--show`
   - If the user says "test" or "verify", use `--test`
   - If the user says "clear", "remove", or "delete", use `--clear`

2. **Run the script:**

   ```bash
   <python> .claude/skills/interclaw/scripts/git/git_token.py [args]
   ```

   Common invocations:
   ```bash
   # Set all three required fields at once
   <python> .claude/skills/interclaw/scripts/git/git_token.py --token glpat-xxx --url https://gitlab.example.com --project-id 123

   # Show current config
   <python> .claude/skills/interclaw/scripts/git/git_token.py --show

   # Test connection
   <python> .claude/skills/interclaw/scripts/git/git_token.py --test

   # Clear token
   <python> .claude/skills/interclaw/scripts/git/git_token.py --clear

   # Change branch prefix
   <python> .claude/skills/interclaw/scripts/git/git_token.py --branch-prefix "contrib/"
   ```

3. **Display the result:**
   - On success: show the stored config (token masked) and test result if auto-tested
   - On error: show the error and suggest what's missing
   - The script auto-tests the connection when all three fields (token, url, project-id) are configured

## Config Storage

Settings are stored in `config/orchestrator.json` under the `gitlab` key:
```json
{
    "gitlab": {
        "url": "https://gitlab.example.com",
        "projectId": "123",
        "token": "glpat-...",
        "branchPrefix": "skills/",
        "defaultLabels": ["interclaw"]
    }
}
```

The token is stored in plaintext in the config file. This is acceptable because:
- The config file is `.gitignore`d on user machines
- Each install gets its own scoped token (Developer role, limited to one project)
- Tokens can be revoked via `/git-token --clear` or from GitLab's UI
