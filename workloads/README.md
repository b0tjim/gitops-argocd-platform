# workloads

The bakery-orders-api deployment as Kustomize: a `base` that renders the Helm
chart from k8s-observability-lab, and `dev`/`prod` overlays that change only
what differs between environments (replicas, namespace, limits).
