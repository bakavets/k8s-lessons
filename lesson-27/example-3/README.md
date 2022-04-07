### Create a Secret for accessing a container image registry:

```bash
kubectl create secret docker-registry secret-docker-registry \
  --docker-email=bakavets.com@gmail.com \
  --docker-username=bakavets \
  --docker-password=password \
  --docker-server=https://index.docker.io/v1/
```
Ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

