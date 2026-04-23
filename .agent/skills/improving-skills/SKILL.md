---
name: improving-skills
description: Use when a skill repeatedly fails to trigger correctly, provides ineffective guidance, or needs updating after workflow changes
tools: [read_file, write_file, create_file, delete_file]
---

# Improving Skills

## Overview

Skills are code that shapes behavior, not documentation. When a skill fails, apply systematic observation, evidence-backed modification, adversarial testing, and rollback safety.

**Core principle:** Every modification requires proof of improvement. No change ships without before-and-after evidence.

## When to Use

**Always:**
- Skill repeatedly fails to trigger when it should
- Skill triggers but provides vague or ineffective guidance
- Skill conflicts with other instructions
- Workflow changes make skill guidance stale

**Never:**
- Single anecdotal failure without pattern
- Theoretical improvement without observed problem
- User preference contradicts documented best practice without evidence

## The Iron Law

```
NO SKILL MODIFICATION WITHOUT OBSERVED FAILURE EVIDENCE
```

Modify without evidence? Stop. Document the failure pattern first.

## File Access Tools

Skills live on the filesystem at `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/`. Use ULTRACLAW tools to read and modify them.

| Tool | Purpose | Example |
|------|---------|---------|
| `read_file` | Read skill content | `read_file(path: ".agent/skills/dtl/SKILL.md")` |
| `write_file` | Overwrite skill (update) | `write_file(path: ".agent/skills/dtl/SKILL.md", content: "...")` |
| `create_file` | Create new skill file | `create_file(path: ".agent/skills/new/SKILL.md", content: "...")` |
| `delete_file` | Delete skill file | `delete_file(path: ".agent/skills/old/SKILL.md")` |

**Install directory base:** `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw`

Skill paths are relative to install directory: `.agent/skills/<name>/SKILL.md`

Reference paths are relative to install directory: `.agent/skills/<name>/references/<file>.md`

## Observation-Analysis-Modify-Test-Evaluate

### OBSERVE - Document Failure Pattern

Search recent sessions where the skill should have triggered or was explicitly invoked. Document at least three instances of the same failure mode.

**Create observation file:**
```
create_file(
  path: ".agent/skills/improving-skills/observations/dtl-2026-04-23.md",
  content: """
## Observation: dtl skill - 2026-04-23

**Pattern:** Agent skips schema fetch in 4 out of 6 recent DTL creation turns

**Evidence:**
- Session abc123, turn 14: Jumped to writing DTL XML without schema
- Session def456, turn 8: User said "create DTL", agent wrote transform immediately
- Session ghi789, turn 22: Agent pulled schema only after DTL compilation failed

**Failure mode:** Schema guidance appears mid-file, easy to skim past

**Impact:** Generated DTLs use wrong field paths, fail testing
"""
)
```

**Requirements:**
- Three or more instances of same failure
- Specific session IDs or turn numbers
- Quantified impact (X out of Y turns)

### ANALYZE - Root Cause

| Failure Mode | Root Cause | Solution Pattern |
|--------------|------------|------------------|
| Skill fails to trigger | Description too narrow | Broaden trigger keywords |
| Skill triggers, guidance ignored | Vague or buried mid-file | Add examples, move to top |
| Skill conflicts with other guidance | Contradictory instructions | Clarify priority |
| Skill references stale paths/tools | Workflow changed | Update references |
| Agent rationalizes around skill | Guidance allows interpretation | Tighten language, add Red Flags |

### MODIFY - Minimal Change with Backup

**Before modifying:**

1. **Backup current version**
```
read_file(path: ".agent/skills/dtl/SKILL.md")  # Read current content
create_file(
  path: ".agent/skills/improving-skills/backups/dtl-2026-04-23.md",
  content: <current-content>
)
```

2. **Document hypothesis**
```
write_file(
  path: ".agent/skills/improving-skills/observations/dtl-2026-04-23.md",
  content: """
## Modification Hypothesis

Moving schema requirement from line 47 to line 3 with MANDATORY heading will increase compliance from 33% to >90%

**Rationale:** Agent reads skill top-to-bottom, sees DTL structure guidance first, begins implementation before reaching schema section.
"""
)
```

3. **Make ONE change**
```
write_file(
  path: ".agent/skills/dtl/SKILL.md",
  content: <modified-content>
)
```

**Modification principles:**
- One change per iteration
- Preserve working sections unchanged
- Add concrete examples if guidance is abstract
- Increase prominence for critical guidance

### TEST - Adversarial Scenarios

Create test scenarios designed to stress the modification. Run in fresh sessions.

**Test types:**

1. **Positive case:** Skill should trigger and provide correct guidance
2. **Negative case:** Skill should NOT trigger (verify no false positives)
3. **Edge case:** Boundary condition where guidance is ambiguous
4. **Conflict test:** Scenario where skill might contradict other guidance
5. **Rationalization test:** Scenario where agent might work around constraint

**Document test scenarios:**
```
create_file(
  path: ".agent/skills/improving-skills/tests/dtl-tests.md",
  content: """
## Test Suite: dtl skill

### Positive Case
**Scenario:** User says "create a DTL from ADT_A01 to custom schema"
**Expected:** Agent reads schema before writing DTL XML
**Result:** [Run in fresh session]

### Rationalization Test
**Scenario:** User says "quick DTL for simple field copy, just PID-3 to PID-3"
**Expected:** Agent still reads schema (might reveal nested groups)
**Result:** [Run in fresh session]
"""
)
```

