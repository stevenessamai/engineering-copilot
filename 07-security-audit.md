# Example: Security Audit

**User request:**
> `/engineering-copilot:security`

**Plugin workflow:**
1. `/security` scans for secrets in source (finds none committed, but notices `.env.example` includes a real-looking key left over from a copy-paste — flagged, not printed).
2. Checks authentication/authorization: finds one admin route (`POST /api/admin/users/:id/role`) that checks the session exists but never checks the session's role before allowing a role change — a real privilege-escalation path.
3. Checks SQL usage: the project uses an ORM everywhere except one raw query in a reporting script, built via string formatting with a user-supplied date range — flagged as SQL injection risk.
4. Checks dependency risk by cross-referencing `/dependencies`-style findings: one HTTP client library is several majors behind, but no specific CVE could be confirmed from available information — reported as "unconfirmed risk," not asserted as vulnerable.
5. Checks AI-specific surface: the support bot passes retrieved document content directly into the system prompt with no delimiter or instruction-injection guarding — flagged as a prompt-injection risk if any retrieved document could contain attacker-controlled text.

**Expected output (excerpt):**
```
[CRITICAL] backend/api/admin.py:88
Category: authn-authz
Finding: Role-change endpoint checks session validity but not session role
Evidence: `if session: role = request.json["role"]` — no role/permission check
Recommendation: Require an explicit admin-role check before this handler
runs, matching the pattern in backend/api/admin.py:34 for other admin routes

[HIGH] scripts/reporting.py:41
Category: sql
Finding: Raw SQL built via f-string with user-supplied date range
Evidence: f"SELECT * FROM events WHERE ts BETWEEN '{start}' AND '{end}'"
Recommendation: Use parameterized query via the existing db.execute(query, params) helper

## Limitations
Did not perform dynamic/runtime testing. Did not query a CVE database —
the outdated HTTP client is flagged as unconfirmed risk pending manual
verification. No visibility into deployed infrastructure or network
configuration.
```
