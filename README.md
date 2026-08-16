# Tests

Structural and behavioral validation for the Engineering Copilot plugin repository itself (not for codebases the plugin is used on).

## Running

```bash
bash tests/run_all.sh
```

This runs every test script in this directory and reports a pass/fail summary. Individual scripts can also be run directly, e.g. `bash tests/test_manifests.sh`.

## What's covered

| Script | Checks |
|---|---|
| `test_manifests.sh` | `plugin.json` and `marketplace.json` are valid JSON and have required fields |
| `test_skills.sh` | Every `skills/*/SKILL.md` exists, has valid frontmatter (`name`, `description`), and the frontmatter `name` matches the folder name; no duplicate skill names |
| `test_agents.sh` | Every `agents/*.md` has valid frontmatter (`name`, `description`, `tools`); no duplicate agent names |
| `test_hooks.sh` | `hooks/hooks.json` is valid JSON; every script it references exists and is executable; each hook script runs against sample input and exits `0` |
| `test_scripts.sh` | Every file in `scripts/` and `bin/` is executable and has a shebang |
| `test_no_placeholders.sh` | No `TODO`, `FIXME`, or "implement later" strings remain outside of intentional deployment placeholders (`YOUR_GITHUB_USERNAME`, `SECURITY_CONTACT_HERE`) |
| `test_no_secrets.sh` | No obvious committed secrets, using the same heuristic scan as `bin/ec-secret-scan` |

## What this does not do

This suite does not replace `claude plugin validate .` — run that too if your installed Claude Code version supports it (checked with `command -v claude` in `run_all.sh`; skipped with a note if unavailable, never assumed). It also does not perform a live install/discovery test inside a running Claude Code session — see `README.md`'s "Development" section for that manual step.
