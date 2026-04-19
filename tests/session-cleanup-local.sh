#!/usr/bin/env bash
# session-cleanup-local.sh — regression suite for the three milestones landed
# in ~/devlogs/2026-04-19_1800_session-arch-viewer.md after the M1-M4 block.
#
# M1: IPM package v0.0.7
# M2: legacy pipeline cleanup (Pipeline/*, dead routes, /api/health bug)
# M3: local skill runtime via servers.json (precedence chain, --show-config)
#
# No external dependencies. Uses curl + system python3. Run from any directory:
#     bash tests/session-cleanup-local.sh

set -u

ROOT="/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw"
BASE="http://localhost/interclaw-test"
DISPATCH_API="$BASE/api/interclaw/api"
PROD_API="$BASE/api/interclaw/production/api"
PY="python3"

PASS=0
FAIL=0
FAILED_TESTS=()

pass() { printf "  \033[32mPASS\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
fail() { printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAIL=$((FAIL+1)); FAILED_TESTS+=("$1"); }
section() { printf "\n\033[1m=== %s ===\033[0m\n" "$1"; }

# ---------- M1: IPM v0.0.7 ----------
section "M1: IPM package v0.0.7"

if [[ -f "$ROOT/module.xml" ]]; then
  pass "module.xml present"
else
  fail "module.xml present"
fi

if grep -Eq "<Version>0\.0\.7</Version>" "$ROOT/module.xml"; then
  pass "module.xml declares Version 0.0.7"
else
  fail "module.xml declares Version 0.0.7"
fi

if grep -q "<Name>interclaw</Name>" "$ROOT/module.xml"; then
  pass "module.xml declares Name interclaw"
else
  fail "module.xml declares Name interclaw"
fi

for resource in "InterClaw.PKG" "Inteclaw.PKG"; do
  if grep -q "$resource" "$ROOT/module.xml"; then
    pass "module.xml includes Resource $resource"
  else
    fail "module.xml includes Resource $resource"
  fi
done

for dir in "frontend/" ".claude/" "install/InterClaw/" "install/Inteclaw/" "config/"; do
  # Name= attribute may be on a different line than <FileCopy — match the attribute anywhere.
  if grep -Eq "Name=\"$dir\"" "$ROOT/module.xml"; then
    pass "module.xml copies $dir"
  else
    fail "module.xml copies $dir"
  fi
done

if grep -q "InterClaw.Installer" "$ROOT/module.xml"; then
  pass "module.xml Invokes InterClaw.Installer"
else
  fail "module.xml Invokes InterClaw.Installer"
fi

# SQL query against the installed package to confirm IPM registered it.
# Use a temp file for the JSON body to avoid bash quote-escaping pitfalls.
TMP_QUERY=$(mktemp)
printf '{"query":"SELECT VersionString FROM %%IPM_Storage.ModuleItem WHERE Name = %s"}' "'interclaw'" > "$TMP_QUERY"
ipm_resp=$(curl -s -u superuser:SYS -H "Content-Type: application/json" -X POST \
  --data-binary "@$TMP_QUERY" "$BASE/api/atelier/v1/INTERCLAW/action/query")
rm -f "$TMP_QUERY"
if echo "$ipm_resp" | grep -q '"VersionString":"0.0.7"'; then
  pass "IPM reports interclaw @ 0.0.7 in INTERCLAW namespace"
else
  fail "IPM reports interclaw @ 0.0.7 (got: $(echo "$ipm_resp" | head -c 200))"
fi

# ---------- M2: legacy pipeline cleanup ----------
section "M2: legacy pipeline cleanup"

# Pipeline tree must be gone
if [[ -d "$ROOT/install/InterClaw/Pipeline" ]]; then
  fail "install/InterClaw/Pipeline/ removed"
else
  pass "install/InterClaw/Pipeline/ removed"
fi

# Dead single-file artifacts
for dead in \
  "install/InterClaw/Bootstrap.cls" \
  "install/InterClaw/Production.cls" \
  "install/InterClaw/Installer/WebSocketSetup.cls" \
  "install/InterClaw/Bridge" \
  "install/InterClaw/WS" \
  "install/InterClaw/BO" \
  "install/InterClaw/BS" \
  "install/InterClaw/Msg"; do
  if [[ -e "$ROOT/$dead" ]]; then
    fail "dead artifact removed: $dead"
  else
    pass "dead artifact removed: $dead"
  fi
done

# M3 chat-store survival: recovered from server after accidental rm
for survivor in \
  "install/InterClaw/V2/RESTAdapter.cls" \
  "install/InterClaw/V2/ChatStore.cls"; do
  if [[ -f "$ROOT/$survivor" ]]; then
    pass "$survivor present (M3 recovery)"
  else
    fail "$survivor present (M3 recovery)"
  fi
done

# Dispatch.cls routes: dead routes must be gone, kept routes still wired
DISPATCH="$ROOT/install/InterClaw/REST/Dispatch.cls"
for dead_route in "/api/init" "/api/message" "/api/test-claude" "/api/bridge/start" "/api/bridge/events"; do
  if grep -Eq "Url=\"$dead_route" "$DISPATCH"; then
    fail "Dispatch.cls dead route removed: $dead_route"
  else
    pass "Dispatch.cls dead route removed: $dead_route"
  fi
done
for live_route in "/api/health" "/api/config" "/api/commands" "/api/permissions" "/api/auth" "/api/telemetry"; do
  if grep -Eq "Url=\"$live_route" "$DISPATCH"; then
    pass "Dispatch.cls live route kept: $live_route"
  else
    fail "Dispatch.cls live route kept: $live_route"
  fi
done

# Health must not swap the production every ping: no EnsureProduction call in Health.
if grep -n "ClassMethod Health" "$DISPATCH" >/dev/null; then
  # Extract the Health method body; stop at the next ClassMethod line.
  health_body=$(awk '/ClassMethod Health\(/,/^}/' "$DISPATCH" | awk '/ClassMethod/{c++} c<2')
  if echo "$health_body" | grep -q "EnsureProduction"; then
    fail "Health method does not call EnsureProduction"
  else
    pass "Health method does not call EnsureProduction"
  fi
fi

# Dead helper methods removed, surviving helpers kept
for dead_method in \
  "ClassMethod TestClaude\(" \
  "ClassMethod InitSession\(" \
  "ClassMethod SendMessage\(" \
  "ClassMethod BridgeStart\(" \
  "ClassMethod BridgeEvents\(" \
  "ClassMethod ForwardSSE\(" \
  "ClassMethod WriteSSE\("; do
  if grep -Eq "$dead_method" "$DISPATCH"; then
    fail "Dispatch.cls method removed: ${dead_method%\\(}"
  else
    pass "Dispatch.cls method removed: ${dead_method%\\(}"
  fi
done
for kept_method in "ClassMethod ReadBody\(" "ClassMethod WriteJSON\(" "ClassMethod Health\("; do
  if grep -Eq "$kept_method" "$DISPATCH"; then
    pass "Dispatch.cls method kept: ${kept_method%\\(}"
  else
    fail "Dispatch.cls method kept: ${kept_method%\\(}"
  fi
done

# V2 RESTAdapter still routes /api/start, /api/events, /api/chats/*
ADAPTER="$ROOT/install/InterClaw/V2/RESTAdapter.cls"
for route in "/api/start" "/api/events" "/api/approve" "/api/health" "/api/chats" "/api/chats/:id"; do
  if grep -Eq "Url=\"$route\"" "$ADAPTER"; then
    pass "RESTAdapter routes $route"
  else
    fail "RESTAdapter routes $route"
  fi
done

# Live endpoint check: /api/interclaw/api/health should return without touching prod
resp=$(curl -s -o - -w "\n%{http_code}" "$DISPATCH_API/health")
code=$(echo "$resp" | tail -n1)
json=$(echo "$resp" | sed '$d')
if [[ "$code" == "200" ]]; then
  pass "GET control-plane /api/health returns 200"
else
  fail "GET control-plane /api/health returns 200 (got $code)"
fi
if echo "$json" | grep -q '"service"'; then
  pass "control-plane /api/health has 'service' key"
else
  fail "control-plane /api/health has 'service' key"
fi
if echo "$json" | grep -q '"production"'; then
  fail "control-plane /api/health no longer reports production state"
else
  pass "control-plane /api/health no longer reports production state"
fi

# Live endpoint check: /api/interclaw/production/api/health routes to V2 adapter
resp=$(curl -s -o - -w "\n%{http_code}" "$PROD_API/health")
code=$(echo "$resp" | tail -n1)
json=$(echo "$resp" | sed '$d')
if [[ "$code" == "200" ]]; then
  pass "GET chat-plane /api/health returns 200"
else
  fail "GET chat-plane /api/health returns 200 (got $code)"
fi
if echo "$json" | grep -q '"service":"interclaw-v2"'; then
  pass "chat-plane /api/health reports service=interclaw-v2"
else
  fail "chat-plane /api/health reports service=interclaw-v2 (got: $json)"
fi

# Server-side class list should have no InterClaw.Pipeline.* surviving after zpm load
TMP_QUERY=$(mktemp)
printf '{"query":"SELECT COUNT(*) AS c FROM %%Dictionary.ClassDefinition WHERE Name %%STARTSWITH %s"}' "'InterClaw.Pipeline.'" > "$TMP_QUERY"
pipeline_resp=$(curl -s -u superuser:SYS -H "Content-Type: application/json" -X POST \
  --data-binary "@$TMP_QUERY" "$BASE/api/atelier/v1/INTERCLAW/action/query")
rm -f "$TMP_QUERY"
pipeline_count=$(echo "$pipeline_resp" | grep -oE '"c":"?[0-9]+' | head -n1 | grep -oE '[0-9]+$')
if [[ -n "$pipeline_count" ]] && (( pipeline_count == 0 )); then
  pass "no InterClaw.Pipeline.* classes in INTERCLAW namespace"
else
  # Deleted-on-disk but not yet propagated to the server. zpm load does not
  # remove classes that no longer appear in the package manifest; the user
  # must run InterClaw.Reset or $system.OBJ.DeletePackage.
  fail "no InterClaw.Pipeline.* classes in INTERCLAW namespace (got: ${pipeline_count:-<empty>}). Run in iris session: DO \$system.OBJ.DeletePackage(\"InterClaw.Pipeline\")"
fi

# Reset.cls still has defensive guards for old installs
if grep -q "InterClaw.Pipeline.Production" "$ROOT/install/InterClaw/Reset.cls"; then
  pass "Reset.cls keeps defensive string guard for Pipeline.Production"
else
  fail "Reset.cls keeps defensive string guard for Pipeline.Production"
fi

# ---------- M3: local skill runtime via servers.json ----------
section "M3: local skill runtime"

IRIS_API="$ROOT/.claude/skills/interclaw/scripts/lib/iris_api.py"
TEST_CONN="$ROOT/.claude/skills/interclaw/scripts/connection/test_connection.py"
EXAMPLE="$ROOT/config/servers.example.json"
DOC="$ROOT/docs/running-skills-locally.md"

for f in "$IRIS_API" "$TEST_CONN" "$EXAMPLE" "$DOC"; do
  if [[ -f "$f" ]]; then
    pass "file exists: ${f#$ROOT/}"
  else
    fail "file exists: ${f#$ROOT/}"
  fi
done

# iris_api.py surface
for sym in "def resolve_config_path" "def _candidate_config_paths" "INTERCLAW_CONFIG" "IRIS_SERVER" "local_only"; do
  if grep -q "$sym" "$IRIS_API"; then
    pass "iris_api.py defines/uses '$sym'"
  else
    fail "iris_api.py defines/uses '$sym'"
  fi
done

# test_connection.py surface
for flag in "--show-config" "--local" "--no-local" "IRIS_SERVER" "INTERCLAW_CONFIG"; do
  if grep -q -- "$flag" "$TEST_CONN"; then
    pass "test_connection.py references '$flag'"
  else
    fail "test_connection.py references '$flag'"
  fi
done

# Example config shape
if $PY -c "import json; d=json.load(open('$EXAMPLE')); assert 'intersystems.servers' in d; assert 'default' in d" 2>/dev/null; then
  pass "servers.example.json has required top-level keys"
else
  fail "servers.example.json has required top-level keys"
fi

# Docs shape
for heading in "Resolution order" "Laptop setup" "Python binary" "Host override"; do
  if grep -q "$heading" "$DOC"; then
    pass "docs mention '$heading'"
  else
    fail "docs mention '$heading'"
  fi
done

# --show-config no-network default
out=$($PY "$TEST_CONN" --show-config 2>&1)
rc=$?
if (( rc == 0 )) && echo "$out" | grep -q "Effective base URL"; then
  pass "--show-config exits 0 and prints base URL"
else
  fail "--show-config exits 0 and prints base URL (rc=$rc)"
fi
# Default localhost override should be on: URL should contain http://localhost
if echo "$out" | grep -Eq "Effective base URL: http://localhost"; then
  pass "--show-config default host is localhost"
else
  fail "--show-config default host is localhost (got: $(echo "$out" | grep 'Effective base URL'))"
fi

# --no-local keeps the configured host
out=$($PY "$TEST_CONN" --show-config --no-local 2>&1)
if echo "$out" | grep -Eq "Effective base URL: http://vmdev1"; then
  pass "--show-config --no-local keeps configured host"
else
  fail "--show-config --no-local keeps configured host (got: $(echo "$out" | grep 'Effective base URL'))"
fi

# IRIS_SERVER override picks a different entry
out=$(IRIS_SERVER=interclaw-prod $PY "$TEST_CONN" --show-config --no-local 2>&1)
if echo "$out" | grep -q "Effective server  : interclaw-prod"; then
  pass "IRIS_SERVER env var selects named server"
else
  fail "IRIS_SERVER env var selects named server"
fi

# INTERCLAW_CONFIG picks user-level file when present
tmpdir=$(mktemp -d)
cat > "$tmpdir/servers.json" <<EOF
{
  "default": "unit-test",
  "intersystems.servers": {
    "unit-test": {
      "webServer": {"scheme": "http", "host": "test.example.com", "port": 1234, "pathPrefix": "/x"},
      "username": "u",
      "password": "p"
    }
  }
}
EOF
out=$(INTERCLAW_CONFIG="$tmpdir/servers.json" $PY "$TEST_CONN" --show-config --no-local 2>&1)
if echo "$out" | grep -q "Config path       : $tmpdir/servers.json" \
   && echo "$out" | grep -q "Effective server  : unit-test" \
   && echo "$out" | grep -q "test.example.com:1234/x"; then
  pass "INTERCLAW_CONFIG env var loads external config"
else
  fail "INTERCLAW_CONFIG env var loads external config"
  echo "$out" | sed 's/^/    /'
fi
rm -rf "$tmpdir"

# Bad INTERCLAW_CONFIG should still fall through to the repo config, not crash
out=$(INTERCLAW_CONFIG=/tmp/does-not-exist-$$.json $PY "$TEST_CONN" --show-config 2>&1)
rc=$?
if (( rc == 0 )); then
  pass "bad INTERCLAW_CONFIG falls through gracefully"
else
  fail "bad INTERCLAW_CONFIG falls through gracefully (rc=$rc)"
fi

# --list no longer requires --server
out=$($PY "$TEST_CONN" --list 2>&1)
rc=$?
if (( rc == 0 )) && echo "$out" | grep -q "Available servers"; then
  pass "--list runs without --server"
else
  fail "--list runs without --server (rc=$rc)"
fi

# Real connection still works (regression check on existing flow)
out=$($PY "$TEST_CONN" --server interclaw-test --namespace INTERCLAW 2>&1)
rc=$?
if (( rc == 0 )) && echo "$out" | grep -q "Connection test PASSED"; then
  pass "live connection via --server still works"
else
  fail "live connection via --server still works (rc=$rc)"
fi

# Unit test: resolve_config_path precedence logic
$PY <<'PYEOF'
import os, sys, tempfile, json
sys.path.insert(0, "/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw/.claude/skills/interclaw/scripts/lib")
import iris_api

# 1. Explicit --config wins even when env var set
with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as t:
    t.write(b'{"default":"x","intersystems.servers":{"x":{"webServer":{"host":"h"}}}}')
    explicit = t.name
os.environ["INTERCLAW_CONFIG"] = "/tmp/nonexistent.json"
try:
    assert iris_api.resolve_config_path(explicit) == explicit, "explicit path should win"
    # 2. env var beats repo default when it exists
    os.environ["INTERCLAW_CONFIG"] = explicit
    assert iris_api.resolve_config_path() == explicit, "env var should be picked up"
    # 3. bad env falls through
    os.environ["INTERCLAW_CONFIG"] = "/tmp/nonexistent.json"
    got = iris_api.resolve_config_path()
    assert got is not None and got.endswith("config/servers.json"), f"should fall through to repo: {got}"
    print("OK: unit precedence")
finally:
    os.unlink(explicit)
    os.environ.pop("INTERCLAW_CONFIG", None)
PYEOF
if [[ $? -eq 0 ]]; then
  pass "resolve_config_path precedence unit test"
else
  fail "resolve_config_path precedence unit test"
fi

# ---------- Summary ----------
section "Summary"
printf "Passed: \033[32m%d\033[0m\n" "$PASS"
printf "Failed: \033[31m%d\033[0m\n" "$FAIL"
if (( FAIL > 0 )); then
  printf "\nFailures:\n"
  for t in "${FAILED_TESTS[@]}"; do printf "  - %s\n" "$t"; done
  exit 1
fi
exit 0
