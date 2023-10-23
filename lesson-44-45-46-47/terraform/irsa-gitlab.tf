locals {
  gitlab_s3_bucket_arns = [
    module.s3_gitlab_artifacts.s3_bucket_arn,
    module.s3_gitlab_backups.s3_bucket_arn,
    module.s3_gitlab_lfs.s3_bucket_arn,
    module.s3_gitlab_packages.s3_bucket_arn,
    module.s3_gitlab_tmp.s3_bucket_arn,
    module.s3_gitlab_uploads.s3_bucket_arn,
    module.s3_gitlab_pages.s3_bucket_arn
  ]
  gitlab_service_account_names = [
    "gitlab-webservice",
    "gitlab-sidekiq",
    "gitlab-toolbox"
  ]
  gitlab_namespace = "gitlab"
}

module "irsa_gitlab" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "5.29.1"
  create_role      = true
  role_name        = "${local.cluster_name}-gitlab-role"
  role_description = "EKS IRSA for GitLab (https://docs.gitlab.com/ee/install/aws/manual_install_aws.html#create-an-iam-policy)."
  provider_url     = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    for id in local.gitlab_service_account_names :
    "system:serviceaccount:${local.gitlab_namespace}:${id}"
  ]
}

resource "aws_iam_role_policy" "gitlab" {
  name   = "${local.cluster_name}-gitlab"
  role   = module.irsa_gitlab.iam_role_name
  policy = data.aws_iam_policy_document.gitlab.json
}

data "aws_iam_policy_document" "gitlab" {

  statement {
    sid    = "S3CRUD"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl"
    ]
    resources = [for arn in local.gitlab_s3_bucket_arns : "${arn}/*"]
  }

  statement {
    sid    = "S3ListBuckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:ListBucketMultipartUploads"
    ]
    resources = local.gitlab_s3_bucket_arns
  }
}
