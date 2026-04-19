# /route-test - Route Coverage Testing

Generate and run route-coverage tests against a production to verify every branch of every routing rule, DTL conditional, and BPL switch case is exercised.

Usage:
  /route-test <package> [--manifest <path>] [--test <id>]
  /route-test Sanford                          # generate manifest + run all tests
  /route-test Sanford --test B1-R1             # run a single test
  /route-test --manifest tests/Sanford/route-manifest.json  # run existing manifest

---

## Overview

Route-coverage testing ensures that every message path in a production is tested — not just the happy path. This includes:

- **Routing rule branches**: Message type constraints, facility filters, discard/filter rules
- **DTL conditionals**: if/else branches (e.g., empty vs non-empty fields), foreach edge cases
- **BPL switch cases**: Every `<case>` and `<default>` in a `<switch>` block
- **Alert paths**: Default/error handlers that generate alerts

## Workflow

### Phase 1: Generate Manifest (if no --manifest provided)

Analyze the production to map every branch, then generate test messages and a manifest.

#### Step 1: Pull production and identify components

```bash
get_doc.py --server myserver --namespace <NS> --doc <Pkg>.Production.cls
```

From the production class, extract:
- All services (BS.*) — these are entry points for test messages
- All routing engines — pull their routing rule classes
- All BPL processes — pull their BPL classes
- All DTLs referenced in rules or BPLs
- All operations (BO.*) — these are the expected targets

#### Step 2: Map routing rule branches

For each routing rule, pull the class and extract every `<route>` and `<when>`:

```bash
get_doc.py --server myserver --namespace <NS> --doc <Pkg>.Rule.<Name>RoutingRule.cls
```

For each `<when>`:
- Extract the `<constraint>` (message type filter, e.g., `docName=ADT_A01`)
- Extract the `condition` (business logic, e.g., `HL7.{MSH:SendingFacility.NamespaceID}="USDMC"`)
- Extract the `<send>` targets — these are the expected operation targets
- Note any `transform` attributes — these reference DTLs to analyze
- Note any `disabled` routes (skip them)

Each `<when>` becomes at least one test case:
- **Match case**: Message that satisfies both constraint AND condition → targets receive it
- **Mismatch case**: Message that fails constraint OR condition → discard/filter
- **Default/otherwise**: If no `<when>` matches → test the fallthrough

Create test IDs: `B<build>-R<route>` for routing rule branches.

#### Step 3: Map DTL conditionals

For each DTL referenced in the routing rules, pull the class:

```bash
get_doc.py --server myserver --namespace <NS> --doc <Pkg>.DTL.<Name>.cls
```

Parse the DTL XML and find every `<if>` and `<foreach>`:

- **`<if condition="...">`**: Creates TRUE and FALSE branches. Identify what field values trigger each.
  - Example: `condition="source.{PV1:VisitNumber}]&quot;&quot;"` → test with PV1:VisitNumber populated (TRUE) and empty (FALSE)
- **`<foreach property="...">`**: If it contains `<if>` or `<break/>`, test with:
  - Data that matches early (triggers break on first iteration)
  - Data with no match (foreach completes without break)
  - Data with match in last position
- **Lookup calls**: `..Lookup("TableName", source.{field})` → test with each value in the lookup table
- **Utility functions**: `..SubString()`, `..ReplaceStr()`, `..Strip()` → test with input that exercises the transformation

Create test IDs: `B<build>-D<dtl>` for DTL conditional branches.

#### Step 4: Map BPL switch cases

For each BPL, pull the class:

```bash
get_doc.py --server myserver --namespace <NS> --doc <Pkg>.BPL.<Name>Process.cls
```

Parse the BPL XML and find every `<switch>`, `<if>`, and `<case>`:

- **`<switch>`**: Each `<case condition="...">` and `<default>` needs a test
  - Example: `<case condition="request.{MSH:MessageType.MessageCode}=&quot;ORM&quot;">` → send ORM message
  - `<default>` → send a message type not covered by any case
- **`<if>`**: TRUE and FALSE branches
- **`<sql>`**: If the BPL queries a database, test with data that produces rows (match) and no rows (no match)
- **`<alert>`**: Verify alerts fire when expected

Create test IDs: `B<build>-B<bpl>` for BPL switch cases.

#### Step 5: Create test messages

For each branch identified in Steps 2-4, create a minimal HL7 test message that triggers exactly that path:

- **Segment order must match schema** — pull with `get_schema.py --message <cat:msg>`
- **Set trigger fields explicitly** — MSH:9 for message type, MSH:4 for facility, field values for DTL conditionals
- **Include values that exercise transformations** — SSN with dashes for strip test, gender text for lookup test
- **Use unique identifiers** — different MRN/order numbers per test so SQL assertions don't collide
- **Never pre-populate target fields** — if DTL writes to a field via lookup/transform, leave it with the source value

Save test messages to `tests/<Pkg>/<Build>/<test_name>.hl7`.

#### Step 6: Build the manifest

Generate `tests/<Pkg>/route-manifest.json`:

