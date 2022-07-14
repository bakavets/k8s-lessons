Ingress annotations: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/

Service annotations: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/service/annotations/

Install AWS Load Balancer Controller using Helm:

```helm repo add eks https://aws.github.io/eks-charts```

```helm repo update eks```

```helm search repo eks/aws-load-balancer-controller```

```helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller --version 1.4.2 -n kube-system -f albc-values.yaml```

