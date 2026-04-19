Install, verify, or uninstall an IPM package from a local directory on an IRIS server.

Usage: /ipm-install <directory> [action] [namespace]

Arguments:
- **directory** (required) — absolute path to the directory containing `module.xml`
- **action** — `install` (default), `verify`, `uninstall`, `reset`
- **namespace** — target namespace (defaults to connected namespace from conversation context)

Examples:
- `/ipm-install .`
- `/ipm-install /opt/my-package install MYNAMESPACE`
- `/ipm-install /opt/my-package verify`
- `/ipm-install /opt/my-package uninstall`
- `/ipm-install /opt/my-package reset`

---

## Parsing

1. Extract the directory path (first argument — must be an absolute path or `.` for current project root)
2. If `.` is given, resolve to the current working directory (project root)
3. Extract the action (second argument, default `install`)
4. Extract the namespace (third argument, or from conversation context, or prompt the user)
5. Determine the server from `config/servers.json` (default myserver)

---

## Pre-flight (all actions)

1. Verify the directory exists and contains `module.xml`:
   ```bash
   ls <directory>/module.xml
   ```
   If missing, stop and tell the user.

2. Read `module.xml` to extract the package name:
   ```bash
   grep '<Name>' <directory>/module.xml
   ```

3. Verify IPM is available on the server (terminal required — ZPM has no REST API):
   ```bash
   <python> .claude/skills/interclaw/scripts/lib/iris_terminal.py --server myserver --namespace %SYS --code 'write $classmethod("%ZPM.PackageManager","%ExistsId",""),!' --raw
   ```
   If IPM is not available, tell the user and stop.

---

## Action: install (default)

Load and install the module from the local directory.

1. Run pre-flight checks
2. Load the module (terminal required — ZPM has no REST API):
   ```bash
   <python> .claude/skills/interclaw/scripts/lib/iris_terminal.py --server myserver --namespace <NAMESPACE> --code 'zpm "load <directory> -v"' --raw
   ```
3. Show the output
4. If successful, run the **verify** action automatically

---

## Action: verify

Check that the package components deployed correctly.

1. Run pre-flight checks to get the package name
2. Read `module.xml` to find:
   - All `<CSPApplication Url="...">` entries
   - All `<Resource Name="...">` entries
   - All `<Invoke>` class references
3. For each CSP application, check it exists:
   ```bash
   <python> .claude/skills/interclaw/scripts/infrastructure/manage_webapp.py --server myserver --exists <url>
   ```
4. For each resource class package, check classes exist via SQL:
   ```bash
   <python> .claude/skills/interclaw/scripts/documents/run_query.py --server myserver --namespace <NAMESPACE> --sql "SELECT COUNT(*) FROM %Dictionary.ClassDefinition WHERE Name %STARTSWITH '<PackageName>'" --format json
   ```
5. Check if `<DeployPath>` directories have files on disk (resolve `${cspdir}` to the IRIS install directory + `csp/`)
6. Report each check as [OK] or [FAIL]
7. Show a summary table

---

## Action: uninstall

Remove the package.

1. Run pre-flight checks to get the package name
2. Try IPM uninstall first (terminal required — ZPM has no REST API):
   ```bash
   <python> .claude/skills/interclaw/scripts/lib/iris_terminal.py --server myserver --namespace <NAMESPACE> --code 'zpm "uninstall <package-name>"' --raw
   ```
3. Check if the module has an `<Invoke>` class with a `Reset` or `Uninstall` method — if so, call it (terminal required — arbitrary method invocation):
   ```bash
   <python> .claude/skills/interclaw/scripts/lib/iris_terminal.py --server myserver --namespace <NAMESPACE> --code 'do ##class(<InvokeClass>).Reset()' --raw
   ```
4. Verify web apps and files were cleaned up. If not, offer to clean up manually.

---

## Action: reset

Full uninstall + reinstall cycle.

1. Run the **uninstall** action
2. Run the **install** action

---

## After Any Action

Show a summary table of what was found/changed:

```
| Component              | Status |
|------------------------|--------|
| module.xml             | ...    |
| <CSP App 1>            | ...    |
| <CSP App 2>            | ...    |
| <Class Package>        | ...    |
| <Deploy Path>          | ...    |
| IPM registered         | ...    |
```
