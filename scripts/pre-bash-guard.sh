#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash).
# Purpose: warn — never silently block — when a Bash command about to run
# looks destructive (per docs/safety.md's "Destructive Operations" list).
# This hook is intentionally conservative: it never exits non-zero to block
# the command outright. It only adds context reminding Claude to confirm
# with the user first, because Engineering Copilot's safety principles
# require explicit confirmation before destructive operations, and a hook
# has no way to actually collect that confirmation itself.
#
# Input: JSON on stdin with a `tool_input.command` field (Claude Code's
# standard PreToolUse payload for the Bash tool).
# Output: on match, a short warning printed to stderr. Exit code is always 0.

set -euo pipefail

INPUT="$(cat)"

COMMAND="$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get("tool_input", {}).get("command", ""))
except Exception:
    print("")
' 2>/dev/null || true)"

if [ -z "$COMMAND" ]; then
  exit 0
fi

PATTERNS=(
  "rm -rf"
  "rm -fr"
  "git reset --hard"
  "git clean -f"
  "git push --force"
  "git push -f"
  "git filter-branch"
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE"
  ":(){ :|:& };:"
)

for pattern in "${PATTERNS[@]}"; do
  if printf '%s' "$COMMAND" | grep -qiF "$pattern"; then
    echo "[engineering-copilot] Heads up: this command ('$pattern') is treated as destructive by Engineering Copilot's safety principles. Confirm with the user before running it, and explain what it will do." >&2
    break
  fi
done

exit 0
