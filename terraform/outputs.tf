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

output "tfstate_s3_bucket_name" {
  description = "Name of the Terraform state S3 bucket"
  value       = aws_s3_bucket.tfstate.bucket
}

output "tfstate_lock_table_name" {
  description = "Name of the Terraform state DynamoDB lock table"
  value       = aws_dynamodb_table.tfstate_locks.name
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
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "irsa_apps_role_arn" {
  description = "ARN of IAM Role for finflow core apps"
  value       = module.irsa_finflow_apps.iam_role_arn
}

output "irsa_infra_role_arn" {
  description = "ARN of IAM Role for finflow infrastructure database/rabbitmq"
  value       = module.irsa_finflow_infra.iam_role_arn
}

output "argocd_service_endpoint" {
  description = "LoadBalancer endpoint for accessing ArgoCD UI"
  value       = var.enable_k8s_addons ? "Run: kubectl get service -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'" : null
}

output "argocd_access_info" {
  description = "Information to access ArgoCD"
  value = var.enable_k8s_addons ? {
    username             = "admin"
    namespace            = kubernetes_namespace.argocd[0].metadata[0].name
    get_password_command = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
    port_forward_command = "kubectl port-forward -n argocd svc/argocd-server 8080:443"
  } : null
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate."
  value       = aws_acm_certificate.app.arn
}

output "acm_dns_validation_records" {
  description = "DNS records required to validate the ACM certificate."
  value = [
    for option in aws_acm_certificate.app.domain_validation_options : {
      name  = option.resource_record_name
      type  = option.resource_record_type
      value = option.resource_record_value
    }
  ]
}
