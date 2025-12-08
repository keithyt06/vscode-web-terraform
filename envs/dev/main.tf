# Dev environment entry point
# This file references the root module

module "vscode_web" {
  source = "../../"

  # Region
  region = var.region

  # Naming
  name = var.name

  # Network
  vpc_id            = var.vpc_id
  public_subnet_ids = var.public_subnet_ids
  private_subnet_id = var.private_subnet_id

  # EC2
  instance_type           = var.instance_type
  root_volume_size        = var.root_volume_size
  data_volume_size        = var.data_volume_size
  existing_data_volume_id = var.existing_data_volume_id
  key_name                = var.key_name
  iam_instance_profile    = var.iam_instance_profile

  # VSCode
  vscode_password = var.vscode_password
  vscode_port     = var.vscode_port

  # CloudFront
  cloudfront_price_class = var.cloudfront_price_class

  # Tags
  tags = var.tags
}
