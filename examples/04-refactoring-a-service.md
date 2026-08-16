# Example: Refactoring a Service

**User request:**
> `/engineering-copilot:refactor "the NotificationService class has grown to handle email, SMS, and push — split it up"`

**Plugin workflow:**
1. `/refactor` reads `NotificationService` and its call sites, and checks existing test coverage for it.
2. Coverage is found to be partial (email path tested, SMS/push are not) — this is flagged to the user before proceeding, with a recommendation to add characterization tests for the untested paths first.
3. Defines invariants: the public `notify(user, message, channel)` interface used by callers must not change; each channel's current behavior (retry counts, formatting) must be preserved exactly.
4. Plans small steps: extract `EmailNotifier`, extract `SmsNotifier`, extract `PushNotifier`, have `NotificationService` delegate to each by channel, remove now-dead code in the original class.
5. Executes one step at a time, running tests after each.

**Expected output (excerpt):**
```
## Risk notes
SMS and push paths had no existing tests. Added characterization tests
for both (capturing current behavior, not necessarily "correct" behavior)
before extracting them, so the refactor has a real safety net.

## Steps completed
1. Extract EmailNotifier — 12 passed
2. Add characterization tests for SMS/push — 4 passed (new)
3. Extract SmsNotifier — 16 passed
4. Extract PushNotifier — 16 passed
5. NotificationService delegates by channel; dead code removed — 16 passed
```
