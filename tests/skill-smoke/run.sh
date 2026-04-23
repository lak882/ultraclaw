#!/usr/bin/env bash
# Skill smoke test runner. Runs each probe in probes/*.sh, collects
# pass/fail, prints a summary. Exits non-zero on any failure.
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export INTERCLAW_URL="${INTERCLAW_URL:-http://vmdev1.iscinternal.com/interclaw-test}"
export INTERCLAW_USER="${INTERCLAW_USER:-SuperUser}"
export INTERCLAW_PASS="${INTERCLAW_PASS:-SYS}"
export INTERCLAW_NS="${INTERCLAW_NS:-ULTRACLAW}"
export INTERCLAW_LIB="$DIR/lib.sh"

passed=0
failed=0
names_failed=()

printf "%-40s %s\n" "probe" "result"
printf "%-40s %s\n" "----------------------------------------" "------"

for probe in "$DIR"/probes/*.sh; do
    name=$(basename "$probe" .sh)
    out=$(bash "$probe" 2>&1)
    rc=$?
    if [ $rc -eq 0 ]; then
        passed=$((passed + 1))
        printf "%-40s %s\n" "$name" "PASS"
    else
        failed=$((failed + 1))
        names_failed+=("$name")
        printf "%-40s %s\n" "$name" "FAIL"
        echo "  $out" | head -3 | sed 's/^/    /'
    fi
done

echo
printf "Summary: %d passed, %d failed\n" "$passed" "$failed"
if [ $failed -gt 0 ]; then
    echo "Failed probes:"
    for n in "${names_failed[@]}"; do
        echo "  - $n"
    done
    exit 1
fi
exit 0
