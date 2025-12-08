# EC2 Outputs
output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.ec2.instance_private_ip
}

output "data_volume_id" {
  description = "ID of the data volume"
  value       = module.ec2.data_volume_id
}

# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (Access VSCode Web here)"
  value       = module.cloudfront.distribution_domain_name
}

output "vscode_web_url" {
  description = "URL to access VSCode Web"
  value       = "https://${module.cloudfront.distribution_domain_name}"
}
