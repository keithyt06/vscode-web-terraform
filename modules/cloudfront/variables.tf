variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "alb_arn" {
  description = "ALB ARN"
  type        = string
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_200"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
