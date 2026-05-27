output "app_s3_bucket_name" {
  description = "Name of the application S3 bucket"
  value       = aws_s3_bucket.results.bucket
}

output "tfstate_s3_bucket_name" {
  description = "Name of the Terraform state S3 bucket"
  value       = aws_s3_bucket.tfstate.bucket
}

output "tfstate_lock_table_name" {
  description = "Name of the Terraform state DynamoDB lock table"
  value       = aws_dynamodb_table.tfstate_locks.name
}
