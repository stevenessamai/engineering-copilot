---
name: test
description: Generate high-value tests that follow the project's existing testing conventions, run them, fix failures they expose, and report coverage gaps — without generating low-value bulk tests. Use when the user asks to add tests, improve coverage, or runs /engineering-copilot:test.
---

# Test

## Purpose

Add tests that catch real bugs and document real behavior, matching how the project already tests itself — not a mechanically generated wall of trivial assertions.

## When to use

- The user runs `/engineering-copilot:test`.
- The user asks to add tests for a feature, file, or recent change, or to improve coverage.

## Safety constraints

- **Do not blindly generate hundreds of useless tests.** Prioritize high-value tests: untested behavior that's likely to break, important edge cases, and previously-uncovered failure paths.
- Follow the project's existing test framework, file layout, and naming convention — do not introduce a second testing framework or a divergent style.
- Only fix test failures caused by the newly generated tests where the fix is clearly correct; if a generated test reveals a real bug in existing code, report it rather than silently "fixing" the test to match broken behavior.

## Workflow

1. **Inspect existing tests** for the target area (or, if none exist yet, for the project generally) to learn the framework, assertion style, fixture/mocking conventions, and file naming pattern.
2. **Understand the testing framework** in use (e.g. pytest, Jest, Vitest, Go's `testing`, JUnit) and how tests are run (discovered the same way `/verify` discovers commands).
3. **Identify untested behavior** in the target file(s) — public functions/methods/endpoints with no corresponding test.
4. **Identify important edge cases**: boundary values, empty/null inputs, error paths, concurrent or async behavior, and integration points with external services (mocked appropriately).
5. **Generate tests** that match existing conventions: same assertion library, same fixture setup style, same naming pattern (e.g. `test_<behavior>` or `describe/it` blocks matching neighboring tests).
6. **Run the tests.**
7. **Fix failures** caused by the generated tests — e.g. incorrect assumptions about return shape — where the fix is clearly in the test, not the implementation. If a failure instead reveals a genuine bug, stop and report it rather than adjusting the test to hide it.
8. **Report coverage gaps** that remain: behavior identified in step 3-4 that wasn't covered in this pass, with a reason (e.g. "requires a live external service, not mocked here — flagged for integration test suite").

## Output format

```
## Framework detected
## Tests added
(file, what each test covers, and why it was prioritized)

## Run result
(command, pass/fail)

## Bugs revealed
(if a generated test exposed a real bug — described, not silently patched)

## Remaining coverage gaps
(behavior not covered in this pass, with reason)
```

## Failure handling

- If no test framework can be detected, say so and ask the user which framework/convention to use rather than picking one arbitrarily.
- If tests can't be executed in this environment, say why and mark the added tests as unverified.
