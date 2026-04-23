## Observation: iris-sql skill - 2026-04-23 (TEST)

**Pattern:** Agent forgets to load iris-sql skill before calling run_sql in 3 out of 5 recent queries

**Evidence:**
- Session test-001, turn 5: User asked "how many classes in Demo package", agent called run_sql without loading skill, used wrong syntax "LIMIT 100" instead of "TOP 100"
- Session test-002, turn 12: User asked "show recent event log errors", agent called run_sql without loading skill, queried Type as string 'Error' instead of integer 2
- Session test-003, turn 8: User asked "list production hosts", agent loaded skill first, query succeeded

**Failure mode:** AGENTS.md says "Before calling run_sql, load iris-sql skill" but this guidance is buried in a table mid-file

**Impact:** Queries fail with SQL syntax errors, require retry after loading skill

**Hypothesis:** Moving the mandatory skill loading table to the top of AGENTS.md with a prominent heading will increase pre-load compliance from 40% to >80%
