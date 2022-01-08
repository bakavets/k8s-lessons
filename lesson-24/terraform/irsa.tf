locals {
  k8s_service_account_demo_namespace = "demo-irsa"
  k8s_service_account_demo_name      = "demo"
}

module "iam_assumable_role_demo" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.8.0"
  create_role                   = true
  role_name                     = "${local.cluster_name}-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.demo.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_demo_namespace}:${local.k8s_service_account_demo_name}"]
}

resource "aws_iam_policy" "demo" {
  name        = "${local.cluster_name}-policy"
  description = "EKS AWS Demo policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:PutObjectAcl",
                "s3:PutObject",
                "s3:ListBucket",
                "s3:GetObjectAcl",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::lesson-24-demo-bucket/*",
                "arn:aws:s3:::lesson-24-demo-bucket"
            ]
        }
    ]
}
EOF
}
