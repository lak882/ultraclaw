Run iterative POC testing: build a POC exercise repeatedly with fresh agents, fix skill issues after each run, stop at equilibrium (two consecutive 0-error runs), and produce a report.

Usage: /poc-test <poc-spec-path> [exercise-name] [--namespace <ns>] [--max-runs <n>]

Defaults: namespace from active connection, max-runs = 6.

---

## Overview

This command tests and improves the POC-building skills by running the same exercise multiple times. Each run uses a **fresh agent with no prior context** — it can only succeed if the skill documentation is good enough. After each run, analyze errors and update skill files so the next agent doesn't repeat them.

## Workflow

### Phase 1: Prepare

1. Read the POC spec at `<poc-spec-path>`. Extract the specific exercise (Build 1, Build 2, etc.) based on `[exercise-name]` or run all exercises sequentially.
2. Derive the package name from the spec (e.g., `ElRio.Build1`).
3. Confirm the target namespace is accessible via `test_connection.py`.
4. Ensure the server is clean: run `reset_package.py` and clear any existing lookup tables for this package.

### Phase 2: Iterative Runs

For each run (up to `--max-runs`):

1. **Clean slate**: Reset the package on server, delete local files (`src/<NS>/<Pkg>/`, `tests/<Pkg>/`), clear FileDrop output directories, clear lookup tables.

2. **Launch fresh agent**: Spawn a new agent (no shared context) with:
   - The exercise spec (extracted text)
   - Server/namespace connection info
   - Package naming convention
   - Instructions to follow CLAUDE.md rules and use dedicated scripts only
   - Instructions to report: pass/fail per step, total errors, DTL diff, trace output
   - **On the FINAL run only**: instruction to leave the production running for human review

3. **Evaluate against quality criteria**: After each agent completes, evaluate its output against the full scorecard in `references/data/DTL/poc-quality-criteria.md`. The evaluation MUST include:

   **DTL checks (D1-D14)**:
   - Read every DTL class the agent produced. Check named paths (D1), DependsOn tuple (D2), no `<comment>` tags (D3), correct create mode (D4), utility functions (D5-D6), foreach syntax with `<break/>` where appropriate (D7), schema fetched first (D8).
   - **D9 DocType verification**: Confirm every `sourceDocType`/`targetDocType` matches a real schema. For Z-structures, verify the agent pulled the specific Z-type with `get_schema.py` — not just the base message.
   - **D10 Segment completeness**: If `create='new'` was used, pull the schema structure and verify every group/segment from the source schema is explicitly copied. Count the source schema groups vs the number of assign statements copying groups — they should match.
   - **D11 Field repeat iteration**: If the DTL iterates over tilde-delimited field repeats (e.g., OBX:ObservationValue), check it uses DTL-native `<foreach property='...ObservationValue()'>` not `$PIECE` in `<code>`.
   - **D12 No assign/code mixing**: Verify DTL doesn't mix virtual document `<assign>` with `<code>` blocks that also do `SetValueAt()`.
   - **D13 Source metadata preserved**: If the DTL creates new segments from field repeats (e.g., exploding OBX:5 tilde values into individual OBX segments), verify data segments copy `ObservationResultStatus`, `ValueType`, and `ObservationIdentifier` from the source OBX — not hardcoded from header/footer templates. Header/footer OBX (static text) may use hardcoded values.
   - **D14 DTL-native elements preferred**: Read the DTL source. If the transform is mostly or entirely `<code>` blocks wrapping `GetValueAt()`/`SetValueAt()` calls, it FAILS. DTLs must use `<assign>` for segment/field copies, `<foreach>` for iteration, `<if>` for conditionals. `<code>` is only acceptable for dynamic variable-indexed group paths (e.g., `OBXgrp(counter)`) or disabled debug `write` statements.

   **Test message checks (T1-T6)**:
   - T6: Verify the test message's MSH:9 type matches the DTL's sourceDocType.

   **Production checks (P1-P6)**:
   - **P4 Standard template**: Production has Ens.Alert handler and BadMessageHandler.
   - **P5 MessageSchemaCategory**: File service schema category matches the DTL's DocType version.
   - **P6 Routing filter**: Routing rules filter on the correct message type per spec.

   **BPL checks (B1-B5)** (if exercise includes BPL/BP):
   - B1 request immutability, B2 context properties, B3 alert routing, B4 SQL table naming, B5 OBRunion path.

4. **Record results**: Log the agent's report and quality scorecard — duration, error count, error descriptions, DTL diff correctness, trace success, D/T/P/B/E scores.

5. **Check equilibrium**: If this is the 2nd consecutive run with 0 D/T/P/B errors, stop iterating.

