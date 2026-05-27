output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded CA certificate for the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for the cluster (used with IRSA)"
  value       = module.eks.oidc_provider_arn
}

output "eks_managed_node_groups" {
  description = "Map of EKS managed node group attributes from upstream module"
  value       = module.eks.eks_managed_node_groups
}

output "main_node_group_iam_role_name" {
  description = "IAM role name for the 'main' managed node group (if present)"
  value       = try(module.eks.eks_managed_node_groups["main"].iam_role_name, "")
}
