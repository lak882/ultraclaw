Validate a production package with static analysis before pushing to the server.

Usage: /validate <package> [--server <server>] [--namespace <namespace>]

Checks: target resolution, DTL DocType matching, lookup table existence, CfgItem presence, EnableStandardRequests target, routing rule syntax, package naming.

Steps:
1. Parse "$ARGUMENTS" — package name (required), optional `--server` and `--namespace`.
2. Run:
   ```bash
   cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/production/validate_package.py --server <server> --namespace <namespace> --package <package>
   ```
3. Summarize PASS/WARN/FAIL results. Explain failures and suggest fixes.
