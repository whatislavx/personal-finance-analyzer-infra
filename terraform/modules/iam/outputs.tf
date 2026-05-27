output "secrets_manager_secret_arn" {
  description = "ARN of AWS Secrets Manager secret for application"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "app_policy_arn" {
  description = "ARN of combined IAM policy for app access"
  value       = aws_iam_policy.app_policy.arn
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.app.arn
}

output "acm_dns_validation_records" {
  description = "DNS records required to validate the ACM certificate"
  value = [for option in aws_acm_certificate.app.domain_validation_options : {
    name  = option.resource_record_name
    type  = option.resource_record_type
    value = option.resource_record_value
  }]
}

output "irsa_finflow_apps_iam_role_arn" {
  value = module.irsa_finflow_apps.iam_role_arn
}

output "irsa_finflow_infra_iam_role_arn" {
  value = module.irsa_finflow_infra.iam_role_arn
}

output "irsa_alb_controller_iam_role_arn" {
  value = module.irsa_alb_controller.iam_role_arn
}

output "ebs_csi_irsa_role_arn" {
  value = module.ebs_csi_irsa_role.iam_role_arn
}
