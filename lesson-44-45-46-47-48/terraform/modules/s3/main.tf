resource "aws_s3_bucket" "bucket" {
  bucket = "${var.deployment_prefix}-${var.deployment_suffix}"
  tags = {
    "Name"        = "${var.deployment_prefix}-${var.deployment_suffix}"
    "Type"        = "Storage Service"
    "Description" = "Store data for deployment related to ${var.deployment_suffix}"
  }
}