5. **Update skills** (if errors > 0): For each error the agent encountered:
   - Classify it: DTL authoring, test message, lookup table, production config, routing rule, script usage
   - Find the relevant skill file (CLAUDE.md, poc.md, data-transformations.md, lookup-tables.md, routing-rules.md, etc.)
   - Add a targeted rule/warning that would prevent this error
   - Be specific — include the exact error message, wrong vs right syntax, and why

6. **Merge productions** (multi-exercise POCs): When exercises run in parallel, each agent builds its own production for testing. After all agents complete, merge into a single `<Pkg>.Production`:
   - Combine all `<Item>` elements from each exercise production
   - Keep ONE shared `Ens.Alert` and ONE shared `BadMessageHandler` (remove per-exercise duplicates)
   - Preserve `Category` attributes on each item to group by exercise
   - Normalize file paths to use the CSP filedrop directory consistently
   - Update routing rule `production=` attributes to reference the merged production name
   - Delete the per-exercise production classes from the server
   - Start the merged production and verify all exercises still route correctly

### Phase 3: Report

After equilibrium (or max runs), produce a report at `demos/<date>_poc-test-<exercise>.md`:

```markdown
# Iterative POC Testing Report: <Exercise Name>

**Date**: <date>
**POC**: <exercise description>
**Namespace**: <ns>
**Equilibrium**: Run <N> (confirmed by Run <N+1>)

## Summary Table

| Run | Duration | Errors | Agent Context | Key Change |
|-----|----------|--------|---------------|------------|
| 1   | Xm Ys    | N      | Fresh agent   | Baseline   |
| 2   | Xm Ys    | N      | Fresh agent   | <what changed> |
| ...

## Run Details

### Run 1: Baseline
- **Errors**: [list each error with root cause]
- **Skill updates applied**: [list files changed and rules added]

### Run 2: ...

## Skill Changes Summary

| File | Change | Prevented Error |
|------|--------|-----------------|
| ...

## Quality Scorecard

| Criterion | Run 1 | Run 2 | ... |
|-----------|-------|-------|-----|
| D1 Named paths | | | |
| D2 DependsOn tuple | | | |
| D3 No comment tags | | | |
| D4 Correct create mode | | | |
| D5-D6 Utility functions | | | |
| D7 Foreach syntax + break | | | |
| D8 Schema fetched | | | |
| D9 DocType verified | | | |
| D10 Segment completeness | | | |
| D11 Field repeat iteration | | | |
| D12 No assign/code mixing | | | |
| D13 Source metadata preserved | | | |
| D14 DTL-native elements | | | |
| T1-T6 Test messages | | | |
| P1-P6 Production/routing | | | |
| B1-B5 BPL (if applicable) | | | |
| E1-E5 Efficiency | | | |

## Metrics

| Metric | Run 1 | Run 2 | ... |
|--------|-------|-------|-----|
| Duration | | | |
| D/T/P/B failures | | | |
| Self-corrections | | | |
| DTL compile attempts | | | |
| Test message rewrites | | | |
| Total tool calls | | | |
```

## Agent Prompt Template

When launching each fresh agent, use this structure:

```
You are executing a POC build. Build <Exercise> from scratch.
Server: vmdev1, Namespace: <NS>.

## POC SPEC
<extracted exercise text>

## COMPONENTS TO BUILD
<list: services, operations, routers, rules, DTLs, lookups>

## EXECUTION STEPS
1. Fetch HL7 schema for <message type>
2. Create lookup table(s) via manage_lookup.py
3. Write DTL class(es) to src/<NS>/<Pkg>/...
4. Write routing rule to src/<NS>/<Pkg>/...
5. Write production class to src/<NS>/<Pkg>/...
6. Push and compile all classes
7. Write test message(s) to tests/<Pkg>/...
8. Test DTL(s) with test_dtl.py --diff
9. Start production
10. Send test message(s) via FileDrop
11. Check trace

## RULES
- cd to project root, use irispython
- Always pass --server vmdev1 --namespace <NS>
- Read CLAUDE.md for DTL/test message rules BEFORE writing
- Use manage_lookup.py for lookups (NOT iris_terminal.py)
- Do NOT use iris_terminal.py
- <FINAL RUN ONLY>: Do NOT clean up — leave production running

## OUTPUT
Report: step pass/fail, total errors, DTL diff, trace output.
```

## Key Principles

- **Fresh agent = honest test**: If the agent fails, the skills are insufficient. Don't blame the agent — fix the skills.
- **Targeted skill updates**: Don't add vague guidance. Add the exact rule that would have prevented the specific error.
- **Equilibrium = two consecutive 0-error runs**: One clean run could be luck. Two confirms the skills are solid.
- **Keep final production**: The last successful run's production stays running for human review. Only clean up intermediate runs.
