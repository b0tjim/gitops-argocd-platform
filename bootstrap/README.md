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

## projects/

The `bakery` `AppProject`. Every Application in this repo uses it, and it only
allows this repo, the k8s-observability-lab chart repo and the two pinned Helm
repos as sources, deploying to `argocd`, `kube-system`, `monitoring`,
`bakery-dev` and `bakery-prod`. `make argocd-install` applies it after ArgoCD's
CRDs exist (applying both in one go fails because the `AppProject` kind isn't
registered yet).