### EVALUATE - Before/After Evidence

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Trigger rate (relevant sessions) | 33% (2/6) | ? (run tests) | ? |
| False positive rate | 0% (0/6) | ? (run tests) | ? |
| Compliance rate (follows guidance after trigger) | 50% (1/2) | ? (run tests) | ? |
| Unexpected side effects | N/A | ? (observe) | ? |

**Decision:** Commit change if improved, rollback if degraded

### COMMIT or ROLLBACK

**Commit if:**
- Trigger rate improved
- No false positives introduced
- No unexpected side effects

```
# Document in changelog
write_file(
  path: ".agent/skills/improving-skills/changelog.md",
  content: <append-entry>
)

# Delete backup
delete_file(path: ".agent/skills/improving-skills/backups/dtl-2026-04-23.md")
```

**Rollback if:**
- No improvement or degradation
- False positives introduced
- Side effects break other workflows

```
# Restore backup
read_file(path: ".agent/skills/improving-skills/backups/dtl-2026-04-23.md")
write_file(path: ".agent/skills/dtl/SKILL.md", content: <backup-content>)

# Document failure
write_file(
  path: ".agent/skills/improving-skills/changelog.md",
  content: <append-rollback-entry>
)
```

## Red Flags - STOP

These thoughts mean rationalization:

| Thought | Reality |
|---------|---------|
| "This skill could be better" | Could ≠ evidence. Document failures first. |
| "I saw it fail once" | One instance ≠ pattern. Observe more. |
| "Theoretical improvement" | Theory ≠ proof. Test before shipping. |
| "User prefers different style" | Style ≠ effectiveness. Measure outcomes. |
| "Skill is outdated" | Outdated how? Show stale references. |
| "Make it clearer" | Clearer to whom? Test comprehension. |
| "Small change, low risk" | Low risk ≠ no risk. Backup and test. |

## Verification Checklist

Before committing modification:

- [ ] Documented 3+ instances of same failure mode
- [ ] Verified pattern exists (not isolated incidents)
- [ ] Identified specific root cause
- [ ] Created backup of current version
- [ ] Documented hypothesis with measurable prediction
- [ ] Made ONE minimal change
- [ ] Created 3+ adversarial test scenarios
- [ ] Ran tests in fresh sessions
- [ ] Measured before/after metrics
- [ ] No unexpected side effects observed
- [ ] Results support hypothesis

Can't check all boxes? Don't commit.

## File Structure

```
.agent/skills/improving-skills/
├── SKILL.md              (this file)
├── changelog.md          (modification history)
├── observations/         (documented failure patterns)
│   └── [skill-name]-YYYY-MM-DD.md
├── backups/              (pre-modification copies)
│   └── [skill-name]-YYYY-MM-DD.md
└── tests/                (adversarial test scenarios)
    └── [skill-name]-tests.md
```

## Example: Full Cycle

**User report:** "The dtl skill keeps forgetting to pull schema first."

**OBSERVE**
```
read_file(path: ".agent/skills/dtl/SKILL.md")  # Read current skill

create_file(
  path: ".agent/skills/improving-skills/observations/dtl-2026-04-23.md",
  content: "Pattern: Skipped schema in 3/4 recent turns. Schema guidance at line 47, after structure guidance."
)
```

**ANALYZE**
Root cause: Schema section buried mid-file. Agent reads structure guidance first, begins implementation before reaching schema section.

Hypothesis: Moving schema to line 3 with MANDATORY heading increases compliance.

**MODIFY**
```
# Backup
read_file(path: ".agent/skills/dtl/SKILL.md")
create_file(path: ".agent/skills/improving-skills/backups/dtl-2026-04-23.md", content: <current>)

# Modify
write_file(
  path: ".agent/skills/dtl/SKILL.md",
  content: """
---
name: dtl
description: ...
---

# dtl

## MANDATORY FIRST STEP: Pull Schema

Before writing any DTL, read the HL7 schema:

<schema-pull-instructions>

**Why:** Field paths like PIDgrpgrp(1).PIDgrp... are not predictable. Wrong paths = zero-diff test results.

<rest-of-skill>
"""
)
```

**TEST**
```
create_file(
  path: ".agent/skills/improving-skills/tests/dtl-tests.md",
  content: """
### Positive Case
Scenario: "create a DTL from ADT_A01 to custom schema"
Expected: Agent reads schema before writing DTL
Result: [Run in fresh session]

### Rationalization Test
Scenario: "quick DTL for simple field copy"
Expected: Agent still reads schema
Result: [Run in fresh session]
"""
)
```

Run tests, measure compliance rate.

**EVALUATE**

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Compliance | 25% (1/4) | 100% (4/4) | +75% |
| False positives | 0% | 0% | None |

**COMMIT**
```
write_file(
  path: ".agent/skills/improving-skills/changelog.md",
  content: <append>"""
## dtl - 2026-04-23

**Modification:** Moved schema requirement to top with MANDATORY heading

**Evidence:** Compliance 25% → 100% across 4 test sessions

**Outcome:** Committed
"""
)

delete_file(path: ".agent/skills/improving-skills/backups/dtl-2026-04-23.md")
```

## Final Rule

```
Skill modification → observed pattern + evidence + testing
Otherwise → not improvement
```

No exceptions without your human partner's permission.
