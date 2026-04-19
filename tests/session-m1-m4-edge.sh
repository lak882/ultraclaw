#!/usr/bin/env bash
# session-m1-m4-edge.sh — edge-case regressions for M1-M4. Complements
# tests/session-m1-m4.sh (happy-path). Focuses on:
#   - cross-milestone consistency (install-config ns ↔ diagnostics ns)
#   - welcome page action endpoints actually exist
#   - diagnostics sub-card structure (ok:boolean, detail:string) per card
#   - reload button placement (after model selector, before separator)
#   - portal-urls response is a JSON array and each entry has slug+url
#   - no hard-coded credentials leaked in frontend JS
#   - installer prints a welcome URL whose host/port resolve to a live page
#   - welcome page polls diagnostics (6000ms interval)
#   - reload button has title attribute (a11y) and type=button (no form submit)
#
# Run: bash tests/session-m1-m4-edge.sh

set -u

ROOT="/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw"
FRONTEND="$ROOT/frontend"
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

# Pre-cache things we'll reference repeatedly
welcome_html=$(curl -s "$FRONT_URL/welcome/index.html")
install_cfg=$(curl -s "$FRONT_URL/install-config.js")
hdrjs=$(curl -s "$FRONT_URL/interclaw-header.js")
hdrcss=$(curl -s "$FRONT_URL/interclaw-header.css")
diag_json=$(curl -s "$DISPATCH_API/diagnostics")
portal_json=$(curl -s "$PROD_API/portal-urls")

# ---------- Cross-milestone consistency ----------
section "Cross-milestone consistency"

