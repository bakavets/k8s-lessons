```
# Point to the internal API server hostname
APISERVER=https://kubernetes.default.svc

# Path to ServiceAccount token
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount

# Read this Pod's namespace
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

# Read the ServiceAccount bearer token
TOKEN=$(cat ${SERVICEACCOUNT}/token)

# Reference the internal certificate authority (CA)
CACERT=${SERVICEACCOUNT}/ca.crt

# Explore the API with TOKEN
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api
```
---
```
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/apis/apps/v1/namespaces/${NAMESPACE}/deployments
```
```
curl -s --retry 3 --retry-delay 3 \
    --cacert ${CACERT} \
    -X PATCH \
    -H "Content-Type: application/strategic-merge-patch+json" \
    -H "Authorization: Bearer ${TOKEN}" \
    --data '{"spec":{"replicas":3}}' \
    ${APISERVER}/apis/apps/v1/namespaces/${NAMESPACE}/deployments/nginx-deployment
```
---
```
kubectl cluster-info
kubectl config set-cluster demo-cluster --server=https://kubernetes.default --certificate-authority=ca.crt
kubectl config set-context demo-context --cluster=demo-cluster
kubectl config set-credentials demo-user --token={token}
kubectl config set-context demo-context --user=demo-user
kubectl config use-context demo-context
```
---
```
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/${NAMESPACE}/services

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/${NAMESPACE}/pods

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/${NAMESPACE}/pods/kuber-1-58b5bd8664-b95b5/log

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/apis/apps/v1/namespaces/${NAMESPACE}/deployments/kuber-2
```