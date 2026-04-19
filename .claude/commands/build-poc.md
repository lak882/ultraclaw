Build an InterSystems Health Connect Proof of Concept from a requirements document.

Usage: /build-poc <path-to-file> [package-name] [namespace]

Accepts .md, .docx, and .pdf files. Non-markdown files are automatically converted.

---

## Phase 0: Convert input file if needed

- **`.md`** — Use directly.
- **`.docx`** — Convert with `docx_to_md.py`.
- **`.pdf`** — Read with Read tool, save as markdown.

## Phase 1: Parse exercises

Read the converted markdown and split it into discrete exercises/use cases. For each exercise, extract a natural language description covering: inbound transport, message types, transformations, routing logic, outbound destinations, lookup tables, and test scenarios.

**Single Production**: All exercises share ONE production class (`<Pkg>.Production`). Use the `Category` attribute on each `<Item>` to group hosts by exercise (e.g., `Category="Build 1 - VXU to ASIIS"`, `Category="Build 2 - ORM to Rad Ltd"`).

If custom Z-segments are needed for any exercise: create .HL7 schema file, push via Atelier API. Use tilde-wrapped syntax (`[~PD1~]` not `[PD1]`). DTL DocType must reference the structure name, not message type name. Do this before delegating to `/production`.

## Phase 2: Build each exercise via /production

For exercise 1: invoke `/production` with the exercise description. This creates `<Pkg>.Production` and all components for that exercise.

For exercises 2+: invoke `/production update` with the exercise description and specify `Category="Build N - <title>"`. This adds components to the existing production.

Each `/production` call handles its own schema fetching, DTL/rule/BPL creation (with parallel agents), test message generation, and compilation. Do NOT duplicate those instructions here — `/production` owns the build logic.

**BPL mandate**: All orchestration processes MUST be BPL (`Ens.BusinessProcessBPL`), not code-based BP. This is enforced by `/production` — do not override it.

## Phase 3: Final integration test

After all exercises are built:
1. Start production with `manage_production.py --start <Pkg>.Production --stop-first`
2. Send test messages for ALL exercises (file drop or `send_hl7.py`)
3. Check traces for each exercise — verify routing, confirm no errors in event log
4. Report results per exercise
