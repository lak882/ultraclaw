---
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
description: Install IRIS, pull latest code from git, and run InterClaw post-install setup.
---

Chain together a full InterClaw instance setup: IRIS installation, git pull, and post-install configuration.

Usage: /setup-instance <config-name> [options]

## Argument parsing

Parse "$ARGUMENTS":
- **config-name** (required): Name of the installation config from `~/.claude/config/iris-install-config.json` (e.g., `interclaw-prod`, `interclaw-dev`, `interclaw-test`)
- `--skip-iris`: Skip the IRIS installation step (instance already installed)
- `--skip-pull`: Skip the git pull step
- `--skip-auth`: Skip Bedrock authentication
- `--verify-only`: Only run verification checks
- `--dry-run`: Show what would happen without making changes

If no config-name is provided, list available configs:
```bash
python3 -c "import json; c=json.load(open(os.path.expanduser('~/.claude/config/iris-install-config.json'))); [print(f'  {k}: {v.get(\"description\",\"\")}') for k,v in c['installations'].items() if k != 'template']"
```

## Execution

### Phase 1: IRIS Installation (skip with --skip-iris)

Use the `/iris-install` skill to install IRIS for Health using the config-name profile.

1. Read the config to extract the instance name and directory:
   ```bash
   python3 -c "
   import json, os
   c = json.load(open(os.path.expanduser('~/.claude/config/iris-install-config.json')))
   inst = c['installations']['<config-name>']
   print(inst['instance']['name'])
   print(inst['instance']['directory'])
   "
   ```

2. Check if the instance is already running:
   ```bash
   sudo iris qlist 2>/dev/null | grep -i <instance-name>
   ```

3. If not installed, invoke the iris-install skill:
   ```
   /iris-install Install InterSystems IRIS for Health instance <INSTANCE-NAME>
   ```

4. If already running, report it and move on.

### Phase 2: Git Pull

1. Determine the repo path. The InterClaw repo is at the current working directory (project root):
   ```bash
   pwd
   ```
   Verify it contains `module.xml`:
   ```bash
   ls module.xml
   ```

2. Pull the latest code:
   ```bash
   git pull
   ```

3. Report what changed (if anything).

### Phase 3: Post-Install Setup

1. Determine the server name from the config-name. The server name in `config/servers.json` matches the config-name (e.g., `interclaw-prod`).

2. Run the post-install setup script:
   ```bash
   cd <deployed-csp-dir> && <python> .claude/skills/interclaw/scripts/infrastructure/setup_interclaw.py \
     --server <server-name> \
     --repo <repo-path> \
     --namespace INTERCLAW \
     [--skip-auth] [--dry-run] [--verify-only]
   ```

   The deployed CSP directory is at `<instance-directory>/csp/interclaw/`. If the instance was just installed and has never had InterClaw loaded, the scripts will not exist in the deployed directory yet. In that case, run the script directly from the repo using python3:
   ```bash
   cd <repo-path> && <python> .claude/skills/interclaw/scripts/infrastructure/setup_interclaw.py \
     --server <server-name> \
     --repo <repo-path> \
     --namespace INTERCLAW \
     [--skip-auth] [--dry-run] [--verify-only]
   ```

   Note: The script needs the `iris_terminal` and `iris_api` libraries from the repo's `scripts/lib/` directory. Running from the repo root ensures the import paths resolve correctly.

3. If `--skip-auth` was NOT passed and `AWS_BEARER_TOKEN_BEDROCK` is set in the environment, the script will use it automatically. Otherwise it will skip authentication and tell the user to run `/authenticate` later.

### Phase 4: Summary

Report a table:

| Phase | Status |
|-------|--------|
| IRIS Install | ... |
| Git Pull | ... |
| Namespace | ... |
| ZPM | ... |
| IPM Load | ... |
| Authentication | ... |
| Verification | ... |

Include the instance URL: `http://<host>/<pathPrefix>/ui/interop/interclaw/interop-editor/index.html`

## Examples

```
/setup-instance interclaw-prod
/setup-instance interclaw-dev --skip-iris
/setup-instance interclaw-test --dry-run
/setup-instance interclaw-prod --skip-iris --skip-pull --verify-only
```

## Important

- The IRIS installation requires sudo and runs interactively. The `/iris-install` skill handles this.
- The git pull runs in the current working directory (the InterClaw repo root).
- The post-install script is idempotent. Running it again on an already-configured instance will detect existing state and skip what is already done.
- If the IRIS instance has never had InterClaw installed before, the first `zpm "load"` creates the CSP application, web apps, and all production components from scratch.
