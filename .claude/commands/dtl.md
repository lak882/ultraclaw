Create or update an HL7 Data Transformation (DTL).

Usage: /dtl [--test-message <filepath>] <description>

The description should specify source/target message types, field mappings, lookup tables, and functions. See CLAUDE.md "DTL Authoring" gotchas for authoring rules.

Steps:

1. **Fetch the HL7 schema** for source and target message types. Read the output — note segment paths, field positions, subcomponents, and repeating groups.

2. **Generate the DTL class** fulfilling the user's requirements. Save to `src/<Namespace>/<Pkg>/DTL/<ClassName>.cls`.
   - `create='copy'` when all fields pass through with selective modifications
   - `create='new'` for segment filtering or cross-type transforms (HL7→SDA3)
   - Use `foreach` for segments inside repeating groups (e.g., `ORCgrp()`)
   - **Iterator keys:** Use k1, k2, k3 to indicate nesting level. Sequential (non-nested) loops reuse k1; nested loops must use distinct keys
   - Use **named field paths** (e.g., `OBR:UniversalServiceIdentifier.Identifier`) not numeric (`OBR:4.1`)
   - Use `..Lookup("TableName", source.{path})` for lookup table mappings
   - After concatenating OBX values into NTE, remove source OBX with `action='remove'`
   - Never use ObjectScript `<code>` blocks — for complex logic, create a custom utility function class extending `Ens.Rule.FunctionSet`

3. **Push, compile, and test.** If `--test-message` was given, use that file; otherwise generate a sample. Always use `--diff`.
