# Go / No-Go: Launch Decision

**Date / time:** Wed Nov 18, 2026, (evidence captured 16:27 UTC)
**Decision:** ☒ GO   ☐ NO-GO   ☐ GO WITH CONDITIONS

## CI evidence

- Latest run on `delivery/lead`: **[green]**
- Workflow file: `.github/workflows/ci.yml`
- What the workflow actually checked: **Test the API** ran the API tests against a `mongo:7` service container. **Type-check and build the client** ran type-check and the production build. It did **not** check the cluster demo, the landing links, or that the premiums are believable; those are human checks, covered in the next section.

## Environment evidence (my cluster)

Everything below describes **my** local cluster, `kind-evergreen`, not the shared `demo` environment that the incident is about.

```
$ date; kubectl config current-context
Wed Nov 18 16:27:14 UTC 2026
kind-evergreen

$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
evergreen-quote-api-5b99c99f9c-6hcd4   1/1     Running   0          3h2m
evergreen-quote-api-5b99c99f9c-tlkfz   1/1     Running   0          3h2m
evergreen-quote-api-5b99c99f9c-zs4cn   1/1     Running   0          3h2m
mongo-77984b56bb-qx8bw                 1/1     Running   0          3h3m

$ grep -n -A1 "name: MONGODB_URI" k8s/deployment.yaml
26:            - name: MONGODB_URI
27-              value: mongodb://mongo:27017/evergreen
```

- **My stack is healthy.** Three API pods and one mongo pod are `Running` with zero restarts after about three hours.
- **My manifest uses the variable name the app reads** (`MONGODB_URI`), so the shared cluster's failure mode (pods restarting after the name became `MONGO_URI`) is not present here.
- **Not shown above:** [optional: a quote saved through the port-forward landing in the cluster's database; add the `mongosh` output if you captured it].

## What "GO" would mean

- Merge `delivery/lead` → `main`, squash, delete branch.
- Tag the merge commit `launch`.
- Friday's demo runs on the local stack I verified: the `evergreen` kind cluster, port-forward to 3000, and the client on 5173, as confirmed in writing Tuesday.

## What "NO-GO" would mean

- Hold the merge until: CI run is green.  This condition exists if any of my CI runs before the demo go red.
- Owner of that condition: me (Delivery Lead) for CI and my own cluster. 
- Re-evaluate at: Thursday 16:00, after the merge and the cluster re-verification, or within an hour of any red CI run.

## My call

**Go, on my own stack's evidence.** CI runs to date are green and my cluster is healthy (see Environment evidence), so the incident is not in my environment. The failing pods are on the **shared demo cluster**, owned by the platform team, where a renamed variable (`MONGO_URI` where the app reads `MONGODB_URI`) preceded the crash loop. I routed the evidence to them with a specific ask and sent the manager a holding note (see Addendum). What would flip this to no-go: a red CI job on `main` after the merge, or my cluster demo failing re-verification Thursday. If the shared environment is still down Friday, nothing changes, because the demo doesn't depend on it.

## Addendum: Inject #2 messages sent

Kept here for tracking, since they belong to the incident response and have no other home in the package.

### 1. To the platform owner (routing the problem)

**To:** Platform team (owner of the shared demo cluster) · **From:** Marc Gagne · **Wed Nov 18, 2026**

Hi team: the manager's pre-launch dry run on the **shared demo environment** has shown "Could not load recent quotes" since about 13:25. The `demo` namespace shows all three `evergreen-quote-api` pods in CrashLoopBackOff (6–7 restarts), while the `mongo` pod is healthy (1/1 Running, 0 restarts). The API logs show it trying to reach the database at 127.0.0.1, and the deployment now injects `MONGO_URI` where the application reads `MONGODB_URI`; the restarts began with the variable-name tidy-up about 30 minutes before. Can your team confirm that rename and restore the name the app reads (the value looks correct), and tell me by 16:00 today whether that is done or what you need from us? Our own cluster and CI are unaffected and green, so I'm not touching the shared environment. Happy to provide logs or take a call if useful; I can also confirm the variable name against our manifest.

### 2. To the reporting manager (holding message)

**To:** Reporing Manager · **From:** Marc Gagne · **Wed Nov 18, 2026**

Thanks for flagging this. What we know: the shared demo environment you tested is down because its API can't find its database after a configuration rename made earlier today. The database itself is fine. The platform team owns that environment, and I've sent them the evidence and a specific ask. Friday's launch demo doesn't run on that environment. It runs on our own separate stack, which is working and passing its checks. I'll update you by 16:30 today, or sooner if the platform team replies.