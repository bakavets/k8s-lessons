Securing Ingress Resources: https://cert-manager.io/docs/usage/ingress/

Check allowed domains in cert:

```bash
kubectl get secret app-tls -o json | jq -r '.data."tls.crt"' | base64 -d | openssl x509 -dates -noout -text | grep DNS:
```
