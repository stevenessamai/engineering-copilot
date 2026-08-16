# Example: Adding OAuth

**User request:**
> `/engineering-copilot:plan "Add Google OAuth login"`

**Plugin workflow:**
1. `/plan` reads `.claude/engineering-copilot/project-context.md` (or runs targeted discovery if it's missing/stale).
2. Searches for existing auth code, session handling, and the user model.
3. Finds the existing email/password login flow as the closest analogous pattern and models the new flow's file layout on it.
4. Identifies dependencies: an OAuth client library already used elsewhere in the stack (or the smallest addition consistent with it), plus the need for provider client ID/secret as environment variables (never hardcoded).
5. Produces a plan naming exact files to modify/create (e.g. `backend/api/auth.py`, new `backend/services/oauth.py`, a migration adding provider-identity columns to `User`).

**Expected output (excerpt):**
```
## Files to modify
- backend/api/auth.py — add /auth/google/callback route
- backend/models/user.py — extend User with provider + provider_id fields

## Files to create
- backend/services/oauth.py — encapsulates Google OAuth token exchange
- backend/migrations/0014_add_oauth_identity.py

## Testing plan
- Unit: token exchange success/failure in oauth.py
- Integration: callback route with valid state, invalid state, expired code, duplicate account linking
```

The user reviews the plan, then runs `/engineering-copilot:implement` to execute it, followed by `/engineering-copilot:verify`.
