locals {
  k8s_service_account_external_dns_namespace = "kube-system"
  k8s_service_account_external_dns_name      = "external-dns"
}

module "iam_assumable_role_external_dns" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.2.0"
  create_role                   = true
  role_name                     = "${local.cluster_name}-external-dns-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.external_dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_external_dns_namespace}:${local.k8s_service_account_external_dns_name}"]
}

resource "aws_iam_policy" "external_dns" {
  name        = "${local.cluster_name}-external-dns-policy"
  description = "EKS AWS ExternalDNS policy for cluster ${local.cluster_name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
