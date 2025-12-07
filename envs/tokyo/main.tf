# Tokyo Environment Configuration
# This file references the root module

module "vscode_web" {
  source = "../../"

  # General
  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name

  # Network
  vpc_id              = var.vpc_id
  public_subnet_ids   = var.public_subnet_ids
  private_subnet_ids  = var.private_subnet_ids
  allowed_cidr_blocks = var.allowed_cidr_blocks

  # EC2
  instance_type    = var.instance_type
  root_volume_size = var.root_volume_size
  root_volume_type = var.root_volume_type
  key_name         = var.key_name

  # VSCode Web
  vscode_password = var.vscode_password
  vscode_port     = var.vscode_port

  # CloudFront
  enable_cloudfront      = var.enable_cloudfront
  cloudfront_price_class = var.cloudfront_price_class

  # ALB
  alb_internal      = var.alb_internal
  health_check_path = var.health_check_path

  # Tags
  tags = var.tags
}

#--------------------------------------------------------------
# Outputs
#--------------------------------------------------------------
output "vscode_web_url" {
  description = "VSCode Web UI URL"
  value       = module.vscode_web.vscode_web_url
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = module.vscode_web.cloudfront_domain_name
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.vscode_web.ec2_instance_id
}

output "ec2_private_ip" {
  description = "EC2 private IP"
  value       = module.vscode_web.ec2_private_ip
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.vscode_web.alb_dns_name
}
