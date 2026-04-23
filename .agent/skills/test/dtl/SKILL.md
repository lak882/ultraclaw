---
name: test-dtl
description: Test a DTL transform in-memory with no production involvement. Use to verify a DTL before pushing or to debug an unexpected transform output. Returns segment-level diff and full transformed message. Triggers on "test DTL", "verify transform", "DTL diff".
---

# test/dtl

In-memory DTL testing. No production, no HTTP, no message queue. The transform runs synchronously and returns its output.

## Tool reference

| Goal | How |
|---|---|
| Run a DTL Transform (HL7 in, HL7 out) | `exec:` `Set msg = ##class(EnsLib.HL7.Message).ImportFromString(hl7In) Set sc = ##class(MyDtl).Transform(msg, .out) Set %result = out.OutputToString()` |
| Simple Transform for string-based DTLs | `exec:` `Set sc = ##class(MyDtl).Transform(input, .out) Set %result = out` |
| Segment-level diff | `exec:` `Set %result = ##class(InterClaw.Script.Production.Test.DTL).Execute("{""dtl"":""MyDtl"",""input"":""MSH|...""}")` |

## Input-format helpers

- HL7 v2 raw text (`MSH|^~\&|...`): use `EnsLib.HL7.Message.ImportFromString`.
- `Ens.StringRequest`: construct with `##class(Ens.StringRequest).%New()` and set `StringValue`.
- Custom request classes: instantiate and populate required properties before passing.

## Gotchas

- Ensure CRLF line endings are stripped or converted to CR before `ImportFromString`. IRIS HL7 parsing is strict: `$Replace(msg, $Char(13,10), $Char(13))` then `$Replace(msg, $Char(10), $Char(13))`.
- `Transform` is a ClassMethod. It does NOT need a production running.
- A DTL with `Untyped="true"` requires raw-string inputs; typed DTLs require the declared `%Class` from the DTL's `<transform>` element.
- Errors returned as `%Status`; unwrap with `$System.Status.GetErrorText(sc)`.

## See also

- `dtl/SKILL.md` — authoring
- `manage-production/SKILL.md` — reloading production config after a DTL change
