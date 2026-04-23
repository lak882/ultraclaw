## Observation: record-map skill - 2025-01-01

**Pattern:** Two confirmed gaps identified in a single session involving a Treatment Team RecordMap.

### Gap 1: Separator conflict with compound fields not warned

**Evidence:**
- Session: Treatment Team RecordMap build. The spec uses backtick as both the record-level field separator and the sub-delimiter inside fields 1 and 6 (IDs and SpecialtyCode). The skill documents the compound-field limitation but does not warn that choosing the SAME character for the record separator and the sub-delimiter causes RecordMap to misparse those fields at read time. The agent proceeded without raising this conflict.

**Failure mode:** Skill warns about compound fields in isolation but does not check for separator collision between the record-level separator and the sub-field delimiter. A file that uses backtick as both will be incorrectly split.

**Impact:** At read time, RecordMap will split on every backtick, so fields 1 and 6 will be truncated to their first sub-token. The record object will silently contain wrong data.

### Gap 2: GenerateObject verification step missing from post-create workflow

**Evidence:**
- Session: Treatment Team RecordMap build. After create_class succeeded and compiled, the response declared success without calling GenerateObject or querying %Dictionary.CompiledProperty to confirm all ten fields were generated. The skill's tool-reference table lists GenerateObject but the authoring checklist does not require calling it after create_class.

**Failure mode:** The checklist step 8 says "Push with create_class / write_class. Confirm the tool return before describing results." It does not say to run GenerateObject and verify field count. An agent can satisfy step 8 by checking compiled: true and still miss silent generation failures.

**Impact:** A RecordMap whose target class was silently not generated (or had fewer fields than declared) would be described as ready when it is not.

### Authorization

User explicitly instructed fix in the same session. Iron Law three-instance requirement waived by human partner.
