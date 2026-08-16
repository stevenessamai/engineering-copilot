---
name: docs
description: Update project documentation (README, setup, configuration, API docs, architecture, deployment, dev workflow) to accurately reflect the actual codebase — never inventing functionality. Use when the user asks to update, write, or fix documentation, or runs /engineering-copilot:docs.
---

# Docs

## Purpose

Keep documentation truthful and current relative to the real codebase — not a generic template, and never describing functionality that doesn't exist.

## When to use

- The user runs `/engineering-copilot:docs`.
- The user asks to write or update a README, setup guide, API docs, or architecture notes.
- Documentation is found to be stale during `/analyze` or `/plan` and the user opts to fix it.

## Safety constraints

- **Do not invent functionality.** Every documented behavior, flag, endpoint, or config option must correspond to something that actually exists in the code.
- Update documentation only where it's actually wrong, missing, or stale — don't rewrite accurate sections just to change style.
- Preserve the existing documentation structure/voice unless the user asks for a restructure.

## Workflow

1. **Inventory existing docs**: `README.md`, `docs/`, inline setup instructions, API reference files, architecture notes, deployment guides.
2. **Cross-check each documented claim against the code**: does this env var actually get read? Does this endpoint actually exist with this contract? Does this setup command actually work given current dependencies?
3. **Identify gaps**: functionality that exists but isn't documented (new endpoints, new config, new scripts).
4. **Identify staleness**: documented behavior that no longer matches the code (renamed commands, removed features, changed defaults).
5. **Update only what's needed** — add missing sections, correct stale ones, leave accurate sections untouched.
6. **Verify commands and examples** you write into docs actually run (via `/verify`'s command-discovery approach) rather than assuming syntax.

## Coverage areas

README, setup/installation, configuration and environment variables, API reference, architecture overview, deployment, and development workflow (how to run, test, and contribute locally).

## Output format

```
## Files updated
(path, and a one-line description of what changed and why)

## Gaps found but not filled
(documentation debt noted for the user's attention, with reason it wasn't addressed now)

## Verified
(commands/examples confirmed to actually work)
```

## Failure handling

- If a documented behavior can't be confirmed against the code either way, flag it as "unverified" rather than asserting it's correct or rewriting it based on assumption.
