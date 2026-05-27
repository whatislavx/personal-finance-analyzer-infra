data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

// Configure providers for the EKS cluster and expose aliased providers for modules
provider "kubernetes" {
  alias = "eks"

  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  alias = "eks"

  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "eks" {
  source          = "./modules/eks"
  project_name    = var.project_name
  environment     = var.environment
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
}

module "storage" {
  source                           = "./modules/storage"
  project_name                     = var.project_name
  environment                      = var.environment
  s3_bucket_name_override          = var.s3_bucket_name_override
  tfstate_bucket_name_override     = var.tfstate_bucket_name_override
  tfstate_lock_table_name_override = var.tfstate_lock_table_name_override
  account_id                       = data.aws_caller_identity.current.account_id
}

module "iam" {
  source                = "./modules/iam"
  project_name          = var.project_name
  environment           = var.environment
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  eks_managed_node_role = module.eks.main_node_group_iam_role_name

  # Передаємо ресурси S3 для політики доступу додатка
  s3_resources = [
    "arn:aws:s3:::${module.storage.app_s3_bucket_name}",
    "arn:aws:s3:::${module.storage.app_s3_bucket_name}/*"
  ]

  db_password                   = var.db_password
  jwt_secret_key                = var.jwt_secret_key
  rabbitmq_password             = var.rabbitmq_password
  rabbitmq_username             = var.rabbitmq_username
  rabbitmq_erlang_cookie        = var.rabbitmq_erlang_cookie
  slack_webhook_url             = var.slack_webhook_url
  acm_domain_name               = var.acm_domain_name
  acm_subject_alternative_names = var.acm_subject_alternative_names
}

module "argocd" {
  source                 = "./modules/argocd"
  enable_k8s_addons      = var.enable_k8s_addons
  enable_argocd_root_app = var.enable_argocd_root_app
  argocd_admin_password  = var.argocd_admin_password
  gitops_repo_url        = var.gitops_repo_url
  gitops_repo_revision   = var.gitops_repo_revision

  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  token                  = data.aws_eks_cluster_auth.cluster.token
  depends_on             = [module.eks]
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
}
