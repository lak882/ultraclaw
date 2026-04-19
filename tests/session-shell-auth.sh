#!/usr/bin/env bash
# session-shell-auth.sh — regression suite for the shell + auth-gate work
# landed in this session (devlog entries [04:04]..[04:13]).
#
# What this covers:
#   Shell-1  index.html is the InterClaw shell (three iframes + chatbot + shell.js)
#   Shell-2  shell.css defines auth-gate + iframe-visibility rules
#   Shell-3  shell.js owns tab state, lazy iframe src, hash routing
#   Shell-4  shell.js auth gate: apiBase(), refreshAuth(), applyAuthGate(),
#            window 'focus' + 'interclaw-auth-changed' listeners, fail-closed
#   Auth-1   /api/auth-status endpoint still serves the expected shape
#   Auth-2   send.js dispatches interclaw-auth-changed on /login + /logout
#   Auth-3   no duplicate chrome: legacy-ui + skills-editor skip header/chatbot
#            when loaded with ?chrome=none (the shell sets that flag)
#   Portal-1 portal-urls endpoint returns catalog (already in session-m1-m4;
#            we re-assert here so this file stands alone)
#
# Run from the project root:
#   bash tests/session-shell-auth.sh

set -u

ROOT="/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw"
FRONTEND="$ROOT/frontend"
BASE="http://localhost/interclaw-test"
FRONT_URL="$BASE/ui/interop/interclaw"
DISPATCH_API="$BASE/api/interclaw/api"
PROD_API="$BASE/api/interclaw/production/api"
AUTH="-u superuser:SYS"

PASS=0
FAIL=0
FAILED_TESTS=()

