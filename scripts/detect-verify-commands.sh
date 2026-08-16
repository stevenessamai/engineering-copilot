#!/usr/bin/env bash
# Utility script (not a hook): prints a best-effort list of the project's
# own test/lint/typecheck/build commands, discovered from real project
# files, for /engineering-copilot:verify and /engineering-copilot:ship to
# use instead of guessing generic commands. Read-only.
#
# Usage: scripts/detect-verify-commands.sh [path-to-project-root]

set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

echo "## Discovered verification commands"
echo

if [ -f package.json ]; then
  echo "### package.json scripts"
  python3 -c '
import json
try:
    with open("package.json") as f:
        data = json.load(f)
    scripts = data.get("scripts", {})
    for name in ("test", "lint", "typecheck", "type-check", "build"):
        if name in scripts:
            print(f"- npm run {name}  →  {scripts[name]}")
except Exception as e:
    print(f"(could not parse package.json: {e})")
'
  echo
fi

if [ -f pyproject.toml ]; then
  echo "### pyproject.toml signals"
  grep -qE "pytest" pyproject.toml && echo "- pytest  →  pytest"
  grep -qE "\[tool\.ruff\]" pyproject.toml && echo "- ruff  →  ruff check ."
  grep -qE "\[tool\.black\]" pyproject.toml && echo "- black  →  black --check ."
  grep -qE "\[tool\.mypy\]" pyproject.toml && echo "- mypy  →  mypy ."
  echo
fi

if [ -f Makefile ]; then
  echo "### Makefile targets"
  grep -E "^(test|lint|check|build|verify)[[:space:]]*:" Makefile | sed 's/:.*/  →  make &/' || true
  echo
fi

if [ -f justfile ]; then
  echo "### justfile recipes"
  grep -E "^(test|lint|check|build|verify):" justfile | sed 's/:.*/  →  just &/' || true
  echo
fi

if [ -d .github/workflows ]; then
  echo "### CI workflow files (source of truth if it disagrees with the above)"
  ls .github/workflows/*.y*ml 2>/dev/null || true
  echo
fi

echo "If nothing above was found, verification commands could not be determined from repository evidence — ask the user how this project verifies itself."
