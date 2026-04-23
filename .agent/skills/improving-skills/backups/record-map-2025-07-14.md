---
name: record-map
description: Parse and create fixed-width or delimited flat files in IRIS Interoperability. Use when building CSV, TSV, pipe-separated, or fixed-width file integrations, when authoring a `EnsLib.RecordMap.RecordMap` subclass, or when wiring RecordMap services/operations into a production. Triggers on "record map", "CSV", "flat file", "fixed-width", "file parser", "delimited file".
---

# record-map

Create and maintain RecordMap classes that parse and emit flat files (CSV, TSV, fixed-width). A RecordMap class describes the file layout; IRIS generates a persistent target class with one property per field, plus `GetObject` / `PutObject` helpers for round-tripping.

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
| Force target-class generation | `exec:` `Set tSC = ##class(EnsLib.RecordMap.Generator).GenerateObject("MyApp.RecordMap.Foo", .tTarget) Set %result = $System.Status.GetErrorText(tSC)` |
| Inspect generated target class | `read_class` ? pass the `targetClassname` value |

## Key gotchas

- `<Record name="...">` is the record-map class, NOT the generated target. Always set `targetClassname="..."` to a distinct class; otherwise IRIS aborts generation with `ERROR #5768` or silently skips property creation.
- `type="delimited"` uses `<Separators>`; `type="fixedwidth"` uses `width="N"` per field.
- `recordTerminator` is usually `\x0d\x0a` (CRLF) for Windows-origin files, `\x0a` (LF) for Unix-origin.
- For batch files with headers/trailers, use `BatchFileService` / `BatchFileOperation` variants, and IRIS sends a `EnsLib.RecordMap.BatchRequest` carrying all records.

## Authoring checklist

1. Load `references/authoring.md` via `read_file` for the full reference (class hierarchy, all attributes, production wiring patterns, gotchas).
2. Pick the right `type` based on the file format: `delimited` for CSV/TSV/pipe-separated, `fixedwidth` for positional.
3. Set `name` to the record-map classname you're creating and `targetClassname` to a distinct persistent class.
4. Set `char_encoding` and `recordTerminator` per the source system's conventions.
5. Declare every `<Field>` with a `name`, `datatype`, and either a `<Separator>` or `width`.
6. Mark required fields with `required="1"`; add `index="1"` where you'll query by that field.
7. Push with `create_class` / `write_class`.
8. If wiring into a production, set `RecordMap` on the service or operation `Host` settings (see `references/authoring.md`).

## References

| Asset | When to load |
|---|---|
| `references/authoring.md` | Full RecordMap reference ? class hierarchy, field and record attributes, delimited and fixed-width examples, generation gotchas, production wiring (File/FTP service and operation, Batch variants), HealthShare patterns. Load whenever you touch a RecordMap. |

Load via `read_file` at `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/record-map/references/authoring.md`.

## HealthShare use case

Common pattern: receive CSV/flat files from facilities, parse via RecordMap, transform to SDA3 or HL7, push to the Hub.

```
[CSV File Drop] -> [RecordMap Service] -> [Transform Process (RecordMap -> HL7/SDA3)] -> [Hub Operation]
```
