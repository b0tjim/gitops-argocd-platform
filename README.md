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

Each overlay lists its `postgresql-sealedsecret.yaml` as a resource and deletes
the chart's plain Secret, so the only Secret in the cluster is the one the
controller decrypts. The committed files hold the `.env.example` placeholders
sealed with a throwaway cert, so they only show the shape: on your cluster,
re-run the script for each environment before syncing.

## CI

Every push runs yamllint, `kustomize build --enable-helm` and kubeconform. On
`main`, an end-to-end job also creates a kind cluster, builds the app image from
source, installs ArgoCD, applies the root app and waits until
`bakery-orders-api-dev` is Synced and its Deployment is ready. The committed
SealedSecret can't be decrypted by that fresh controller (it was sealed with a
throwaway cert), so the job creates a CI-only plain DB Secret first; the
SealedSecret shows as Degraded there, which is expected.

## License

MIT
