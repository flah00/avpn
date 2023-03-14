
output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "aws s3 bucket arn"
}

output "s3_bucket_key" {
  description = "TF state path"
  value       = var.bucket_key
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "dynamodb table"
}

