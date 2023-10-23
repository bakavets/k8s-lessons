locals {
  cert_manager = {
    namespace            = "cert-manager"
    service_account_name = "cert-manager-route53"
  }
}

module "irsa_cert_manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.3.0"
  create_role                   = true
  role_name                     = "${local.cluster_name}-cert-manager-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cert_manager.namespace}:${local.cert_manager.service_account_name}"]
}

# https://cert-manager.io/docs/configuration/acme/dns01/route53/

resource "aws_iam_policy" "cert_manager" {
  name        = "${local.cluster_name}-cert-manager-policy"
  description = "EKS AWS Cert Manager policy for cluster ${local.cluster_name}"

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
      "Resource": "arn:aws:route53:::hostedzone/${data.aws_route53_zone.zone.zone_id}"
    }
  ]
}
EOF
}
