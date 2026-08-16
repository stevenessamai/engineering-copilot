---
name: plan
description: Turn a natural-language feature or change request into a concrete, file-level implementation plan by first deeply inspecting the codebase — never write code directly from this skill. Use when the user describes a feature, change, or task to implement (e.g. "add Google OAuth", "add Stripe subscriptions") or runs /engineering-copilot:plan.
---

# Plan

## Purpose

This is the most important skill in Engineering Copilot. It converts a natural-language request into a plan specific enough that another developer could execute it without rediscovering the codebase themselves.

## When to use

- The user runs `/engineering-copilot:plan "<task description>"` or `/engineering-copilot:plan` followed by a description.
- The user describes a nontrivial feature or change and hasn't asked for something small and safe (see "Plan-first safety" below).

## Safety constraints

- **Do not write or modify code in this skill.** Planning only. Implementation happens in `/implement`, after the user has seen and approved the plan.
- Do not assume unstated requirements — if the request is ambiguous in a way that changes the plan materially (e.g. "add auth" without specifying provider), ask one targeted question before proceeding, or state the assumption explicitly and proceed.
- Every file path in the plan must be a real path you verified exists (for files to modify) or a path that follows the project's existing conventions (for files to create).

## Workflow

1. **Requirement extraction.** Restate the task in your own words as a testable objective. Note any ambiguity.
2. **Codebase discovery.** If `.claude/engineering-copilot/project-context.md` exists and is fresh, read it first. If it's missing or stale, run a lightweight version of `/analyze`'s discovery (don't re-run the full report) to get current stack/architecture facts.
3. **Relevant file discovery.** Search for files related to the task's domain (e.g. for "add Google OAuth": existing auth code, session handling, user model, route definitions, config/env loading). Use `grep`/`git grep` for keywords tied to the feature, not a full-repo read.
4. **Existing architecture analysis.** Identify the layer(s) this change touches (API, service, data, frontend, AI) and how similar features are currently implemented, so the plan follows existing conventions instead of introducing a new pattern.
5. **Existing implementation pattern discovery.** Find at least one analogous existing feature (e.g. an existing OAuth-like integration, an existing CRUD endpoint) to model file organization, naming, and error handling on.
6. **Dependency analysis.** Determine what new packages, services, or environment variables the change requires, and what must exist before implementation can start (e.g. a provider API key, a schema migration tool already configured).
7. **Impact analysis.** Identify every file, module, or contract the change touches, directly or indirectly (e.g. changing a shared `User` model affects every consumer of that model).
8. **Security analysis.** Consider authn/authz, secret handling, input validation, and injection surface introduced by the change.
9. **Testing analysis.** Identify what test types are needed (unit, integration, e2e) and which existing test suites the new tests belong in.
10. **Implementation planning.** Sequence the steps so each is independently verifiable, and order them by dependency (e.g. migration before model change before endpoint before frontend).

## Output format

```
## Objective
## Existing architecture
## Relevant files
## Files to modify        (exact paths)
## Files to create         (exact paths)
## Files to delete         (exact paths, if applicable)
## Dependencies             (what must happen first — packages, config, external setup)
## Implementation steps     (detailed, ordered sequence)
## Data changes             (schema/migration changes, or "None")
## API changes              (endpoints/contracts, or "None")
## Frontend changes         (or "None")
## AI changes               (model/prompt/tool/context/eval/cost/latency impact, or "None")
## Security considerations
## Testing plan
## Rollback considerations
## Risks
## Acceptance criteria
## Verification commands
## Definition of done
```

**Specificity is mandatory.** Never write "Update backend." Write "Modify `backend/api/auth.py` to add the OAuth callback route; add `backend/services/oauth.py` to encapsulate provider interaction; extend the `User` model with provider identity fields; add migration `oauth_identity`." Avoid generic filler like "consider best practices" or "improve security" — every line must be an action tied to a real file or command.

## AI-specific planning

When the task touches an AI component (detected during discovery or stated by the user), the plan's "AI changes" section must cover: model impact, prompt impact, tool impact, context-construction impact, retrieval/chunking/embedding impact if RAG is involved, evaluation impact, cost impact, latency impact, and failure handling.

## Plan-first safety

- For changes that touch multiple files, the data layer, auth, or external integrations: always produce a plan and wait for confirmation before implementing.
- For small, explicitly-scoped changes the user asks to implement directly ("just rename this function"), it's reasonable to skip a formal plan and let `/implement`-equivalent work happen directly — use judgment, but default to planning first when in doubt.

## Saving the plan

After presenting the plan, save it to `.claude/engineering-copilot/plans/` using a descriptive kebab-case filename derived from the objective (e.g. `add-google-oauth.md`), not a generic name. If a plan file for the same objective already exists, ask whether to overwrite or version it (`add-google-oauth-2.md`) rather than silently overwriting. Never overwrite an unrelated plan file.

## Failure handling

- If the codebase gives no evidence of how a required piece (e.g. session handling) currently works, say "Unable to determine from the available repository evidence" in that section rather than inventing a convention.
- If the task as stated is infeasible given the current architecture, say so and propose the smallest architectural change that would make it feasible, flagged clearly as a prerequisite.
