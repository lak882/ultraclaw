# iris-install

Install InterSystems IRIS for Health instances using JSON configuration and interactive installer.

## Quick Start

```bash
# 1. Edit configuration
vim ~/.claude/config/iris-install-config.json

# 2. Run installation
cd ~/IRISHealth-2026.1.0.233.0-lnxubuntu2204x64
python3 ~/.claude/skills/iris-install/scripts/generate_install_answers.py \
  --config irisclaw-analytics --format heredoc | sudo ./irisinstall
```

## Configuration-Based Installation

All installation settings are defined in `~/.claude/config/iris-install-config.json`. This provides:
- Declarative installation profiles
- Version control for instance configurations
- Template for creating new instances
- Complete documentation of all installer prompts

Example configuration:
```json
{
  "installations": {
    "my-instance": {
      "instance": {
        "name": "my-instance",
        "directory": "/usr/local/InterSystems/my-instance"
      },
      "security": {
        "password": "SYS",
        "csp_password": "SYS"
      },
      "license": {
        "license_file": "/home/lkabelka/isc.key"
      }
    }
  }
}
```

## Parameters

The skill supports both flag-based and natural language input:

### Flags
- `--name <instance>` - Instance name (required)
- `--port <port>` - Web server port (default: auto-assign starting from 52773)
- `--superserver <port>` - SuperServer port (default: auto-assign starting from 1972)
- `--dir <path>` - Installation directory (default: /usr/local/InterSystems/<name>)
- `--nginx` - Configure nginx reverse proxy
- `--nginx-port <port>` - Nginx listen port (default: 80)
- `--password <pwd>` - System password (default: SYS)
- `--csppassword <pwd>` - CSP password (default: SYS)
- `--user <user>` - IRIS system user (default: irisusr)
- `--group <group>` - IRIS system group (default: irisusr)
- `--type <type>` - Setup type: Development|Custom|Minimal (default: Development)
- `--security <level>` - Security level: Minimal|Normal|Locked (default: Normal)
- `--license <path>` - License file path (default: ~/iris.key)
- `--no-pws` - Don't install private web server (requires apache)
- `--no-unicode` - Skip unicode installation
- `--no-ipm` - Skip IPM installation
- `--version <version>` - IRIS version to install (e.g., 2026.1, 2025.1)
- `--kit <path>` - Path to installer kit (auto-detected if not specified)
- `--dry-run` - Generate parameter file but don't install

### Natural Language
Alternatively, provide a description and the skill will extract parameters:
- "Install IRIS 2026.1 called myinstance on port 5555"
- "Set up IRISHealth 2025.1.3 named analytics with nginx on port 8080"
- "Create instance demo-server using password MyPass123"

## What It Does

1. **Find installer kit** - Searches for IRIS installer tar.gz files in common locations
2. **Extract if needed** - Unzips tar.gz to /tmp if not already extracted
3. **Generate parameters** - Creates an .isc parameter file with all settings
4. **Run installation** - Executes silent install with sudo
5. **Configure nginx** (if requested) - Sets up reverse proxy with upstream
6. **Update config** - Adds server to config/servers.json

## Installation Parameters

The skill generates a parameter file with the following settings:

```
install_mode.setup_type: Development | Custom | Minimal
server_location.instance_name: <instance-name>
server_location.target_dir: /usr/local/InterSystems/<instance-name>
security_settings.initial_level: Minimal | Normal | Locked
security_settings.password: <password>
security_settings.csppassword: <csp-password>
security_settings.iris_user: <user>
security_settings.iris_group: <group>
security_settings.manager_user: <current-user>
security_settings.manager_group: <current-group>
port_selection.superserver_port: <port>
port_selection.webserver_port: <port>
unicode_selection.install_unicode: Y | N
private_web_server.install_PWS: Y | N
ipm.install: Y | N
license_key.enter_key: Y
license_key.license_file: <path-to-license>
csp_gateway.configure_web: Y
csp_gateway.directory: /opt/webgateway
```

## Nginx Configuration

When `--nginx` is specified, creates an nginx site config:

