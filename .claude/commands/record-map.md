Create or update a Record Map (delimited or fixed-width file parser).

Usage: /record-map <description>

The description should specify the file format (delimited vs fixed-width), field layout, and the record class name. See the `interclaw/data/record-maps.md` reference for the full authoring rules.

Steps:

1. **Read the reference**: call read_skill_file on `.claude/skills/interclaw/data/record-maps.md` before writing the class. The reference covers delimited vs fixed-width syntax, separator escapes, encoding, batch headers/trailers, and the auto-generated service/operation pairing.

2. **Generate the Record Map class** extending `EnsLib.RecordMap.RecordMap`. Save to `src/<Namespace>/<Pkg>/RecordMap/<ClassName>.cls`.
   - Pick the right `type`: `delimited` for CSV/TSV/pipe-separated, `fixed` for positional fields.
   - Set `char_encoding` (default `UTF-8`) and `recordTerminator` (usually `\x0d\x0a`).
   - For delimited maps: declare `<Separators>` in order (outer to inner).
   - For fixed-width maps: each `<Field>` needs a `position` and `size`.
   - Give every `<Field>` a name + `datatype` (%String, %Date, %Integer, etc.).
   - Mark required fields with `required="1"`.

3. **Push and compile**. Use put_class with the target class name; IRIS will auto-generate the persistent record class and the service/operation helpers alongside it.

4. **Test the generated map.** Call `test_record_map` with `direction=parse` and a sample line that exercises every declared field. This verifies (a) the auto-generated `<ClassName>.Record` class was actually created (RecordMap XML can silently fail to generate the helper class even when the container compiles), and (b) each field lands in the right property. Report the parsed JSON to the user so they can confirm MRN, DOB, etc. landed where expected. If the user gave test data upfront, use it; otherwise synthesize a realistic line matching the schema and note that it's synthetic. If the user asked for a round-trip check, also call `test_record_map` with `direction=compose` on the parsed record.

5. **Wire into a production** only if the user asked for it. Default hosts:
   - Read side: `EnsLib.RecordMap.Service.FileService` (with `RecordMap` setting pointing at your map class)
   - Write side: `EnsLib.RecordMap.Operation.FileOperation`
   - For multi-record files with headers/trailers: use the `BatchFileService`/`BatchFileOperation` variants.

6. **Do not guess** — if the user's description leaves field types or positions ambiguous, ask one clarifying question before generating.
