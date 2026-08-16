#!/usr/bin/env bash
# Validates every skills/*/SKILL.md: frontmatter present, name matches
# folder, description present, and no duplicate skill names.
set -uo pipefail
cd "$(dirname "$0")/.."

FAIL=0
EXPECTED_SKILLS="analyze plan implement debug review test refactor docs dependencies security architecture verify ship"

for name in $EXPECTED_SKILLS; do
  f="skills/$name/SKILL.md"
  if [ ! -f "$f" ]; then
    echo "FAIL: missing $f"
    FAIL=1
    continue
  fi
done

python3 - <<'EOF' || FAIL=1
import re, sys, glob

seen_names = {}
fail = False

for path in sorted(glob.glob("skills/*/SKILL.md")):
    folder = path.split("/")[1]
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

    if not name_match:
        print(f"FAIL: {path} frontmatter missing 'name'")
        fail = True
        continue
    if not desc_match or len(desc_match.group(1).strip()) < 20:
        print(f"FAIL: {path} frontmatter missing or too-short 'description'")
        fail = True
        continue

    skill_name = name_match.group(1).strip()
    if skill_name != folder:
        print(f"FAIL: {path} frontmatter name '{skill_name}' does not match folder '{folder}'")
        fail = True

    if skill_name in seen_names:
        print(f"FAIL: duplicate skill name '{skill_name}' in {path} and {seen_names[skill_name]}")
        fail = True
    else:
        seen_names[skill_name] = path

    for required_section in ["## Purpose", "## When to use", "## Safety constraints", "## Workflow"]:
        if required_section not in content:
            print(f"FAIL: {path} missing required section '{required_section}'")
            fail = True

    print(f"PASS: {path}")

sys.exit(1 if fail else 0)
EOF

exit $FAIL
