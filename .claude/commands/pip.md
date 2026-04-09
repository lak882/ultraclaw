Install, list, or remove Python packages in the IRIS embedded Python environment.

Usage: /pip <action> [packages...]

Actions: install, uninstall, list, show, check. Default: list.

Steps by action:

**install** <packages...>:
1. Install:
   ```bash
   sudo /usr/local/InterSystems/IRISHealth/bin/irispython -m pip install --target /usr/local/InterSystems/IRISHealth/lib/python <packages>
   ```
2. Verify by importing in IRIS embedded Python:
   ```bash
   /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/ws_terminal.py --server <server> --namespace %SYS --code 'set py = ##class(%SYS.Python).Import("<package>") write py,!' --raw
   ```

**uninstall** <packages...>:
1. Try: `sudo /usr/local/InterSystems/IRISHealth/bin/irispython -m pip uninstall -y <packages>`
2. If that fails (--target installs), remove manually:
   ```bash
   sudo rm -rf /usr/local/InterSystems/IRISHealth/lib/python/<package> /usr/local/InterSystems/IRISHealth/lib/python/<package>-*.dist-info
   ```

**list**:
```bash
pip3 list --path /usr/local/InterSystems/IRISHealth/lib/python/
```

**show** <package>:
```bash
pip3 show --path /usr/local/InterSystems/IRISHealth/lib/python/ <package>
```

**check**:
1. Check IRIS Python version:
   ```bash
   /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/ws_terminal.py --server <server> --namespace %SYS --code 'set py = ##class(%SYS.Python).Import("sys") write py.version,!' --raw
   ```
2. Count packages: `ls /usr/local/InterSystems/IRISHealth/lib/python/ | wc -l`
3. Report Python version and package count.

Notes:
- Always use `sudo` — lib/python is typically owned by root.
- Use `irispython -m pip`, not `pip3 install` — ensures correct Python.
- Some packages require IRIS restart to be picked up by embedded Python.
