#--------------------------------------------------------------
# General Configuration
#--------------------------------------------------------------
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod, tokyo)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "vscode-web"
}

#--------------------------------------------------------------
# Network Configuration
#--------------------------------------------------------------
variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EC2 and ALB"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs (for reference)"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the VSCode Web (for security group)"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

#--------------------------------------------------------------
# EC2 Configuration
#--------------------------------------------------------------
variable "instance_type" {
  description = "EC2 instance type (e.g., t3.medium, g6.xlarge for GPU)"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 100
}

variable "root_volume_type" {
  description = "Root volume type (gp3, gp2, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "key_name" {
  description = "SSH key pair name (optional, for SSH access)"
  type        = string
  default     = null
}

#--------------------------------------------------------------
# VSCode Web Configuration
#--------------------------------------------------------------
variable "vscode_password" {
  description = "Password for VSCode Web UI authentication"
  type        = string
  sensitive   = true
}

variable "vscode_port" {
  description = "Port for VSCode Web server"
  type        = number
  default     = 8080
}

#--------------------------------------------------------------
# CloudFront Configuration
#--------------------------------------------------------------
variable "enable_cloudfront" {
  description = "Enable CloudFront distribution for HTTPS access"
  type        = bool
  default     = true
}

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_200"
}

#--------------------------------------------------------------
# ALB Configuration
#--------------------------------------------------------------
variable "alb_internal" {
  description = "Whether ALB is internal (true) or internet-facing (false)"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path for ALB target group"
  type        = string
  default     = "/"
}

#--------------------------------------------------------------
# Tags
#--------------------------------------------------------------
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
