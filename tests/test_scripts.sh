#!/usr/bin/env bash
# Validates every file in scripts/ and bin/: executable, has a shebang.
set -uo pipefail
cd "$(dirname "$0")/.."

FAIL=0

for f in scripts/*.sh bin/*; do
  [ -f "$f" ] || continue
  if [ ! -x "$f" ]; then
    echo "FAIL: $f is not executable"
    FAIL=1
    continue
  fi
  first_line=$(head -n1 "$f")
  if [[ "$first_line" != "#!"* ]]; then
    echo "FAIL: $f has no shebang line"
    FAIL=1
    continue
  fi
  echo "PASS: $f is executable with a shebang"
done

exit $FAIL
