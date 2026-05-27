resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.project_name}-${var.environment}-secrets"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    DB_PASSWORD            = var.db_password
    JWT_SECRET_KEY         = var.jwt_secret_key
    RABBITMQ_PASSWORD      = var.rabbitmq_password
    RABBITMQ_USERNAME      = var.rabbitmq_username
    RABBITMQ_ERLANG_COOKIE = var.rabbitmq_erlang_cookie
    SLACK_WEBHOOK_URL      = var.slack_webhook_url
  })
}

resource "aws_acm_certificate" "app" {
  domain_name               = var.acm_domain_name
  subject_alternative_names = var.acm_subject_alternative_names
  validation_method         = "DNS"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-acm"
  })
}

data "aws_iam_policy_document" "app_combined_access" {
  statement {
    sid = "AllowSecretsManager"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      aws_secretsmanager_secret.app_secrets.arn
    ]
  }

  statement {
    sid = "AllowS3Access"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts"
    ]
    resources = var.s3_resources
  }
}

resource "aws_iam_policy" "app_policy" {
  name   = "${var.project_name}-${var.environment}-app-policy"
  policy = data.aws_iam_policy_document.app_combined_access.json
}

module "irsa_finflow_apps" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.project_name}-${var.environment}-apps-irsa"

  role_policy_arns = {
    policy = aws_iam_policy.app_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn = var.eks_oidc_provider_arn
      namespace_service_accounts = [
        "finflow-apps:finflow-api-sa",
        "finflow-apps:finflow-worker-sa"
      ]
    }
  }
}

module "irsa_finflow_infra" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.project_name}-${var.environment}-infra-irsa"

  role_policy_arns = {
    policy = aws_iam_policy.app_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn = var.eks_oidc_provider_arn
      namespace_service_accounts = [
        "finflow-infra:finflow-infra-sa"
      ]
    }
  }
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.project_name}-${var.environment}-ebs-csi-irsa"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  role       = var.eks_managed_node_role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa_alb_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                              = "${var.project_name}-${var.environment}-alb-controller-irsa"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}


