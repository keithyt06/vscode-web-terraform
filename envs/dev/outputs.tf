# Outputs for dev environment

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.vscode_web.instance_id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.vscode_web.instance_private_ip
}

output "data_volume_id" {
  description = "ID of the data volume"
  value       = module.vscode_web.data_volume_id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.vscode_web.alb_dns_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.vscode_web.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.vscode_web.cloudfront_domain_name
}

output "vscode_web_url" {
  description = "URL to access VSCode Web"
  value       = module.vscode_web.vscode_web_url
}
