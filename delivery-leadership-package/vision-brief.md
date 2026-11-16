# Evergreen Quote: Vision Brief

## Product
**Name:** Evergreen Insurance Quote (the launch: full-stack delivery)
**Delivery week:** Final
**Delivery Lead:** Marc Gagne
**Engineering team (represented by):** _Link to your Evergreen Quote project repo_
**GitHub Project board:** _Link to your board_

## Who is the customer?
A first-time insurance shopper in their 20s or 30s who needs coverage soon and wants a believable monthly number on their phone, fast, with no account and no phone call. What is new with this launch is that they come back: they got a number on Tuesday, and on Thursday they want to see it again and compare it with a second option.

## What pain does Evergreen Quote remove?
Right now our customer gets half an experience. They can type their details into the quote page and watch a number move, but if they refresh or come back tomorrow, it's gone and they start over. Meanwhile we have a service that stores quotes reliably, but no customer can reach it. What a shopper actually wants is simple: "I got a number yesterday, show it to me again." That is the pain I'm removing. My job as Delivery Lead this week is to connect what we already built, so a quote someone saves is still there when they come back.

## What does "good" look like at end of the week?
- The recent-quotes panel shows quotes from the database, not a bundled sample: save a quote, reload the page, and it persists.
- The estimate on screen and the saved premium agree to the cent, because the client and API use the same rate table.
- Both CI jobs (API tests; client type-check and build) are green on the merge commit on `main`.
- The containerized API runs as three replicas on the local Kubernetes cluster, and a quote saved in the browser lands in the cluster's database.
- The landing page carries the launch banner, and both quote links point at the running app.


## What are we explicitly NOT doing this week?
- **No refactoring of the three codebases.** The landing page, client, and API each have an owning team. This launch integrates them as they are; any cleanup goes on the backlog.
- **No roadmap features.** User authentication and accounts, saved quotes tied to a customer identity, email capture and reminders, side-by-side quote comparison, and the path from quote to purchase are all future roadmap items. Each one adds scope and risk to a launch whose value is connecting what already exists.
- **No new infrastructure, pipeline, or pricing work.** We use the existing Docker image, manifests, and two-job CI as provided, with no new environments or monitoring. The only rate change is aligning the client to the server, which is the source of truth.

## How will we know if it worked?
- In every demo attempt, a saved quote survives a reload and the on-screen estimate equals the saved premium to the cent.
- The final showcase runs end to end on the local stack.