```nginx
upstream iris_<instance> {
    server 127.0.0.1:<webserver-port>;
}

server {
    listen <nginx-port>;
    server_name _;

    location / {
        proxy_pass http://iris_<instance>;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Actual Installer Prompt Sequence

The IRIS installer asks these questions in order (total: 17 prompts + 1 confirmation):

1. **Instance name** (text)
2. **Create new instance?** (Y/N, default: Y)
3. **Destination directory** (absolute path)
4. **Installation type** (1=Development, 2=Server only, 3=Custom, default: 1)
5. **Security level** (1=Locked Down, 2=Normal, default: 1)
6. **Instance owner user** (text, creates IRIS account)
7. **Password for _SYSTEM, Admin, SuperUser, <user>** (hidden input)
8. **Password confirmation** (hidden input)
9. **CSPSystem password** (hidden input)
10. **CSPSystem password confirmation** (hidden input)
11. **Group for start/stop** (text)
12. **Unicode support?** (Y/N, default: Y)
13. **Use local web server?** (Y/N, default: Y) - if Apache detected
14. **Enter license key?** (Y/N, default: N)
15. **License file path** (path, if yes to #14)
16. **Install IPM?** (Y/N, default: Y)
17. **Final confirmation** (Y/N, default: Y)

**Note:** Effective group, SuperServer user, and port numbers are **auto-determined** by the installer and NOT prompted for.

## Important Gotchas

1. **Password prompts**: Requires 4 password entries (system password twice + CSP password twice)
2. **Port auto-assignment**: SuperServer and WebServer ports are automatically assigned (e.g., 51773, 80)
3. **License expiration**: Check license validity before installation (`grep ExpirationDate <license-file>`)
4. **Apache integration**: If Apache is detected, CSP Gateway is automatically configured
5. **Hidden input**: Password prompts use `stty` for hidden input (causes "Inappropriate ioctl" messages when piped)

## Defaults

- **Password**: SYS (for both system and CSP)
- **User/Group**: lkabelka/sales (or current user)
- **IRIS process user**: irisusr/irisusr (auto-determined)
- **Setup Type**: Development
- **Security Level**: Normal
- **Web Server**: Apache CSP Gateway (if detected)
- **Unicode**: Yes
- **IPM**: Yes
- **License**: ~/isc.key (must be valid, check expiration date)
- **SuperServer Port**: Auto-assigned (e.g., 51773)
- **Web Server Port**: 80 (via Apache CSP Gateway)

## Version Detection

The skill searches for installer kits in:
1. ~/IRISHealth-*-lnxubuntu2204x64.tar.gz
2. ~/IRIS-*-lnxubuntu2204x64.tar.gz
3. ~/Downloads/IRISHealth-*.tar.gz
4. ~/Downloads/IRIS-*.tar.gz
5. /tmp/IRISHealth-*/
6. /tmp/IRIS-*/

When `--version` is specified (e.g., "2026.1"), it finds the best match.

## Post-Installation

After successful installation:
1. Instance is started automatically
2. Entry is added to config/servers.json
3. Nginx is configured and reloaded (if --nginx)
4. Summary is displayed with connection details

## Error Handling

- Validates license file exists before installation
- Checks for port conflicts with existing instances
- Verifies installer kit is found
- Requires root privileges (uses sudo)
- Shows clear error messages for common failures

## Real Installation Example

**Configuration** (`~/.claude/config/iris-install-config.json`):
```json
{
  "installations": {
    "irisclaw-analytics": {
      "instance": {
        "name": "irisclaw-analytics",
        "directory": "/usr/local/InterSystems/irisclaw-analytics"
      },
      "security": {
        "password": "SYS",
        "csp_password": "SYS"
      },
      "ownership": {
        "instance_owner_user": "lkabelka",
        "instance_owner_group": "sales"
      },
      "license": {
        "license_file": "/home/lkabelka/isc.key"
      },
      "csp_gateway": {
        "configure_web": "Y",
        "url_prefix": "/irisclaw-analytics"
      }
    }
  }
}
```

**Installation command**:
```bash
cd ~/IRISHealth-2026.1.0.233.0-lnxubuntu2204x64
python3 ~/.claude/skills/iris-install/scripts/generate_install_answers.py \
  --config irisclaw-analytics --format heredoc | sudo ./irisinstall
```

**Result**:
```
Starting IRISCLAW-ANALYTICS
Installation completed successfully

You can now access IRISHealth, to access the management portal point your browser to:
http://localhost/irisclaw-analytics/csp/sys/UtilHome.csp
```

**Instance verification**:
```bash
$ sudo iris qlist | grep irisclaw
IRISCLAW-ANALYTICS^/usr/local/InterSystems/irisclaw-analytics^2026.1.0.233.0^running^51773^80

$ curl -I http://localhost/irisclaw-analytics/csp/sys/UtilHome.csp
HTTP/1.1 200 OK
```

**servers.json entry**:
```json
"irisclaw-analytics": {
    "webServer": {
        "scheme": "http",
        "host": "localhost",
        "port": 80
    },
    "username": "superuser",
    "password": "SYS"
}
```

**Connect with Atelier API**:
```bash
/connect irisclaw-analytics
```
