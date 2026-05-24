terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Стан інфраструктури (state) краще зберігати в S3, але для старту можна залишити локально.
  # Коли створиш бакет, розкоментуєш цей блок:
  # backend "s3" {
  #   bucket         = "your-finflow-tf-state-bucket"
  #   key            = "eks/terraform.tfstate"
  #   region         = "eu-central-1"
  # }
}

provider "aws" {
  region = var.aws_region
}
