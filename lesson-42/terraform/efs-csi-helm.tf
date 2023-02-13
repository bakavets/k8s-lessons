provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}

################################################################################
# EFS CSI Helm
################################################################################

resource "helm_release" "efs_csi_driver" {
  name = "efs-csi-driver"

  repository       = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart            = "aws-efs-csi-driver"
  version          = "2.3.7"
  namespace        = local.efs_csi_driver.namespace
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/efs-csi-values.yaml", {
      sa_name  = local.efs_csi_driver.service_account_name,
      role_arn = module.irsa_efs_csi_driver.iam_role_arn
    })
  ]

  depends_on = [
    module.eks
  ]
}
