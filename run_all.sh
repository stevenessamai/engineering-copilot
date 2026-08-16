#!/usr/bin/env bash
# Runs every test script in this directory and reports a summary.
set -uo pipefail
cd "$(dirname "$0")"

TOTAL=0
PASSED=0
FAILED_SCRIPTS=()

for script in test_manifests.sh test_skills.sh test_agents.sh test_hooks.sh test_scripts.sh test_no_placeholders.sh test_no_secrets.sh; do
  echo "=================================================="
  echo "Running $script"
  echo "=================================================="
  TOTAL=$((TOTAL + 1))
  if bash "$script"; then
    PASSED=$((PASSED + 1))
  else
    FAILED_SCRIPTS+=("$script")
  fi
  echo
done

echo "=================================================="
echo "Summary: $PASSED / $TOTAL test scripts passed"
if [ "${#FAILED_SCRIPTS[@]}" -gt 0 ]; then
  echo "Failed: ${FAILED_SCRIPTS[*]}"
fi
echo "=================================================="

if command -v claude >/dev/null 2>&1; then
  echo
  echo "Detected 'claude' CLI — running official plugin validation:"
  (cd .. && claude plugin validate .) || echo "Note: 'claude plugin validate .' reported issues above."
else
  echo
  echo "Note: 'claude' CLI not found in this environment — skipped 'claude plugin validate .'. Run it manually where Claude Code is installed."
fi

[ "${#FAILED_SCRIPTS[@]}" -eq 0 ]
