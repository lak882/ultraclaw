---
name: iris-install
description: Install InterSystems IRIS for Health instances with natural language configuration
---

Install InterSystems IRIS for Health using natural language or explicit parameters.

## Usage

When the user asks to install IRIS, run the installation script:

```bash
python3 ~/.claude/skills/iris-install/scripts/install_iris.py [args]
```

## Parsing User Intent

The user may provide installation requirements in several forms:

### Explicit flags:
- "Install IRIS 2026.1 with name myinstance on port 5555"
  → `--name myinstance --version 2026.1 --port 5555 --nginx`

- "Create instance analytics-prod using port 8080 and nginx"
  → `--name analytics-prod --nginx-port 8080 --nginx`

- "Install IRISHealth 2025.1.3 called demo"
  → `--name demo --version 2025.1.3`

### Natural language only:
- "Install IRIS 2026.1 called irisclaw-analytics on port 5555 with nginx forwarding"
  → Pass entire string as natural language: `"Install IRIS 2026.1 called irisclaw-analytics on port 5555 with nginx forwarding"`

### Common parameters:
- **Required**: instance name (--name or in description)
- **Optional**: version (--version), port (--port for nginx, --superserver for SuperServer)
- **Defaults**: password=SYS, user=irisusr, group=irisusr, type=Development

## Workflow

1. **Understand request** - Parse user's natural language or extract explicit parameters
2. **Find installer** - Script searches for IRIS kit matching version
3. **Extract if needed** - Unzips tar.gz to /tmp if not already extracted
4. **Generate params** - Creates installation parameter file
5. **Run installation** - Executes silent install with sudo (requires user permission)
6. **Configure nginx** - If requested, sets up reverse proxy
7. **Update config** - Adds entry to config/servers.json
8. **Show summary** - Display connection details and portal URL

## Important Notes

- **Requires sudo** - Installation needs root privileges, user will be prompted
- **Auto port assignment** - If ports not specified, finds next available starting from 1972/52773
- **License required** - Defaults to ~/iris.key (must exist)
- **Nginx optional** - Only configured if explicitly requested with --nginx flag
- **Dry run available** - Use --dry-run to generate params without installing

## After Installation

The instance is:
- Automatically started
- Added to config/servers.json
- Accessible via /connect command
- Available through Management Portal

## Error Handling

Common failures:
- License file not found → Check ~/iris.key exists
- Port conflict → Script auto-assigns if not specified
- Installer not found → Specify version or use --kit path
- Nginx config fails → Instance still works, nginx setup skipped

## Examples

User says: "Install IRIS 2026.1 and forward it to port 5555 using nginx, call it irisclaw-analytics"

Run:
```bash
cd ~/.claude && python3 ~/.claude/skills/iris-install/scripts/install_iris.py \
  --name irisclaw-analytics \
  --version 2026.1 \
  --nginx \
  --nginx-port 5555
```

User says: "Set up a dev instance called test-server with IRIS 2025.1"

Run:
```bash
cd ~/.claude && python3 ~/.claude/skills/iris-install/scripts/install_iris.py \
  --name test-server \
  --version 2025.1 \
  --type Development
```

User says: "Install IRIS 2026.1 named myinstance"

Run:
```bash
cd ~/.claude && python3 ~/.claude/skills/iris-install/scripts/install_iris.py \
  --name myinstance \
  --version 2026.1
```
