Manage production hosts — add, update, remove, or list hosts in a production.

Usage: /host <action> [arguments]

Actions: add, update, remove, list, settings.

Steps:

1. Parse "$ARGUMENTS" — action, production class, host name, className (for add), key=value settings (for add/update), type (for settings).
2. Build InteropEditors API base URL: `{scheme}://{host}:{port}{pathPrefix}/api/interop-editors/v3/{namespace}`

---

### Action: list

Call `GET {baseUrl}/productions/{productionClass}` with Basic Auth. Display hosts grouped by type (Services, Processes, Operations).

```bash
python3 -c "
import json, sys
sys.path.insert(0, '.claude/skills/interclaw/scripts')
from iris_api import load_server_config, build_interop_url, make_interop_request
cfg = load_server_config('<server>')
url = build_interop_url(cfg, '<namespace>')
resp = make_interop_request(f'{url}/productions/<productionClass>', cfg['username'], cfg.get('password',''), method='GET')
print(json.dumps(json.loads(resp), indent=2))
"
```

---

### Action: add

1. **Fetch settings** for the host class to determine correct Target values (Host vs Adapter):
   ```bash
   <python> .claude/skills/interclaw/scripts/connection/get_settings.py --server <server> --namespace <ns> --class <className> --type <service|process|operation>
   ```
   Determine type from className: `Service`/`.BS.`--service, `Process`/`MsgRouter`/`.BP.`/`.BPL.`--process, `Operation`/`.BO.`--operation.

2. **Create host** via `PUT {baseUrl}/productions/{productionClass}/{hostName}`:
   ```json
   {"className": "<cls>", "enabled": true, "settings": [{"name": "...", "value": "...", "target": "Host|Adapter"}]}
   ```
   HTTP Services default: `EnableStandardRequests=1` (Host), `PoolSize=0`.

3. **Create FileDrop directories** under `${cspdir}interclaw/filedrop/<Package>/<Component>/` if file-based adapter (see CLAUDE.md "File Directories").

4. **Restart production** with `manage_production.py --start <prod> --stop-first`.

---

### Action: update

1. Fetch settings with `get_settings.py` to determine correct Targets. If className unknown, run **list** first.
2. Update via `PUT {baseUrl}/productions/{productionClass}/{hostName}/settings`:
   ```json
   {"settings": [{"name": "...", "value": "...", "target": "Host|Adapter"}]}
   ```
3. Restart production.

---

### Action: remove

1. Confirm with user before deleting.
2. Delete via `PUT {baseUrl}/productions/{productionClass}/{hostName}/delete`.
3. Restart production.

---

### Action: settings

```bash
<python> .claude/skills/interclaw/scripts/connection/get_settings.py --server <server> --namespace <ns> --class <className> --type <type>
```
Display grouped by Target (Host vs Adapter).

---

**Fallback**: If InteropEditors API is unavailable, edit Production class XDATA directly via `get_doc.py`/`put_doc.py`.
