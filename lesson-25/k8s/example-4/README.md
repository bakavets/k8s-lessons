Check allowed domains in cert:

```bash
kubectl -n demo get secret app-tls-bakavets -o json | jq -r '.data."tls.crt"' | base64 -d | openssl x509 -dates -noout -text | grep DNS:
```
