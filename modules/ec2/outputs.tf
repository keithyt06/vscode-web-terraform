output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.vscode.id
}

output "private_ip" {
  description = "EC2 instance private IP"
  value       = aws_instance.vscode.private_ip
}

output "instance_arn" {
  description = "EC2 instance ARN"
  value       = aws_instance.vscode.arn
}
