# Workflows

Engineering Copilot's skills are designed to chain together. The most common paths:

## Build a feature

```
/engineering-copilot:analyze   (once, or when stale)
→ /engineering-copilot:plan "<feature description>"
→ (you review and approve the plan)
→ /engineering-copilot:implement
→ /engineering-copilot:verify
→ /engineering-copilot:ship
```

## Fix a bug

```
/engineering-copilot:debug "<symptom or pasted error>"
→ /engineering-copilot:test          (regression test, often done inside /debug already)
→ /engineering-copilot:verify
```

## Review before merging

```
/engineering-copilot:review
→ (fix findings, manually or by asking Claude to address specific items)
→ /engineering-copilot:verify
```

## Understand an unfamiliar codebase

```
/engineering-copilot:analyze
→ /engineering-copilot:architecture   (deeper structural view, if needed)
```

## Pre-release audit

```
/engineering-copilot:security
→ /engineering-copilot:dependencies
→ /engineering-copilot:review
```

## Notes on sequencing

- `/plan` never writes code; `/implement` does, and only against an approved plan.
- `/verify` is called both standalone and internally by `/implement` and `/ship` — it always discovers real project commands rather than assuming them.
- `/ship` never pushes, merges, or opens a PR on its own; it prepares everything and hands the action back to you.
- For small, explicitly-scoped changes, it's reasonable to skip straight to implementation without a formal `/plan` — see "Plan-first safety" in `skills/plan/SKILL.md`.
