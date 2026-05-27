terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }

  backend "s3" {
    bucket = "finflow-prod-tfstate-668751951204"
    key    = "eks/terraform.tfstate"
    region = "eu-central-1"
    # 'dynamodb_table' is deprecated; using new lockfile behavior instead
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region
}

#provider "kubernetes" {
#  host = module.eks.cluster_endpoint
#
#  cluster_ca_certificate = base64decode(
#    module.eks.cluster_certificate_authority_data
#  )
#
#  token = data.aws_eks_cluster_auth.cluster.token
#}

#provider "helm" {
#  kubernetes {
#    host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#    token                  = data.aws_eks_cluster_auth.cluster.token
#  }
#}
