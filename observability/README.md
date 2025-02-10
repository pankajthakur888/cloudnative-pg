# Installation
## In most cases, you will need to clone this repository (or your fork):

```sh
git clone https://github.com/dotdc/grafana-dashboards-kubernetes.git
cd grafana-dashboards-kubernetes

```
# Install with ArgoCD

## If you are using ArgoCD, this will deploy the dashboards in the default project of ArgoCD:
```sh
kubectl apply -f argocd-app.yml
```
