################################################################################
# AWS KMS Key
################################################################################

resource "aws_kms_key" "kms" {
  description              = "AWS KMS key used to encrypt AWS resources."
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
}