pass() { printf "  \033[32mPASS\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
fail() { printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAIL=$((FAIL+1)); FAILED_TESTS+=("$1"); }

section() { printf "\n\033[1m=== %s ===\033[0m\n" "$1"; }

# ── Shell-1 ─────────────────────────────────────────────────────────────
section "Shell-1: index.html is the shell"

resp=$(curl -s -o - -w "\n%{http_code}" "$FRONT_URL/index.html")
code=$(echo "$resp" | tail -n1)
index_html=$(echo "$resp" | sed '$d')
if [[ "$code" == "200" ]]; then
  pass "index.html served 200"
else
  fail "index.html served 200 (got $code)"
fi

# Three iframes with data-tab markers
for tab in portal traces skills; do
  if echo "$index_html" | grep -q "data-tab=\"$tab\""; then
    pass "shell has iframe for tab '$tab'"
  else
    fail "shell has iframe for tab '$tab'"
  fi
done

# Auth overlay markup must be present
for needle in 'id="shell-auth-overlay"' 'id="shell-auth-title"' 'Please log in' '/login &lt;username&gt;'; do
  if echo "$index_html" | grep -q -- "$needle"; then
    pass "shell markup contains '$needle'"
  else
    fail "shell markup contains '$needle'"
  fi
done

# Shell scripts referenced with cache-busting versions
for asset in "shell.css?v=" "shell.js?v=" "interclaw-chatbot.js?v="; do
  if echo "$index_html" | grep -q "$asset"; then
    pass "shell loads $asset"
  else
    fail "shell loads $asset"
  fi
done

# The chat-only redirect is still in place (preserves ?view=chat -> interop-editor)
if echo "$index_html" | grep -q "interop-editor/index.html"; then
  pass "shell preserves chat-only redirect"
else
  fail "shell preserves chat-only redirect"
fi

# ── Shell-2 ─────────────────────────────────────────────────────────────
section "Shell-2: shell.css gate + iframe visibility"

css=$(curl -s "$FRONT_URL/shell.css")
if [[ -n "$css" ]]; then
  pass "shell.css served non-empty"
else
  fail "shell.css served non-empty"
fi

# Gate class selector flips overlay on
if echo "$css" | grep -q "body.shell-login-required #shell-auth-overlay"; then
  pass "gate class toggles overlay"
else
  fail "gate class toggles overlay"
fi
# Iframes frozen while gated: no pointer events, greyed
if echo "$css" | grep -q "body.shell-login-required .shell-iframe" && echo "$css" | grep -q "pointer-events: none"; then
  pass "gate freezes iframes (pointer-events: none)"
else
  fail "gate freezes iframes (pointer-events: none)"
fi
if echo "$css" | grep -q "grayscale"; then
  pass "gate applies grayscale filter"
else
  fail "gate applies grayscale filter"
fi
# Iframe state preservation: non-active iframes are `visibility: hidden`,
# not `display: none`. That keeps their DOM alive across tab switches.
if echo "$css" | grep -q "visibility: hidden" && echo "$css" | grep -q ".shell-iframe--active"; then
  pass "inactive iframes use visibility:hidden (state-preserving)"
else
  fail "inactive iframes use visibility:hidden (state-preserving)"
fi

# ── Shell-3 ─────────────────────────────────────────────────────────────
section "Shell-3: shell.js tab machinery"

js=$(curl -s "$FRONT_URL/shell.js")
if [[ -n "$js" ]]; then
  pass "shell.js served non-empty"
else
  fail "shell.js served non-empty"
fi

for needle in \
  "VALID_TABS" \
  "activateTab" \
  "shell-iframe--active" \
  "buildSources" \
  "preloadAllIframes" \
  "_interclawShell" \
  "openInTab" \
  "interclaw-shell-tab-change" ; do
  if echo "$js" | grep -q -- "$needle"; then
    pass "shell.js contains '$needle'"
  else
    fail "shell.js contains '$needle'"
  fi
done

# Hash-shortcut removal: per user request, #tab=... URL state is gone.
# Assert we no longer touch the hash for tab state.
if echo "$js" | grep -q "setHash\|hashchange\|tab=.*\\\\w"; then
  fail "shell.js no longer uses #tab=... shortcut"
else
  pass "shell.js no longer uses #tab=... shortcut"
fi

# Sources should include the three known paths
for src in "legacy-ui/index.html" "skills-editor/index.html" "EnsPortal.ProductionConfig.zen" "EnsPortal.MessageViewer.zen"; do
  if echo "$js" | grep -q "$src"; then
    pass "shell.js references '$src'"
  else
    fail "shell.js references '$src'"
  fi
done

# The shell passes chrome=none so nested pages skip their own chrome.
if echo "$js" | grep -q "chrome=none"; then
  pass "shell.js passes chrome=none to iframe sources"
else
  fail "shell.js passes chrome=none to iframe sources"
fi

# Header click interception must attach at window capture to beat any
# descendant handler regardless of render timing. A plain addEventListener
# on `#interclaw-header` or similar is the old, race-prone pattern.
if echo "$js" | grep -q "window.addEventListener('click'" && echo "$js" | grep -A20 "window.addEventListener('click'" | grep -E -q "^\s*\}, true\)"; then
  pass "shell.js installs click interception at window capture"
else
  fail "shell.js installs click interception at window capture"
fi

# Eager iframe preload: the previous lazy-load made first clicks flicker and
# amplified race conditions with the header. boot() must preload all three.
if echo "$js" | grep -q "preloadAllIframes"; then
  pass "shell.js eagerly preloads all iframes"
else
  fail "shell.js eagerly preloads all iframes"
fi

# Public API for /goto integration
if echo "$js" | grep -q "window._interclawShell" && echo "$js" | grep -q "openInTab"; then
  pass "shell.js exposes window._interclawShell.openInTab"
else
  fail "shell.js exposes window._interclawShell.openInTab"
fi

# ── Shell-4 ─────────────────────────────────────────────────────────────
section "Shell-4: shell.js auth gate"

for needle in \
  "apiBase" \
  "refreshAuth" \
  "applyAuthGate" \
  "auth-status" \
  "shell-login-required" \
  "interclaw-auth-changed" \
  "AbortSignal.timeout" \
  "authGateApplied" ; do
  if echo "$js" | grep -q -- "$needle"; then
    pass "shell.js has '$needle'"
  else
    fail "shell.js has '$needle'"
  fi
done

# Fail-closed: catch block applies the gate even on fetch failure
if echo "$js" | grep -B1 -A3 "catch (e)" | grep -q "applyAuthGate(false)"; then
  pass "shell.js fails closed on auth-status error"
else
  fail "shell.js fails closed on auth-status error"
fi

# Boot sequence calls refreshAuth
if echo "$js" | grep -A8 "function boot" | grep -q "refreshAuth()"; then
  pass "shell.js boot() calls refreshAuth()"
else
  fail "shell.js boot() calls refreshAuth()"
fi

# Window focus event re-checks auth (tab-switch recovery)
if echo "$js" | grep -q "window.addEventListener('focus'"; then
  pass "shell.js re-checks auth on window focus"
else
  fail "shell.js re-checks auth on window focus"
fi

# ── Auth-1 ──────────────────────────────────────────────────────────────
section "Auth-1: /api/auth-status endpoint"

resp=$(curl -s $AUTH -o - -w "\n%{http_code}" "$DISPATCH_API/auth-status")
code=$(echo "$resp" | tail -n1)
auth_json=$(echo "$resp" | sed '$d')
if [[ "$code" == "200" ]]; then
  pass "GET /api/auth-status returns 200"
else
  fail "GET /api/auth-status returns 200 (got $code)"
fi

for k in authenticated logged_in; do
  if echo "$auth_json" | grep -q "\"$k\""; then
    pass "auth-status JSON has key '$k'"
  else
    fail "auth-status JSON has key '$k'"
  fi
done

# Logged-in dev instance should report logged_in: true
if echo "$auth_json" | grep -Eq '"logged_in"[[:space:]]*:[[:space:]]*true'; then
  pass "auth-status.logged_in == true on authenticated request"
else
  fail "auth-status.logged_in == true on authenticated request"
fi

# Anonymous request (no credentials) — the gate is intentionally a
# single-user-per-host design, so `logged_in` reflects whether anyone has
# persisted an InterClaw.User credential via /login, not the per-request
# identity. That is the documented behavior in CLAUDE.md ("validates IRIS
# credentials and persists them via Ens.Config.Credentials('InterClaw.User')").
# What we DO require is that the endpoint stays reachable without creds so
# the shell's gate check never 500s.
anon_resp=$(curl -s -o - -w "\n%{http_code}" --no-keepalive -H "Authorization:" "$DISPATCH_API/auth-status")
anon_code=$(echo "$anon_resp" | tail -n1)
anon_json=$(echo "$anon_resp" | sed '$d')
if [[ "$anon_code" == "200" ]]; then
  pass "anonymous auth-status reachable (shell needs this to compute the gate)"
else
  fail "anonymous auth-status reachable (got $anon_code)"
fi
if echo "$anon_json" | grep -q '"logged_in"'; then
  pass "anonymous auth-status returns the logged_in field"
else
  fail "anonymous auth-status returns the logged_in field"
fi

# ── Auth-2 ──────────────────────────────────────────────────────────────
section "Auth-2: send.js dispatches interclaw-auth-changed"

send_js=$(curl -s "$FRONT_URL/interclaw-chatbot/send.js")
if [[ -n "$send_js" ]]; then
  pass "send.js served non-empty"
else
  fail "send.js served non-empty"
fi

# Login path dispatches with loggedIn:true
if echo "$send_js" | grep -q "interclaw-auth-changed.*loggedIn: true"; then
  pass "send.js dispatches interclaw-auth-changed {loggedIn:true} on /login"
else
  fail "send.js dispatches interclaw-auth-changed {loggedIn:true} on /login"
fi
# Logout path dispatches with loggedIn:false
if echo "$send_js" | grep -q "interclaw-auth-changed.*loggedIn: false"; then
  pass "send.js dispatches interclaw-auth-changed {loggedIn:false} on /logout"
else
  fail "send.js dispatches interclaw-auth-changed {loggedIn:false} on /logout"
fi

# ── Auth-3 ──────────────────────────────────────────────────────────────
section "Auth-3: nested pages skip their own chrome"

# legacy-ui/index.html sets _interclawChromeNone from ?chrome=none and guards
# the header + chatbot injections. Without this guard, loading the shell
# would double-render chrome inside each iframe.
legacy=$(curl -s "$FRONT_URL/legacy-ui/index.html")
if echo "$legacy" | grep -q "_interclawChromeNone"; then
  pass "legacy-ui reads ?chrome=none flag"
else
  fail "legacy-ui reads ?chrome=none flag"
fi
# Both header + chatbot should be guarded behind the flag (no re-injection)
if echo "$legacy" | grep -q "if (!window._interclawChromeNone)"; then
  pass "legacy-ui guards header + chatbot injection behind chrome=none"
else
  fail "legacy-ui guards header + chatbot injection behind chrome=none"
fi

# Skills editor: either serves 200 (if deployed) or is an internal-only mount.
# Don't hard-fail on absence; just note presence.
skills=$(curl -s -o - -w "\n%{http_code}" "$FRONT_URL/skills-editor/index.html")
skills_code=$(echo "$skills" | tail -n1)
skills_html=$(echo "$skills" | sed '$d')
if [[ "$skills_code" == "200" ]]; then
  pass "skills-editor/index.html served 200"
  if echo "$skills_html" | grep -q "_interclawChromeNone\|chrome=none"; then
    pass "skills-editor respects chrome=none"
  else
    fail "skills-editor respects chrome=none"
  fi
else
  fail "skills-editor/index.html served 200 (got $skills_code)"
fi

# ── Header-1: interclaw-header is shell-aware ───────────────────────────
section "Header-1: interclaw-header delegates to shell"

hdr_js=$(curl -s "$FRONT_URL/interclaw-header.js")
if [[ -n "$hdr_js" ]]; then
  pass "interclaw-header.js served non-empty"
else
  fail "interclaw-header.js served non-empty"
fi

# When rendered inside the shell, Portal/Traces/Skills clicks should delegate
# to _interclawShell.activateTab instead of letting the <a href> navigate.
# This is the real fix for "Skills tab navigates away" — without it, the
# only defense is shell.js's own click interception, which leaves a timing
# race on the table.
if echo "$hdr_js" | grep -q "_interclawShell" && echo "$hdr_js" | grep -q "shell.activateTab"; then
  pass "interclaw-header calls _interclawShell.activateTab for workspace tabs"
else
  fail "interclaw-header calls _interclawShell.activateTab for workspace tabs"
fi

# All four HTML entry points must reference header v>=15 so the shell-aware
# click handler actually ships.
for page in index.html interop-editor/index.html legacy-ui/index.html skills-editor/index.html; do
  f="$ROOT/frontend/$page"
  if [[ ! -f "$f" ]]; then fail "$page exists"; continue; fi
  if grep -Eq "interclaw-header\.js\?v=(1[5-9]|[2-9][0-9])|v=[1-9][0-9]{2,}" "$f"; then
    pass "$page references interclaw-header v>=15"
  else
    fail "$page references interclaw-header v>=15"
  fi
done

# ── Goto-1: /goto routes into shell iframes ─────────────────────────────
section "Goto-1: goto.js is shell-aware"

goto_js=$(curl -s "$FRONT_URL/interclaw-chatbot/goto.js")
if [[ -n "$goto_js" ]]; then
  pass "goto.js served non-empty"
else
  fail "goto.js served non-empty"
fi

# navigateLegacyUi must prefer the shell's openInTab over the legacy-ui-only
# #viewer-frame and over window.location.href. Without this, /goto on the
# shell either opens new tabs or navigates the top window away.
if echo "$goto_js" | grep -q "_interclawShell" && echo "$goto_js" | grep -q "openInTab"; then
  pass "goto.js navigateLegacyUi calls _interclawShell.openInTab"
else
  fail "goto.js navigateLegacyUi calls _interclawShell.openInTab"
fi

# Class-lookup success path must actually navigate now — previously it fell
# through to the "Non-trace gotos: nothing to do" no-op, so /goto My.DTL.Foo
# did nothing on the shell.
if echo "$goto_js" | grep -q "buildPortalLink" && echo "$goto_js" | grep -B2 -A5 "buildPortalLink" | grep -q "navigateLegacyUi"; then
  pass "goto.js class-match path navigates via navigateLegacyUi"
else
  fail "goto.js class-match path navigates via navigateLegacyUi"
fi

# Catalog fallback no longer relies on window.open for legacy-ui URLs; it
# must use navigatePortalUrl (which itself routes to the shell) as the
# last resort.
if echo "$goto_js" | grep -q "navigatePortalUrl"; then
  pass "goto.js catalog fallback uses navigatePortalUrl"
else
  fail "goto.js catalog fallback uses navigatePortalUrl"
fi

# ── Portal-1 ────────────────────────────────────────────────────────────
section "Portal-1: /api/portal-urls (re-assertion)"

resp=$(curl -s $AUTH -o - -w "\n%{http_code}" "$PROD_API/portal-urls")
code=$(echo "$resp" | tail -n1)
json=$(echo "$resp" | sed '$d')
if [[ "$code" == "200" ]]; then
  pass "GET /api/portal-urls returns 200"
else
  fail "GET /api/portal-urls returns 200 (got $code)"
fi
# Must be real JSON (starts with {) and parseable
if echo "$json" | head -c 1 | grep -q '{' ; then
  pass "portal-urls body is JSON"
else
  fail "portal-urls body is JSON"
fi

# ── Summary ─────────────────────────────────────────────────────────────
section "Summary"
printf "Passed: \033[32m%d\033[0m\n" "$PASS"
printf "Failed: \033[31m%d\033[0m\n" "$FAIL"
if (( FAIL > 0 )); then
  printf "\nFailures:\n"
  for t in "${FAILED_TESTS[@]}"; do printf "  - %s\n" "$t"; done
  exit 1
fi
exit 0
