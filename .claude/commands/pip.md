Install, list, or remove Python packages in the IRIS embedded Python environment.

Usage: /pip <action> [packages...]

Actions: install, uninstall, list, show, check. Default: list.

Steps by action:

**install** <packages...>:
1. Install:
   ```bash
   python3 -m pip install --target ../../mgr/python <packages>
   ```
2. Verify by importing in IRIS embedded Python:
   ```bash
   <python> .claude/skills/interclaw/scripts/iris_terminal.py --server <server> --namespace %SYS --code 'set py = ##class(%SYS.Python).Import("<package>") write py,!' --raw
   ```

**uninstall** <packages...>:
1. Try: `python3 -m pip uninstall -y <packages>`
2. If that fails (--target installs), remove manually:
   ```bash
   rm -rf ../../mgr/python/<package> ../../mgr/python/<package>-*.dist-info
   ```

**list**:
```bash
pip3 list --path ../../mgr/python/
```

**show** <package>:
```bash
pip3 show --path ../../mgr/python/ <package>
```

**check**:
1. Check IRIS Python version:
   ```bash
   <python> .claude/skills/interclaw/scripts/iris_terminal.py --server <server> --namespace %SYS --code 'set py = ##class(%SYS.Python).Import("sys") write py.version,!' --raw
   ```
2. Count packages: `ls ../../mgr/python/ | wc -l`
3. Report Python version and package count.

Notes:
- Use `python3 -m pip`, not `pip3 install` -- ensures correct Python.
- Some packages require IRIS restart to be picked up by embedded Python.
