# Project Context

Engineering Copilot maintains lightweight, project-specific context so skills don't re-discover the same codebase facts on every invocation.

## Location

```
.claude/engineering-copilot/
├── project-context.md   # stack, architecture, conventions, key paths, commands
├── plans/                # plans produced by /plan, one file per objective
└── reports/              # optional saved output from /analyze, /security, /architecture, etc.
```

This directory lives in your project repository (not inside the plugin), so it's specific to each codebase you use Engineering Copilot on. Commit it if you want the context shared with your team, or gitignore it if you'd rather keep it local — both are reasonable; Engineering Copilot doesn't require either choice.

## `project-context.md`

Written or refreshed by `/engineering-copilot:analyze`, and read by `/plan`, `/review`, `/security`, `/architecture`, and `/dependencies` to avoid redundant discovery. Contains:

- Stack (language, frameworks, package manager, build system)
- Architecture summary
- Conventions observed (naming, file organization, error handling patterns)
- Important paths (entry points, key modules, test directory)
- Test / build / verification commands discovered
- Deployment hints
- Decisions the user has explicitly stated

Inferred information is prefixed `Inferred:` so anyone reading the file later knows what was observed by Claude versus stated directly by a developer.

## `plans/`

Each plan produced by `/engineering-copilot:plan` is saved with a descriptive, kebab-case filename derived from its objective — e.g. `add-google-oauth.md` — never a generic name like `plan.md`. Unrelated plans are never overwritten; if a plan for the same objective already exists, `/plan` asks whether to overwrite or version it.

## What never goes here

Per Engineering Copilot's safety principles: never secrets, never API keys, never tokens, never private credentials — even if they were visible in a `.env` file or config during analysis. If sensitive configuration needs to be referenced, only the variable *name* is recorded, never its value.

## Keeping context small

Engineering Copilot deliberately avoids giant duplicated context files. `project-context.md` is updated in place, not appended to indefinitely. `/analyze` only rewrites it when something material has actually changed.
