# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.name_prefix}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb"
  })
}

# Target Group
resource "aws_lb_target_group" "vscode" {
  name     = "${var.name_prefix}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200,302"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-tg"
  })
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "vscode" {
  target_group_arn = aws_lb_target_group.vscode.arn
  target_id        = var.target_instance_id
  port             = var.target_port
}

# HTTP Listener (port 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vscode.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-listener"
  })
}
