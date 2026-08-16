# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project uses [Semantic Versioning](https://semver.org/).

## [1.0.0] - Initial release

### Added

- 13 skills: `analyze`, `plan`, `implement`, `debug`, `review`, `test`, `refactor`, `docs`, `dependencies`, `security`, `architecture`, `verify`, `ship`.
- 9 specialized agents: `codebase-analyst`, `debugger`, `security-reviewer`, `architecture-reviewer`, `test-engineer`, `code-reviewer`, `refactoring-engineer`, `dependency-analyst`, `documentation-engineer`.
- 4 hooks: destructive-command guard, secret-write scanner, sensitive-file notice, project-context freshness check.
- Standalone `bin/ec-secret-scan` CLI for diff/file secret scanning, used by `/ship`.
- `scripts/detect-verify-commands.sh` for project-native verification command discovery, used by `/verify`.
- Persistent, lightweight project context under `.claude/engineering-copilot/` (`project-context.md`, `plans/`, `reports/`).
- Plugin manifest (`.claude-plugin/plugin.json`) and marketplace manifest (`.claude-plugin/marketplace.json`).
- Documentation: `docs/safety.md`, `docs/hooks.md`, `docs/context.md`, `docs/workflows.md`.
- Seven full example workflows covering OAuth, debugging, API endpoints, refactoring, testing, AI/RAG, and security audits.
- Local test suite validating manifest correctness, skill/agent structure, hook configuration, and script executability.
