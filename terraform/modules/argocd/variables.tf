variable "enable_k8s_addons" {
  type    = bool
  default = false
}

variable "enable_argocd_root_app" {
  type    = bool
  default = false
}

variable "argocd_admin_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "gitops_repo_url" {
  type    = string
  default = ""
}

variable "gitops_repo_revision" {
  type    = string
  default = "main"
}

variable "dependency" {
  type    = any
  default = []
}

variable "cluster_endpoint" {
  type = string
  default = ""
}

variable "cluster_ca_certificate" {
  type = string
  default = ""
}

variable "token" {
  type = string
  default = ""
}
