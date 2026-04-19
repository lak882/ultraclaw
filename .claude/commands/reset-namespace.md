Reset an IRIS namespace — delete and recreate as a fresh HealthShare Foundation namespace. Equivalent to /delete-namespace + /new-namespace.

Usage: /reset-namespace <name>

Steps:
1. Parse "$ARGUMENTS" — namespace name. Uppercase it.
2. Check permission mode:
   ```bash
   <python> .claude/skills/interclaw/scripts/infrastructure/permissions.py --check reset
   ```
   Exit 0 → skip confirmation. Exit 2 → dry-run + confirm below.
3. Check if namespace exists:
   ```bash
   <python> .claude/skills/interclaw/scripts/infrastructure/manage_namespace.py --server <server> --exists <NAME>
   ```
4. If confirmation required, show dry-runs for both delete and create. Stop and ask: "Proceed with resetting namespace <NAME>? All data will be destroyed."
5. Delete (skip gracefully if doesn't exist):
   ```bash
   <python> .claude/skills/interclaw/scripts/infrastructure/manage_namespace.py --server <server> --delete <NAME>
   ```
6. Create:
   ```bash
   <python> .claude/skills/interclaw/scripts/infrastructure/manage_namespace.py --server <server> --create <NAME>
   ```
7. Report results. Reconnect with `/connect <server> <NAME>` if it was the active namespace.
