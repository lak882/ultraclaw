Create or update an HL7 Data Transformation (DTL).

Usage: /dtl [--test-message <filepath>] <description>

The description should specify source/target message types, field mappings, lookup tables, and functions. See the interclaw-dtl skill for authoring rules and gotchas.

Steps:

1. **Fetch the HL7 schema** for source and target message types. Read the output — note segment paths, field positions, subcomponents, and repeating groups.
   - **Check for nested same-name groups.** Scan the schema structure output for any group that contains a child group with the same name (e.g., `PIDgrp > PIDgrp` in ORU_R01). When found, the OUTER group path must use the doubled name (e.g., `PIDgrpgrp`). See `data-transformations.md` "Nested Same-Name Groups" for the full rule. Getting this wrong causes silent failures where foreach loops iterate zero times.

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
   - **Zero-diff red flag.** If the diff reports "no differences" but the DTL contains `<foreach>`, `<if>`, or `<assign>` elements that should have modified the output, treat this as a path resolution failure, not a passing test. Re-examine group paths against the schema structure before proceeding.
