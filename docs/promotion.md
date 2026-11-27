# Promoting a release from dev to prod

Git is the only way a new version reaches the cluster. Each overlay pins the
image tag it runs in its `kustomization.yaml`:

```yaml
images:
  - name: ghcr.io/b0tjim/bakery-orders-api
    newTag: "0.1.0"
```

Both ArgoCD Applications track `main`, so changing that tag on `main` is a
deploy. The difference is what happens next:

| Environment | Application              | After the tag changes on `main` |
|-------------|--------------------------|---------------------------------|
| dev         | `bakery-orders-api-dev`  | Auto-sync rolls it out within ~3 minutes (ArgoCD's default poll). |
| prod        | `bakery-orders-api-prod` | Shows **OutOfSync**; nothing changes until someone syncs it. |

## Steps

1. **Release the app.** Push a version tag (e.g. `v0.2.0`) in
   [bakery-orders-api](https://github.com/b0tjim/bakery-orders-api). Its CI
   publishes `ghcr.io/b0tjim/bakery-orders-api:0.2.0`. Check the tag's Actions
   run is green before going on.
2. **Promote to dev.** Open a PR here that changes `newTag` in
   `workloads/bakery-orders-api/overlays/dev/kustomization.yaml`. CI renders
   and validates both overlays. Merge it; ArgoCD syncs dev on its own.
3. **Check dev.** In the ArgoCD UI (or `argocd app get bakery-orders-api-dev`)
   the app should be Synced and Healthy. Hit `/health` and watch the Grafana
   dashboard for errors.
4. **Promote to prod.** Open a second PR that makes the same `newTag` change in
   `overlays/prod/kustomization.yaml`. The PR is the approval record: who
   promoted what, when, and after which review.
5. **Sync prod.** After merging, prod shows OutOfSync. Review the diff in
   ArgoCD, then click **Sync** or run `argocd app sync bakery-orders-api-prod`.
   Prod runs two replicas behind a PodDisruptionBudget, so the rolling update
   keeps at least one pod serving.

## Rolling back

Revert the promotion PR (`git revert <commit>`) and merge it. Dev rolls back on
its own; sync prod by hand as in step 5. Avoid `argocd app rollback` or
`kubectl set image`: on dev, self-heal undoes them, and on prod they leave the
cluster out of step with git.

## Why two PRs instead of one

Dev and prod never change in the same commit, so a bad image is caught in dev
before anyone touches prod, and the git log shows exactly when each environment
got each version.
