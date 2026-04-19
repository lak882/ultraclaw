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

1. **Clean slate**: Reset the package on server, delete local files (`src/<NS>/<Pkg>/`, `tests/<Pkg>/`), clear FileDrop output directories, clear lookup tables. **Delete custom HL7 schemas**: If the exercise uses a custom schema category (e.g., `SH2.5`), delete the `.HL7` document from the server via the Atelier DELETE API: `IrisHTTP(server, namespace).delete_doc("<Category>.HL7")` (import from `lib/iris_http.py`). The `put_doc.py` script does not support `--delete`. Also delete the local `.HL7` file from `src/<NS>/<Pkg>/`. The agent must recreate schemas from scratch each run — leftover schemas mask registration bugs.

2. **Launch fresh agent**: Spawn a new agent (no shared context) with:
   - The exercise spec (extracted text)
   - Server/namespace connection info
   - Package naming convention
   - Instructions to follow CLAUDE.md rules and use dedicated scripts only
   - Instructions to report: pass/fail per step, total errors, DTL diff, trace output
   - **File isolation rules**: Do NOT read `tests/*/reference/`, `*_output.hl7`, `*_expected.*`, `*_answer.*`, or `*_solution.*`. Build from spec only.
   - **BPL mandate**: ALWAYS use BPL (`Ens.BusinessProcessBPL`), NEVER code-based BP (`Ens.BusinessProcess`).
   - **On the FINAL run only**: instruction to leave the production running for human review

3. **Evaluate against quality criteria**: After each agent completes, evaluate its output against the full scorecard in `dtl/poc-quality-criteria.md`. The evaluation MUST include:

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
   - **P4 Business logic only**: POC should contain only business logic components — no infrastructure boilerplate.
   - **P5 MessageSchemaCategory**: File service schema category matches the DTL's DocType version.
   - **P6 Routing filter**: Routing rules filter on the correct message type per spec.

   **BPL checks (B1-B6)** (if exercise includes BPL/BP):
   - **B6 BPL mandate**: Every business process MUST extend `Ens.BusinessProcessBPL`, NOT `Ens.BusinessProcess`. Read each BP/BPL class file. If ANY class `Extends Ens.BusinessProcess` (without the `BPL` suffix), it is an automatic FAIL. The agent must use BPL for all orchestration.
   - B1 request immutability, B2 context properties, B3 alert routing, B4 SQL table naming, B5 OBRunion path.

4. **Self-correcting loop** (up to 3 correction attempts): If the initial evaluation found D/T/P/B failures, attempt to fix them **without rebuilding from scratch**. This tests whether the errors are fixable vs fundamental skill gaps.

   For each correction attempt (max 3):

   a. **Classify failures**: Group by type:
      - **P-fixable** (compilation/push errors): Fix the source file, re-push, re-compile
      - **D-fixable** (DTL quality): Fix DTL XML (positional paths → named, missing DependsOn, etc.), re-push, re-test with `test_dtl.py --diff`
      - **T-fixable** (test message issues): Fix test message (segment order, field alignment, missing data), re-send, re-trace
      - **B-fixable** (BPL issues): Fix BPL XML or convert BP → BPL, re-push, re-compile
      - **Unfixable** (fundamental design error): Log as requiring skill update, do not attempt correction

   b. **Apply fixes**: For each fixable failure:
      - Read the produced artifact (DTL class, test message, production class, BPL class)
      - Apply the targeted fix (e.g., replace positional paths with named paths, fix segment order)
      - Push and compile the corrected artifact using `put_doc.py --force --compile`
      - If the fix is a BP→BPL conversion: rewrite the class as `Ens.BusinessProcessBPL` with `XData BPL`, update production to reference the new BPL class, push both

   c. **Re-test**: After all fixes applied:
      - Re-run `test_dtl.py --diff` for corrected DTLs
      - Re-send test messages via FileDrop
      - Re-check traces with `trace.py`
      - Re-evaluate against quality criteria

   d. **Check result**: If all D/T/P/B criteria now PASS → correction succeeded, record as "CLEAN (corrected)". If failures remain, continue to next correction attempt.

   e. **Log correction**: Record what was broken, what was fixed, and whether the fix resolved it. Format:
      ```
      Correction #N: Fixed D1 (positional PID:3.1 → named PID:PatientIdentifierList.IDNumber in DTL).
                     Fixed T1 (reordered NK1 before PV1 in test message).
                     Result: 2 failures resolved, 0 remaining.
      ```

   After 3 correction attempts or all failures resolved, proceed to step 5.

