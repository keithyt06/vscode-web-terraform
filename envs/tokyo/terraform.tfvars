#--------------------------------------------------------------
# General Configuration
#--------------------------------------------------------------
aws_region   = "ap-northeast-1"
environment  = "tokyo"
project_name = "vscode-web"

#--------------------------------------------------------------
# Network Configuration
#--------------------------------------------------------------
vpc_id = "vpc-03cbd3143d9879509"

public_subnet_ids = [
  "subnet-003f359df86dc2043",
  "subnet-0e3c552a20c82dd1a",
  "subnet-09be9c1fef36be113"
]

private_subnet_ids = [
  "subnet-011bada2e052f22e4",
  "subnet-01063ca1a55fed54e",
  "subnet-0d1b72dd54b8a4a1e"
]

#--------------------------------------------------------------
# EC2 Configuration
#--------------------------------------------------------------
instance_type    = "g6.xlarge"
root_volume_size = 2000
root_volume_type = "gp3"

# SSH Key (optional - uncomment if needed)
# key_name = "your-key-name"

#--------------------------------------------------------------
# VSCode Web Configuration
#--------------------------------------------------------------
# Password is set via TF_VAR_vscode_password environment variable
# Example: export TF_VAR_vscode_password="your-secure-password"
vscode_port = 8080

#--------------------------------------------------------------
# CloudFront Configuration
#--------------------------------------------------------------
enable_cloudfront      = true
cloudfront_price_class = "PriceClass_200"

#--------------------------------------------------------------
# ALB Configuration
#--------------------------------------------------------------
alb_internal      = true
health_check_path = "/"

#--------------------------------------------------------------
# Tags
#--------------------------------------------------------------
tags = {
  Owner     = "keithyu"
  ManagedBy = "terraform"
}
