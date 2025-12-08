terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# Security Groups
module "security_groups" {
  source = "./modules/security-groups"

  name        = var.name
  vpc_id      = var.vpc_id
  vscode_port = var.vscode_port
  tags        = var.tags
}

# EC2 Instance
module "ec2" {
  source = "./modules/ec2"

  name                    = var.name
  instance_type           = var.instance_type
  vpc_id                  = var.vpc_id
  subnet_id               = var.private_subnet_id
  security_group_ids      = [module.security_groups.ec2_security_group_id]
  root_volume_size        = var.root_volume_size
  data_volume_size        = var.data_volume_size
  existing_data_volume_id = var.existing_data_volume_id
  key_name                = var.key_name
  iam_instance_profile    = var.iam_instance_profile
  vscode_password         = var.vscode_password
  vscode_port             = var.vscode_port
  tags                    = var.tags
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"

  name               = var.name
  vpc_id             = var.vpc_id
  public_subnet_ids  = var.public_subnet_ids
  security_group_ids = [module.security_groups.alb_security_group_id]
  target_instance_id = module.ec2.instance_id
  target_port        = 80
  tags               = var.tags
}

# CloudFront Distribution
module "cloudfront" {
  source = "./modules/cloudfront"

  name         = var.name
  alb_dns_name = module.alb.alb_dns_name
  price_class  = var.cloudfront_price_class
  tags         = var.tags
}