5. **Record results**: Log the agent's initial report, correction history, and final quality scorecard:
   - Initial D/T/P/B error count (before corrections)
   - Number of correction attempts made
   - Final D/T/P/B error count (after corrections)
   - For each correction: what was fixed and whether it resolved the issue
   - DTL diff correctness, trace success, E scores

6. **Check equilibrium**: If this is the 2nd consecutive run with 0 D/T/P/B errors (after corrections), stop iterating.

7. **Update skills** (if errors remain after corrections): For each error that could NOT be corrected:
   - Classify it: DTL authoring, test message, lookup table, production config, routing rule, script usage
   - Find the relevant skill file (CLAUDE.md, poc.md, data-transformations.md, lookup-tables.md, routing-rules.md, etc.)
   - Add a targeted rule/warning that would prevent this error
   - Be specific — include the exact error message, wrong vs right syntax, and why
   - **Do NOT update skills for errors that were successfully corrected** — those indicate the agent can self-correct, not that skills are missing

8. **Merge productions** (multi-exercise POCs): When exercises run in parallel, each agent builds its own production for testing. After all agents complete, merge into a single `<Pkg>.Production`:
   - Combine all `<Item>` elements from each exercise production
   - Remove any infrastructure boilerplate hosts that are not required by the spec
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

| Run | Duration | Initial Errors | Corrections | Final Errors | Result |
|-----|----------|----------------|-------------|--------------|--------|
| 1   | Xm Ys    | N              | N/3         | N            | CLEAN/NEEDS WORK |
| 2   | Xm Ys    | N              | N/3         | N            | PERFECT/CLEAN |
| ...

## Run Details

### Run 1: Baseline
- **Initial errors**: [list each D/T/P/B failure with root cause]
- **Correction attempts**:
  - Correction #1: Fixed [what]. Result: [resolved/remaining].
  - Correction #2: Fixed [what]. Result: [resolved/remaining].
- **Final errors**: [remaining unfixable errors, if any]
- **Skill updates applied**: [list files changed and rules added — only for unfixable errors]

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
| B1-B5 BPL quality (if applicable) | | | |
| B6 BPL mandate | | | |
| B8 Call assign pattern | | | |
| B9 Switch for branching | | | |
| B10 Spec field numbers verified | | | |
| B11 Sequence elements named | | | |
| B12 No unnecessary sequence nesting | | | |
| E1-E5 Efficiency | | | |

## Metrics

