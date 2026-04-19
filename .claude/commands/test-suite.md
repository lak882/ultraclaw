Run all test messages for a package and check traces automatically.

Usage: /test-suite <package> [--to <configItemName>] [--wait <seconds>] [--test-dir <dir>]

Steps:
1. Parse "$ARGUMENTS" ÃÂ¢ÃÂÃÂ package prefix (required), `--to <configItem>`, `--wait <seconds>` (default 2), `--test-dir <dir>` (default tests/).
2. Build HTTP service URL from `--to` config item, or auto-detect from active production.
3. Run:
   ```bash
   <python> .claude/skills/interclaw/scripts/hl7/test_suite.py --server <server> --namespace <ns> --package <package> --url <url> [--test-dir <dir>] [--wait <wait>]
   ```
4. Display results: PASS/FAIL/ERROR for each test message.
5. For failures: show error details, suggest `/trace --component <name>` to investigate.
6. Report overall pass/fail counts.
