locals {
  k8s_service_account_cert_manager_namespace = "cert-manager"
  k8s_service_account_cert_manager_name      = "cert-manager-route53"
}

module "iam_assumable_role_cert_manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.8.0"
  create_role                   = true
  role_name                     = "${local.cluster_name}-cert-manager-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_cert_manager_namespace}:${local.k8s_service_account_cert_manager_name}"]
}

resource "aws_iam_policy" "cert_manager" {
  name        = "${local.cluster_name}-cert-manager-policy"
  description = "EKS AWS Cert Manager policy for the cluster ${local.cluster_name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
          "arn:aws:route53:::hostedzone/${aws_route53_zone.k8s_zone.zone_id}",
          "arn:aws:route53:::hostedzone/${var.aws_route53_hosted_zone_id}"
      ]
    }
  ]
}
EOF
}
