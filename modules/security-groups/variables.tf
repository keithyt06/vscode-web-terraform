variable "name" {
  description = "Name prefix for security groups"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vscode_port" {
  description = "Port for VSCode Web UI"
  type        = number
  default     = 8080
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
