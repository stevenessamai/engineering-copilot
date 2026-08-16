---
name: security
description: Perform a security-focused audit of the codebase covering secrets, auth, input validation, file/subprocess/SQL operations, serialization, dependency risk, sensitive logging, and AI-specific vulnerabilities, reporting findings and limitations rather than claiming the project is secure. Use when the user asks for a security review/audit or runs /engineering-copilot:security.
---

# Security

## Purpose

A focused, evidence-based security audit — findings and their limitations, never a "this is secure" verdict.

## When to use

- The user runs `/engineering-copilot:security`.
- The user asks for a security audit or review before a release, or asks about a specific security concern.

## Safety constraints

- **Never claim a project is "secure."** Security review has inherent limits (static review, no penetration testing, no runtime analysis) — state them.
- Do not paste real secret values found during the scan into the report, even redacted-looking ones — reference the file and line only, and recommend rotation if a live-looking secret is found.

## Workflow — inspect each area against the actual code

**Secrets & environment variables**: hardcoded credentials, API keys, or tokens in source; `.env` files committed to version control; secrets logged or included in error messages.

**Authentication & authorization**: how identity is established, where authorization checks happen (or are missing) on sensitive routes/actions, session/token handling and expiry.

**Input validation**: where user input enters the system and whether it's validated/sanitized before use.

**File operations**: path construction from user input (path traversal risk), unrestricted file upload/write locations.

**Subprocess & shell commands**: command construction from user input (injection risk), use of `shell=True`/`exec`/`eval`-equivalents.

**SQL & data access**: string-concatenated queries versus parameterized queries/ORM usage, raw query usage in general.

**HTTP clients & SSRF**: outbound requests built from user-supplied URLs/hosts without an allowlist.

**Uploads, serialization & deserialization**: unsafe deserialization of untrusted data (e.g. `pickle`, unsafe YAML loaders), unrestricted upload types/sizes.

**Dependency risk**: cross-reference with `/dependencies` findings for known-risky packages.

**Logging of sensitive data**: PII, credentials, or tokens written to logs.

**AI-specific vulnerabilities** (if AI components are present): prompt injection from untrusted content reaching a system/user prompt, tool authorization (can the model call sensitive tools without a human in the loop?), excessive agency (tools with broader permissions than the task needs), data leakage across users/sessions/tenants, handling of untrusted retrieved content in RAG pipelines, unsafe or unchecked tool calls (e.g. arbitrary code execution tools).

## Output format

```
[SEVERITY] file:line-range (if available)
Category: <secrets / authn-authz / input-validation / ... >
Finding: <what was found>
Evidence: <specific code, not a general claim>
Recommendation: <specific, actionable>
```

End with an explicit **Limitations** section: what this audit did *not* cover (e.g. no dynamic/runtime testing, no dependency CVE database access, no infrastructure/network review) — this is required, not optional.

## Failure handling

- If a category can't be evaluated (e.g. no visibility into deployed infrastructure), say so in Limitations rather than silently skipping it.
