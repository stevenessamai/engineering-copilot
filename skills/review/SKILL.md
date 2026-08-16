---
name: review
description: Perform a serious engineering code review covering correctness, security, performance, architecture, testing, and (when applicable) AI-specific risks, with severity-ranked findings tied to specific evidence. Use when the user asks for a code review, asks "is this safe to merge", or runs /engineering-copilot:review.
---

# Review

## Purpose

A real code review, not a rubber stamp. Every finding must be tied to specific evidence in the diff or file; no invented issues to pad the output.

## When to use

- The user runs `/engineering-copilot:review`.
- The user asks for a review of a diff, PR, branch, or specific file(s) before merging.

## Safety constraints

- **Do not produce fake issues.** If a category has no findings, say so plainly rather than inventing a low-severity issue to fill the section.
- Read-only unless the user explicitly asks for fixes to be applied — a review reports, it doesn't silently rewrite code.

## Scope discovery

Default to reviewing the current diff (`git diff` against the base branch, or uncommitted changes if there's no PR context). If the user names specific files or a PR, review exactly that scope — don't expand it unasked.

## Workflow — check each category against the actual code in scope

**Correctness**: bugs, edge cases (empty input, null/undefined, boundary values, concurrent access), race conditions, error handling (swallowed exceptions, missing error paths, incorrect error propagation).

**Security**: authn/authz checks, injection (SQL, command, template, path traversal), secrets in code or logs, unsafe deserialization, SSRF, unsafe input handling, data exposure in responses/logs.

**Performance**: N+1 queries, unnecessary or redundant queries, blocking calls on hot paths, expensive operations inside loops, unnecessary external API calls.

**Architecture**: coupling between layers that shouldn't know about each other, boundary violations, duplicated logic that should be shared, abstractions that don't match the problem, maintainability of the approach taken.

**Testing**: missing tests for the new/changed behavior, weak assertions (e.g. only checking status code, not response content), untested failure/error paths.

**AI-specific** (only if the diff touches AI code — prompts, tool definitions, agent loops, RAG): prompt injection surface from untrusted input reaching a prompt, hallucination risk in unguarded outputs, over-broad tool permissions, unsafe tool use (e.g. shell/file tools without validation), context/data leakage between users or sessions, missing model-failure handling, unnecessary token usage, gaps in evaluation coverage for the changed behavior.

## Output format

For each finding:

```
[SEVERITY] file:line-range (if available)
Problem: <what's wrong>
Evidence: <the specific code/pattern that shows it>
Recommendation: <specific, actionable fix — not "improve X">
```

Severities: `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`. Group findings by category, and within each category order by severity. End with a one-line summary verdict (e.g. "2 HIGH findings block merge; rest are non-blocking") — but the merge decision is the user's, not a claim of guaranteed safety.

## Failure handling

- If the diff is too large to review meaningfully in one pass, review the highest-risk files first (auth, data access, external calls) and say explicitly which files were not covered and why.
- Never claim a review is exhaustive or that code is "secure" — report findings and the review's own limitations (e.g. "did not execute the code; static review only").