| Metric | Run 1 | Run 2 | ... |
|--------|-------|-------|-----|
| Duration | | | |
| D/T/P/B failures (initial) | | | |
| Correction attempts | | | |
| D/T/P/B failures (after corrections) | | | |
| Self-corrections | | | |
| DTL compile attempts | | | |
| Test message rewrites | | | |
| Total tool calls | | | |
```

## Agent Prompt Template

When launching each fresh agent, use this structure:

```
You are executing a POC build. Build <Exercise> from scratch.
Server: myserver, Namespace: <NS>.

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
- cd to project root, use python3
- Always pass --server myserver --namespace <NS>
- Read CLAUDE.md, dtl/data-transformations.md, and bpl/bpl-reference.md BEFORE writing ANY DTL or BPL
- Use manage_lookup.py for lookups (NOT iris_terminal.py)
- Do NOT use iris_terminal.py
- **ZERO `<code>` blocks in DTL — no exceptions.** `<assign>` property paths support variables (`counter`, `k1`) and expressions (`counter+1`). Use `<assign>` for ALL operations: segment copies, counter management, dynamic-indexed targets (`target.{...OBXgrp(counter).OBX}`), raw segment strings. The ONLY acceptable `<code>` is `disabled='1'` debug writes. Any active `<code>` block = automatic quality failure.
- **Use `<sql>` in BPL for SQL operations** (INSERT, SELECT INTO, DELETE) — NOT `<code>` wrapping utility classes. Bind context properties with `:context.Property` syntax.
- **ALWAYS create BPL (Ens.BusinessProcessBPL) for business processes — NEVER code-based BP (Ens.BusinessProcess)**. See the BPL reference in bpl/bpl-reference.md for patterns.
- **Routing rules: use `<constraint>` for message type filtering.** Use `<constraint name="docName" value="ADT_A01"/>` — NOT `HL7.{MSH:MessageType.MessageCode}` in conditions. Conditions should only contain business logic (e.g., SendingFacility checks).
- **Fail fast**: If any step errors or takes more than 2 minutes of investigation, log the exact error and move on. Tag with [SKILL-GAP]. Do not spend time debugging — the fix belongs in skill docs, not working memory.
- <FINAL RUN ONLY>: Do NOT clean up — leave production running

## FILE ISOLATION — MANDATORY
- Do NOT read, reference, or access ANY files in `tests/*/reference/` directories
- Do NOT read any files named `*_output.hl7`, `*_expected.*`, `*_answer.*`, or `*_solution.*`
- Do NOT read any notes, reference outputs, or answer keys — build ONLY from the POC spec
- The POC spec is your SOLE source of requirements — if it doesn't specify something, make a reasonable choice
- Violation of these rules invalidates the entire run

## OUTPUT
Report: step pass/fail, total errors, DTL diff, trace output.
```

## Key Principles

- **Fresh agent = honest test**: If the agent fails, the skills are insufficient. Don't blame the agent — fix the skills.
- **Correct before rebuilding**: When D/T/P/B failures are found, try to fix the artifacts in place (up to 3 attempts) before declaring the run a failure. This separates "fixable quality issues" from "fundamental skill gaps."
- **Correctable ≠ skill gap**: If the evaluator can fix an error (e.g., positional path → named path), it means the agent CAN produce the right thing but didn't on this run. Only update skills for errors that cannot be corrected — those indicate missing knowledge.
- **Targeted skill updates**: Don't add vague guidance. Add the exact rule that would have prevented the specific error.
- **Equilibrium = two consecutive 0-error runs**: One clean run could be luck. Two confirms the skills are solid. Post-correction 0 errors count.
- **BPL mandate**: Every business process must be BPL. A code-based BP is always a B6 failure and should be corrected to BPL in the correction loop.
- **File isolation**: Agents must never read answer keys, reference outputs, or expected results. Violation invalidates the run.
- **Keep final production**: The last successful run's production stays running for human review. Only clean up intermediate runs.
- **Fail fast, log immediately**: If any step errors or requires excessive debugging (more than 2 minutes of investigation), stop trying to fix it in-flight. Log the exact error, the command that produced it, and what you expected instead — then move on. Every error that takes "too much thinking" is a skill gap signal. Record it immediately in the run report with the tag `[SKILL-GAP]` so the evaluator can update documentation. The goal is to surface problems, not solve them during the test run. Time spent debugging inside a test run is wasted — the fix belongs in the skill files, not in the agent's working memory.
- **Custom schemas are ephemeral**: Always delete and recreate custom HL7 schema categories (e.g., `SH2.5`) as part of the clean slate. A leftover schema from a prior run masks bugs in schema creation logic. The agent must prove it can register schemas from scratch.
