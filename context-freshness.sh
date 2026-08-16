#!/usr/bin/env bash
# SessionStart hook.
# Purpose: at the start of a session, check whether
# .claude/engineering-copilot/project-context.md exists and how old it is
# relative to the latest commit, so Claude knows whether to suggest
# refreshing it with /engineering-copilot:analyze before relying on it.
# Read-only, informational, never blocks. Exit code is always 0.

set -euo pipefail

CONTEXT_FILE=".claude/engineering-copilot/project-context.md"

if [ ! -f "$CONTEXT_FILE" ]; then
  echo "[engineering-copilot] No project context found yet. Run /engineering-copilot:analyze to build one — later skills (plan, review, architecture) will use it instead of re-discovering the codebase each time." >&2
  exit 0
fi

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  CONTEXT_MTIME=$(stat -c %Y "$CONTEXT_FILE" 2>/dev/null || stat -f %m "$CONTEXT_FILE" 2>/dev/null || echo 0)
  LAST_COMMIT_TIME=$(git log -1 --format=%ct 2>/dev/null || echo 0)
  if [ "$LAST_COMMIT_TIME" -gt "$CONTEXT_MTIME" ]; then
    echo "[engineering-copilot] project-context.md predates the latest commit. It may be stale — consider running /engineering-copilot:analyze to refresh it." >&2
  fi
fi

exit 0
