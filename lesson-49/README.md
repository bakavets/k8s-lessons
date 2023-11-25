Terraform
```
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

cd terraform
terraform init
terraform plan
terraform apply

aws configure --profile personal
aws eks update-kubeconfig --name demo-eks-cluster --profile personal --region eu-west-1
```

K8s
```
cd k8s
kubectl create ns gitlab-space-external
kubectl apply -f gitlab-runner-secret.yaml

helm repo add gitlab https://charts.gitlab.io
helm repo update gitlab
helm install --namespace gitlab-space-external gitlab-runner -f gitlab-runner-values.yaml gitlab/gitlab-runner --version 0.57.0

kubectl apply -f sa-kaniko.yaml
```
