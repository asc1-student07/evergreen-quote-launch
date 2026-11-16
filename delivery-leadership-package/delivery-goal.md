# Delivery Goal: Evergreen Quote

## Goal

> By Thursday EOD, the Evergreen Quote client is wired to the API so a shopper's saved quote survives a reload, the containerized API has been demonstrated on the local cluster, and the launch is merged to `main` through a reviewed PR with both CI jobs green.

## "Done" looks like

- The quote page loads its recent quotes from the API, and a saved quote survives a reload.
- The estimate on screen and the saved premium agree, at the launch rates.
- `npm test` (API) and `npm run type-check` + `npm run build` (client) pass; both CI jobs on the merge commit are **green**.
- The containerized API serves the wired app, and the cluster demo shows three API pods behind one Service.
- The landing page carries the launch banner and points at the app.
- A reviewed PR is merged, branch deleted.

## Out of scope (this week)

- Refactoring the landing page, client, or API codebases; this launch integrates them as they are.
- Roadmap features: user authentication and accounts, saved quotes tied to a customer identity, email capture and reminders, quote comparison, and the path from quote to purchase.
