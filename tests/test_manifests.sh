#!/usr/bin/env bash
# Validates .claude-plugin/plugin.json and marketplace.json.
set -uo pipefail
cd "$(dirname "$0")/.."

FAIL=0

check_json() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "FAIL: $file does not exist"
    FAIL=1
    return
  fi
  if ! python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
    echo "FAIL: $file is not valid JSON"
    FAIL=1
    return
  fi
  echo "PASS: $file is valid JSON"
}

check_json ".claude-plugin/plugin.json"
check_json ".claude-plugin/marketplace.json"

python3 - <<'EOF' || FAIL=1
import json, sys

with open(".claude-plugin/plugin.json") as f:
    plugin = json.load(f)

required = ["name", "version", "description"]
missing = [k for k in required if k not in plugin]
if missing:
    print(f"FAIL: plugin.json missing required fields: {missing}")
    sys.exit(1)
print("PASS: plugin.json has required fields (name, version, description)")

with open(".claude-plugin/marketplace.json") as f:
    marketplace = json.load(f)

required_mkt = ["name", "owner", "plugins"]
missing_mkt = [k for k in required_mkt if k not in marketplace]
if missing_mkt:
    print(f"FAIL: marketplace.json missing required fields: {missing_mkt}")
    sys.exit(1)
print("PASS: marketplace.json has required fields (name, owner, plugins)")

if not isinstance(marketplace["plugins"], list) or len(marketplace["plugins"]) == 0:
    print("FAIL: marketplace.json 'plugins' must be a non-empty list")
    sys.exit(1)

for p in marketplace["plugins"]:
    if "name" not in p or "source" not in p:
        print(f"FAIL: marketplace plugin entry missing name/source: {p}")
        sys.exit(1)
print("PASS: marketplace.json plugin entries have name + source")
EOF

exit $FAIL
