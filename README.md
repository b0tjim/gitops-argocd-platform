# gitops-argocd-platform

GitOps platform for the Dang Good Pies projects: an ArgoCD app-of-apps with
Kustomize dev/prod overlays and Sealed Secrets, deploying
[bakery-orders-api](https://github.com/b0tjim/bakery-orders-api) (via the Helm
chart in [k8s-observability-lab](https://github.com/b0tjim/k8s-observability-lab))
to a local kind cluster.

Work in progress — see [ROADMAP.md](ROADMAP.md).

## Layout

| Directory    | Role |
|--------------|------|
| `bootstrap/` | Applied by hand once: installs ArgoCD and the root app-of-apps. |
| `apps/`      | ArgoCD `Application` manifests; the root app watches this folder. |
| `platform/`  | Cluster add-ons (Sealed Secrets, kube-prometheus-stack). |
| `workloads/` | The bakery app: Kustomize base plus dev/prod overlays. |

## Local cluster

Needs [kind](https://kind.sigs.k8s.io/), Docker and kubectl.

```bash
make cluster-up     # single-node kind cluster named bakery-gitops
make cluster-down   # delete it
```

## License

MIT
