# Copilot Reflection: Seed Data

**Date:** Wednesday, November 18, 2026
**Author:** Marc Gagne
**Decision area:** AI oversight: extending `api/src/seed.js` with Copilot

## Context

The lab asks for one AI-assisted assembly step and a written critique. I had Copilot add two quotes to the seed file, which resets the `evergreen` database to known test data. The change is low-risk, but it touches the database contract, so it's a good place to practice reviewing AI output before accepting it.

## The prompt I gave

> I would like to add more data to my seed file. This file is run to seed a mongodb. There are currently 6 test quotes. I would like to add 2 more. You'll notice there are 3 categories - auto, home and life. A 4th exists, and I would like one of the quotes to be that, renters. There are some data retrictions, like min/max age, review the entire code base to try to infer those to make sure the test data is within the restrictions. Before making changes, summarize to me what you plan to do, and ask any questions you may have.

Two choices in the prompt were deliberate: I named the constraint to respect (data restrictions) without listing the values, and I asked for a plan and questions **before** any edits.

## What Copilot proposed (plan, before any changes)

> - Update only seed.js.
> - Keep the existing six quotes and add q7 and q8, making q7 a renters quote.
> - Keep all ages between 18–100 and coverage amounts at least $10,000.
> - Set realistic premiums and descriptive tags.
> - Update the seed-file comment from "six known quotes" to "eight known quotes."
> - Add a renters quote as an age-31 customer with $35,000 coverage.
> - Make q8 a senior life quote or let you choose a different category.

## Why I was confident

- **Narrow scope.** One file, additive only. The existing six quotes stay.
- **Constraints match the real contract.** The plan's limits (age 18–100, coverage of at least $10,000) are the ones in the Mongoose schema in `api/src/Quote.js`. Copilot found them by reading the codebase, as I asked, rather than guessing.
- **It asked before acting.** The plan gave me a chance to redirect, and it left the q8 category as my call.
- **The change is checkable.** Running the seed exercises every row against the schema.

## Evidence: the seed run

```
labadmin@ip-172-16-174-46:~/evergreen-quote-launch/api$ npm run seed

> evergreen-quote-api@1.0.0 seed
> node --env-file=.env src/seed.js

Connected to MongoDB: mongodb://127.0.0.1:27017/evergreen
Seeded 8 quotes into the 'quotes' collection.
```

What this shows:
- **Eight documents, six plus two.** The seed inserts every row through the Mongoose schema, so a bad type, age, or coverage amount would have thrown instead of printing a count.
- **Renters passed validation.** That's only true because `"renters"` is in the schema's `type` enum, added during Tuesday's renters work. Before that change, q7 would have been rejected.

What this does **not** show:
- It doesn't show the values of q7 and q8.
- It ran against the **VM's** database. The cluster's database in the mongo pod is separate and was not seeded.

## Critique (what it got right, what I'd check)

Copilot got the important things right. It found the real limits (age 18–100, coverage of at least $10,000) by reading the codebase, kept the change to one file, and asked before editing. The seed run confirms all eight rows passed the schema. What the plan alone can't confirm is the premiums: it called them "realistic," but the seed's own comment says stored premiums are historical and needn't match the rate table, so "realistic" is unverified. It also left q8's category open, which was my decision to make. I'd ship these rows as test data, because the schema validates them and they aren't customer data.

## Which gate catches a bad row

The **Mongoose schema** in `api/src/Quote.js`. It validates every document the seed inserts, so an unknown coverage type, an age of 12, or a premium as a string would make `npm run seed` fail. It only fires at runtime, when someone runs the seed, so reading the proposal first and running the seed myself both matter.

## What would change my mind

If a seeded row passed the schema but was wrong in a way the schema can't see (for example, a premium far outside what the rate table would produce), I'd want a check that compares seed data to `calculatePremium`. Until then, I treat seed data as test data and review it by eye.