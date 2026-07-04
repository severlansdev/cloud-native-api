# ============================================================
# Terraform - ALB (Application Load Balancer)
# ============================================================
# Production-grade load balancer with:
# - HTTP listener (port 80)
# - Health check against /health endpoint
# - Target group for ECS Fargate tasks
# ============================================================

# ---- Application Load Balancer ----

resource "aws_lb" "api" {
  name               = "${var.project_name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = var.environment == "production"

  tags = {
    Name = "${var.project_name}-alb-${var.environment}"
  }
}

# ---- Target Group ----

resource "aws_lb_target_group" "api" {
  name        = "${var.project_name}-tg-${var.environment}"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  # Slow start to avoid overwhelming new tasks
  slow_start = 30

  tags = {
    Name = "${var.project_name}-tg-${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---- Listener (HTTP) ----

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  # In production, redirect to HTTPS:
  # default_action {
  #   type = "redirect"
  #   redirect {
  #     port        = "443"
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
  #   }
  # }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  tags = {
    Name = "${var.project_name}-listener-${var.environment}"
  }
}
