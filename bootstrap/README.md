# bootstrap

The only manifests applied by hand (`kubectl apply -k`). They install ArgoCD and
the root app-of-apps `Application`; from then on ArgoCD manages everything else
from Git.
