export K8S_NODE=ip-10-23-80-243.eu-west-1.compute.internal

kubectl taint nodes $K8S_NODE gpu=true:NoExecute
