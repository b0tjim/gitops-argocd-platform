# Roadmap

GitOps platform for the Dang Good Pies projects: ArgoCD app-of-apps, Kustomize
dev/prod overlays and Sealed Secrets, deploying the bakery-orders-api Helm chart
from b0tjim/k8s-observability-lab plus the monitoring stack. Everything runs on a
local kind cluster, so it needs no cloud account.

Each step is small and should leave `main` green.

- [x] 1. Repo scaffolding: README stub, MIT LICENSE, .gitignore, .editorconfig.
- [x] 2. Directory layout: `bootstrap/`, `apps/`, `platform/`, `workloads/` with a short README in each explaining its role.
- [ ] 3. `kind/cluster.yaml` and a Makefile with `cluster-up` / `cluster-down` targets.
- [ ] 4. `bootstrap/argocd/` Kustomization that installs a pinned ArgoCD release from the upstream manifest.
- [ ] 5. Makefile `argocd-install` and `argocd-password` targets, plus port-forward instructions.
- [ ] 6. ArgoCD `AppProject` (`bakery`) restricting source repos and destination namespaces.
- [ ] 7. Root app-of-apps `Application` (`bootstrap/root-app.yaml`) pointing at `apps/`.
- [ ] 8. `platform/sealed-secrets` Application (pinned Helm chart) in the `kube-system` namespace.
- [ ] 9. `platform/kube-prometheus-stack` Application (pinned chart, slim values reused from k8s-observability-lab).
- [ ] 10. `workloads/bakery-orders-api/base`: Kustomization that renders the Helm chart from k8s-observability-lab via `helmCharts`.
- [ ] 11. `overlays/dev`: one replica, `bakery-dev` namespace, debug log level.
- [ ] 12. `overlays/prod`: two replicas, resource limits, `bakery-prod` namespace, PodDisruptionBudget.
- [ ] 13. Child Applications for dev (auto-sync + self-heal) and prod (manual sync) under `apps/`.
- [ ] 14. Sealed Secrets workflow: `scripts/seal-db-secret.sh` using `kubeseal`, `.env.example`, docs on why only the sealed file is committed.
- [ ] 15. Wire the sealed DB secret into the dev and prod overlays.
- [ ] 16. CI: yamllint and `kustomize build --enable-helm` for every overlay on every push.
- [ ] 17. CI: kubeconform schema validation of rendered manifests (with CRD schemas for ArgoCD).
- [ ] 18. CI: spin up kind, install ArgoCD, apply the root app and wait until the dev app is Synced/Healthy.
- [ ] 19. Dependabot for GitHub Actions; pin action versions.
- [ ] 20. Promotion doc: how a new image tag moves from dev to prod (PR that bumps the tag in the prod overlay).
- [ ] 21. README: Mermaid architecture diagram, what it demonstrates, how to run it, CI badge.
- [ ] 22. Polish and release: tidy docs, annotated `v0.1.0` tag (verify via the Actions run for the tag).
