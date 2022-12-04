GitHub: https://github.com/kubernetes-sigs/kind

Installation and usage: https://github.com/kubernetes-sigs/kind#installation-and-usage

To use kind, you will need to install docker. Once you have docker running you can create a cluster with:

```kind create cluster --name k8s --config kind-config.yaml```

To delete your cluster use:

```kind delete cluster --name k8s```

Rolling restart of the "zone-spread-topology" deployment:

```kubectl rollout restart deployment zone-spread-topology```
