```for node in $(kubectl get po -o wide | grep -v NODE | awk '{print $7}'); do kubectl get node $node -L topology.kubernetes.io/zone,node.k8s/role | tail -n +2 | awk '{ print $1, "\033[32m" $6 "\033[0m","\033[35m" $7 "\033[0m"}'; done | sort | uniq -c```

### Respect PodTopologySpread after rolling upgrades:

https://github.com/kubernetes/enhancements/issues/3243

https://github.com/kubernetes/kubernetes/pull/111441

Issues:
* https://github.com/kubernetes/kubernetes/issues/98215
* https://github.com/kubernetes/kubernetes/issues/105661
* https://stackoverflow.com/questions/66510883/k8s-pod-topology-spread-is-not-respected-after-rollout
