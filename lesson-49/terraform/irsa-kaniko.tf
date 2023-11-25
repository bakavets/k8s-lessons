locals {
  kaniko = {
    namespace            = "gitlab-space-external"
    service_account_name = "ci-kaniko"
  }
}

module "irsa_kaniko" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.3.0"
  create_role                   = true
  role_name                     = "${local.cluster_name}-kaniko"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.kaniko.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.kaniko.namespace}:${local.kaniko.service_account_name}"]
}

resource "aws_iam_policy" "kaniko" {

  name        = "${local.cluster_name}-kaniko-policy"
  description = "EKS Kaniko policy to push container images to AWS ECR for cluster ${local.cluster_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:CompleteLayerUpload",
                "ecr:GetAuthorizationToken",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

