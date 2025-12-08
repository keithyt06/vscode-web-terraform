variable "name" {
  description = "Name prefix for CloudFront resources"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB origin"
  type        = string
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_All"
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
