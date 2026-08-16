---
name: dependencies
description: Audit project dependencies for unused, duplicate, suspicious, outdated, or unnecessary packages and lockfile inconsistencies, reporting risk without automatically upgrading anything. Use when the user asks about dependencies, package bloat, or outdated packages, or runs /engineering-copilot:dependencies.
---

# Dependencies

## Purpose

Give a clear, risk-ranked picture of the dependency tree — never silently modify it.

## When to use

- The user runs `/engineering-copilot:dependencies`.
- The user asks about unused packages, dependency risk, or why the project has certain packages installed.

## Safety constraints

- **Never automatically upgrade dependencies.** Report findings; only modify the manifest/lockfile after explicit user approval, or if the user explicitly requested automatic remediation up front.
- Do not claim a version is vulnerable without evidence (an advisory, changelog, or the package's own documentation) — if you can't verify, say the risk is unconfirmed rather than asserting it.

## Workflow

1. **Read the manifest(s)** (`package.json`, `pyproject.toml`/`requirements.txt`, `Cargo.toml`, `go.mod`, etc.) and lockfile(s).
2. **Cross-reference declared dependencies against actual imports/usage** in the codebase (`grep`/`git grep` for import statements) to find packages that are declared but never used.
3. **Check for duplicates**: the same capability provided by two different packages (e.g. both `moment` and `date-fns`), or the same package pinned at conflicting versions across a monorepo.
4. **Flag suspicious dependencies**: unusually small/unmaintained packages doing security-sensitive work, typosquatting-risk names, or packages with excessive install-time scripts.
5. **Check for outdated versions** when version information is available (declared version vs. what's actually resolved in the lockfile; how far behind the latest major/minor if that information is accessible).
6. **Check for lockfile inconsistencies**: manifest and lockfile out of sync, multiple lockfiles for the same package manager present simultaneously.
7. **Assess transitive risk**: dependencies of dependencies that pull in a disproportionate number of packages or known-risky transitive packages.

## Output format

A table, one row per finding:

```
| Dependency | Current version | Issue | Risk | Recommendation |
```

Followed by a short summary grouping findings by severity of risk, and an explicit note that no changes were made unless the user asked for automatic remediation.

## Failure handling

- If version/vulnerability data isn't accessible in this environment, say so explicitly per dependency rather than guessing at CVEs.
- If usage can't be confirmed either way for a "possibly unused" package (e.g. dynamic imports), mark it "possibly unused — verify manually" rather than recommending removal outright.
