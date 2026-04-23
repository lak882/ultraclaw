---
name: complex-record-map
description: Create and maintain Complex Record Maps in IRIS Interoperability. A Complex Record Map (`EnsLib.RecordMap.ComplexMap`) composes existing RecordMap classes into a hierarchical file structure with an optional header, a body of records and nested sequences, and an optional trailer. Use when a flat file contains multiple record types, per-record parent-child relationships, or repeating groups that cannot be expressed with a single RecordMap. Triggers on "complex record map", "ComplexMap", "ComplexBatch", "nested records", "header + body + trailer file", "multi-record-type file", "RecordSequence", "RecordReference".
tools: [read_class, create_class, write_class, run_sql, xecute]
---

# complex-record-map

Create and maintain Complex Record Map classes. A Complex Record Map describes a file whose records are of different types, organized into headers, trailers, and nested sequences. The Complex Record Map itself composes existing `RecordMap` classes; it does not redefine field layouts.

## When to use

- The file contains multiple record types distinguished by leading data (e.g. `PAT|...`, `ENC|...`, `OBX|...`).
- Records have parent-child or repeating-group relationships (e.g. one Patient followed by N Encounters, each Encounter followed by N Locations).
- The file has an optional header or trailer record.
- You need a single generated message class that wraps all the sub-records together.

For a simple single-record-type file (CSV patient list, fixed-width transaction log), use the plain `record-map` skill instead.

## Prerequisites

Before authoring a ComplexMap, you must already have:

1. One `EnsLib.RecordMap.RecordMap` class per distinct record type in the file (e.g. one for `PAT|`, one for `ENC|`, etc.).
2. Each of those RecordMap classes must set `RecordInComplexMap = 1` and declare a `LeadingData` value matching its record-type tag (e.g. `LeadingData="PAT|"`). Without these, the ComplexMap parser cannot dispatch records to the right RecordMap.

The `record-map` skill covers authoring those prerequisite RecordMaps.

## Tool reference

| Goal | How |
|---|---|
| Read an existing ComplexMap | `read_class` — pass `classname` |
| Create a new ComplexMap | `create_class` — pass full UDL body; compiles by default |
| Update an existing ComplexMap | `write_class` — pass full UDL body |
| Generate the batch target class (required after compile) | `exec:` `Set sc = ##class(EnsLib.RecordMap.ComplexGenerator).Generate("Pkg.Foo.ComplexMap") Set %result = $System.Status.GetErrorText(sc)` |
| Inspect the generated batch class | `read_class` — pass the `BATCHCLASS` parameter value |
| Verify generated batch has properties | `run_sql`: `SELECT Name, Type, Collection FROM %Dictionary.CompiledProperty WHERE parent = 'Pkg.Foo.ComplexMapBatch' AND Name NOT %STARTSWITH '%' ORDER BY SequenceNumber` |

## Key gotchas

- Compiling the ComplexMap class alone does NOT generate the batch target class. You must call `EnsLib.RecordMap.ComplexGenerator.Generate("ClassName")` after compile, or the batch class will not exist and routing rules referencing it will fail.
- Each referenced `RecordMap` must set `RecordInComplexMap = 1` and `LeadingData="TAG|"`. Without both, the ComplexMap parser cannot identify which records belong to which type.
- Header and trailer records cannot repeat. If your file's repeating structure spans the whole body (common), put a top-level `<RecordSequence repeating="1">` as the only element of the outer sequence.
- `BATCHCLASS` parameter names the generated batch class and must differ from the ComplexMap class name.
- `targetClassname` on the `<ComplexBatch>` XML element must match `BATCHCLASS`. Mismatches compile silently and then fail at generation.
- `char_encoding` on the ComplexMap overrides whatever encoding each referenced RecordMap declared. Keep them consistent.
- Mixing delimited and fixed-width records in one ComplexMap is supported but discouraged; make all referenced RecordMaps the same family.

## Authoring checklist

1. Load `references/authoring.md` for the full reference.
2. Create or verify every sub-RecordMap exists. Each must set `RecordInComplexMap = 1` and a unique `LeadingData`.
3. Decide the hierarchy: flat list of records, or nested `RecordSequence` groups?
4. Write the ComplexMap class extending `EnsLib.RecordMap.ComplexMap` with:
   - `Parameter BATCHCLASS = "Pkg.Foo.ComplexMapBatch"` (distinct from the ComplexMap class name)
   - `Parameter RECORDMAPGENERATED = 1`
   - `XData ComplexBatch` block with namespace `http://www.intersystems.com/Ensemble/RecordMap`
   - `<ComplexBatch>` root, with `name`, `char_encoding`, `targetClassname` matching `BATCHCLASS`
   - Optional `<Header>` child, body `<RecordReference>` and `<RecordSequence>` children, optional `<Trailer>`
5. Push with `create_class` / `write_class`.
6. Generate the batch: `exec:` `Set sc = ##class(EnsLib.RecordMap.ComplexGenerator).Generate("Pkg.Foo.ComplexMap") Set %result = $System.Status.GetErrorText(sc)`.
7. Verify the batch class got properties with the SQL above.
8. Wire into a production: `EnsLib.RecordMap.ComplexMap.FileService` (inbound) or `EnsLib.RecordMap.ComplexMap.FileOperation` (outbound), with the ComplexMap class name on the `ComplexMap` host setting.

## References

| Asset | When to load |
|---|---|
| `references/authoring.md` | Full ComplexMap reference: file-structure contract (header/body/trailer), XData schema (`<ComplexBatch>`, `<RecordReference>`, `<RecordSequence>`, `<Header>`, `<Trailer>`), generation workflow, production wiring, a real-world hybrid-hierarchy example from a clinical MPI, gotchas around `RecordInComplexMap` and `BATCHCLASS`/`targetClassname` alignment. |

Load via `read_file` at `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/complex-record-map/references/authoring.md`.

## Examples

| Asset | Purpose |
|---|---|
| `examples/patient-encounters.md` | Concrete minimum-viable ComplexMap: header + repeating Patient-group + trailer. Shows sub-RecordMap setup, `Generate` call, production wiring. Load for a worked example. |

Load via `read_file` at `/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.agent/skills/complex-record-map/examples/<name>.md`.

## See also

- `record-map/SKILL.md` — authoring the individual RecordMap classes that a ComplexMap composes
- `production/SKILL.md` — wiring File/FTP services and operations that consume a ComplexMap
- `sample/SKILL.md` — building sample input files for ComplexMap testing
