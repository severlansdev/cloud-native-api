# ============================================================
# Terraform - ECR (Elastic Container Registry)
# ============================================================
# Docker image repository with:
# - Image scanning on push (security)
# - Lifecycle policy to auto-clean old images (cost control)
# - Immutable tags for production safety
# ============================================================

resource "aws_ecr_repository" "api" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.environment != "production"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-ecr-${var.environment}"
  }
}

# ---- Lifecycle Policy: Keep only last 10 images ----

resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
