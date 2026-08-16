# Safety

Engineering Copilot operates on your real codebase. These are the rules every skill in the plugin follows.

## Core principles

1. Never expose secrets.
2. Never transmit source code to external services except through the Claude interaction itself or explicitly configured integrations.
3. Never install unknown dependencies automatically.
4. Never execute destructive commands without user approval.
5. Never delete large sections of code without explicit approval.
6. Never force-push.
7. Never modify git history destructively.
8. Never push code automatically.
9. Never claim security guarantees.
10. Never fabricate test results.

## Destructive operations

These are treated as high risk across every skill. The plugin asks for confirmation before running them, unless Claude Code's own approval mechanism already covers it:

- `rm` (especially `rm -rf`)
- `git reset --hard`
- `git clean` (with `-f`)
- force push (`git push --force` / `-f`)
- `git filter-branch` / history rewrites
- database deletion
- destructive migrations (drops, irreversible schema changes)
- mass file deletion
- credential changes
- production deployment

The `pre-bash-guard` hook (see below) flags commands matching common destructive patterns before they run, as a reminder — it never blocks execution on its own, since only a human can give real approval.

## What `/implement` and `/ship` will never do on their own

- `/implement` never pushes, merges, or deploys.
- `/ship` never pushes, merges, or opens a pull request unless you explicitly ask it to in that turn.
- No skill force-pushes or rewrites history.

## Hooks

Engineering Copilot ships four intentionally conservative hooks (`hooks/hooks.json`), documented individually in [`docs/hooks.md`](./hooks.md). All of them:

- Run entirely locally.
- Never transmit repository content anywhere.
- Are informational — they warn via stderr, they do not block normal development.

## Context storage

Persistent project knowledge lives under `.claude/engineering-copilot/` (see [`docs/context.md`](./context.md)). This directory never stores secrets, API keys, tokens, or credentials, even if they were visible in a `.env` file or config during analysis.
