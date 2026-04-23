# Improving Skills

Systematic skill improvement through observation, analysis, modification, testing, and rollback.

## Structure

```
.agent/skills/improving-skills/
├── SKILL.md              Main skill definition
├── changelog.md          Modification history
├── README.md             This file
├── observations/         Documented failure patterns
├── backups/              Pre-modification copies
└── tests/                Adversarial test scenarios
```

## When to Use

- Skill repeatedly fails to trigger when it should
- Skill triggers but provides ineffective guidance
- Skill conflicts with other instructions
- Workflow changes make skill guidance stale

## Methodology

1. **OBSERVE** - Document 3+ instances of same failure mode
2. **ANALYZE** - Identify specific root cause
3. **MODIFY** - Make minimal change with backup and hypothesis
4. **TEST** - Run adversarial scenarios in fresh sessions
5. **EVALUATE** - Measure before/after metrics
6. **COMMIT or ROLLBACK** - Keep if improved, restore if degraded

## Iron Law

```
NO SKILL MODIFICATION WITHOUT OBSERVED FAILURE EVIDENCE
```

Single anecdotal failure or theoretical improvement? Stop. Document pattern first.

## Red Flags

- "This skill could be better" (could ≠ evidence)
- "I saw it fail once" (one ≠ pattern)
- "Theoretical improvement" (theory ≠ proof)
- "Make it clearer" (clearer to whom?)
- "Small change, low risk" (still backup and test)

## Example

**User:** "The /dtl command keeps forgetting to pull schema first"

**Response:**
1. Read `.agent/commands/dtl.md`
2. Search sessions for `/dtl` invocations
3. Document: "Skipped schema in 4/6 turns, guidance buried at line 47"
4. Backup current version
5. Move schema requirement to line 3 with MANDATORY heading
6. Test: 5 scenarios including rationalization attempts
7. Measure: Compliance 33% → 100%
8. Commit and document in changelog

## Integration with Superpowers

Applies superpowers quality standards:
- Skills are code that shapes behavior
- Modifications require evidence
- Adversarial testing is mandatory
- No change without proof of improvement

## Verification Checklist

Before committing:
- [ ] 3+ failure instances documented
- [ ] Pattern verified (not isolated)
- [ ] Root cause identified
- [ ] Backup created
- [ ] Hypothesis documented
- [ ] ONE minimal change
- [ ] 3+ adversarial tests
- [ ] Fresh session testing
- [ ] Before/after metrics
- [ ] No side effects
