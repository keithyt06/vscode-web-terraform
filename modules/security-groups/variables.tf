variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB"
  type        = list(string)
  default     = []
}

variable "vscode_port" {
  description = "Port for VSCode Web server"
  type        = number
  default     = 8080
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
