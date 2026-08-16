#!/usr/bin/env bash
# Fails if disallowed placeholder markers exist as actual unresolved
# placeholders (code-style markers, not prose that documents this
# feature or the plugin's own TODO/FIXME-detection behavior).
set -uo pipefail
cd "$(dirname "$0")/.."

FAIL=0

# Files that legitimately reference TODO/FIXME/placeholder terminology
# as documentation of a *feature* (e.g. "/analyze greps for TODO/FIXME"),
# not as an actual unresolved placeholder left in this repo.
META_EXCLUDES=(
  "--exclude-dir=.git"
  "--exclude=test_no_placeholders.sh"
  "--exclude=SKILL.md"
  "--exclude=README.md"
  "--exclude=CONTRIBUTING.md"
)

# Real, unresolved placeholder markers: a code-comment-style TODO/FIXME,
# or the literal phrase "implement later" used as an instruction to self.
MATCHES=$(grep -rnE "(#|//|/\*)\s*(TODO|FIXME)\b|implement later" \
  "${META_EXCLUDES[@]}" \
  . 2>/dev/null || true)

if [ -n "$MATCHES" ]; then
  echo "FAIL: unresolved placeholder markers found:"
  echo "$MATCHES"
  FAIL=1
else
  echo "PASS: no unresolved TODO/FIXME/'implement later' code markers found"
fi

# Confirm the only allowed ALL-CAPS deployment placeholders are the
# intentional ones. Scope this to values that look like a real
# placeholder token (ALL_CAPS_WITH_UNDERSCORES), not filenames or
# ordinary prose, and exclude this test script itself and run_all.sh
# (whose own name / file list legitimately contain the word "placeholder").
ALLOWED='YOUR_GITHUB_USERNAME|SECURITY_CONTACT_HERE'
PLACEHOLDER_LIKE=$(grep -rnoE "\b[A-Z][A-Z0-9]*(_[A-Z0-9]+){1,}_HERE\b|\bYOUR_[A-Z0-9_]+\b" \
  --exclude-dir=.git \
  --exclude="test_no_placeholders.sh" \
  --exclude="run_all.sh" \
  . 2>/dev/null | grep -vE "$ALLOWED" || true)

if [ -n "$PLACEHOLDER_LIKE" ]; then
  echo "FAIL: unexpected placeholder-like tokens found (only YOUR_GITHUB_USERNAME and SECURITY_CONTACT_HERE are allowed):"
  echo "$PLACEHOLDER_LIKE"
  FAIL=1
else
  echo "PASS: only intentional deployment placeholders present"
fi

exit $FAIL
