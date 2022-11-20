export K8S_NODE=ip-10-23-56-192.eu-west-1.compute.internal

kubectl taint nodes $K8S_NODE node.k8s/app-role=api:PreferNoSchedule

kubectl taint nodes $K8S_NODE gpu=true:NoSchedule

# Remove from node '$K8S_NODE' the taint with key 'node.k8s/app-role' and effect 'PreferNoSchedule' if one exists

kubectl taint nodes $K8S_NODE node.k8s/app-role:PreferNoSchedule-

kubectl taint nodes $K8S_NODE gpu=true:NoSchedule-
