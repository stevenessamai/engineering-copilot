---
name: analyze
description: Deeply analyze the current codebase's project setup, architecture, data layer, APIs, AI components, quality signals, and risks, and optionally initialize or refresh persistent project context. Use when the user asks to understand, map, audit, or get oriented in a codebase, or asks "what is this project", "how does this codebase work", or runs /engineering-copilot:analyze.
---

# Analyze

## Purpose

Build (or refresh) a structured, evidence-based understanding of the current codebase. This is the foundation every other skill in Engineering Copilot relies on — `/plan`, `/review`, `/security`, `/architecture`, and `/dependencies` all assume an analysis has been run at least once and reuse its output via `.claude/engineering-copilot/project-context.md`.

## When to use

- The user explicitly runs `/engineering-copilot:analyze`.
- The user asks to understand, map, or get oriented in an unfamiliar codebase.
- Another Engineering Copilot skill needs project context that does not exist yet or is stale (see `scripts/context-freshness.sh`).

## Safety constraints

- **Read-only.** Do not modify source files during `/analyze`. The only files this skill writes to are inside `.claude/engineering-copilot/` (context/report files), and only after presenting the analysis.
- Never fabricate findings. Every claim must be traceable to a file, config entry, or command output you actually inspected.
- If something cannot be determined from repository evidence, say so explicitly — do not guess.

## Workflow

1. **Targeted discovery first.** Do not read the entire repository. Start with the signals that reveal project type fastest:
   - Manifest/config files at repo root: `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`, `Gemfile`, `composer.json`, `*.csproj`.
   - Lockfiles: `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `poetry.lock`, `Cargo.lock`, `go.sum`.
   - `README.md`, `Makefile`, `justfile`, CI config (`.github/workflows/`, `.gitlab-ci.yml`), `Dockerfile`, `docker-compose.yml`.
   - Top-level directory names (`src/`, `app/`, `pkg/`, `cmd/`, `apps/`, `services/`, `packages/` for monorepos).
2. **Identify project type, language(s), frameworks, package manager, build system, runtime, and deployment hints** from what was found in step 1. Note monorepo vs. single-package structure.
3. **Map architecture**: entry points (`main.*`, `index.*`, `app.*`, `cmd/*/main.go`), modules/services/layers, how they communicate (HTTP, message queue, direct import, RPC), and boundaries between them.
4. **Survey the codebase**: important directories and files, repeated patterns and abstractions, shared utilities, configuration loading, and the test directory/framework in use. Sample representative files rather than reading every file — pick 2-4 files per layer that look canonical.
5. **Inspect the data layer** if present: database engine, ORM/query builder, schema/model definitions, migrations directory, and the data-access pattern used (repository, active record, raw queries, etc.).
6. **Inspect APIs**: route/controller definitions, request/response contracts, API clients used to call external services, and third-party integrations.
7. **Detect AI components** if present (see also `/plan`'s AI-specific planning and `agents/codebase-analyst.md`): SDKs (Anthropic, OpenAI, Gemini, OpenRouter, LiteLLM), orchestration frameworks (LangChain, LangGraph, CrewAI, AutoGen), prompts/system prompts, tool/function-calling schemas, RAG pipeline (chunking, embeddings, vector store), memory, and evaluation harnesses.
8. **Assess quality signals**: presence and apparent coverage of tests, linting/formatting config, CI pipeline steps, and a targeted grep for `TODO`, `FIXME`, `XXX`, `HACK`, and other technical-debt markers (report counts and a few representative examples, not an exhaustive dump).
9. **Identify risks**, separated by category: architectural, security, performance, maintainability, dependency. Each risk needs the file/pattern that evidences it.
10. **Write the report** using the structure below, clearly separating CURRENT STATE from RECOMMENDED IMPROVEMENTS.
11. **Offer to persist context.** If `.claude/engineering-copilot/project-context.md` does not exist, or is stale relative to what you just learned, offer to create/update it (see "Project context file" below). Do this only after the user has seen the analysis, and only if they want it — this is a convenience, not a requirement.

## Tools to inspect

Prefer fast, targeted commands over exhaustive reads:
- `git ls-files | head -200` / `find . -maxdepth 2 -type d` for a shallow map.
- `grep -rn "TODO\|FIXME\|XXX\|HACK" --include=*.{py,js,ts,go,rb,java} -l` capped to a sample, not the whole tree.
- Manifest files read directly (`cat package.json`, `cat pyproject.toml`, etc.).
- `git log --oneline -20` for recent activity context, if useful.

## Output format

```
## Project
(type, language, frameworks, package manager, build system, runtime, deployment hints)

## Architecture
(entry points, modules/services/layers, boundaries, communication patterns)

## Codebase
(important directories/files, patterns, abstractions, utilities, config, tests)

## Data
(database, ORM, schemas, migrations, data access layer — or "None detected")

## APIs
(routes, controllers, clients, external integrations — or "None detected")

## AI
(models, prompts, agents, tools, RAG, vector DBs, memory, evals — or "None detected")

## Quality
(test coverage signals, linting, formatting, CI, technical debt, TODO/FIXME counts, suspicious patterns)

## Risks
(architectural / security / performance / maintainability / dependency — each with evidence)

## CURRENT STATE vs RECOMMENDED IMPROVEMENTS
(explicitly separated — do not blend the two)
```

## Project context file

When the user agrees, write or update `.claude/engineering-copilot/project-context.md` with:
- Stack, architecture summary, conventions observed, important paths, test/build/verification commands discovered, deployment hints, and any decisions the user states explicitly.
- Prefix inferred information with "Inferred:" so future readers know what was observed versus stated.
- Keep it concise — this is a reusable summary other skills read, not a duplicate of the analysis report. Update in place rather than appending unbounded history.
- Never write secrets, API keys, tokens, or credentials into this file, even if seen in `.env` or config during analysis.

## Failure handling

- If a manifest or config file can't be parsed, report that specifically ("`pyproject.toml` present but malformed TOML — skipping dependency parsing") rather than silently omitting the section.
- If the repository is empty or has no recognizable project type, report that plainly and stop rather than inventing a stack.
