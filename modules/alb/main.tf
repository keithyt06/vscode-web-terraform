resource "aws_lb" "main" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  # Increase idle timeout for WebSocket connections (code-server needs this)
  idle_timeout = 3600

  tags = merge(var.tags, {
    Name = "${var.name}-alb"
  })
}

resource "aws_lb_target_group" "main" {
  name     = "${var.name}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200,302"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, {
    Name = "${var.name}-tg"
  })
}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.target_instance_id
  port             = var.target_port
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name}-http-listener"
  })
}
