# General
variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "vscode-web"
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Network
variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_id" {
  description = "Private subnet ID for EC2 instance"
  type        = string
}

# EC2
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "g6.xlarge"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 200
}

variable "data_volume_size" {
  description = "Data volume size in GB (set to 0 to disable)"
  type        = number
  default     = 2000
}

variable "existing_data_volume_id" {
  description = "Existing EBS volume ID to attach (optional, overrides data_volume_size)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = ""
}

# VSCode Web
variable "vscode_password" {
  description = "Password for VSCode Web UI"
  type        = string
  sensitive   = true
}

variable "vscode_port" {
  description = "Port for VSCode Web UI (internal)"
  type        = number
  default     = 8080
}

# CloudFront
variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_All"
}
