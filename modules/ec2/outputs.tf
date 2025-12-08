output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.vscode.id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.vscode.private_ip
}

output "instance_availability_zone" {
  description = "Availability zone of the EC2 instance"
  value       = aws_instance.vscode.availability_zone
}

output "data_volume_id" {
  description = "ID of the data volume"
  value       = var.existing_data_volume_id != "" ? var.existing_data_volume_id : (var.data_volume_size > 0 ? aws_ebs_volume.data[0].id : "")
}
