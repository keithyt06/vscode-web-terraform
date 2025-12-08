# CloudFront managed prefix list data source
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# ALB Security Group - Only allows CloudFront traffic
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Security group for ALB - CloudFront only"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-alb-sg"
  })
}

resource "aws_security_group_rule" "alb_ingress_cloudfront" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP from CloudFront"
}

resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound traffic"
}

# EC2 Security Group - Only allows traffic from ALB
resource "aws_security_group" "ec2" {
  name        = "${var.name}-ec2-sg"
  description = "Security group for VSCode EC2 instance"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-ec2-sg"
  })
}

resource "aws_security_group_rule" "ec2_ingress_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2.id
  description              = "Allow HTTP from ALB"
}

resource "aws_security_group_rule" "ec2_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
  description       = "Allow all outbound traffic"
}
