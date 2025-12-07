provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

# Security Groups
module "security_groups" {
  source = "./modules/security-groups"

  name_prefix         = local.name_prefix
  vpc_id              = var.vpc_id
  allowed_cidr_blocks = var.allowed_cidr_blocks
  vscode_port         = var.vscode_port
  tags                = local.common_tags
}

# EC2 Instance with VSCode Web
module "ec2" {
  source = "./modules/ec2"

  name_prefix        = local.name_prefix
  instance_type      = var.instance_type
  subnet_id          = var.private_subnet_ids[0]
  security_group_ids = [module.security_groups.ec2_security_group_id]
  root_volume_size   = var.root_volume_size
  root_volume_type   = var.root_volume_type
  vscode_password    = var.vscode_password
  vscode_port        = var.vscode_port
  key_name           = var.key_name
  tags               = local.common_tags
}

# Internal Application Load Balancer
module "alb" {
  source = "./modules/alb"

  name_prefix        = local.name_prefix
  vpc_id             = var.vpc_id
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [module.security_groups.alb_security_group_id]
  target_instance_id = module.ec2.instance_id
  internal           = var.alb_internal
  health_check_path  = var.health_check_path
  target_port        = var.vscode_port
  tags               = local.common_tags
}

# CloudFront Distribution (optional)
module "cloudfront" {
  count  = var.enable_cloudfront ? 1 : 0
  source = "./modules/cloudfront"

  name_prefix  = local.name_prefix
  alb_dns_name = module.alb.alb_dns_name
  alb_arn      = module.alb.alb_arn
  price_class  = var.cloudfront_price_class
  tags         = local.common_tags
}
