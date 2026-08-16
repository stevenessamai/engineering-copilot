# Example: Debugging a Production Error

**User request:**
> `/engineering-copilot:debug "users receive 500 when uploading images"`

**Plugin workflow:**
1. `/debug` looks for an image-upload route/handler and traces the code path from the request entry point.
2. Inspects the traceback if one was pasted; otherwise reads the handler and its dependencies (storage client, image-processing library, size/type validation).
3. Forms ranked hypotheses (e.g. "unhandled exception when the image exceeds provider's max size", "content-type validation rejects a valid MIME type", "storage client credential misconfiguration") and checks each against actual code and config.
4. Confirms the root cause with evidence — for example, the handler doesn't catch the storage client's exception type at all, so any transient storage error surfaces as an unhandled 500.
5. Applies the minimal fix (catch the specific exception, return a proper 4xx/5xx with a useful message) and adds a regression test simulating the storage failure.
6. Runs the test suite and reports the result.

**Expected output (excerpt):**
```
## Root cause
backend/api/uploads.py:47 does not catch StorageTimeoutError raised by
services/storage_client.py — any transient timeout becomes an unhandled 500.

## Fix
Wrap the storage call in a try/except for StorageTimeoutError, return 503
with a retry-after hint.

## Tests added
tests/api/test_uploads.py::test_upload_handles_storage_timeout

## Verification result
5 passed, 0 failed (pytest tests/api/test_uploads.py)
```
