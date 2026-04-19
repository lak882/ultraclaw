Browse and run POC sample exercises from the poc-examples catalog.

Usage: /samples [poc-name] [exercise-number] [--namespace <ns>]

---

## Execution

Parse `$ARGUMENTS` and run the matching script command. Display the output verbatim.

**No args:**
```bash
cd "<project-root>" && <python> .claude/skills/interclaw/scripts/production/samples.py --list
```

**POC name only:**
```bash
cd "<project-root>" && <python> .claude/skills/interclaw/scripts/production/samples.py --poc <name>
```

**POC name + exercise number** → extract and build:
```bash
cd "<project-root>" && <python> .claude/skills/interclaw/scripts/production/samples.py --poc <name> --exercise <N>
```
Then invoke `/build-poc` with the spec path and package name from the script output.
