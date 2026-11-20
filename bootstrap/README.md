# bootstrap

The only manifests applied by hand (`kubectl apply -k`). They install ArgoCD and
the root app-of-apps `Application`; from then on ArgoCD manages everything else
from Git.

## argocd/

Installs ArgoCD v3.5.8 from the upstream `install.yaml`, pinned by tag so a
cluster rebuild always gets the same version. Apply it server-side, because the
ArgoCD CRDs are too large for client-side apply's annotation:

```sh
kubectl apply --server-side -k bootstrap/argocd
```
