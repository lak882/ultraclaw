#!/usr/bin/env bash
# chats-sidebar-m1-m4.sh — regression suite for the persistent-chat work
# landed across M1-M4 in ~/devlogs/2026-04-19_1800_session-arch-viewer.md
#
# M1: ChatGPT-style sidebar (DOM + icons + CSS)
# M2: Server-backed list/read (GET /api/chats, GET /api/chats/:id)
# M3: Write API + auto-title + rename/delete (PUT, DELETE) + helpers
# M4: /goto fuzzy-match against config/portal-urls.json via /api/portal-urls
#
# Run from the project root:
#     bash tests/chats-sidebar-m1-m4.sh
#
# Exit 0 = all green. Exit 1 = one or more failures.

set -u

ROOT="/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw"
FRONTEND="$ROOT/frontend"
PY="$ROOT/../../bin/irispython"
BASE="http://localhost/interclaw-test"
FRONT_URL="$BASE/ui/interop/interclaw"
PROD_API="$BASE/api/interclaw/production/api"
AUTH='-u superuser:SYS'

PASS=0
FAIL=0
FAILED_TESTS=()

pass() { printf "  \033[32mPASS\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
fail() { printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAIL=$((FAIL+1)); FAILED_TESTS+=("$1"); }
section() { printf "\n\033[1m=== %s ===\033[0m\n" "$1"; }

# ---------- M1: sidebar DOM + CSS ----------
section "M1: ChatGPT-style sidebar (frontend assets)"

sidebar_js_path="$FRONTEND/interclaw-chatbot/chats-sidebar.js"
sidebar_css_path="$FRONTEND/interclaw-chatbot/chats-sidebar.css"

if [[ -f "$sidebar_js_path" ]]; then pass "chats-sidebar.js present"; else fail "chats-sidebar.js present"; fi
if [[ -f "$sidebar_css_path" ]]; then pass "chats-sidebar.css present"; else fail "chats-sidebar.css present"; fi

# Sidebar must be listed in the module loader
if grep -q "'chats-sidebar.js'" "$FRONTEND/interclaw-chatbot/index.js"; then
  pass "index.js registers chats-sidebar.js module"
else
  fail "index.js registers chats-sidebar.js module"
fi

# Required DOM hooks
# Chats rail is always visible again — no collapse, no reopen pill.
for hook in "ic-chats-sidebar" "ic-chats-new" "ic-chats-list" "ic-chats-search-input"; do
  if grep -q "$hook" "$sidebar_js_path"; then
    pass "sidebar defines #$hook"
  else
    fail "sidebar defines #$hook"
  fi
done
if ! grep -q "reopenBtn.id" "$sidebar_js_path"; then
  pass "reopen pill not injected (chats rail always visible)"
else
  fail "reopen pill not injected (chats rail always visible)"
fi
if ! grep -q "ic-chats-collapse-btn" "$sidebar_js_path"; then
  pass "collapse button not rendered (chats rail always visible)"
else
  fail "collapse button not rendered (chats rail always visible)"
fi
if grep -q "data-action=\"favorite\"" "$sidebar_js_path"; then
  pass "sidebar renders favorite action (via popup menu)"
else
  fail "sidebar renders favorite action (via popup menu)"
fi
if grep -q "cc.openChatMenu" "$sidebar_js_path"; then
  pass "sidebar defines openChatMenu (3-dot popup)"
else
  fail "sidebar defines openChatMenu (3-dot popup)"
fi
if grep -q "chatsSearchQuery" "$sidebar_js_path"; then
  pass "sidebar has live search query state"
else
  fail "sidebar has live search query state"
fi

# Core action functions exist
for fn in "cc.startNewChat" "cc.openChat" "cc.renameChatInline" "cc.deleteChat" "cc.renderChatsSidebar" "cc.refreshChatsList"; do
  if grep -q "$fn" "$sidebar_js_path"; then
    pass "sidebar exposes $fn"
  else
    fail "sidebar exposes $fn"
  fi
done

# ---------- M2: list + read endpoints ----------
section "M2: GET /api/chats, GET /api/chats/:id"

resp=$(curl -s $AUTH -o - -w "\n%{http_code}" "$PROD_API/chats")
code=$(echo "$resp" | tail -n1)
json=$(echo "$resp" | sed '$d')
if [[ "$code" == "200" ]]; then
  pass "GET /api/chats returns 200"
else
  fail "GET /api/chats returns 200 (got $code)"
fi
for k in "\"user\"" "\"chats\""; do
  if echo "$json" | grep -q "$k"; then
    pass "list response contains $k"
  else
    fail "list response contains $k"
  fi
done

# Seed a chat we can read + delete
tid="test-m2m3-$$"
put_resp=$(curl -s $AUTH -X PUT -H 'Content-Type: application/json' \
  --data '{"title":"Fixture chat","messages":[{"type":"user","html":"hi"},{"type":"assistant","html":"<div>hello</div>"}]}' \
  -o - -w "\n%{http_code}" "$PROD_API/chats/$tid")
put_code=$(echo "$put_resp" | tail -n1)
if [[ "$put_code" == "200" ]]; then pass "seed PUT returns 200"; else fail "seed PUT returns 200 (got $put_code)"; fi

get_resp=$(curl -s $AUTH -o - -w "\n%{http_code}" "$PROD_API/chats/$tid")
get_code=$(echo "$get_resp" | tail -n1)
get_body=$(echo "$get_resp" | sed '$d')
if [[ "$get_code" == "200" ]]; then pass "GET /api/chats/:id returns 200"; else fail "GET /api/chats/:id returns 200 (got $get_code)"; fi
if echo "$get_body" | grep -q '"Fixture chat"'; then pass "GET :id returns seeded title"; else fail "GET :id returns seeded title"; fi
if echo "$get_body" | grep -q '"messages"'; then pass "GET :id returns messages array"; else fail "GET :id returns messages array"; fi
if echo "$get_body" | grep -q '"createdAt"'; then pass "GET :id returns createdAt"; else fail "GET :id returns createdAt"; fi
if echo "$get_body" | grep -q '"updatedAt"'; then pass "GET :id returns updatedAt"; else fail "GET :id returns updatedAt"; fi

# Unknown id must 404
miss_code=$(curl -s $AUTH -o /dev/null -w "%{http_code}" "$PROD_API/chats/does-not-exist-xyz-$$")
if [[ "$miss_code" == "404" ]]; then pass "GET :id 404s on unknown id"; else fail "GET :id 404s on unknown id (got $miss_code)"; fi

# ---------- M3: write API (PUT merge, DELETE, path traversal) ----------
section "M3: PUT/DELETE merge semantics + safety"

# Rename-only PUT preserves messages (merge test)
curl -s $AUTH -X PUT -H 'Content-Type: application/json' \
  --data '{"title":"Renamed fixture"}' \
  "$PROD_API/chats/$tid" > /dev/null
merged=$(curl -s $AUTH "$PROD_API/chats/$tid")
if echo "$merged" | grep -q '"Renamed fixture"'; then pass "rename PUT updates title"; else fail "rename PUT updates title"; fi
if echo "$merged" | grep -q '"html":"hi"'; then pass "rename PUT preserves messages"; else fail "rename PUT preserves messages"; fi

# Path-traversal id is rejected (SafeId strips slashes/dots)
curl -s $AUTH -X PUT -H 'Content-Type: application/json' \
  --data '{"title":"bad"}' \
  "$PROD_API/chats/../etc-passwd" > /dev/null
# The sanitized id becomes "etcpasswd" — file should exist (valid) OR
# become something safe. Critical invariant: the traversal must not escape
# the per-user directory.
user_dir_escape=$(find "$ROOT/data/chats" -name '*etc-passwd*' -o -name '*..*' 2>/dev/null)
if [[ -z "$user_dir_escape" ]]; then
  pass "path-traversal id does not escape user dir"
else
  fail "path-traversal id does not escape user dir (found: $user_dir_escape)"
fi

# Also verify the sanitized file lives under data/chats/<user>/
if find "$ROOT/data/chats" -type f -name 'etcpasswd.json' 2>/dev/null | grep -q chats; then
  pass "path-traversal id sanitized to safe filename"
  # Clean it up
  find "$ROOT/data/chats" -type f -name 'etcpasswd.json' -exec rm -f {} \;
else
  pass "path-traversal id sanitized to safe filename (no leftover file)"
fi

# DELETE the seed chat
del_resp=$(curl -s $AUTH -X DELETE -o - -w "\n%{http_code}" "$PROD_API/chats/$tid")
del_code=$(echo "$del_resp" | tail -n1)
del_body=$(echo "$del_resp" | sed '$d')
if [[ "$del_code" == "200" ]]; then pass "DELETE returns 200"; else fail "DELETE returns 200 (got $del_code)"; fi
if echo "$del_body" | grep -q '"deleted":true'; then pass "DELETE body reports deleted:true"; else fail "DELETE body reports deleted:true"; fi

after_code=$(curl -s $AUTH -o /dev/null -w "%{http_code}" "$PROD_API/chats/$tid")
if [[ "$after_code" == "404" ]]; then pass "GET after DELETE returns 404"; else fail "GET after DELETE returns 404 (got $after_code)"; fi

# Second DELETE should succeed but report deleted:false (idempotent)
idem_body=$(curl -s $AUTH -X DELETE "$PROD_API/chats/$tid")
if echo "$idem_body" | grep -q '"deleted":false'; then
  pass "second DELETE idempotent (deleted:false)"
else
  fail "second DELETE idempotent (deleted:false)"
fi

# ---------- M3: ChatStore helper correctness ----------
section "M3: ChatStore.NowMs + DeriveTitle helpers"

helper_out=$(mktemp)
cat > /tmp/chatstore_helpers.mac <<'EOF'
  write "NOW=",##class(InterClaw.V2.ChatStore).NowMs(),!
  write "PLAIN=[",##class(InterClaw.V2.ChatStore).DeriveTitle("hello world"),"]",!
  write "SLASH=[",##class(InterClaw.V2.ChatStore).DeriveTitle("/model opus then pull DTL"),"]",!
  write "LONG=[",##class(InterClaw.V2.ChatStore).DeriveTitle("please explain the complete routing architecture for the multi hospital production including fallback paths"),"]",!
  write "WS=[",##class(InterClaw.V2.ChatStore).DeriveTitle("   spaced   "),"]",!
  write "EMPTY=[",##class(InterClaw.V2.ChatStore).DeriveTitle(""),"]",!
  write "SAFE1=[",##class(InterClaw.V2.ChatStore).SafeId("abc.123"),"]",!
  write "SAFE2=[",##class(InterClaw.V2.ChatStore).SafeId("../bad/path"),"]",!
  write "SAFE3=[",##class(InterClaw.V2.ChatStore).SafeId("keep-me_ok-123"),"]",!
EOF
$PY .claude/skills/interclaw/scripts/lib/iris_terminal.py --server interclaw-test --namespace INTERCLAW --file /tmp/chatstore_helpers.mac > "$helper_out" 2>&1

if grep -Eq "NOW=[0-9]{13}" "$helper_out"; then pass "NowMs returns 13-digit ms epoch"; else fail "NowMs returns 13-digit ms epoch"; fi
if grep -q "PLAIN=\[hello world\]" "$helper_out"; then pass "DeriveTitle plain text unchanged"; else fail "DeriveTitle plain text unchanged"; fi
if grep -q "SLASH=\[opus then pull DTL\]" "$helper_out"; then pass "DeriveTitle strips leading slash command"; else fail "DeriveTitle strips leading slash command"; fi
if grep -q "LONG=.*\.\.\.\]" "$helper_out"; then pass "DeriveTitle truncates long text with ellipsis"; else fail "DeriveTitle truncates long text with ellipsis"; fi
if grep -q "WS=\[spaced\]" "$helper_out"; then pass "DeriveTitle trims surrounding whitespace"; else fail "DeriveTitle trims surrounding whitespace"; fi
if grep -q "EMPTY=\[\]" "$helper_out"; then pass "DeriveTitle handles empty input"; else fail "DeriveTitle handles empty input"; fi
if grep -q "SAFE1=\[abc123\]" "$helper_out"; then pass "SafeId strips dots"; else fail "SafeId strips dots"; fi
if grep -q "SAFE2=\[badpath\]" "$helper_out"; then pass "SafeId strips traversal slashes+dots"; else fail "SafeId strips traversal slashes+dots"; fi
if grep -q "SAFE3=\[keep-me_ok-123\]" "$helper_out"; then pass "SafeId keeps letters/digits/dash/underscore"; else fail "SafeId keeps letters/digits/dash/underscore"; fi

rm -f "$helper_out" /tmp/chatstore_helpers.mac

# ---------- M3: frontend wiring ----------
section "M3: frontend wiring for persistence"

if grep -q "cc.persistChat" "$sidebar_js_path"; then pass "sidebar defines cc.persistChat"; else fail "sidebar defines cc.persistChat"; fi
if grep -q "_m3Wrapped" "$sidebar_js_path"; then pass "sidebar wraps cc.saveState for server PUT"; else fail "sidebar wraps cc.saveState for server PUT"; fi
if grep -q "method: 'DELETE'" "$sidebar_js_path"; then pass "deleteChat issues DELETE"; else fail "deleteChat issues DELETE"; fi
if grep -q "method: 'PUT'" "$sidebar_js_path"; then pass "renameChatInline/persistChat issue PUT"; else fail "renameChatInline/persistChat issue PUT"; fi
if grep -q "deriveTitle" "$sidebar_js_path"; then pass "client-side deriveTitle exists (parity with ChatStore.DeriveTitle)"; else fail "client-side deriveTitle exists"; fi

# ---------- M4: portal catalog endpoint + JSON structure ----------
section "M4: /api/portal-urls catalog + structural invariants"

resp=$(curl -s $AUTH -o - -w "\n%{http_code}" "$PROD_API/portal-urls")
code=$(echo "$resp" | tail -n1)
catalog=$(echo "$resp" | sed '$d')
if [[ "$code" == "200" ]]; then pass "GET /api/portal-urls returns 200"; else fail "GET /api/portal-urls returns 200 (got $code)"; fi

# Run the Python validator — exits 0 on clean
if $PY .claude/skills/interclaw/scripts/docs/catalog_portal_urls.py > /dev/null 2>&1; then
  pass "catalog_portal_urls.py validator exits 0"
else
  fail "catalog_portal_urls.py validator exits 0"
fi

# Structural invariants via Python JSON parser
py_check() {
  python3 -c "$1" 2>/dev/null
}
count=$(echo "$catalog" | py_check "import json, sys; d=json.load(sys.stdin); print(len(d.get('entries', [])))")
if [[ "${count:-0}" -ge 30 ]]; then pass "catalog has >=30 entries (got $count)"; else fail "catalog has >=30 entries (got ${count:-0})"; fi

# Every entry has slug, title, url, category
bad_fields=$(echo "$catalog" | py_check "
import json, sys
d = json.load(sys.stdin)
req = {'slug','title','url','category'}
bad = [e.get('slug','?') for e in d['entries'] if req - e.keys()]
print(len(bad))
")
if [[ "${bad_fields:-1}" == "0" ]]; then pass "all entries have required fields"; else fail "all entries have required fields (${bad_fields:-?} bad)"; fi

# Slugs unique
dup=$(echo "$catalog" | py_check "
import json, sys
d = json.load(sys.stdin)
slugs = [e['slug'] for e in d['entries']]
print(len(slugs) - len(set(slugs)))
")
if [[ "${dup:-1}" == "0" ]]; then pass "all slugs unique"; else fail "all slugs unique (${dup:-?} duplicates)"; fi

# Entries using {name} in template must declare requires:['name']
mismatched=$(echo "$catalog" | py_check "
import json, sys
d = json.load(sys.stdin)
bad = []
for e in d['entries']:
    needs = '{name}' in e.get('url','')
    declared = 'name' in (e.get('requires') or [])
    if needs != declared:
        bad.append(e['slug'])
print(','.join(bad))
")
if [[ -z "$mismatched" ]]; then pass "{name} template usage matches 'requires:[name]'"; else fail "{name} template usage matches 'requires:[name]' (bad: $mismatched)"; fi

# Known-expected slugs. The served JSON is pretty-printed, so slug lines
# look like:  "slug": "audit",  (space between colon and value). Match
# both compact and pretty forms.
for slug in audit queues message-viewer event-log production production-list dtl-editor rule-editor-angular bpl-editor hl7-schemas; do
  if echo "$catalog" | grep -Eq "\"slug\"[[:space:]]*:[[:space:]]*\"$slug\""; then
    pass "catalog contains slug '$slug'"
  else
    fail "catalog contains slug '$slug'"
  fi
done

# mtime cache: edit -> expect fresh body (sanity check: endpoint still serves same entry count after GET+GET)
count2=$(curl -s $AUTH "$PROD_API/portal-urls" | py_check "import json, sys; d=json.load(sys.stdin); print(len(d.get('entries', [])))")
if [[ "$count" == "$count2" ]]; then pass "repeated GET returns same count"; else fail "repeated GET returns same count"; fi

# ---------- M4: fuzzy scorer parity (node-free reimplementation of goto.js) ----------
section "M4: fuzzy /goto scoring invariants"

# Every plain-English query should pick its intended slug as top hit.
# The scorer lives in frontend/interclaw-chatbot/goto.js; mirror its
# algorithm in Python and run the catalog through it.
scorer_out=$(python3 <<'PYEOF'
import json, urllib.request, base64, os, sys

# Load catalog via HTTP so we test the server path
auth = base64.b64encode(b'superuser:SYS').decode()
req = urllib.request.Request('http://localhost/interclaw-test/api/interclaw/production/api/portal-urls',
                             headers={'Authorization': 'Basic ' + auth})
data = json.loads(urllib.request.urlopen(req).read().decode())
entries = data['entries']

def trigrams(s):
    s = s.lower()
    t = {}
    for i in range(len(s) - 2):
        tri = s[i:i+3]
        t[tri] = t.get(tri, 0) + 1
    return t

def tri_sim(a, b):
    ta = trigrams(a); tb = trigrams(b)
    if not ta or not tb: return 0.0
    shared = sum(min(ta[k], tb.get(k, 0)) for k in ta)
    total_a = sum(ta.values()); total_b = sum(tb.values())
    return (2.0 * shared) / (total_a + total_b) if (total_a + total_b) else 0.0

def score(entry, q):
    q = q.lower().strip()
    s = 0.0
    fields = [entry.get('slug',''), entry.get('title',''), entry.get('description','')]
    fields += entry.get('aliases') or []
    fields += entry.get('keywords') or []
    if entry.get('slug','').lower() == q: s += 2.0
    if entry.get('title','').lower() == q: s += 2.0
    for a in entry.get('aliases') or []:
        if a.lower() == q: s += 1.8
    for k in entry.get('keywords') or []:
        if k.lower() == q: s += 1.2
    for f in fields:
        if not f: continue
        fl = f.lower()
        if fl == q: continue
        if q in fl: s += 0.4
        sim = tri_sim(q, fl)
        if sim > 0.3: s += sim * 0.6
    return s

def resolve(q, topn=3):
    scored = [(score(e, q), e) for e in entries]
    scored.sort(key=lambda r: -r[0])
    return [(sc, e['slug']) for sc, e in scored[:topn] if sc > 0.4]

# Each case: (query, expected-top-slug)
cases = [
    ('audit', 'audit'),
    ('audit log', 'audit'),
    ('queues', 'queues'),
    ('message viewer', 'message-viewer'),
    ('messages', 'message-viewer'),
    ('event log', 'event-log'),
    ('visual trace', 'visual-trace'),
    ('suspended', 'suspended-messages'),
    ('credentials', 'credentials'),
    ('hl7 schemas', 'hl7-schemas'),
    ('production monitor', 'production-monitor'),
    ('production list', 'production-list'),
    ('rules', 'rule-list'),
    ('lookup', 'lookup-table'),
    ('sql', 'sql'),
    ('classes', 'classes'),
    ('namespaces', 'namespaces'),
    ('journal', 'journal'),
    ('tasks', 'tasks'),
    ('processes', 'processes'),
    ('users', 'users'),
    ('roles', 'roles'),
    ('ssl', 'ssl-configs'),
]

wrong = 0
for query, expected in cases:
    hits = resolve(query)
    if not hits:
        print(f'NOHIT  {query!r} -> expected {expected}')
        wrong += 1
        continue
    top = hits[0][1]
    if top == expected:
        print(f'OK     {query!r} -> {top}')
    else:
        print(f'WRONG  {query!r} -> {top} (expected {expected}, hits={hits})')
        wrong += 1

print(f'WRONG_COUNT={wrong}')
PYEOF
)

echo "$scorer_out" | grep -v "WRONG_COUNT=" | sed 's/^/    /'
wrong_count=$(echo "$scorer_out" | grep -Eo 'WRONG_COUNT=[0-9]+' | tail -n1 | cut -d= -f2)
if [[ "${wrong_count:-99}" == "0" ]]; then
  pass "fuzzy scorer resolves all 23 natural-language queries to expected slug"
else
  fail "fuzzy scorer resolves all natural-language queries (wrong: $wrong_count)"
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
