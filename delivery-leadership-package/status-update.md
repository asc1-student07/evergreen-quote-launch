# Stakeholder Status Update: Evergreen Quote, Tue EOD

**To:** Priya Ramanathan (Project Sponsor)
**From:** Marc Gagne (Delivery Lead)
**Date:** Tuesday, November 17, 2026

## What shipped today

- Client wired to the API. A saved quote now survives a reload for the first time in the program. The client and API rates are aligned, so the estimate and the saved row both read $450.00, for example.
- **Marketing's hero and banner line: approved and applied.** It's landing-page content we own, so it's done.
- **Renters coverage: built end to end** across the client type union, the form, and both rate tables. It also covers the API's database validation, and a renters quote saves and persists.

## What slipped (and why)

- No original scope slipped

## Life Default Decision

- **The life-first form default is acknowledged, not done.** It seems simple, but it lives in the engineering team's `useQuoteEstimate.ts` hook, which every estimate flows through and it's added risk to touch application code two days before launch. I’ve routed it to the engineering team (logged as a board issue with the Friday launch date on it), and I recommend it leads their first post-launch change.

## Renters decision

Last week I deferred renters as scope creep. This week the call is **yes, in scope**, because the cost that drove the deferral is gone. Last week's AI-assisted development work taught the team how to direct agentic AI, and we used it to build renters ahead of your ask. It's verified, not speculative.

## Demo plan (confirmed in writing)

Friday's demo runs locally on my VM, with nothing in the cloud. It uses the kind cluster `evergreen`, `kubectl port-forward svc/evergreen-quote-api 3000:80`, and the wired client at `http://localhost:5173`.

## What I need from you

- **Confirm by 11:00 Wednesday:** the form default stays out of this launch, and renters ships in it.
- Acknowledge the demo plan above.