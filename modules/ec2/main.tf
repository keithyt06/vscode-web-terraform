data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "vscode" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name != "" ? var.key_name : null
  iam_instance_profile   = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true

    tags = merge(var.tags, {
      Name = "${var.name}-root"
    })
  }

  user_data_base64 = base64encode(templatefile("${path.module}/user_data.sh", {
    vscode_password = var.vscode_password
    vscode_port     = var.vscode_port
    data_device     = var.existing_data_volume_id != "" || var.data_volume_size > 0 ? "/dev/nvme1n1" : ""
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = merge(var.tags, {
    Name = var.name
  })

  lifecycle {
    ignore_changes = [ami]
  }
}

# Create new data volume if no existing volume is provided
resource "aws_ebs_volume" "data" {
  count = var.existing_data_volume_id == "" && var.data_volume_size > 0 ? 1 : 0

  availability_zone = aws_instance.vscode.availability_zone
  size              = var.data_volume_size
  type              = "gp3"
  encrypted         = true

  tags = merge(var.tags, {
    Name = "${var.name}-data"
  })
}

# Attach new data volume
resource "aws_volume_attachment" "data_new" {
  count = var.existing_data_volume_id == "" && var.data_volume_size > 0 ? 1 : 0

  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data[0].id
  instance_id = aws_instance.vscode.id
}

# Attach existing data volume
resource "aws_volume_attachment" "data_existing" {
  count = var.existing_data_volume_id != "" ? 1 : 0

  device_name = "/dev/sdf"
  volume_id   = var.existing_data_volume_id
  instance_id = aws_instance.vscode.id
}
