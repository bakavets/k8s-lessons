Network Load Balancer: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/service/nlb/

Service annotations: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/service/annotations/

Pod readiness gate: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/pod_readiness_gate/

```while true; do sleep 1; curl http://domain-name.amazonaws.com; echo " - "$(date); done```

```kubectl get pod -o wide -n example-1```