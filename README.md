# VSCode Web Terraform

Deploy VSCode Web (code-server) on AWS with Terraform. This project creates a secure, production-ready VSCode Web environment accessible via CloudFront HTTPS.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CloudFront                               │
│                    (HTTPS Termination)                           │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Internal ALB (VPC Origin)                     │
│                         (HTTP:80)                                │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      EC2 Instance                                │
│                   (code-server:8080)                             │
│                    Private Subnet                                │
└─────────────────────────────────────────────────────────────────┘
```

## Features

- **Secure Access**: CloudFront provides HTTPS access with no public IP exposure
- **Flexible Configuration**: Customizable instance type, storage, and networking
- **GPU Support**: Use GPU instances (e.g., g6.xlarge) for ML/AI workloads
- **SSM Access**: Connect to instance via AWS Systems Manager (no SSH required)
- **Reusable**: Easy to deploy across multiple environments/regions

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- VPC with private subnets (with NAT Gateway for outbound internet)

## Quick Start

### 1. Clone and Configure

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/vscode-web-terraform.git
cd vscode-web-terraform

# Copy example configuration
mkdir -p envs/my-env
cp terraform.tfvars.example envs/my-env/terraform.tfvars

# Edit configuration
vi envs/my-env/terraform.tfvars
```

### 2. Set Password

```bash
# Set VSCode Web password (required)
export TF_VAR_vscode_password="your-secure-password"
```

### 3. Deploy

```bash
cd envs/my-env

# Initialize Terraform
terraform init

# Review changes
terraform plan

# Deploy
terraform apply
```

### 4. Access

After deployment, Terraform outputs the VSCode Web URL:

```bash
terraform output vscode_web_url
# https://d1234567890.cloudfront.net
```

## Configuration

### Required Variables

| Variable | Description |
|----------|-------------|
| `aws_region` | AWS region (e.g., ap-northeast-1) |
| `vpc_id` | VPC ID |
| `private_subnet_ids` | List of private subnet IDs |
| `vscode_password` | Password for VSCode Web UI |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `instance_type` | t3.medium | EC2 instance type |
| `root_volume_size` | 100 | Root volume size (GB) |
| `root_volume_type` | gp3 | Volume type |
| `vscode_port` | 8080 | VSCode Web port |
| `enable_cloudfront` | true | Enable CloudFront |
| `cloudfront_price_class` | PriceClass_200 | CloudFront price class |
| `alb_internal` | true | Internal ALB |

See `terraform.tfvars.example` for full configuration options.

## Project Structure

```
vscode-web-terraform/
├── main.tf                    # Root module
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── versions.tf                # Provider versions
├── terraform.tfvars.example   # Configuration template
├── modules/
│   ├── ec2/                   # EC2 instance module
│   ├── alb/                   # Application Load Balancer
│   ├── cloudfront/            # CloudFront distribution
│   └── security-groups/       # Security groups
└── envs/
    └── tokyo/                 # Example environment
        ├── main.tf
        ├── variables.tf
        ├── terraform.tfvars
        └── backend.tf
```

## Multi-Environment Setup

Create new environments by copying the template:

```bash
# Create new environment
mkdir -p envs/production
cp envs/tokyo/main.tf envs/production/
cp envs/tokyo/variables.tf envs/production/
cp envs/tokyo/versions.tf envs/production/
cp terraform.tfvars.example envs/production/terraform.tfvars

# Configure for production
vi envs/production/terraform.tfvars
```

## Security

- EC2 instance has no public IP
- ALB is internal only
- CloudFront provides HTTPS termination
- Security groups restrict access to VPC CIDR
- SSM provides secure shell access without SSH

## Connect via SSM

```bash
# Get instance ID
INSTANCE_ID=$(terraform output -raw ec2_instance_id)

# Connect via SSM
aws ssm start-session --target $INSTANCE_ID
```

## Cleanup

```bash
terraform destroy
```

## License

MIT License
