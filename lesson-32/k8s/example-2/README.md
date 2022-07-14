```while true; do sleep 1; curl -H "Host: app-1.kubxr.com" http://domain-name.amazonaws.com; echo " - "$(date); done```

```kubectl get pod -o wide -n example-2```