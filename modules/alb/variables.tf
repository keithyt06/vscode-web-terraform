variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "target_instance_id" {
  description = "EC2 instance ID to register as target"
  type        = string
}

variable "internal" {
  description = "Whether ALB is internal"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "target_port" {
  description = "Target port for the application"
  type        = number
  default     = 8080
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
