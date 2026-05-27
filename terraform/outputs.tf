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
  value       = module.storage.app_s3_bucket_name
}

output "tfstate_s3_bucket_name" {
  description = "Name of the Terraform state S3 bucket"
  value       = module.storage.tfstate_s3_bucket_name
}

output "tfstate_lock_table_name" {
  description = "Name of the Terraform state DynamoDB lock table"
  value       = module.storage.tfstate_lock_table_name
}

output "app_s3_region" {
  description = "Region of the application S3 bucket"
  value       = var.aws_region
}

output "app_s3_endpoint" {
  description = "S3 endpoint to use in app configuration"
  value       = "https://s3.${var.aws_region}.amazonaws.com"
}

output "secrets_manager_secret_arn" {
  description = "ARN of AWS Secrets Manager secret for application"
  value       = module.iam.secrets_manager_secret_arn
}

output "irsa_apps_role_arn" {
  description = "ARN of IAM Role for finflow core apps"
  value       = module.iam.irsa_finflow_apps_iam_role_arn
}

output "irsa_infra_role_arn" {
  description = "ARN of IAM Role for finflow infrastructure database/rabbitmq"
  value       = module.iam.irsa_finflow_infra_iam_role_arn
}

output "argocd_service_endpoint" {
  description = "LoadBalancer endpoint for accessing ArgoCD UI"
  value       = try(module.argocd.argocd_service_commands["get_lb_host"], null)
}

output "argocd_access_info" {
  description = "Information to access ArgoCD (commands and namespace)"
  value       = try(module.argocd.argocd_service_commands, null)
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate."
  value       = module.iam.acm_certificate_arn
}

output "acm_dns_validation_records" {
  description = "DNS records required to validate the ACM certificate."
  value       = module.iam.acm_dns_validation_records
}
