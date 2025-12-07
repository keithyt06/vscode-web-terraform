#--------------------------------------------------------------
# General Configuration
#--------------------------------------------------------------
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "vscode-web"
}

#--------------------------------------------------------------
# Network Configuration
#--------------------------------------------------------------
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access"
  type        = list(string)
  default     = []
}

#--------------------------------------------------------------
# EC2 Configuration
#--------------------------------------------------------------
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 100
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = null
}

#--------------------------------------------------------------
# VSCode Web Configuration
#--------------------------------------------------------------
variable "vscode_password" {
  description = "VSCode Web UI password"
  type        = string
  sensitive   = true
}

variable "vscode_port" {
  description = "VSCode Web server port"
  type        = number
  default     = 8080
}

#--------------------------------------------------------------
# CloudFront Configuration
#--------------------------------------------------------------
variable "enable_cloudfront" {
  description = "Enable CloudFront"
  type        = bool
  default     = true
}

variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_200"
}

#--------------------------------------------------------------
# ALB Configuration
#--------------------------------------------------------------
variable "alb_internal" {
  description = "Whether ALB is internal"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

#--------------------------------------------------------------
# Tags
#--------------------------------------------------------------
variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
