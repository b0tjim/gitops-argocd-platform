# workloads

The bakery-orders-api deployment as Kustomize: a `base` that renders the Helm
chart from k8s-observability-lab, and `dev`/`prod` overlays that change only
what differs between environments (replicas, namespace, limits).

Render the base locally with `kustomize build --enable-helm workloads/bakery-orders-api/base`.
The chart under `base/charts/` is a vendored copy; see the comment in
`base/kustomization.yaml` for where it comes from and how to update it.

Overlays live in `bakery-orders-api/overlays/`:

- `dev`: one replica in the `bakery-dev` namespace, with `UVICORN_LOG_LEVEL=debug`.
