---
name: debug
description: Turn a bug report, stack trace, or error message into a structured investigation with a ranked root-cause hypothesis, evidence, a minimal fix, and a regression test. Use when the user reports a bug, pastes an error/traceback, or runs /engineering-copilot:debug.
---

# Debug

## Purpose

Replace guess-and-check debugging with a structured investigation that produces evidence before a fix.

## When to use

- The user runs `/engineering-copilot:debug` or `/engineering-copilot:debug "<symptom>"`.
- The user pastes a stack trace, error message, or describes unexpected behavior.

## Safety constraints

- **Never guess a root cause without inspecting evidence** (the actual code path, logs, or a reproduction). A hypothesis is not a conclusion.
- Apply the minimal fix that addresses the root cause — do not use a debugging session as an excuse for unrelated refactoring.
- Always add or update a regression test for the specific bug before declaring it fixed, unless the codebase has no test infrastructure at all (state this explicitly if so).

## Workflow

1. **Reproduce if possible.** If a reproduction is feasible (a script, a test, a specific input), do it before theorizing. If reproduction isn't feasible in this environment, say so and proceed on static evidence instead.
2. **Inspect the traceback/error** line by line — identify the exact file, function, and line where it originates, not just where it surfaces.
3. **Locate relevant code** around the failure point, plus its callers, using `grep`/`git grep` for the function/class names involved.
4. **Trace the execution path** from the entry point that triggers the symptom through to the failure, noting state/assumptions at each step.
5. **Inspect dependencies** that could be involved (library version, external service behavior, config value).
6. **Identify likely root causes** — list every plausible cause the evidence so far supports, not just the first one that comes to mind.
7. **Rank hypotheses** by how well they're supported by the evidence gathered.
8. **Test hypotheses** against the code/logs/reproduction, starting with the top-ranked one, until one is confirmed or all are exhausted (in which case, report what was ruled out and what remains uncertain).
9. **Apply the minimal fix** that addresses the confirmed root cause.
10. **Add a regression test** that fails before the fix and passes after it.
11. **Run tests** — the new regression test plus the surrounding suite, to check for side effects.
12. **Verify the fix** against the original symptom description.

## Output format

```
## Symptom
## Reproduction
(steps taken, or "Not reproducible in this environment — proceeding on static evidence")

## Root cause
## Evidence
(the specific code/log/behavior that confirms this is the cause, not just a plausible story)

## Fix
## Files changed
## Tests added
## Verification result
```

## Failure handling

- If no hypothesis is confirmed with available evidence, report the ranked list of remaining hypotheses and what additional information (logs, access, reproduction steps) would be needed to confirm one — do not apply a speculative fix.
- If tests can't be run in this environment, say why and report the fix as unverified rather than claiming it passed.
