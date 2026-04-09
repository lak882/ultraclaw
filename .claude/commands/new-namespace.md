Create a new HealthShare Foundation namespace with full HSLIB/HSCUSTOM mappings and interoperability enabled.

Usage: /new-namespace <name>

Steps:
1. Parse "$ARGUMENTS" — namespace name. Uppercase it.
2. Check permission mode:
   ```bash
   cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/infrastructure/permissions.py --check delete
   ```
   Exit 0 → skip confirmation. Exit 2 → dry-run + confirm below.
3. If confirmation required, run dry-run first:
   ```bash
   cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/infrastructure/manage_namespace.py --server <server> --create <NAME> --dry-run
   ```
   Stop and ask user to confirm.
4. Run create:
   ```bash
   cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/infrastructure/manage_namespace.py --server <server> --create <NAME>
   ```
5. Report results. Suggest `/connect <server> <NAME>` to start working in it.
