locals {
  ebs_csi_driver = {
    namespace            = "kube-system"
    service_account_name = "ebs-csi-controller-sa"
  }
}

module "irsa_ebs_csi_driver" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.3.0"
  create_role                   = true
  role_name                     = "${local.cluster_name}-ebs-csi-driver-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_driver.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.ebs_csi_driver.namespace}:${local.ebs_csi_driver.service_account_name}"]
}

data "aws_iam_policy" "ebs_csi_driver" {
  name = "AmazonEBSCSIDriverPolicy"
}
