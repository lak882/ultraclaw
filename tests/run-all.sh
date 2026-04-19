#!/usr/bin/env bash
# run-all.sh — run every regression suite in tests/ and report combined totals.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

overall_rc=0
# Discover every *.sh in tests/ (excluding self) so newly-added suites run
# automatically without having to edit this file.
suites=()
for f in tests/*.sh; do
  name=$(basename "$f")
  [[ "$name" == "run-all.sh" ]] && continue
  suites+=("$f")
done

for suite in "${suites[@]}"; do
  printf "\n\033[1m########## %s ##########\033[0m\n" "$suite"
  if bash "$suite"; then
    printf "\033[32m[OK]\033[0m %s\n" "$suite"
  else
    printf "\033[31m[FAIL]\033[0m %s\n" "$suite"
    overall_rc=1
  fi
done
exit $overall_rc
