<a href="https://youtu.be/A_0zbCZbSbE" target="_blank">
 <img src="https://img.youtube.com/vi/A_0zbCZbSbE/0.jpg" alt="Watch the video" width="860" height="620" border="10" />
</a>

Installing Helm: https://helm.sh/docs/intro/install/

Helm create:

```helm create demo-chart```

The Chart File Structure: https://helm.sh/docs/topics/charts/#the-chart-file-structure

Predefined Values: https://helm.sh/docs/topics/charts/#predefined-values

Install App:

```helm install demo-app ./demo-chart```

List all available releases across all namespaces:

```helm list --all-namespaces```

The status of a specific release:

```helm status demo-app```

Display the release history:

```helm history demo-app```

Simulate an upgrade of release with debug:

```helm upgrade demo-app ./demo-chart --debug --dry-run```

Release upgrade:

```helm upgrade demo-app ./demo-chart --debug --wait```

Helm upgrade options: https://helm.sh/docs/helm/helm_upgrade/#options

Helm install options: https://helm.sh/docs/helm/helm_install/#options

```helm upgrade demo-app ./demo-chart --set image.tag=1.212121```

Roll back a release:

```helm rollback demo-app 1```

Release upgrade with rolls back in case of failed upgrade:

```helm upgrade demo-app ./demo-chart --debug --atomic --timeout 20s --set image.tag=1.212121```

Install App in namespace:

```helm upgrade --install demo-app-test ./demo-chart -f demo-chart/values-dev.yaml -n app --create-namespace --dry-run```

```helm template demo-app-test ./demo-chart -f demo-chart/values-dev.yaml```

```helm upgrade --install demo-app-test ./demo-chart -f demo-chart/values-dev.yaml -n app --create-namespace```

Chart Management:

```helm lint demo-chart```

```helm package demo-chart```

```helm upgrade --install demo-app-test demo-chart-0.1.0.tgz --dry-run```

Helm Secrets:

```kubectl get secrets/sh.helm.release.v1.demo-app.v2 --template={{.data.release}} | base64 -D | base64 -D | gzip -cd > release_decoded```

```echo -n "" | base64 --decode > ingr.yaml```

Uninstall Apps:

```helm uninstall demo-app```

```helm uninstall demo-app-test -n app```

Helm pull:

```helm repo add prometheus-community https://prometheus-community.github.io/helm-charts```

```helm repo update```

```helm search repo prometheus-community/kube-prometheus-stack```

```helm pull prometheus-community/kube-prometheus-stack```