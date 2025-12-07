output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_private_ip" {
  description = "EC2 instance private IP"
  value       = module.ec2.private_ip
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (if enabled)"
  value       = var.enable_cloudfront ? module.cloudfront[0].domain_name : null
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (if enabled)"
  value       = var.enable_cloudfront ? module.cloudfront[0].distribution_id : null
}

output "vscode_web_url" {
  description = "VSCode Web UI URL"
  value       = var.enable_cloudfront ? "https://${module.cloudfront[0].domain_name}" : "http://${module.alb.alb_dns_name}"
}
