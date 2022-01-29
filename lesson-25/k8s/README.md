## Install NGINX Ingress Controller: https://kubernetes.github.io/ingress-nginx/deploy/#aws

NGINX Ingress Controller ingressClassName: https://kubernetes.github.io/ingress-nginx/user-guide/basic-usage/

# Install Cert-manager using Helm

```bash
helm repo add jetstack https://charts.jetstack.io
```

```bash
helm repo update
```

```bash
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.7.0 -f values-cert-manager.yaml
```

# Upgrade Cert-manager using Helm

```bash
helm upgrade cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.7.0 -f values-cert-manager.yaml
```