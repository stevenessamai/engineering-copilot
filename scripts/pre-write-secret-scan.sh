#!/usr/bin/env bash
# PreToolUse hook (matcher: Write|Edit).
# Purpose: warn before writing content that looks like it contains a live
# secret (API key, private key, token). This is a best-effort heuristic
# scan, not a guarantee — it runs locally and never transmits anything
# anywhere. Non-blocking: it warns via stderr and always exits 0, so it
# never gets in the way of normal development.
#
# Input: JSON on stdin with `tool_input.content` (Write) or
# `tool_input.new_string` (Edit).

set -euo pipefail

INPUT="$(cat)"

CONTENT="$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    ti = data.get("tool_input", {})
    print(ti.get("content") or ti.get("new_string") or "")
except Exception:
    print("")
' 2>/dev/null || true)"

if [ -z "$CONTENT" ]; then
  exit 0
fi

# Heuristic patterns for common secret shapes. Intentionally broad and
# best-effort — false negatives are expected, false positives are fine
# since this only warns.
if printf '%s' "$CONTENT" | grep -qE \
  -e "AKIA[0-9A-Z]{16}" \
  -e "sk-[A-Za-z0-9]{20,}" \
  -e "ghp_[A-Za-z0-9]{30,}" \
  -e "-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----" \
  || printf '%s' "$CONTENT" | grep -qEi \
  -e "(api_key|apikey|secret|password|token)[[:space:]]*[:=][[:space:]]*['\"][A-Za-z0-9/+_-]{16,}['\"]"; then
  echo "[engineering-copilot] This write looks like it may contain a live secret or key. Double-check before committing, and prefer environment variables over hardcoded credentials." >&2
fi

exit 0