```json
{
  "package": "<Pkg>",
  "production": "<Pkg>.Production",
  "service_paths": {
    "<Pkg>.Build1.BS.ADTFileService": "/path/to/filedrop/<Pkg>/ADTFileService/In"
  },
  "tests": [
    {
      "id": "B1-R1",
      "name": "ADT_A01 from USDMC — transform and route to 3 targets",
      "file": "Build1/adt_a01_usdmc.hl7",
      "service": "<Pkg>.Build1.BS.ADTFileService",
      "branch": "ADTRoutingRule: USDMC ADT_A01",
      "expect": {
        "targets": ["<Pkg>.Build1.BO.SystemA"],
        "status": "completed",
        "alert": false
      }
    }
  ]
}
```

### Phase 2: Run Tests

```bash
cd "<project-root>" && <python> .claude/skills/interclaw/scripts/hl7/route_test.py \
  --server myserver --namespace <NS> \
  --manifest tests/<Pkg>/route-manifest.json \
  --verbose
```

To run a single test:
```bash
route_test.py --server myserver --namespace <NS> \
  --manifest tests/<Pkg>/route-manifest.json \
  --test B1-R2
```

### Phase 3: Report Coverage

The runner reports per-component coverage. Target: **100% branch coverage**.

If tests fail:
1. Check trace for the session ID reported by the test
2. Common issues:
   - Wrong segment order in test message → check schema
   - Service not picking up file → check FilePath setting and IRIS process user ownership
   - Alert not detected → `Ens_Util.Log.Type` is integer: `6`=Alert, `3`=Warning (not strings)
   - Extra targets → infrastructure targets (routing rules, internal framework targets) are filtered automatically

## Manifest Format

```json
{
  "package": "Sanford",
  "production": "Sanford.Production",
  "service_paths": {
    "Sanford.Build1.BS.ADTFileService": "/path/to/filedrop/Sanford/ADTFileService/In"
  },
  "tests": [...]
}
```

### Test case fields

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique test ID (e.g., B1-R1 = Build 1, Route 1) |
| `name` | Yes | Human-readable description |
| `file` | Yes | Test message path relative to manifest directory |
| `service` | Yes | Config item name of the file service to receive the message |
| `branch` | Yes | Which branch/route this test exercises |
| `depends_on` | No | ID of a test that must run first (e.g., ORM before SIU) |
| `expect.targets` | Yes | List of operation config names that should receive the message. Empty = discard/filter. |
| `expect.status` | No | Expected status ("completed") |
| `expect.alert` | No | `true` if an alert should fire, `false` if it should not |
| `expect.alert_contains` | No | Substring that the alert text should contain |
| `expect.sql_after` | No | SQL query to run after processing |
| `expect.sql_expect` | No | Expected values from the SQL query (key-value pairs) |
| `expect.dtl_checks` | No | Per-target field value assertions (for DTL output validation) |

### ID convention

- `B<n>-R<m>` — Build N, Routing rule branch M
- `B<n>-D<m>` — Build N, DTL conditional branch M
- `B<n>-B<m>` — Build N, BPL switch case M

### service_paths

Map each service config item name to its FilePath (the directory the file service polls). Look up via:
1. Production class `<Item>` settings
2. `get_settings.py --server <s> --namespace <ns> --setting FilePath --host <service_name>`
3. Convention: `${cspdir}interclaw/filedrop/<Pkg>/<Component>/In`

## Branch Analysis Checklist

When generating the manifest, ensure these are covered:

### Routing Rules
- [ ] Each `<when>` with constraint match (happy path)
- [ ] Constraint mismatch (wrong message type)
- [ ] Condition mismatch (wrong facility/value)
- [ ] No-match fallthrough (if no default, message is discarded)
- [ ] Transform + send combinations

### DTL Conditionals
- [ ] Each `<if>` TRUE branch
- [ ] Each `<if>` FALSE branch
- [ ] `<foreach>` with match (triggers `<break/>`)
- [ ] `<foreach>` with no match (completes all iterations)
- [ ] Each `..Lookup()` value (one test per lookup key)
- [ ] Empty/null field edge cases

### BPL Switch Cases
- [ ] Each `<case>` in every `<switch>`
- [ ] `<default>` case
- [ ] Database match vs no-match for `<sql>` queries
- [ ] Alert paths
- [ ] Dependency ordering (`depends_on` for stateful tests)

## Integrating with /poc-test

After each POC build, `/poc-test` can invoke `/route-test` to:

1. Analyze the built artifacts (rules, DTLs, BPLs)
2. Generate a route manifest covering all branches
3. Run `route_test.py` to verify functional correctness
4. Report coverage alongside D/T/P/B quality criteria

This closes the gap between "it compiled" and "every path works."

## Output

```
Production: Sanford.Production
Manifest: tests/Sanford/route-manifest.json
Tests: 14

[B1-R1] ADT_A01 from USDMC — transform and route to 3 targets... PASS
[B1-R2] ADT_A01 from other facility — discard...               PASS
...

ID     | Status | Branch / Test Name
-------+--------+------------------------------------------------------------
B1-R1  | PASS   | ADT_A01 from USDMC — transform and route to 3 targets
B1-R2  | PASS   | ADT_A01 from other facility — discard
...

Coverage: 14/14 branches PASS (100%)

By component:
  ADTRoutingRule: 3/3 (100%) — ALL PASS
  ADTTransform: 3/3 (100%) — ALL PASS
  ORURoutingRule: 2/2 (100%) — ALL PASS
  ORUTransform: 2/2 (100%) — ALL PASS
  OrderScheduleProcess: 4/4 (100%) — ALL PASS
```
