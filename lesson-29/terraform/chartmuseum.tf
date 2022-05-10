resource "aws_s3_bucket" "chartmuseum" {
  bucket = "${var.deployment_prefix}-helm-chartmuseum"
  tags = {
    "Name"        = "${var.deployment_prefix}-chartmuseum"
    "Type"        = "Storage Service"
    "Description" = "Store ChartMuseum data for deployment related to ${var.deployment_prefix}"
  }
}

locals {
  k8s_service_account_chartmuseum_namespace = "chartmuseum"
  k8s_service_account_chartmuseum_name      = "chartmuseum"
}

module "iam_assumable_role_chartmuseum" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.8.0"
  create_role                   = true
  role_name                     = "${local.cluster_name}-chartmuseum-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.chartmuseum.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_chartmuseum_namespace}:${local.k8s_service_account_chartmuseum_name}"]
  tags = {
    "Name"        = "${local.cluster_name}-chartmuseum-role"
    "Description" = "ChartMuseum assumable IAM role for deployment related to ${var.deployment_prefix}"
  }
}

resource "aws_iam_policy" "chartmuseum" {
  name        = "${local.cluster_name}-chartmuseum-policy"
  description = "ChartMuseum policy for IAM role ${module.iam_assumable_role_chartmuseum.iam_role_name} for deployment related to ${var.deployment_prefix}"

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
      "Resource": "${aws_s3_bucket.chartmuseum.arn}"
    },
    {
      "Sid": "AllowObjectsCRUD",
      "Effect": "Allow",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "${aws_s3_bucket.chartmuseum.arn}/*"
    }
  ]
}
EOF
}
