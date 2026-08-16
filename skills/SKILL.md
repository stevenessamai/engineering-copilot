---
name: implement
description: Execute an approved plan from .claude/engineering-copilot/plans/ incrementally, running tests and lint after changes, and stopping to confirm if the codebase has drifted from the plan. Use when the user runs /engineering-copilot:implement or says "implement the plan", "go ahead and build it", after a /plan has been produced.
---

# Implement

## Purpose

Execute an already-approved plan against the real codebase, safely and incrementally, and report exactly what changed.

## When to use

- The user runs `/engineering-copilot:implement`.
- The user has just approved a plan produced by `/plan` and asks to proceed.

## Safety constraints

- **Never blindly execute a stale plan.** Always validate the plan against the current codebase state first (step 3 below).
- Treat destructive operations (see `docs/safety.md`) as high risk: never run `rm -rf`, `git reset --hard`, `git clean -fd`, force-push, destructive migrations, or mass deletions without explicit user confirmation for that specific operation, even if the plan mentions them.
- Make changes incrementally and verify after each meaningful step rather than making every change and verifying once at the end — this makes failures easier to isolate and revert.
- Never fabricate a test result or claim verification passed without actually running it.

## Workflow

1. **Locate the latest relevant plan** in `.claude/engineering-copilot/plans/`. If multiple plans could match the user's current request, ask which one, or use the most recently modified one if the intent is unambiguous.
2. **Read the plan fully** before touching any file.
3. **Validate the plan against the current codebase.** Check that files listed as "Files to modify" still exist and roughly match the described current state; check that "Dependencies" listed as prerequisites are actually satisfied. Use `git status` / `git diff` to see whether anything has changed since planning.
4. **Detect unexpected drift.** If the codebase has changed significantly in the areas the plan touches (files deleted, renamed, or substantially rewritten; conflicting new code in the same area), **STOP** and explain the mismatch to the user. Ask for confirmation before proceeding — do not silently adapt a stale plan.
5. **Implement changes incrementally**, following the plan's ordered "Implementation steps." Prefer one logical change per step, matching existing code style and conventions observed during `/analyze` or `/plan`.
6. **Run relevant tests after changes** — scoped to the affected area first (fast feedback), then the broader suite if the change has cross-cutting impact.
7. **Fix failures** introduced by the new code. Do not silence or delete failing tests to make the suite pass — fix the implementation, or if the test itself was wrong, say so explicitly and explain why before changing it.
8. **Run linting/type checking** where the project has it configured (discovered via `/verify`'s command-discovery approach — `package.json` scripts, `Makefile`, `pyproject.toml`, CI config).
9. **Verify behavior** against the plan's "Acceptance criteria" and "Verification commands."
10. **Summarize exactly what changed**: files created, modified, deleted; commands run and their results; any deviation from the plan and why.

## Output format

```
## Plan used
(path to the plan file, and a one-line restatement of its objective)

## Drift check
(what was validated, and whether the plan still matches — or what changed and why implementation was paused)

## Changes made
(file-by-file: created / modified / deleted, with a one-line description of each)

## Tests run
(command, scope, result)

## Lint / type check
(command, result)

## Verification
(acceptance criteria from the plan, checked off individually)

## Deviations from plan
(any, with justification — or "None")

## Next steps
(anything left for the user: manual config, external provider setup, follow-up work)
```

## Failure handling

- If a test framework or lint tool isn't available in the environment, say so and report what could not be verified rather than skipping the report entirely.
- If implementation must stop partway through due to drift or an unrecoverable failure, leave the codebase in the most consistent state possible and clearly report which of the plan's steps were completed versus not attempted.
