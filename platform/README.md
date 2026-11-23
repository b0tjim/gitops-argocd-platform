# platform

Cluster-wide add-ons that the workloads depend on: Sealed Secrets (decrypts
committed `SealedSecret`s) and kube-prometheus-stack (Prometheus + Grafana).

The add-ons are plain upstream Helm charts, so their `Application` manifests
live in `apps/` (e.g. `apps/sealed-secrets.yaml`) with values inline; this
folder only holds extra manifests or values files when a chart needs them.
