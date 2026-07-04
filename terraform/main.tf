# ============================================================
# Terraform - Main Configuration
# ============================================================
# Cloud-Native API Infrastructure on AWS
# Includes: VPC, ECR, ECS Fargate, ALB
#
# Usage:
#   terraform init
#   terraform plan -var-file="terraform.tfvars"
#   terraform apply -var-file="terraform.tfvars"
#
# LocalStack Testing:
#   terraform init
#   terraform apply -var="use_localstack=true"
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment for remote state in production:
  # backend "s3" {
  #   bucket         = "my-terraform-state"
  #   key            = "cloud-native-api/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

# ---- Provider Configuration ----

provider "aws" {
  region = var.aws_region

  # LocalStack overrides (for local testing without AWS account)
  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      ecr = "http://localhost:4566"
      ecs = "http://localhost:4566"
      ec2 = "http://localhost:4566"
      elb = "http://localhost:4566"
      iam = "http://localhost:4566"
      sts = "http://localhost:4566"
    }
  }

  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# ---- Data Sources ----

data "aws_availability_zones" "available" {
  state = "available"
}
