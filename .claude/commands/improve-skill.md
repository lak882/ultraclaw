Execute a command while tracking errors and self-corrections, then update the skill files to prevent those issues in future runs.

Usage: /improve-skill <command> [arguments]

Example: /improve-skill /dtl create an ADT_A01 transform for Sanford

This is a meta-command. It wraps another command, observes how it performs, and feeds the lessons back into the skill documentation.

## Phase 1: Execute the inner command

1. Parse "$ARGUMENTS" -- extract the inner command (e.g., `/dtl`) and its arguments.
2. Before executing, create a tracking log in memory. Initialize these counters:
   - `errors`: compile failures, API errors, script failures
   - `retries`: repeated attempts at the same operation
   - `self_corrections`: times you caught and fixed your own mistake
   - `schema_lookups`: times you had to pull a schema or reference you should have known
   - `workarounds`: times you worked around a limitation or bug
   - `assumptions_wrong`: times an assumption turned out incorrect
3. Execute the inner command normally, following all its instructions. Do not change your behavior -- work exactly as you would without `/improve-skill`. The point is to observe natural execution, not perform artificially.
4. During execution, log each incident as it happens. For each incident, record:
   - **What happened**: the error message, the wrong output, the failed step
   - **Root cause**: why it happened (missing instruction, ambiguous guidance, wrong example, missing example, edge case not covered)
   - **How you recovered**: what you did to fix it
   - **Preventable?**: yes/no -- could a skill file update have prevented this?

## Phase 2: Analyze performance

After the inner command completes (successfully or not), review the tracking log.

1. Separate incidents into two categories:
   - **Skill gaps**: issues that a documentation update could prevent. These are the actionable ones.
   - **Environment issues**: IRIS bugs, network errors, permission problems. Not skill gaps -- do not update docs for these.
2. For each skill gap, identify the specific file and section that should be updated:
   - SKILL.md gotchas section -- for new pitfalls discovered
   - SKILL.md conventions -- for behavioral rules that were unclear
   - Reference docs (e.g., `dtl/data-transformations.md`, `bpl/bpl-reference.md`) -- for domain-specific patterns
   - Command files (`.claude/commands/*.md`) -- for command-specific instructions that were missing or wrong
   - Templates -- for structural patterns that should be baked in
3. Classify each proposed update:
   - **New rule**: something not documented at all
   - **Clarification**: something documented but ambiguous
   - **Better example**: the rule exists but the example was misleading or missing
   - **Correction**: something documented incorrectly

## Phase 3: Present findings

Present a table summarizing the execution:

| Metric | Count |
|--------|-------|
| Errors encountered | N |
| Self-corrections | N |
| Retries | N |
| Schema lookups | N |
| Workarounds | N |
| Wrong assumptions | N |
| **Skill gaps found** | **N** |

Then for each proposed skill update, present:

```
### Gap N: <short description>

**Incident**: <what happened>
**Root cause**: <why>
**File**: <which file to update>
**Section**: <which section>
**Type**: New rule | Clarification | Better example | Correction
**Proposed change**: <the specific text to add or modify>
```

## Phase 4: Apply updates

Ask the user: "Apply these N skill updates?"

If confirmed:
1. Read each target file.
2. Apply the proposed changes using the Edit tool.
3. Sync updated files to the backup directory at `.claude/skills/skills-editor/skills-backup/` so the skills editor does not flag them as modified.
4. Report what was updated.

If declined, report the findings without making changes. The user may choose to apply selectively.

## Guidelines

- **Be honest about your own mistakes.** The value of this command comes from candid self-assessment, not from minimizing errors.
- **Only propose changes that would help a fresh agent.** If the issue required context that only you had from this conversation, it is not a skill gap.
- **Targeted fixes beat general guidance.** "Be careful with X" is useless. "When X, always do Y because Z" is actionable.
- **Examples are more powerful than rules.** If adding a rule, include a concrete RIGHT/WRONG example.
- **Do not propose changes for one-off issues** that are unlikely to recur.
- **Do not dilute existing documentation** with low-value additions. Every line in a skill file costs context tokens. Only add what earns its keep.
