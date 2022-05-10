Install ChartMuseum:

```helm repo add chartmuseum https://chartmuseum.github.io/charts```

```helm repo update chartmuseum```

```helm search repo chartmuseum -l```

```helm pull chartmuseum/chartmuseum```

```helm install chartmuseum -f chartmuseum-values.yaml chartmuseum/chartmuseum -n chartmuseum --create-namespace --dry-run```

```helm install chartmuseum -f chartmuseum-values.yaml chartmuseum/chartmuseum -n chartmuseum --create-namespace```

```kubectl port-forward svc/chartmuseum 8080:8080 -n chartmuseum```

Chart Manipulation:

```helm repo add my-chartmuseum http://localhost:8080/```

```helm repo update my-chartmuseum```

```helm search repo my-chartmuseum -l```

Create Helm app:

```helm create app```

```helm package app```

```curl --data-binary "@app-0.1.0.tgz" http://localhost:8080/api/charts```

```helm install my-app my-chartmuseum/app --dry-run```

Create Helm demo-app:

```helm create demo-app```

```helm package demo-app```

```curl --data-binary "@demo-app-0.1.0.tgz" http://localhost:8080/api/charts```

Delete Helm chart from ChartMuseum:

```curl -X DELETE http://localhost:8080/api/charts/app/0.2.0```

Update ChartMuseum with BASIC_AUTH:

```helm upgrade chartmuseum -f chartmuseum-values.yaml chartmuseum/chartmuseum -n chartmuseum --dry-run```

```helm upgrade chartmuseum -f chartmuseum-values.yaml chartmuseum/chartmuseum -n chartmuseum```

```helm repo add --username admin --password mypassword my-chartmuseum http://localhost:8080/ --force-update```

```helm repo update my-chartmuseum```

```helm search repo my-chartmuseum -l```

```curl --user admin:mypassword --data-binary "@app-0.2.0.tgz" http://localhost:8080/api/charts```

```curl --user admin:mypassword -X DELETE http://localhost:8080/api/charts/app/0.2.0```