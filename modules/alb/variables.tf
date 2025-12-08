variable "name" {
  description = "Name prefix for ALB resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ALB"
  type        = list(string)
}

variable "target_instance_id" {
  description = "EC2 instance ID to register as target"
  type        = string
}

variable "target_port" {
  description = "Port on which the target is listening"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
