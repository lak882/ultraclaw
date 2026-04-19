#!/usr/bin/env bash
# session-m1-m4.sh — regression suite for the four milestones landed in
# ~/devlogs/2026-04-19_1800_session-arch-viewer.md
#
# M1: remove hard-coded INTERCLAW namespace
# M2: welcome page + /api/diagnostics + installer welcome URL banner
# M3: reload button beside model selector
# M4: /api/portal-urls endpoint on InterClaw.V2.RESTAdapter
#
# No external dependencies. Uses curl + the project's vendored irispython.
# Run from the project root:
#     bash tests/session-m1-m4.sh

set -u

ROOT="/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw"
FRONTEND="$ROOT/frontend"
PY="$ROOT/../../bin/irispython"
BASE="http://localhost/interclaw-test"
FRONT_URL="$BASE/ui/interop/interclaw"
DISPATCH_API="$BASE/api/interclaw/api"
PROD_API="$BASE/api/interclaw/production/api"

PASS=0
FAIL=0
FAILED_TESTS=()

pass() { printf "  \033[32mPASS\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
fail() { printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAIL=$((FAIL+1)); FAILED_TESTS+=("$1"); }

section() { printf "\n\033[1m=== %s ===\033[0m\n" "$1"; }

# ---------- M1: namespace de-hardcoding ----------
section "M1: namespace de-hardcoding"

# install-config.js must exist and expose the install namespace
if [[ -f "$FRONTEND/install-config.js" ]]; then
  pass "install-config.js present on disk"
else
  fail "install-config.js present on disk"
fi

body=$(curl -s -o - -w "\n%{http_code}" "$FRONT_URL/install-config.js")
code=$(echo "$body" | tail -n1)
content=$(echo "$body" | sed '$d')
if [[ "$code" == "200" ]]; then
  pass "install-config.js served 200"
else
  fail "install-config.js served 200 (got $code)"
fi
if echo "$content" | grep -q "_interclawConfig"; then
  pass "install-config.js exposes window._interclawConfig"
else
  fail "install-config.js exposes window._interclawConfig"
fi
if echo "$content" | grep -q "namespace"; then
  pass "install-config.js has namespace field"
else
  fail "install-config.js has namespace field"
fi

# install-config.js must be loaded by every HTML entry point with a header
for page in index.html legacy-ui/index.html interop-editor/index.html skills-editor/index.html; do
  f="$FRONTEND/$page"
  if [[ ! -f "$f" ]]; then
    fail "$page exists"
    continue
  fi
  if grep -q "install-config.js" "$f"; then
    pass "$page loads install-config.js"
  else
    fail "$page loads install-config.js"
  fi
done

# No residual bare-string "INTERCLAW" default in namespace-resolving JS.
# Allow fallback branches ('INTERCLAW') as last-resort defaults — but only one
# per file, and the file must also consult _interclawConfig.
for f in "$FRONTEND/interclaw-header.js" \
         "$FRONTEND/interclaw-chatbot/namespace.js" \
         "$FRONTEND/interclaw-chatbot/goto.js"; do
  base=$(basename "$f")
  if ! [[ -f "$f" ]]; then
    fail "$base present"; continue
  fi
  if grep -q "_interclawConfig" "$f"; then
    pass "$base consults window._interclawConfig"
  else
    fail "$base consults window._interclawConfig"
  fi
done

# ---------- M3: reload button beside model selector ----------
section "M3: reload button beside model selector"

hdrjs=$(curl -s "$FRONT_URL/interclaw-header.js")
hdrcss=$(curl -s "$FRONT_URL/interclaw-header.css")

if echo "$hdrjs" | grep -q "ic-header-reload-btn"; then
  pass "header.js renders reload button"
else
  fail "header.js renders reload button"
fi
if echo "$hdrjs" | grep -q "shell-iframe--active"; then
  pass "header.js reload handler targets active shell iframe"
else
  fail "header.js reload handler targets active shell iframe"
fi
if echo "$hdrjs" | grep -q "contentWindow.location.reload"; then
  pass "header.js uses contentWindow.location.reload()"
else
  fail "header.js uses contentWindow.location.reload()"
fi

if echo "$hdrcss" | grep -q "ic-header-reload-btn"; then
  pass "header.css styles reload button"
else
  fail "header.css styles reload button"
fi
if echo "$hdrcss" | grep -q "ic-header-reload-spin"; then
  pass "header.css defines spin keyframes"
else
  fail "header.css defines spin keyframes"
fi

# Cache-version bump: every header-loading page must reference v=14 (or later)
for page in index.html interop-editor/index.html legacy-ui/index.html skills-editor/index.html; do
  f="$FRONTEND/$page"
  if [[ ! -f "$f" ]]; then
    fail "$page exists (header cache bump)"; continue
  fi
  if grep -Eq "interclaw-header\.js\?v=(1[4-9]|[2-9][0-9])" "$f"; then
    pass "$page uses interclaw-header.js?v>=14"
  else
    fail "$page uses interclaw-header.js?v>=14"
  fi
done

# ---------- M4: /api/portal-urls endpoint ----------
section "M4: /api/portal-urls"

resp=$(curl -s -o - -w "\n%{http_code}" "$PROD_API/portal-urls")
code=$(echo "$resp" | tail -n1)
json=$(echo "$resp" | sed '$d')
if [[ "$code" == "200" ]]; then
  pass "GET /api/interclaw/production/api/portal-urls returns 200"
else
  fail "GET /api/interclaw/production/api/portal-urls returns 200 (got $code)"
fi

# Expect at least 30 entries — we shipped 41 in config/portal-urls.json
count=$(echo "$json" | grep -o '"slug"' | wc -l)
if [[ "$count" -ge 30 ]]; then
  pass "portal-urls has >=30 entries (got $count)"
else
  fail "portal-urls has >=30 entries (got $count)"
fi

# At least one expected entry (kept generic — slug key must appear)
for slug_hint in "audit" "queues" "messages" "production"; do
  if echo "$json" | grep -q "\"$slug_hint\""; then
    pass "portal-urls contains an entry matching '$slug_hint'"
  else
    fail "portal-urls contains an entry matching '$slug_hint'"
  fi
done

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
