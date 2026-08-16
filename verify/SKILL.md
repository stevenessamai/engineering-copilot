---
name: verify
description: Discover and run the project's own native tests, lint, type-check, and build commands to verify recent changes, without inventing commands the repository doesn't define. Use when the user asks to verify, check, or confirm changes work, or runs /engineering-copilot:verify.
---

# Verify

## Purpose

Confirm changes actually work using the project's own tooling — never a guess at what commands "should" exist.

## When to use

- The user runs `/engineering-copilot:verify`.
- Called internally by `/implement` and `/ship` after making changes.
- The user asks whether recent changes are safe/working.

## Safety constraints

- **Do not invent commands** when the repository already defines them. Discover real commands before running anything.
- Do not claim a check passed without having actually run it and observed the result.

## Command discovery

Check, in order, and use whatever the project actually defines:
1. `package.json` → `scripts` (`test`, `lint`, `typecheck`, `build`).
2. `pyproject.toml` → `[tool.pytest]`, configured linters (`ruff`, `flake8`, `black --check`, `mypy`), and build backend.
3. `Makefile` / `justfile` → targets named `test`, `lint`, `check`, `build`, `verify`.
4. CI configuration (`.github/workflows/*.yml`, `.gitlab-ci.yml`) — the exact commands CI runs are the most reliable source of truth for what "verified" means for this project.
5. `README.md` — explicit developer instructions, if the above don't cover everything.
6. Existing scripts in `scripts/` or `bin/` that wrap verification.

If two sources disagree (e.g. `README.md` is stale relative to CI config), trust CI config and note the discrepancy so `/docs` can fix the README.

## Workflow

1. Discover commands as above, scoped to what's relevant to the current change (don't run a full monorepo build to verify a one-file change unless that's genuinely necessary).
2. Run tests.
3. Run lint.
4. Run type checking.
5. Run build.
6. Run any relevant runtime/smoke checks the project defines.
7. Confirm the specific behavior that was supposed to change actually changed (not just "tests pass" in the abstract — tie back to the change's intent).
8. Check configuration/environment assumptions the change relies on are documented or already satisfied.

## Output format

```
## Commands discovered
(source: package.json / Makefile / CI config / etc., and the exact command)

## Results
| Check | Command | Result |
|---|---|---|

## Behavior confirmation
(did the specific intended change actually happen — yes/no with evidence)

## Not verified
(anything that couldn't be checked in this environment, with reason)
```

## Failure handling

- If no verification commands can be discovered at all, say so explicitly and suggest the user specify how this project verifies itself, rather than fabricating a generic `npm test`/`pytest` guess without confirming it exists.
