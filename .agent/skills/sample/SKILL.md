---
name: sample
description: Index skill for generating sample messages. Use to build realistic test HL7 (and later other formats) for DTL/rule testing, production smoke tests, and user demos. Triggers on "sample message", "generate HL7", "test message", "example HL7".
---

# sample

Parent skill that points at sub-skills for generating sample messages.

## Sub-skills

| Target | When to load |
|---|---|
| `sample/hl7` | Generate a sample HL7 v2 message from a schema: `ADT_A01`, `ORU_R01`, etc. |

Load a sub-skill via `read_file` with the absolute path to its `SKILL.md`:

- `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/sample/hl7/SKILL.md`
