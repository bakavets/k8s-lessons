locals {
  external_secrets = {
    namespace            = "external-secrets"
    service_account_name = "external-secrets-sa"
  }
}

module "iam_assumable_role_external_secrets" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.3.0"
  create_role                   = true
  role_name                     = "${local.cluster_name}-external-secrets-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.external_secrets.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.external_secrets.namespace}:${local.external_secrets.service_account_name}"]
}

resource "aws_iam_policy" "external_secrets" {
  name        = "${local.cluster_name}-external-secrets-policy"
  description = "EKS AWS External Secrets policy for cluster ${local.cluster_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": [
                "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.account.account_id}:secret:${var.deployment_prefix}-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter*"
            ],
            "Resource": "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.account.account_id}:parameter/${var.deployment_prefix}-*"
        }
    ]
}
EOF
}
