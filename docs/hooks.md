# Hooks

Engineering Copilot ships four hooks, all conservative by design: they inform, they never block normal development, and they never transmit anything outside your machine.

| Hook | Event | Matcher | Script | Purpose |
|---|---|---|---|---|
| Destructive command guard | `PreToolUse` | `Bash` | `scripts/pre-bash-guard.sh` | Warns when a command about to run matches a known-destructive pattern (`rm -rf`, `git reset --hard`, force push, `DROP TABLE`, etc.), reminding Claude to get explicit confirmation first. |
| Secret write scan | `PreToolUse` | `Write\|Edit` | `scripts/pre-write-secret-scan.sh` | Heuristically scans content about to be written for patterns that look like live API keys, tokens, or private keys, and warns before the write completes. |
| Sensitive file notice | `PostToolUse` | `Write\|Edit` | `scripts/sensitive-file-notice.sh` | After a write/edit, notes when the touched file is in a sensitive area (auth, payments, migrations, CI/CD, infrastructure-as-code) and suggests running `/engineering-copilot:review` or `/engineering-copilot:security`. |
| Context freshness check | `SessionStart` | — | `scripts/context-freshness.sh` | At session start, checks whether `.claude/engineering-copilot/project-context.md` exists and is newer than the latest commit, suggesting `/engineering-copilot:analyze` if it's missing or stale. |

## Design constraints every hook follows

- **Never block.** Every hook exits `0` unconditionally. They print warnings to stderr as context for Claude to act on (e.g. asking the user to confirm), but they never prevent a tool call from completing. This matches the plugin's principle: "Hooks must be conservative. Never block normal development unnecessarily."
- **Local only.** No hook makes a network call or writes data anywhere outside the repository. Nothing is transmitted externally.
- **Best-effort, not a guarantee.** The secret-scan hook and its CLI counterpart (`bin/ec-secret-scan`, used by `/ship`) are heuristic pattern matches. They catch common shapes of live credentials but are not a substitute for a dedicated secrets-scanning tool, and false negatives are expected.
- **No project data leaves the machine.** All scripts operate on the JSON payload Claude Code hands them on stdin and inspect local files only.

## Testing hooks locally

Each script accepts the same JSON-on-stdin shape Claude Code sends. For example:

```bash
echo '{"tool_input":{"command":"rm -rf build/"}}' | scripts/pre-bash-guard.sh
echo '{"tool_input":{"content":"const key = \"sk-abcdefghijklmnopqrstuvwxyz\";"}}' | scripts/pre-write-secret-scan.sh
echo '{"tool_input":{"file_path":"src/auth/login.py"}}' | scripts/sensitive-file-notice.sh
scripts/context-freshness.sh
```

See `tests/test_hooks.sh` for the automated version of these checks.
