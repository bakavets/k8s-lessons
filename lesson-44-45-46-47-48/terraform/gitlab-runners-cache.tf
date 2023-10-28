locals {
  gitlab_runners_irsa = [
    {
      service_account_name      = "gitlab-runner",
      service_account_namespace = "gitlab-space"
    },
    {
      service_account_name      = "gitlab-runner-external",
      service_account_namespace = "gitlab-space-external"
    }
  ]
}

module "irsa_gitlab_runners_cache" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "5.29.1"
  create_role      = true
  role_name        = "${local.cluster_name}-gitlab-runners-cache"
  role_description = "EKS IRSA for GitLab Runners Cache (https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnerscaches3-section) for cluster ${local.cluster_name}."
  provider_url     = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    for id in local.gitlab_runners_irsa :
    "system:serviceaccount:${id.service_account_namespace}:${id.service_account_name}"
  ]
}

resource "aws_iam_role_policy" "gitlab_runners_cache" {
  name   = "${local.cluster_name}-gitlab-runners-cache"
  role   = module.irsa_gitlab_runners_cache.iam_role_name
  policy = data.aws_iam_policy_document.gitlab_runners_cache.json
}

data "aws_iam_policy_document" "gitlab_runners_cache" {

  statement {
    sid    = "S3CRUD"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = ["${module.s3_gitlab_runners_cache.s3_bucket_arn}/*"]
  }
}
