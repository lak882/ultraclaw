Send HL7 messages to an IRIS server via HTTP, TCP/MLLP, or file drop.

Usage: /send [--to <configItemName>] [--http|--tcp|--file] <file-or-description>

Transport: auto-detected from component class when `--to` is given. Override with `--http`, `--tcp`, or `--file`.

Steps:
1. Check production is running: `manage_production.py --status`. Start if needed.
2. **Resolve target component.** Always pass `--to <configItem>` and `--namespace <ns>` to `send_hl7.py` — the script auto-detects transport, port, and URL from the production XML. If `--to` not given, find the service from the active production (ask if multiple).
3. Parse the message argument — file path or description. If description, generate a valid HL7 message:
   - MSH with proper separators, message type, control ID, version
   - PID with realistic fake data
   - `\r` as segment terminator
4. Send:
   ```bash
   cd "/usr/local/InterSystems/interop-agent-orchestrator" && /usr/local/InterSystems/IRISHealth/bin/irispython .claude/skills/interclaw/scripts/hl7/send_hl7.py --server <server> --namespace <ns> --to <configItem> --input <file>
   ```
5. Display result. If rejected/errored, offer to check format and run `/trace`.
