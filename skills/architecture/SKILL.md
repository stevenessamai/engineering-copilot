---
name: architecture
description: Produce an architecture review of the current system (components, boundaries, data flow, failure points, scalability, maintainability, security boundaries) and a recommended architecture that preserves what's reasonable rather than proposing a rewrite. Use when the user asks about system architecture or design, or runs /engineering-copilot:architecture.
---

# Architecture

## Purpose

Describe the system as it actually is, then propose targeted improvements — not a from-scratch redesign.

## When to use

- The user runs `/engineering-copilot:architecture`.
- The user asks how the system is structured, whether it will scale, or where the architectural risk is.

## Safety constraints

- **Do not recommend rewriting everything.** Preserve the existing architecture where it's reasonable, and scope recommendations to genuine problems with evidence, not stylistic preference.
- Read-only — this skill produces a review document, it does not modify code.

## Workflow

1. **Reuse `/analyze` output** if `.claude/engineering-copilot/project-context.md` is fresh; otherwise do a targeted architecture pass (entry points, module boundaries, communication patterns).
2. **Map components**: services/modules and their responsibilities.
3. **Map boundaries**: what's supposed to be isolated from what, and whether the code actually respects that (look for reverse dependencies, layer-skipping calls).
4. **Map data flow**: how a request/event moves through the system end to end for at least one representative path.
5. **Identify external services** and how failures in them are handled (retries, timeouts, circuit breaking, or their absence).
6. **Identify failure points**: single points of failure, missing error handling at boundaries, unbounded queues/loops.
7. **Assess scalability**: what would break first under load (a specific bottleneck, not a vague "might not scale").
8. **Assess maintainability**: coupling, duplication, and how hard the current structure makes common changes.
9. **Assess security boundaries**: where trust boundaries are supposed to exist and whether the code enforces them (cross-reference with `/security` if run separately).

## Output format

```
## Current architecture
(components, boundaries, dependencies, data flow, external services)

## Failure points
## Scalability assessment
## Maintainability assessment
## Security boundaries

## Recommended architecture
(specific, targeted changes — each tied to a concrete problem identified above; explicitly note what should stay as-is and why)
```

## Failure handling

- If a data-flow path can't be fully traced (e.g. it crosses into infrastructure not visible in the repo), say so and describe what's known versus unknown about that segment.
