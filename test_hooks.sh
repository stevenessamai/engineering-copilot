#!/usr/bin/env bash
# Validates hooks/hooks.json: valid JSON, referenced scripts exist and are
# executable, and each script runs against sample input without error.
set -uo pipefail
cd "$(dirname "$0")/.."

FAIL=0

if ! python3 -c "import json; json.load(open('hooks/hooks.json'))" 2>/dev/null; then
  echo "FAIL: hooks/hooks.json is not valid JSON"
  exit 1
fi
echo "PASS: hooks/hooks.json is valid JSON"

# Extract referenced script paths (expand ${CLAUDE_PLUGIN_ROOT} to repo root)
SCRIPTS=$(python3 -c "
import json
data = json.load(open('hooks/hooks.json'))
paths = []
for event, entries in data.get('hooks', {}).items():
    for entry in entries:
        for h in entry.get('hooks', []):
            cmd = h.get('command', '')
            paths.append(cmd.replace('\${CLAUDE_PLUGIN_ROOT}', '.'))
print('\n'.join(paths))
")

while IFS= read -r script; do
  [ -z "$script" ] && continue
  if [ ! -f "$script" ]; then
    echo "FAIL: hooks.json references missing script: $script"
    FAIL=1
    continue
  fi
  if [ ! -x "$script" ]; then
    echo "FAIL: $script is not executable"
    FAIL=1
    continue
  fi
  echo "PASS: $script exists and is executable"
done <<< "$SCRIPTS"

# Functional smoke tests
run_hook() {
  local script="$1" input="$2" desc="$3"
  local out rc
  out=$(echo "$input" | "$script" 2>&1)
  rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "FAIL: $script ($desc) exited $rc, expected 0"
    FAIL=1
  else
    echo "PASS: $script ($desc) exited 0"
  fi
}

run_hook "scripts/pre-bash-guard.sh" '{"tool_input":{"command":"rm -rf /tmp/x"}}' "destructive command"
run_hook "scripts/pre-bash-guard.sh" '{"tool_input":{"command":"ls"}}' "safe command"
run_hook "scripts/pre-write-secret-scan.sh" '{"tool_input":{"content":"const x = 1;"}}' "clean content"
run_hook "scripts/sensitive-file-notice.sh" '{"tool_input":{"file_path":"src/index.js"}}' "non-sensitive path"
run_hook "scripts/context-freshness.sh" '' "session start"

exit $FAIL
