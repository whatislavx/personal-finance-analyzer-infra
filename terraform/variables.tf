variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name of the project used for tagging"
  type        = string
  default     = "finflow"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.29"
}

variable "s3_bucket_name_override" {
  description = "Optional custom name for the application S3 bucket. If null, a unique name is generated."
  type        = string
  default     = null
}

variable "tfstate_bucket_name_override" {
  description = "Optional custom name for the Terraform state S3 bucket. If null, a unique name is generated."
  type        = string
  default     = null
}

variable "tfstate_lock_table_name_override" {
  description = "Optional custom name for the Terraform state lock DynamoDB table. If null, a name is generated."
  type        = string
  default     = null
}

variable "argocd_admin_password" {
  description = "Admin password for ArgoCD UI (bcrypt hash). If empty, ArgoCD will generate a random password."
  type        = string
  sensitive   = true
  default     = ""
}

variable "gitops_repo_url" {
  description = "GitOps repository URL for ArgoCD to sync from"
  type        = string
  default     = "https://github.com/your-org/your-repo"
}

variable "gitops_repo_revision" {
  description = "GitOps repository branch/tag to sync"
  type        = string
  default     = "main"
}

variable "enable_k8s_addons" {
  description = "Whether to deploy Kubernetes addons (ArgoCD namespace, Helm release, root app)."
  type        = bool
  default     = false
}

variable "enable_argocd_root_app" {
  description = "Whether to deploy the ArgoCD root Application (requires CRDs to be ready)."
  type        = bool
  default     = false
}

variable "db_password" {
  description = "Database password stored in AWS Secrets Manager."
  type        = string
  sensitive   = true
}

variable "jwt_secret_key" {
  description = "JWT secret key stored in AWS Secrets Manager."
  type        = string
  sensitive   = true
}

variable "rabbitmq_password" {
  description = "RabbitMQ password stored in AWS Secrets Manager."
  type        = string
  sensitive   = true
}

variable "slack_webhook_url" {
  description = "Slack webhook URL stored in AWS Secrets Manager."
  type        = string
  sensitive   = true
}

variable "acm_domain_name" {
  description = "Primary domain name for ACM certificate."
  type        = string
}

variable "acm_subject_alternative_names" {
  description = "Optional additional domain names for the ACM certificate."
  type        = list(string)
  default     = []
}
