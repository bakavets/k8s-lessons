ExternalDNS GitHub: https://github.com/kubernetes-sigs/external-dns

ExternalDNS Artifacthub: https://artifacthub.io/packages/helm/bitnami/external-dns

Install ExternalDNS using Helm:

```helm repo add bitnami https://charts.bitnami.com/bitnami```

```helm repo update bitnami```

```helm search repo bitnami/external-dns```

```helm upgrade --install external-dns bitnami/external-dns --version 6.7.4 -n kube-system -f external-dns-values.yaml```

Note: https://github.com/kubernetes-sigs/external-dns/blob/v0.12.2/docs/registry.md