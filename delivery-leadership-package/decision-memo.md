# Decision Memo: Keep the Instant Quote Estimate, with One Source of Truth

**Date:** Day 2
**Author:** Marc Gagne
**Decision area:** How customers see their price

## Context

Customers see two prices: an instant estimate while they fill in the form, and a saved quote calculated by the server. Before this week's alignment, the same inputs showed $425.00 in the estimate and $450.00 once saved. Nothing was broken, but a customer would have seen their price rise by $25 a month the moment they committed. The rates now match, and we have to decide how to keep them matching.

## Options considered

1. **Keep the instant estimate, server price is the price of record.** Customers get immediate feedback as they type. The cost is that rates are stored in two places and must be updated together.
2. **Calculate every estimate on the server.** One source of rates, so the two numbers can never differ. The cost is a slower, less responsive form, and a blank estimate whenever the service is unavailable.
3. **Remove the estimate and show a price only after saving.** Simplest to keep consistent, but customers lose the instant feedback that makes a quote tool feel useful. Rejected.

## Recommendation

Option 1. Keep the instant estimate, treat the server's rates as the source of truth, and update both places together for any rate change until a rating engine exists.

## Why

Customers judge us on whether the price they saw is the price they get. The instant estimate keeps the experience fast and engaging, and aligned rates keep it honest. A price that changes between the form and the saved quote is the fastest way to lose a customer's trust. Addtionally, customers may never SAVE the quote, so immediate information is important.

## What would change my mind

If any customer-visible mismatch between estimate and saved price occurs, or rates change more than once before a rating engine is in place, I would move to Option 2 until the engine arrives.