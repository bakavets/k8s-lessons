provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}

################################################################################
# AWS KMS Key
################################################################################

resource "aws_kms_key" "kms" {
  description              = "AWS KMS key used to encrypt AWS resources."
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
}

################################################################################
# S3 bucket
################################################################################

resource "aws_s3_bucket" "loki" {
  bucket = "${var.deployment_prefix}-grafana-loki-storage"
  tags = {
    "Name"        = "${var.deployment_prefix}-grafana-loki-storage"
    "Description" = "Grafana Loki Storage for deployment: ${var.deployment_prefix}"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki" {
  bucket = aws_s3_bucket.loki.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms.arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_acl" "loki" {
  bucket = aws_s3_bucket.loki.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "loki" {
  bucket                  = aws_s3_bucket.loki.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################################################################################
# Loki-stack Helm
################################################################################

resource "helm_release" "loki" {
  name = "loki"

  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  version          = "2.8.4"
  namespace        = local.loki.namespace
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/loki-values.yaml", {
      sa_name     = local.loki.service_account_name,
      role_arn    = module.irsa_loki.iam_role_arn,
      region      = aws_s3_bucket.loki.region,
      bucket_name = aws_s3_bucket.loki.id
    })
  ]

  depends_on = [
    module.eks
  ]
}
