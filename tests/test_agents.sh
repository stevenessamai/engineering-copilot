#!/usr/bin/env bash
# Validates every agents/*.md: frontmatter present (name, description,
# tools), and no duplicate agent names.
set -uo pipefail
cd "$(dirname "$0")/.."

FAIL=0
EXPECTED_AGENTS="codebase-analyst debugger security-reviewer architecture-reviewer test-engineer code-reviewer refactoring-engineer dependency-analyst documentation-engineer"

for name in $EXPECTED_AGENTS; do
  f="agents/$name.md"
  if [ ! -f "$f" ]; then
    echo "FAIL: missing $f"
    FAIL=1
  fi
done

python3 - <<'EOF' || FAIL=1
import re, sys, glob

seen_names = {}
fail = False

for path in sorted(glob.glob("agents/*.md")):
    with open(path) as f:
        content = f.read()

    m = re.match(r"^---\n(.*?)\n---\n", content, re.DOTALL)
    if not m:
        print(f"FAIL: {path} missing YAML frontmatter block")
        fail = True
        continue

    frontmatter = m.group(1)
    name_match = re.search(r"^name:\s*(\S+)", frontmatter, re.MULTILINE)
    desc_match = re.search(r"^description:\s*(.+)$", frontmatter, re.MULTILINE)
    tools_match = re.search(r"^tools:\s*(.+)$", frontmatter, re.MULTILINE)

    if not name_match:
        print(f"FAIL: {path} frontmatter missing 'name'")
        fail = True
        continue
    if not desc_match or len(desc_match.group(1).strip()) < 20:
        print(f"FAIL: {path} frontmatter missing or too-short 'description'")
        fail = True
    if not tools_match:
        print(f"FAIL: {path} frontmatter missing 'tools'")
        fail = True

    agent_name = name_match.group(1).strip()
    if agent_name in seen_names:
        print(f"FAIL: duplicate agent name '{agent_name}' in {path} and {seen_names[agent_name]}")
        fail = True
    else:
        seen_names[agent_name] = path

    for required_section in ["## Role", "## Responsibility", "## Instructions", "## Constraints", "## Expected output", "## Safety rules"]:
        if required_section not in content:
            print(f"FAIL: {path} missing required section '{required_section}'")
            fail = True

    print(f"PASS: {path}")

sys.exit(1 if fail else 0)
EOF

exit $FAIL
