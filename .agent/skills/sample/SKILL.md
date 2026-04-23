---
name: sample
description: Generate realistic sample messages for testing and demos. Currently covers HL7 v2 messages (ADT, ORU, ORC-based orders). Use to build test messages for DTLs, routing rules, or production smoke tests. Outputs pipe-delimited v2 text. Triggers on "sample message", "sample HL7", "generate HL7", "generate ADT", "generate ORU", "example HL7 message", "test message", "realistic HL7".
---

# sample

Generate realistic sample messages for testing and demos.

## When to use

- Need a syntactically-correct HL7 v2 message for a DTL or routing-rule smoke test.
- Building a fixture for a batch test suite.
- Demonstrating a production flow to a user who needs input to paste.

## References

Load these via `read_file` on their absolute paths:

| Asset | When to load |
|---|---|
| `references/hl7.md` | HL7 v2 sample generation: schema-pulling one-liners, MSH template, segment patterns for PID/PV1/ORC/OBR/OBX, CR-delimited emission rules, minimum-viable ADT_A01 and ORU_R01 bodies, custom Z-structure handling. |

Base path: `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/sample/references/`.

## See also

- `dtl/SKILL.md` — authoring DTLs that consume these samples
- `rule/SKILL.md` — authoring routing rules that match these samples
- `test/SKILL.md` — testing workflows that use these samples
