variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "eks_oidc_provider_arn" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "jwt_secret_key" {
  type      = string
  sensitive = true
}

variable "rabbitmq_password" {
  type      = string
  sensitive = true
}

variable "rabbitmq_username" {
  type    = string
  default = "finflow_user"
}

variable "rabbitmq_erlang_cookie" {
  type      = string
  sensitive = true
}

variable "slack_webhook_url" {
  type      = string
  sensitive = true
}

variable "acm_domain_name" {
  type = string
}

variable "acm_subject_alternative_names" {
  type    = list(string)
  default = []
}

variable "s3_resources" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "eks_managed_node_role" {
  type    = string
  default = ""
}
