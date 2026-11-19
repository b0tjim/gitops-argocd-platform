# apps

ArgoCD `Application` manifests, one per component. The root app in
`bootstrap/` points at this folder (the "app-of-apps" pattern), so adding a file
here is how a new component gets deployed.
