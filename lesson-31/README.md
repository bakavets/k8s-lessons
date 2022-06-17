```helm repo add elastic https://helm.elastic.co```

```helm repo update elastic```

```helm upgrade --install elasticsearch --version 7.17.3 elastic/elasticsearch --set replicas=1 -n elastic --create-namespace --debug```

```helm upgrade --install kibana --version 7.17.3 elastic/kibana -n elastic --debug```

https://github.com/fluent/fluentd-kubernetes-daemonset

https://docs.fluentd.org/configuration/config-file#5-group-filter-and-output-the-ldquolabelrdquo-directive

