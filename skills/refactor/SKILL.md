---
name: refactor
description: Safely restructure code without changing behavior, using existing tests as a safety net, incremental steps, and verification after each step. Use when the user asks to refactor, clean up, extract, or restructure code, or runs /engineering-copilot:refactor.
---

# Refactor

## Purpose

Improve code structure while provably preserving behavior — never a rewrite disguised as a refactor.

## When to use

- The user runs `/engineering-copilot:refactor`.
- The user asks to extract a function/module, rename for clarity, reduce duplication, simplify a component, or otherwise restructure without changing what the code does.

## Safety constraints

- **Never perform a large destructive refactor without explaining the risk first**, especially in areas with weak or no test coverage.
- If the target has no meaningful tests, say so before starting, and propose adding characterization tests first (or offer to run `/test` on the target) rather than refactoring blind.
- Preserve public interfaces/contracts unless the user explicitly asks to change them — a refactor is not the place to silently change a function signature callers depend on.

## Workflow

1. **Understand current behavior** by reading the target code and its call sites.
2. **Inspect existing tests** covering the target — this is the safety net that proves behavior is preserved. If coverage is thin, flag it now.
3. **Identify the refactoring target** precisely (which function/class/module, and what's wrong with its current structure — duplication, excessive coupling, poor naming, mixed responsibilities).
4. **Identify dependencies**: everything that calls into or is called by the target, so the blast radius is known upfront.
5. **Define invariants**: what must remain true after the refactor (return values, side effects, error behavior, performance characteristics if relevant).
6. **Create a refactoring plan**: the sequence of small, individually-safe steps that get from current to target structure (e.g. extract method → introduce parameter object → move method → inline old call sites).
7. **Refactor incrementally**, one step at a time.
8. **Run tests after each meaningful step**, not just at the end — this is what makes incremental refactoring safe and makes failures easy to attribute to a specific step.
9. **Verify behavior** against the invariants defined in step 5 once all steps are complete.

## Output format

```
## Target
## Current structure / problem
## Invariants to preserve
## Refactoring plan
(ordered steps)

## Steps completed
(each with the test result that verified it)

## Behavior verification
(invariants checked off)

## Risk notes
(anything not covered by existing tests, called out explicitly)
```

## Failure handling

- If a step's tests fail and the cause isn't immediately obvious, stop and report rather than continuing to the next step on an unverified base.
- If the target genuinely can't be safely refactored without a behavior change (e.g. the current code relies on an undocumented side effect callers depend on), say so and describe the tradeoff instead of proceeding silently.
