#!/usr/bin/env bash
# PostToolUse hook (matcher: Write|Edit).
# Purpose: after a file write/edit completes, note when it touched a
# sensitive path (auth, payments, migrations, CI/CD, infra-as-code,
# credentials-adjacent config) so the change gets extra review attention.
# Purely informational — never blocks, never modifies anything, never
# transmits anything externally. Exit code is always 0.
#
# Input: JSON on stdin with `tool_input.file_path`.

set -euo pipefail

INPUT="$(cat)"

FILE_PATH="$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get("tool_input", {}).get("file_path", ""))
except Exception:
    print("")
' 2>/dev/null || true)"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

case "$FILE_PATH" in
  *auth*|*Auth*|*payment*|*Payment*|*billing*|*Billing*|*migration*|*Migration*| \
  *.github/workflows/*|*.gitlab-ci*|*Dockerfile*|*docker-compose*|*terraform*|*.tf| \
  *credentials*|*secrets*|*.env*)
    echo "[engineering-copilot] Note: '$FILE_PATH' is a sensitive path (auth/payments/migrations/CI-CD/infra/credentials-adjacent). Consider running /engineering-copilot:review or /engineering-copilot:security before shipping this change." >&2
    ;;
esac

exit 0
