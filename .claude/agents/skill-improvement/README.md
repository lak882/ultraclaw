# Skill Improvement Agent

Self-mutating skill improvement harness that observes effectiveness and iteratively refines guidance based on real-world usage.

## Structure

```
.claude/agents/skill-improvement/
├── skill.md              Main agent definition and methodology
├── changelog.md          History of all skill modifications
├── README.md             This file
├── observations/         Documented failure modes
├── backups/              Pre-modification skill copies
└── tests/                Adversarial test scenarios
```

## Quick Start

Invoke this agent when:
- A skill repeatedly fails to trigger when it should
- A skill triggers but provides ineffective guidance
- You want to analyze skill health across recent sessions
- You need to update skills after workflow changes

**Example invocations:**
```
"Analyze the /dtl skill and suggest improvements"
"The /trace command keeps skipping the production check. Improve it."
"Health check all production management skills"
"Roll back the /push skill to yesterday"
```

## What This Agent Needs to Function

1. **Session transcript access** - Read conversation history to observe skill behavior
2. **Write permissions** - Modify skill files in `.claude/skills/` and `.claude/commands/`
3. **Testing capability** - Run scenarios with modified skills to validate improvements
4. **Observability hooks** - Ideally see which skills triggered and how guidance was used
5. **Rollback safety** - Timestamped backups before any modification

## Methodology

1. **Observe** - Read skill, find recent invocations, document failure patterns
2. **Analyze** - Identify root cause (trigger too narrow, guidance vague, conflicting instructions)
3. **Modify** - Make minimal, evidence-backed change with clear hypothesis
4. **Test** - Run adversarial scenarios (positive case, edge case, rationalization test)
5. **Evaluate** - Compare before/after, measure improvement or degradation
6. **Commit or rollback** - Keep if improved, restore backup if degraded

## Commands

- `analyze [skill-name]` - Document current effectiveness
- `improve [skill-name]` - Full improvement cycle
- `test [skill-name]` - Run test suite
- `rollback [skill-name]` - Restore backup
- `diff [skill-name]` - Compare versions
- `history [skill-name]` - Show changelog
- `health-check` - Batch analyze all skills

## Integration with Superpowers

This agent applies superpowers quality standards:
- Skills are code that shapes behavior, not prose
- Modifications require before/after evaluation evidence
- Adversarial pressure testing is mandatory
- Changes ship only with proof of improvement
- 94% rejection rate mentality: most proposed changes are not justified

## Self-Referential

This agent can improve itself. If its own guidance becomes stale or ineffective, invoke it on `skill.md`.
