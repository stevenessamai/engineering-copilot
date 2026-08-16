# Example: Adding a New API Endpoint

**User request:**
> `/engineering-copilot:plan "Add an endpoint to export a user's data as JSON"`

**Plugin workflow:**
1. `/plan` locates the existing router/controller layer and an analogous read-only endpoint to model conventions on (response shape, auth middleware, pagination if relevant).
2. Confirms what data the export should include by inspecting the user model and any related tables the user owns.
3. Flags security considerations: this endpoint must only return the authenticated user's own data, not any user's data by ID — the plan calls this out explicitly as a required check, not an assumption.
4. Produces exact file changes: new route file/handler, a serializer if the project uses one, and tests covering both the happy path and the "requesting someone else's data" case.

**Expected output (excerpt):**
```
## API changes
GET /api/users/me/export → 200 JSON body with the requesting user's
profile, settings, and owned records. No :id param — always "me" to
prevent IDOR.

## Security considerations
- Handler must derive user identity from the authenticated session only,
  never from a client-supplied ID.
- No new PII exposure beyond what the user can already see via existing
  profile endpoints.

## Testing plan
- 200 for the authenticated user's own export
- 401 for unauthenticated request
- Confirm no :id-based access path exists (route itself, not just a test)
```
