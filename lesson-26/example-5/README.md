Create a Kubernetes Configmap with custom nginx.conf using kubectl:

```bash
kubectl create configmap nginx-config --from-file=nginx.conf
```

## Create ConfigMaps from literal values

You can use kubectl create configmap with the --from-literal argument to define a literal value from the command line:
```bash
kubectl create configmap config --from-literal=interval=7 --from-literal=count=3 --from-literal=config.ini="Hello from ConfigMap"
```

## Create ConfigMaps from folder:

```bash
kubectl create configmap my-config --from-file=configs/
```

## Use the option --from-env-file to create a ConfigMap from an env-file, for example:

```bash
kubectl create configmap config-env-file --from-env-file=env-file.properties
```