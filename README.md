# Engineering Copilot

An engineering productivity layer for Claude Code that automates the repetitive work around writing software — understanding a codebase, planning a change, implementing it, debugging, reviewing, testing, refactoring, and shipping — all grounded in your real codebase, not generic chat answers.

## Why

Developers spend a large share of their time on work that isn't actually building the product: re-orienting in an unfamiliar codebase, hunting for the right files, writing a plan another person could follow, chasing down a bug's actual root cause, doing a thorough review, writing tests that matter, and getting a change ready to ship. Engineering Copilot turns each of these into a repeatable, evidence-based workflow inside Claude Code — less thinking about the process, more time building the product.

This is not a general chatbot bolted onto your editor. Every skill inspects your actual project structure, source code, architecture, dependencies, frameworks, conventions, tests, configuration, and existing patterns before it says anything.

## Features

| Command | What it does |
|---|---|
| `/engineering-copilot:analyze` | Deep, evidence-based analysis of project setup, architecture, data layer, APIs, AI components, quality signals, and risk |
| `/engineering-copilot:plan` | Turns a natural-language request into a concrete, file-level implementation plan — never writes code |
| `/engineering-copilot:implement` | Executes an approved plan incrementally, running tests/lint after each step, stopping on drift |
| `/engineering-copilot:debug` | Structured root-cause investigation: reproduce, trace, rank hypotheses, evidence-backed fix, regression test |
| `/engineering-copilot:review` | Serious code review — correctness, security, performance, architecture, testing, AI-specific risks |
| `/engineering-copilot:test` | High-value test generation matching existing project conventions |
| `/engineering-copilot:refactor` | Behavior-preserving restructuring in small, test-verified steps |
| `/engineering-copilot:docs` | Keeps documentation accurate to the real codebase — never invents functionality |
| `/engineering-copilot:dependencies` | Audits dependencies for unused/duplicate/suspicious/outdated packages and lockfile issues |
| `/engineering-copilot:security` | Security-focused audit — secrets, authn/authz, injection, AI-specific risks — with explicit limitations |
| `/engineering-copilot:architecture` | Maps components, boundaries, data flow, failure points; recommends targeted improvements, not rewrites |
| `/engineering-copilot:verify` | Discovers and runs the project's own test/lint/typecheck/build commands |
| `/engineering-copilot:ship` | Prepares a change for delivery — diff summary, checks, secrets scan, commit message, PR description |

## Installation

```
/plugin marketplace add stevenessamai/engineering-copilot
/plugin install engineering-copilot@engineering-copilot-marketplace
```

## Usage

```
/engineering-copilot:analyze
/engineering-copilot:plan "Add Google OAuth authentication"
/engineering-copilot:implement
/engineering-copilot:debug "users receive 500 when uploading images"
/engineering-copilot:review
/engineering-copilot:test backend/services/pricing.py
/engineering-copilot:refactor "split NotificationService by channel"
/engineering-copilot:docs
/engineering-copilot:dependencies
/engineering-copilot:security
/engineering-copilot:architecture
/engineering-copilot:verify
/engineering-copilot:ship
```

See [`examples/`](./examples) for full walkthroughs of each command, and [`docs/workflows.md`](./docs/workflows.md) for how they chain together.

## Workflow

```
Analyze → Plan → Implement → Verify
Debug → Test → Verify
Review → Fix → Verify
```

## Safety

Engineering Copilot never force-pushes, never rewrites git history, never pushes or merges automatically, and never opens a PR unless you explicitly ask it to in that turn. Destructive operations (`rm -rf`, `git reset --hard`, database deletion, destructive migrations, and similar) always require your explicit confirmation. Full details: [`docs/safety.md`](./docs/safety.md).

## Privacy

Engineering Copilot does not intentionally transmit your code to any third-party service beyond the Claude interaction itself and any tools/providers you've explicitly configured. Hooks run entirely locally and never make network calls. See [`docs/hooks.md`](./docs/hooks.md) and [`docs/context.md`](./docs/context.md) for what gets stored where.

## Development

Clone this repository, then from Claude Code:

```
/plugin marketplace add /path/to/local/engineering-copilot
/plugin install engineering-copilot@engineering-copilot-marketplace
```

Run the local test suite:

```
bash tests/run_all.sh
```

This validates the plugin manifest, marketplace manifest, skill frontmatter, agent files, hook configuration, and script executability. See [`tests/README.md`](./tests/README.md) for details.

## Contributing

See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for how to add a skill, add an agent, and the pull request process.

## License

MIT — see [`LICENSE`](./LICENSE).
