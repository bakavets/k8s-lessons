### Create a Secret using kubectl from-file:

```bash
echo -n 'admin' > ./username.txt
echo -n 'superpass12345&*' > ./password.txt
```

```bash
kubectl create secret generic db-user-pass-from-file \
  --from-file=./username.txt \
  --from-file=./password.txt
```

```bash
kubectl get secret db-user-pass-from-file -o yaml
```

### Create a Secret using kubectl from-literal:

```bash
kubectl create secret generic db-user-pass-from-literal \
  --from-literal=username=devuser \
  --from-literal=password='P!S?*r$zDsY'
```

### Decoding the Secret:

```bash
kubectl get secret db-user-pass-from-file -o jsonpath='{.data}'
```

```bash
kubectl get secret db-user-pass-from-literal -o jsonpath='{.data.password}' | base64 --decode
```
