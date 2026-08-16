# Example: Adding Tests

**User request:**
> `/engineering-copilot:test backend/services/pricing.py`

**Plugin workflow:**
1. `/test` reads `tests/services/` to learn the project's pytest conventions (fixture style, naming: `test_<behavior>`, use of `pytest.mark.parametrize`).
2. Reads `pricing.py` and finds `calculate_total`, `apply_discount`, and `round_to_currency` are all untested.
3. Prioritizes: `apply_discount` has an unhandled edge case (discount > 100%) that looks like a real bug risk — tested first. `round_to_currency` behavior at exact `.5` boundaries is untested — also prioritized. A pure pass-through getter is skipped as low value.
4. Writes tests matching existing style, runs them.
5. `apply_discount(price, discount=150)` returns a negative price instead of raising or clamping — this is a real bug, not a bad test assumption, so it's reported rather than silently patched.

**Expected output (excerpt):**
```
## Tests added
- test_apply_discount_at_boundary (0%, 100%)
- test_round_to_currency_exact_half_cent
- test_calculate_total_with_multiple_line_items

## Bugs revealed
apply_discount(price, discount=150) returns -50.0 instead of raising
ValueError or clamping to 0. Not fixed automatically — flagged for you
to decide the intended behavior.

## Remaining coverage gaps
get_display_currency() is a pure pass-through getter — skipped as low
value.
```
