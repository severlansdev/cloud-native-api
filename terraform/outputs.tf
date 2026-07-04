# ============================================================
# Terraform - Outputs
# ============================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository (for docker push)"
  value       = aws_ecr_repository.api.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.api.name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.api.name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.api.dns_name
}

output "api_url" {
  description = "Full URL to access the API"
  value       = "http://${aws_lb.api.dns_name}"
}
