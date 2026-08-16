---
name: ship
description: Prepare a completed change for delivery — inspect the diff, run checks, detect accidental files and secrets, and generate a commit message and PR description — without pushing, merging, or opening a PR automatically. Use when the user is ready to commit/ship their change, or runs /engineering-copilot:ship.
---

# Ship

## Purpose

Get a change delivery-ready: summarized, checked, and described — while leaving the actual push/merge/PR-creation action to the user.

## When to use

- The user runs `/engineering-copilot:ship`.
- The user says they're ready to commit, open a PR, or "ship this."

## Safety constraints

- **Never automatically push to remote.**
- **Never automatically merge.**
- **Never automatically create a PR** unless the user explicitly requests it in this turn.
- Never force-push or rewrite git history destructively as part of this skill.

## Workflow

1. **Inspect the git diff** (`git diff`, `git status`) to see the full scope of what would ship.
2. **Summarize changes** by area/purpose, not just a file list.
3. **Check tests** — run via `/verify`'s command discovery, or reuse a recent `/verify` result if it's still current.
4. **Check lint.**
5. **Check build.**
6. **Detect accidental files**: build artifacts, editor/OS junk files, large binaries, files that don't belong in the diff given the stated change.
7. **Detect secrets**: scan the diff for patterns that look like API keys, tokens, private keys, or credentials before they'd be committed/pushed.
8. **Review migration changes** if any are present — confirm they're additive/reversible where possible, flag destructive ones.
9. **Review breaking changes**: public API/contract changes that affect callers.
10. **Generate a commit message**: concise summary line, body explaining what and why (not a restatement of the diff).
11. **Generate a PR description**: summary, motivation, changes, testing performed, risk/rollback notes.

## Output format

```
## Diff summary
## Checks
| Check | Result |
|---|---|

## Accidental files detected
(or "None")

## Secrets scan
(or "None found — static scan only, not a guarantee")

## Migration / breaking-change review
(or "N/A")

## Suggested commit message
## Suggested PR description
## Ready to ship?
(yes/no, with what's blocking if no)
```

Explicitly state at the end: "No changes have been pushed, merged, or opened as a PR — this is ready for you to do that yourself, or ask me to open the PR if you'd like me to."

## Failure handling

- If checks can't be run (e.g. no network for a CI-dependent check), report that as unverified rather than assuming it would pass.
