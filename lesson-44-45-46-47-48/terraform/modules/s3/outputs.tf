output "s3_bucket_arn" {
  value       = aws_s3_bucket.bucket.arn
  description = "AWS S3 Bucket ARN."
}

output "s3_bucket_id" {
  value       = aws_s3_bucket.bucket.id
  description = "AWS S3 Bucket name."
}
