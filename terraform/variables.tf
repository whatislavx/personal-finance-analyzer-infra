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
