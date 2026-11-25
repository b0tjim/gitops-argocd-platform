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

## ArgoCD

```bash
make argocd-install   # pinned ArgoCD v3.5.8 into the argocd namespace
make argocd-password  # initial admin password
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Then open <https://localhost:8080> (self-signed cert, so accept the browser
warning) and log in as `admin` with the printed password.

## Secrets

The database password is managed with
[Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets). The controller
(installed by `apps/sealed-secrets.yaml`) holds a private key that never leaves
the cluster; anyone can encrypt with its public key, but only the controller can
decrypt. So the encrypted `SealedSecret` is safe to commit, and the plain Secret
never is (`.env` and `*.unsealed.yaml` are git-ignored).

Needs [kubeseal](https://github.com/bitnami-labs/sealed-secrets#kubeseal) and the
controller running in the cluster.

```bash
cp .env.example .env              # then set a real POSTGRES_PASSWORD
scripts/seal-db-secret.sh dev     # writes overlays/dev/postgresql-sealedsecret.yaml
scripts/seal-db-secret.sh prod    # same for prod
```

A SealedSecret is bound to its name and namespace, so each environment gets its
own. Re-run the script after rotating the password, or after recreating the
cluster (a new controller has a new key). To seal without cluster access, pass
the public cert: `SEALED_SECRETS_CERT=cert.pem scripts/seal-db-secret.sh dev`.

## License

MIT
