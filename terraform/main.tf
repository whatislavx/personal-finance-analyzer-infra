data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  s3_bucket_name = coalesce(
    var.s3_bucket_name_override,
    "${var.project_name}-${var.environment}-results-${data.aws_caller_identity.current.account_id}"
  )
  s3_iam_user_name = "${var.project_name}-${var.environment}-s3-app"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-eks" = "shared"
    "kubernetes.io/role/elb"                                           = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-eks" = "shared"
    "kubernetes.io/role/internal-elb"                                  = "1"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-${var.environment}-eks"
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    main = {
      name           = "${var.project_name}-node-group"
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 4
      desired_size = 2

      capacity_type = "ON_DEMAND"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 30
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
      }
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket" "results" {
  bucket = local.s3_bucket_name

  tags = {
    Name        = "${var.project_name}-${var.environment}-results"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "results" {
  bucket = aws_s3_bucket.results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "results" {
  bucket = aws_s3_bucket.results.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "results" {
  bucket = aws_s3_bucket.results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "results_bucket_access" {
  statement {
    sid = "AllowListBucket"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.results.arn
    ]
  }

  statement {
    sid = "AllowObjectAccess"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      "${aws_s3_bucket.results.arn}/*"
    ]
  }
}

resource "aws_iam_user" "results_bucket" {
  name = local.s3_iam_user_name
}

resource "aws_iam_user_policy" "results_bucket_access" {
  name   = "${local.s3_iam_user_name}-access"
  user   = aws_iam_user.results_bucket.name
  policy = data.aws_iam_policy_document.results_bucket_access.json
}

resource "aws_iam_access_key" "results_bucket" {
  user = aws_iam_user.results_bucket.name
}
