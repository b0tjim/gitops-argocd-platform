# apps

ArgoCD `Application` manifests, one per component. The root app in
`bootstrap/` points at this folder (the "app-of-apps" pattern), so adding a file
here is how a new component gets deployed.

| File | Deploys | Sync |
|------|---------|------|
| `sealed-secrets.yaml` | Sealed Secrets controller | automatic |
| `kube-prometheus-stack.yaml` | Prometheus + Grafana | automatic |
| `bakery-orders-api-dev.yaml` | `workloads/.../overlays/dev` | automatic + self-heal |
| `bakery-orders-api-prod.yaml` | `workloads/.../overlays/prod` | manual (click Sync) |
