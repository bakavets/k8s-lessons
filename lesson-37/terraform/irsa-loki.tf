locals {
  loki = {
    namespace            = "loki"
    service_account_name = "loki"
  }
}

module "irsa_loki" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.3.0"
  create_role                   = true
  role_name                     = "${local.cluster_name}-grafana-loki-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.loki.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.loki.namespace}:${local.loki.service_account_name}"]
}

resource "aws_iam_policy" "loki" {
  name        = "${local.cluster_name}-grafana-loki-policy"
  description = "EKS Grafana Loki policy for cluster ${local.cluster_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowListObjects",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "${aws_s3_bucket.loki.arn}"
        },
        {
            "Sid": "AllowObjectsCRUD",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "${aws_s3_bucket.loki.arn}/*"
        },
        {
            "Sid": "KMS",
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": "${aws_kms_key.kms.arn}"
        }
    ]
}
EOF
}
