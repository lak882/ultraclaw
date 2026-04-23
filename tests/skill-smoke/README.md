# Skill smoke tests

One probe per skill. Each probe runs the skill's primary `exec:` one-liner or `run_sql` query directly against the `xecute` / `run_sql` tool on `interclaw-test:ULTRACLAW` via the chat REST API, and checks shape-only (no error prefix; for structured returns, required keys present).

## Running

```bash
cd tests/skill-smoke
./run.sh
```

Env vars (optional):
- `INTERCLAW_URL` — base URL, default `http://vmdev1.iscinternal.com/interclaw-test`
- `INTERCLAW_USER` / `INTERCLAW_PASS` — auth, default `SuperUser:SYS`
- `INTERCLAW_NS` — target namespace, default `ULTRACLAW`

## Failure handling

Each probe is independent. The runner continues on failure and prints a summary of passes/fails at the end. Exit code is non-zero if any probe failed.

## Probe list

| # | Skill | Probe | One-liner |
|---|-------|-------|-----------|
| 1 | `dtl` | schema-segment-fields | `InterClaw.Script.HL7.GetSchema.SegmentFields("2.5.1","PID")` |
| 2 | `rule` | schema-message-structure | `InterClaw.Script.HL7.GetSchema.MessageStructure("2.5.1","ADT_A01")` |
| 3 | `record-map` | list-recordmap-classes | `SELECT Name FROM %Dictionary.ClassDefinition WHERE Super LIKE '%RecordMap%'` |
| 4 | `production` | list-classes-in-dictionary | `SELECT COUNT(*) AS N FROM %Dictionary.ClassDefinition` |
| 5 | `manage-production` | production-status | `Ens.Director.GetProductionStatus` |
| 6 | `iris-sql` | top-10-class-names | `SELECT TOP 10 Name FROM %Dictionary.ClassDefinition` |
| 7 | `test/dtl` | hl7-import-string | `EnsLib.HL7.Message.ImportFromString` roundtrip |
| 8 | `sample/hl7` | schema-list-categories | `InterClaw.Script.HL7.GetSchema.ListCategories()` |
| 9 | `xecute` (result convention) | basic-arithmetic | `Set %result = 41+1` |
| 10 | `xecute` (write capture) | basic-write | `Write 41+1` |
