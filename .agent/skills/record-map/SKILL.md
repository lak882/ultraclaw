---
name: record-map
description: Parse and create fixed-width or delimited flat files in IRIS Interoperability. Use when building CSV, TSV, pipe-separated, or fixed-width file integrations, when authoring a `EnsLib.RecordMap.RecordMap` subclass, or when wiring RecordMap services/operations into a production. Triggers on "record map", "CSV", "flat file", "fixed-width", "file parser", "delimited file".
tools: [read_class, create_class, write_class, run_sql, xecute]
---

# record-map

Create and maintain RecordMap classes that parse and emit flat files (CSV, TSV, fixed-width). A RecordMap class describes the file layout; IRIS generates a persistent target class with one property per field, plus `GetObject` / `PutObject` helpers for round-tripping.

## MANDATORY FIRST STEP: Verify the field separator and check for separator collision

Before writing any RecordMap UDL, do both of the following:

1. Identify the field-level separator from the spec.
2. Check every compound field in the spec. If the sub-delimiter used inside any compound field is the SAME character as the record-level separator you have chosen, raise this conflict with the user before proceeding. A collision means RecordMap will split the compound field on every sub-delimiter token, producing truncated and incorrect field values at read time. Either choose a different record separator, or document clearly that the compound fields cannot be round-tripped correctly through this RecordMap.

If the spec describes fields that are compound but uses a different character for sub-delimiting than the record separator, proceed normally and apply the sub-field guidance below.

## Sub-field (compound field) limitation

RecordMap parses one level of structure: it splits a record into fields using the declared `<Separator>`. It cannot parse a second separator within a field. If the spec describes compound fields using a secondary delimiter (backtick, pipe, caret, etc.), RecordMap stores the entire compound token as a raw `%String`.

**What to do when a spec contains compound fields:**

1. Declare the field as `datatype="%String"` in the RecordMap. Do not attempt to declare sub-fields inside RecordMap; that construct does not exist.
2. Tell the user explicitly that the compound field is stored raw and that downstream code must parse the sub-tokens. Provide the correct ObjectScript split pattern:
   ```objectscript
   Set tCode        = $piece(record.EncounterTypeCodes, "`", 1)
   Set tCodingOID   = $piece(record.EncounterTypeCodes, "`", 2)
   Set tSystemName  = $piece(record.EncounterTypeCodes, "`", 3)
   Set tDisplayName = $piece(record.EncounterTypeCodes, "`", 4)
   ```
3. Never silently omit the limitation. State it in the response so the user understands what RecordMap will and will not do with that field.

## When to use

- Authoring a new RecordMap class from a file-format spec.
- Editing an existing RecordMap to add or fix fields.
- Wiring a RecordMap into a production as a service (inbound) or operation (outbound).
- Debugging a RecordMap whose generated target class is empty or missing.

## Tool reference

| Goal | How |
|---|---|
| Read an existing RecordMap | `read_class` ? pass `classname` |
| Create a new RecordMap | `create_class` ? pass full UDL body; compiles by default |
| Update an existing RecordMap | `write_class` ? pass full UDL body |
| Force target-class generation | `xecute:` `Set tSC = ##class(EnsLib.RecordMap.Generator).GenerateObject("MyApp.RecordMap.Foo", .tTarget) Set %result = $System.Status.GetErrorText(tSC)` |
| Verify generated field count | `run_sql` ? see verification query below |
| Inspect generated target class | `read_class` ? pass the `targetClassname` value |

## Verification: confirm generation succeeded after every create or update

After every `create_class` or `write_class` call, perform all three of the following steps before declaring success:

**Step 1.** Check the tool return. If `compiled: false` or `errors` is non-empty, report the error and stop.

**Step 2.** Call `GenerateObject` explicitly and confirm a clean status:
```objectscript
Set tSC = ##class(EnsLib.RecordMap.Generator).GenerateObject("MyApp.RecordMap.Foo", .tTarget)
Set %result = $System.Status.GetErrorText(tSC)
```
An empty string means success. Any non-empty string is an error; report it.

**Step 3.** Query the generated target class to confirm the expected field count:
```sql
SELECT Name, Type FROM %Dictionary.CompiledProperty
WHERE parent = 'MyApp.Record.Foo'
AND Name NOT %STARTSWITH '%'
```
The row count must equal the number of fields declared in the RecordMap. If it is fewer, generation silently dropped fields; do not describe the class as ready.

Only after all three steps pass should you describe the RecordMap as ready.

## Key gotchas

- `<Record name="...">` is the record-map class, NOT the generated target. Always set `targetClassname="..."` to a distinct class; otherwise IRIS aborts generation with `ERROR #5768` or silently skips property creation.
- `type="delimited"` uses `<Separators>`; `type="fixedwidth"` uses `width="N"` per field.
- `recordTerminator` is usually `\x0d\x0a` (CRLF) for Windows-origin files, `\x0a` (LF) for Unix-origin.
- For batch files with headers/trailers, use `BatchFileService` / `BatchFileOperation` variants, and IRIS sends a `EnsLib.RecordMap.BatchRequest` carrying all records.
- Compound fields (secondary delimiters within a field) are stored as raw `%String`. See the sub-field limitation section above.
- Separator collision: if the spec's compound-field sub-delimiter is the same character as the record-level separator, RecordMap will misparse those fields at read time. Check for this before choosing a separator.

## Authoring checklist

1. Load `references/authoring.md` via `read_file` for the full reference (class hierarchy, all attributes, production wiring patterns, gotchas).
2. Pick the right `type` based on the file format: `delimited` for CSV/TSV/pipe-separated, `fixedwidth` for positional.
3. Set `name` to the record-map classname you're creating and `targetClassname` to a distinct persistent class.
4. Set `char_encoding` and `recordTerminator` per the source system's conventions.
5. Declare every `<Field>` with a `name`, `datatype`, and either a `<Separator>` or `width`.
6. Mark required fields with `required="1"`; add `index="1"` where you'll query by that field.
7. For any compound field (secondary delimiter within the field value), use `datatype="%String"` and document the `$piece` split pattern for downstream use.
8. Check for separator collision: if any compound field's sub-delimiter matches the record separator, raise the conflict before proceeding.
9. Push with `create_class` / `write_class`. Then run the three-step verification (GenerateObject + field-count SQL) before declaring success.
10. If wiring into a production, set `RecordMap` on the service or operation `Host` settings (see `references/authoring.md`).

## References

| Asset | When to load |
|---|---|
| `references/authoring.md` | Full RecordMap reference ? class hierarchy, field and record attributes, delimited and fixed-width examples, generation gotchas, production wiring (File/FTP service and operation, Batch variants), HealthShare patterns. Load whenever you touch a RecordMap. |

Load via `read_file` at `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/record-map/references/authoring.md`.

## Examples

| Asset | Purpose |
|---|---|
| `examples/csv-patient.md` | Concrete 10-field delimited CSV patient RecordMap with production wiring. Load for a worked example. |

Load via `read_file` at `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/record-map/examples/<name>.md`.

## HealthShare use case

Common pattern: receive CSV/flat files from facilities, parse via RecordMap, transform to SDA3 or HL7, push to the Hub.

```
[CSV File Drop] -> [RecordMap Service] -> [Transform Process (RecordMap -> HL7/SDA3)] -> [Hub Operation]
```
