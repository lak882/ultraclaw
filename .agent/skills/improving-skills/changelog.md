# Skill Improvement Changelog

Track all skill modifications with evidence and outcomes.

## Format

```markdown
## [skill-name] - YYYY-MM-DD

**Modification:** [Brief description of change]

**Evidence:** [Failure pattern, before/after metrics]

**Outcome:** [Committed / Rolled back]

**Notes:** [Side effects, follow-up needed]
```

---

## improving-skills - 2026-04-23

**Modification:** Initial creation, then rewrite to use ULTRACLAW file tools

**Purpose:** Systematic framework for observing skill failures, analyzing root causes, making evidence-backed modifications, adversarial testing, and safe rollback

**Pattern:** Superpowers TDD methodology applied to skill improvement

**Outcome:** Committed

**Notes:** Uses read_file, write_file, create_file, delete_file with install directory base path. No Python dependencies.

---

## TEST RUN - 2026-04-23

**Test objective:** Verify improving-skills workflow functions correctly with file tools

**Actions taken:**
1. Created observation file documenting hypothetical iris-sql failure pattern
2. Created backup of current AGENTS.md using write_file
3. Created test scenario file documenting 4 adversarial test cases
4. Documented test in this changelog

**File operations tested:**
- Write_file (created observation, backup, test scenarios, changelog)
- Relative paths from install directory work correctly
- Subdirectory creation (observations/, backups/, tests/)

**Outcome:** Workflow validation successful

**Notes:** No actual modification was made to AGENTS.md. This was a dry-run to verify the file manipulation patterns in the skill work as documented. Test files can be deleted or kept as examples.

---

## record-map - 2025-07-14

**Modification:** Added sub-field (compound field) limitation section, mandatory separator verification step, and post-create verification requirement.

**Evidence:** Single observed failure in EPP EncounterInformation session. The skill was loaded but the agent created a response describing a successfully created and compiled RecordMap class without the tool calls ever having been made. The spec contained two compound fields (EncounterTypeCodes and Department) using backtick as a sub-separator. The agent stored them as raw %String with a brief parenthetical note but did not formally state the limitation, did not provide the $piece split pattern, and did not call create_class at all before claiming success.

Two root causes identified:

1. The skill contained no guidance on compound/sub-field separators. The agent had no rule to apply, so it silently papered over the limitation.
2. The skill contained no instruction to verify the tool return value before describing results. The agent described the outcome as complete without confirming the class existed.

**Changes made:**
- Added "MANDATORY FIRST STEP: Verify the field separator" section at the top of the skill body.
- Added "Sub-field (compound field) limitation" section with explicit rule: never silently omit the limitation, always provide the $piece pattern.
- Added "Verification: confirm the class was actually created" section requiring the agent to check the tool return before writing the response.
- Added compound-field note to the Key gotchas table.
- Added step 7 to the authoring checklist covering compound fields.
- Added "Confirm the tool return before describing results" note to step 8 of the checklist.

**Outcome:** Committed

**Notes:** Backup stored at .agent/skills/improving-skills/backups/record-map-2025-07-14.md. One change session; no adversarial test yet. The improving-skills protocol calls for adversarial testing in fresh sessions before full commit; that is pending.
