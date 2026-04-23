---
name: test
description: Testing workflows for IRIS Interoperability components. Covers in-memory DTL testing via `Transform`, segment-level diff, and (future) end-to-end production testing via HL7 send and trace verification. Triggers on "test DTL", "verify transform", "DTL diff", "test production", "run test", "check transform output".
tools: [xecute, read_class]
---

# test

Testing workflows for IRIS Interoperability components.

## When to use

- Verifying a DTL transforms HL7 correctly, before pushing it.
- Debugging an unexpected transform output via segment-level diff.
- (Future) End-to-end production smoke tests via HL7 send and trace verification.

## References

Load these via `read_file` on their absolute paths:

| Asset | When to load |
|---|---|
| `references/dtl.md` | Testing a DTL transform in-memory with `Transform`. Input-format helpers for HL7 v2 raw text, `Ens.StringRequest`, custom request classes. Segment-level diff via `InterClaw.Script.Production.Test.DTL`. Gotchas around line endings, `Untyped="true"`, `%Status` unwrapping. |

Base path: `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/test/references/`.

## See also

- `dtl/SKILL.md` — authoring DTLs (load first if you're writing one)
- `manage-production/SKILL.md` — reloading production config after DTL changes
- `sample/SKILL.md` — generating realistic HL7 test messages
