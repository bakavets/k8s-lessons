Certificate Resources: https://cert-manager.io/docs/usage/certificate/

Check allowed domains in cert:

```bash
kubectl get secret tls-wildcard -o json | jq -r '.data."tls.crt"' | base64 -d | openssl x509 -dates -noout -text | grep DNS:
```
