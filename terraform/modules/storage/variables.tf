variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "s3_bucket_name_override" {
  type    = string
  default = null
}

variable "tfstate_bucket_name_override" {
  type    = string
  default = null
}

variable "tfstate_lock_table_name_override" {
  type    = string
  default = null
}

variable "account_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
