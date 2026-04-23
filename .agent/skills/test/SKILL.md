---
name: test
description: Index skill for testing workflows. Use for DTL testing and production testing. Triggers on "test DTL", "verify transform", "test production", "run test".
---

# test

Parent skill that points at sub-skills for specific test workflows.

## Sub-skills

| Target | When to load |
|---|---|
| `test/dtl` | Testing a DTL transform in-memory, segment-level diff, before/after inspection |
| `test/production` | (deferred — created in a follow-up session) End-to-end production tests via HL7 send and trace verification |

Load a sub-skill via `read_file` with the absolute path to its `SKILL.md`:

- `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/test/dtl/SKILL.md`
