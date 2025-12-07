output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.vscode.id
}

output "domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.vscode.domain_name
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.vscode.arn
}

output "hosted_zone_id" {
  description = "CloudFront Route 53 zone ID"
  value       = aws_cloudfront_distribution.vscode.hosted_zone_id
}
