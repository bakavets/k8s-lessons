Install External Secrets using Helm:

```helm repo add external-secrets https://charts.external-secrets.io```

```helm repo update external-secrets```

```helm search repo external-secrets/external-secrets```

```helm upgrade --install external-secrets external-secrets/external-secrets --version 0.6.0 -n external-secrets --create-namespace```
