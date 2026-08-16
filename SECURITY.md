# Security Policy

## Reporting a vulnerability

If you find a security issue in Engineering Copilot itself (not in a codebase it's been used on), please report it privately rather than opening a public issue. Contact: **SECURITY_CONTACT_HERE**.

Please include:
- A description of the issue and its potential impact.
- Steps to reproduce, if possible.
- The version of Engineering Copilot affected.

We'll acknowledge reports and work with you on a fix before any public disclosure.

## Secrets

Engineering Copilot never intentionally stores secrets, API keys, tokens, or credentials in `.claude/engineering-copilot/` or anywhere else it writes. If a hook or skill's heuristic secret scan (`scripts/pre-write-secret-scan.sh`, `bin/ec-secret-scan`) flags something, treat that as a prompt to verify manually — these are best-effort pattern matches, not a guaranteed secrets scanner, and both false positives and false negatives are expected.

## External integrations

By default, Engineering Copilot operates entirely through Claude Code's built-in tools (file read/write, Bash, Grep/Glob) and does not require or configure any external service. If you connect an MCP server or other integration alongside this plugin, that integration's own data-handling and security posture applies — Engineering Copilot's skills don't audit third-party MCP servers.

## Safe execution

- Hooks run entirely locally and make no network calls.
- No skill executes untrusted code found in a repository as part of investigation (e.g. `/debug` reads code, it does not run arbitrary discovered scripts to "see what they do").
- `/implement`, `/refactor`, and `/test` are the only skills that write to source files, and only within the scope the user asked for.

## Destructive operations

See [`docs/safety.md`](./docs/safety.md) for the full list of operations Engineering Copilot treats as high-risk and requires explicit confirmation for (destructive git operations, database/migration deletions, force-push, production deployment, and similar).

## Scope

This policy covers the Engineering Copilot plugin's own code (skills, agents, hooks, scripts). It does not cover vulnerabilities in codebases you use the plugin on — those should be reported through the affected project's own security process, which `/engineering-copilot:security` can help you locate and follow.
