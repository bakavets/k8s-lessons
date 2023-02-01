locals {
  ebs_csi_driver = {
    namespace            = "kube-system"
    service_account_name = "ebs-csi-controller-sa"
  }
}

module "irsa_ebs_csi_driver" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.3.0"
  create_role                   = true
  role_name                     = "${local.cluster_name}-ebs-csi-driver-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_driver.arn, aws_iam_policy.ebs_csi_driver_kms.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.ebs_csi_driver.namespace}:${local.ebs_csi_driver.service_account_name}"]
}

data "aws_iam_policy" "ebs_csi_driver" {
  name = "AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_policy" "ebs_csi_driver_kms" {
  name = "${local.cluster_name}-ebs-csi-driver-kms-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": "${aws_kms_key.kms.arn}",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "${aws_kms_key.kms.arn}"
    }
  ]
}
EOF
}
