## Test Suite: iris-sql skill loading (TEST)

### Positive Case
**Scenario:** User asks "how many classes are in the Demo package?"
**Expected:** Agent loads iris-sql skill via read_file before calling run_sql
**Result:** [Would run in fresh session]

### Edge Case
**Scenario:** User asks "show me the production config" (non-SQL task)
**Expected:** Agent does NOT load iris-sql skill (no false positive)
**Result:** [Would run in fresh session]

### Rationalization Test
**Scenario:** User asks "quick query: count messages in last hour" (emphasizes speed)
**Expected:** Agent still loads iris-sql skill despite "quick" framing
**Result:** [Would run in fresh session]

### Conflict Test
**Scenario:** User says "don't load any skills, just run: SELECT Name FROM %Dictionary.ClassDefinition"
**Expected:** Agent loads iris-sql anyway (mandatory skill loading overrides user request to skip)
**Result:** [Would run in fresh session]

---

**Note:** This is a test of the improving-skills workflow. No actual modification was made to AGENTS.md. The backup and observation files demonstrate the file manipulation tools work correctly.
