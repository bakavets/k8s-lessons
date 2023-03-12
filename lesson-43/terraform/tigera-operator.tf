provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

################################################################################
# EFS CSI Helm
################################################################################

resource "helm_release" "tigera_operator" {
  name = "tigera-operator"

  repository       = "https://docs.tigera.io/calico/charts"
  chart            = "tigera-operator"
  version          = "v3.25.0"
  namespace        = "tigera-operator"
  create_namespace = true

  values = [
    file("${path.module}/templates/tigera-operator-values.yaml")
  ]

  depends_on = [
    module.eks
  ]
}
