output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "configure_kubectl" {
  description = "Command to configure kubectl to connect to the EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "app_s3_bucket_name" {
  description = "Name of the application S3 bucket"
  value       = aws_s3_bucket.results.bucket
}

output "app_s3_region" {
  description = "Region of the application S3 bucket"
  value       = var.aws_region
}

output "app_s3_endpoint" {
  description = "S3 endpoint to use in app configuration"
  value       = "https://s3.${var.aws_region}.amazonaws.com"
}

output "app_s3_access_key_id" {
  description = "Access key ID for S3 application user"
  value       = aws_iam_access_key.results_bucket.id
  sensitive   = true
}

output "app_s3_secret_access_key" {
  description = "Secret access key for S3 application user"
  value       = aws_iam_access_key.results_bucket.secret
  sensitive   = true
}
