#!/usr/bin/env bash
# Heuristic scan for accidentally committed secrets across the repo,
# using the same pattern set as bin/ec-secret-scan. Excludes this test
# file, the hook/CLI scripts that legitimately contain the patterns as
# code (not as secrets), and .git.
set -uo pipefail
cd "$(dirname "$0")/.."

FAIL=0
PATTERN='(AKIA[0-9A-Z]{16})|(sk-[A-Za-z0-9]{20,})|(ghp_[A-Za-z0-9]{30,})|(-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----)'

MATCHES=$(grep -rnE "$PATTERN" \
  --exclude-dir=.git \
  --exclude="test_no_secrets.sh" \
  --exclude="pre-write-secret-scan.sh" \
  --exclude="ec-secret-scan" \
  --exclude="hooks.md" \
  . 2>/dev/null || true)

if [ -n "$MATCHES" ]; then
  echo "FAIL: possible committed secret found:"
  echo "$MATCHES"
  FAIL=1
else
  echo "PASS: no obvious committed secrets found (heuristic scan)"
fi

exit $FAIL