# install-config.js namespace must equal diagnostics.namespace
cfg_ns=$(echo "$install_cfg" | sed -n 's/.*namespace:[[:space:]]*"\([^"]*\)".*/\1/p')
diag_ns=$(echo "$diag_json" | sed -n 's/.*"namespace":[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
if [[ -n "$cfg_ns" && "$cfg_ns" == "$diag_ns" ]]; then
  pass "install-config.js namespace ($cfg_ns) matches diagnostics.namespace"
else
  fail "install-config.js namespace ($cfg_ns) matches diagnostics.namespace ($diag_ns)"
fi

# install-config.js pathPrefix must equal diagnostics.pathPrefix
cfg_pp=$(echo "$install_cfg" | sed -n 's/.*pathPrefix:[[:space:]]*"\([^"]*\)".*/\1/p')
diag_pp=$(echo "$diag_json" | sed -n 's/.*"pathPrefix":[[:space:]]*"\([^"]*\)".*/\1/p')
if [[ -n "$cfg_pp" && "$cfg_pp" == "$diag_pp" ]]; then
  pass "install-config.js pathPrefix ($cfg_pp) matches diagnostics.pathPrefix"
else
  fail "install-config.js pathPrefix ($cfg_pp) matches diagnostics.pathPrefix ($diag_pp)"
fi

# ---------- Welcome page actions resolve to live endpoints ----------
section "Welcome page action endpoints"

# The welcome page calls /api/interclaw/api/production/start from the
# startProduction action. If the route doesn't exist the button is dead.
# We invoke it; idempotent success either starts or reports already-running.
resp=$(curl -s -o - -w "\n%{http_code}" -X POST -H 'Content-Type: application/json' -d '{}' "$DISPATCH_API/production/start")
code=$(echo "$resp" | tail -n1)
body=$(echo "$resp" | sed '$d')
if [[ "$code" == "200" ]]; then
  pass "POST /api/interclaw/api/production/start returns 200"
else
  fail "POST /api/interclaw/api/production/start returns 200 (got $code)"
fi
if echo "$body" | grep -Eq '"ok"[[:space:]]*:[[:space:]]*true'; then
  pass "production/start reports ok:true"
else
  fail "production/start reports ok:true (body=$body)"
fi
if echo "$body" | grep -q '"production"'; then
  pass "production/start body includes production name"
else
  fail "production/start body includes production name"
fi

# Welcome page fetch URL must match the actual server route
if echo "$welcome_html" | grep -q "'/api/interclaw/api/production/start'"; then
  pass "welcome page calls /api/interclaw/api/production/start (matches server route)"
else
  fail "welcome page calls /api/interclaw/api/production/start (matches server route)"
fi

# ---------- Diagnostics sub-card shape ----------
section "Diagnostics sub-card shape"

# Each card must have both "ok" and "detail"
for card in embeddedPython interop bedrock login production; do
  # pull the card sub-object with python
  has_ok=$(echo "$diag_json" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    c=d.get('$card',{})
    print('YES' if 'ok' in c and isinstance(c['ok'],bool) else 'NO')
except Exception as e:
    print('NO:'+str(e))
")
  has_detail=$(echo "$diag_json" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    c=d.get('$card',{})
    print('YES' if 'detail' in c and isinstance(c['detail'],str) and c['detail'] else 'NO')
except Exception:
    print('NO')
")
  if [[ "$has_ok" == "YES" ]]; then pass "$card has boolean 'ok'"; else fail "$card has boolean 'ok'"; fi
  if [[ "$has_detail" == "YES" ]]; then pass "$card has non-empty string 'detail'"; else fail "$card has non-empty string 'detail'"; fi
done

# top-level ready must be a boolean
ready_type=$(echo "$diag_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(type(d.get('ready')).__name__)")
if [[ "$ready_type" == "bool" ]]; then
  pass "diagnostics.ready is boolean"
else
  fail "diagnostics.ready is boolean (got $ready_type)"
fi

# ---------- Reload button placement & a11y ----------
section "Reload button placement and a11y"

# In the rendered header HTML, reload button must appear AFTER the model
# selector and BEFORE the namespace separator. The header.js concatenates
# the markup across multiple lines; use line numbers to enforce ordering.
model_line=$(grep -n "ic-header-model-dropdown\"" "$FRONTEND/interclaw-header.js" | head -1 | cut -d: -f1)
reload_line=$(grep -n "ic-header-reload-btn\"" "$FRONTEND/interclaw-header.js" | head -1 | cut -d: -f1)
sep_line=$(grep -n "ic-header-sep" "$FRONTEND/interclaw-header.js" | head -1 | cut -d: -f1)
if [[ -n "$model_line" && -n "$reload_line" && "$reload_line" -gt "$model_line" ]]; then
  pass "reload button markup placed after model dropdown (lines: model=$model_line reload=$reload_line)"
else
  fail "reload button markup placed after model dropdown (model=$model_line reload=$reload_line)"
fi
if [[ -n "$reload_line" && -n "$sep_line" && "$sep_line" -gt "$reload_line" ]]; then
  pass "reload button markup placed before ic-header-sep (lines: reload=$reload_line sep=$sep_line)"
else
  fail "reload button markup placed before ic-header-sep (reload=$reload_line sep=$sep_line)"
fi

# type="button" prevents accidental form submits (harmless here but defensive)
if echo "$hdrjs" | grep -q 'class="ic-header-reload-btn" id="ic-header-reload-btn" type="button"'; then
  pass "reload button has type=\"button\""
else
  fail "reload button has type=\"button\""
fi

# title attribute for tooltip / a11y
if echo "$hdrjs" | grep -q 'title="Reload current view"'; then
  pass "reload button has title attribute"
else
  fail "reload button has title attribute"
fi

# SVG icon shipped inline (no external asset dependency)
if echo "$hdrjs" | grep -q 'polyline points="23 4 23 10 17 10"'; then
  pass "reload button inlines SVG refresh icon"
else
  fail "reload button inlines SVG refresh icon"
fi

# Spin animation duration matches CSS definition (0.6s)
if echo "$hdrjs" | grep -q "setTimeout.*removeClass('spinning')\|600.*spinning\|removeClass.*spinning"; then
  pass "reload handler removes .spinning class after animation"
else
  # try a looser match
  if echo "$hdrjs" | grep -q "remove('spinning')"; then
    pass "reload handler removes .spinning class after animation"
  else
    fail "reload handler removes .spinning class after animation"
  fi
fi

# ---------- Portal-URLs structure ----------
section "Portal-URLs structure"

# Catalog is JSON; it may be a bare array OR an object with `entries: [...]`
# (also tolerating `_about`/`_placeholders` metadata fields, prefixed with `_`).
# Accept either shape and extract entries for downstream checks.
shape=$(echo "$portal_json" | python3 -c "
import sys,json
d=json.load(sys.stdin)
if isinstance(d,list):
    print('array')
elif isinstance(d,dict) and isinstance(d.get('entries'),list):
    print('object-with-entries')
else:
    print('unknown')")
if [[ "$shape" == "array" || "$shape" == "object-with-entries" ]]; then
  pass "portal-urls is a JSON array or has .entries array ($shape)"
else
  fail "portal-urls is a JSON array or has .entries array (got $shape)"
fi

entries_with_slug_and_url=$(echo "$portal_json" | python3 -c "
import sys,json
d=json.load(sys.stdin)
entries = d if isinstance(d,list) else d.get('entries',[])
n=sum(1 for e in entries if isinstance(e,dict) and 'slug' in e and 'url' in e)
total=len(entries)
print(f'{n}/{total}')")
good=$(echo "$entries_with_slug_and_url" | cut -d/ -f1)
total=$(echo "$entries_with_slug_and_url" | cut -d/ -f2)
if [[ "$good" -gt 0 && "$good" == "$total" ]]; then
  pass "all $total portal-urls entries have slug+url"
else
  fail "all portal-urls entries have slug+url ($entries_with_slug_and_url)"
fi

# Slugs must be unique (no dupes masking errors)
dupes=$(echo "$portal_json" | python3 -c "
import sys,json,collections
d=json.load(sys.stdin)
entries = d if isinstance(d,list) else d.get('entries',[])
slugs=[e.get('slug') for e in entries if isinstance(e,dict)]
cnt=collections.Counter(slugs)
print(';'.join(k for k,v in cnt.items() if v>1))")
if [[ -z "$dupes" ]]; then
  pass "portal-urls slugs are unique"
else
  fail "portal-urls slugs are unique (dupes: $dupes)"
fi

# ---------- Content-Type headers ----------
section "Content-Type on JSON endpoints"

for endpoint in "$DISPATCH_API/diagnostics" "$PROD_API/portal-urls" "$DISPATCH_API/health"; do
  ctype=$(curl -s -o /dev/null -w '%{content_type}' "$endpoint")
  if echo "$ctype" | grep -q 'application/json'; then
    pass "Content-Type=application/json on $endpoint"
  else
    fail "Content-Type=application/json on $endpoint (got '$ctype')"
  fi
done

# ---------- No hard-coded credentials in frontend JS ----------
section "No hard-coded credentials leaked"

# This tests a broader hygiene concern. Some InterClaw JS legitimately uses
# basic auth ('Basic ' + btoa('superuser:SYS')) for management API calls. We
# simply assert it's NOT present in install-config.js (which is public-facing)
# and NOT in welcome/index.html. Looking for specific leak patterns rather
# than keywords — %SYS as a namespace switch in ObjectScript remediation text
# is not a credential leak.
LEAK_RE='btoa\s*\(\s*["'\'']superuser|password\s*[:=]\s*["'\''][^"]+["'\'']|Authorization:\s*["'\'']Basic '
for f in "$FRONTEND/install-config.js" "$FRONTEND/welcome/index.html"; do
  base=$(basename "$(dirname "$f")")/$(basename "$f")
  if grep -Eq "$LEAK_RE" "$f"; then
    fail "$base free of credential leaks"
  else
    pass "$base free of credential leaks"
  fi
done

# ---------- Installer welcome URL resolves ----------
section "Installer banner welcome URL resolves"

# Reconstruct what the Installer prints: http://<host><pathPrefix>/ui/interop/interclaw/welcome/index.html
# pathPrefix lives in the running config. We simulate the same resolution.
host_from_config=$(echo "$install_cfg" | sed -n 's/.*pathPrefix:[[:space:]]*"\([^"]*\)".*/\1/p')
# The hostname the installer uses comes from $system.INetInfo.LocalHostName().
# In our env that hostname resolves either to localhost or vmdev1.iscinternal.com — try both.
for host in localhost vmdev1.iscinternal.com; do
  url="http://$host${host_from_config}/ui/interop/interclaw/welcome/index.html"
  code=$(curl -s -o /dev/null -w '%{http_code}' --connect-timeout 3 "$url" 2>/dev/null || echo "000")
  if [[ "$code" == "200" ]]; then
    pass "installer banner URL resolves: $url"
  else
    fail "installer banner URL resolves: $url (got $code)"
  fi
done

# ---------- Welcome page polls diagnostics periodically ----------
section "Welcome page polling"

if echo "$welcome_html" | grep -q "setInterval(refresh"; then
  pass "welcome page calls setInterval(refresh, ...)"
else
  fail "welcome page calls setInterval(refresh, ...)"
fi
# Should poll every few seconds — expect a reasonable interval (1000-30000ms)
interval=$(echo "$welcome_html" | sed -n 's/.*setInterval(refresh,[[:space:]]*\([0-9]*\)).*/\1/p')
if [[ -n "$interval" && "$interval" -ge 1000 && "$interval" -le 30000 ]]; then
  pass "welcome page poll interval in [1000,30000]ms (got ${interval}ms)"
else
  fail "welcome page poll interval in [1000,30000]ms (got '$interval')"
fi

# ---------- Welcome page has dark-mode and mobile styles ----------
section "Welcome page responsive / dark mode"

if echo "$welcome_html" | grep -q "@media (prefers-color-scheme: dark)"; then
  pass "welcome page has dark-mode media query"
else
  fail "welcome page has dark-mode media query"
fi
if echo "$welcome_html" | grep -q "@media (max-width:"; then
  pass "welcome page has mobile media query"
else
  fail "welcome page has mobile media query"
fi

# ---------- CTA target is the chat editor ----------
section "Welcome CTA target"

if echo "$welcome_html" | grep -q "interop-editor/index.html"; then
  pass "welcome CTA links to interop-editor"
else
  fail "welcome CTA links to interop-editor"
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
