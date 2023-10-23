resource "aws_iam_user" "gitlab_ses" {
  name = "ses-smtp-user.${var.deployment_prefix}-gitlab"
}

resource "aws_iam_access_key" "gitlab_ses" {
  user = aws_iam_user.gitlab_ses.name
}

data "aws_iam_policy_document" "gitlab_ses" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "this" {
  user   = aws_iam_user.gitlab_ses.name
  name   = "AmazonSesSendingAccess"
  policy = data.aws_iam_policy_document.gitlab_ses.json
}

resource "aws_ssm_parameter" "this" {
  name        = "${var.deployment_prefix}-ses-smtp-user-gitlab-credentials"
  description = "SES SMTP user gitlab credentials for ${var.deployment_prefix}"
  tier        = "Standard"
  type        = "SecureString"
  value = jsonencode({
    smtp_username = aws_iam_access_key.gitlab_ses.id
    smtp_password = aws_iam_access_key.gitlab_ses.ses_smtp_password_v4
  })

  tags = {
    IAMUserName = "ses-smtp-user.${var.deployment_prefix}-gitlab"
  }
}
