## Install Argo CD

```kubectl create namespace argocd```

```kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml```

## Access The Argo CD API Server

```kubectl port-forward svc/argocd-server -n argocd 8080:443```

## Login Using The CLI

```kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo```