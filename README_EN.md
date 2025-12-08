# VSCode Web Terraform

Deploy VSCode Web (code-server) on AWS with Terraform. This project creates a secure, production-ready VSCode Web environment accessible via CloudFront HTTPS.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CloudFront                               │
│                    (HTTPS Termination)                           │
└─────────────────────────────┬───────────────────────────────────┘
                              │ (Only CloudFront IPs allowed)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Public ALB                                    │
│              (HTTP:80, idle_timeout=3600s)                       │
│                  Public Subnets                                  │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      EC2 Instance                                │
│              Ubuntu 24.04 LTS + code-server + nginx              │
│              200GB System + 2TB Data Volume (GP3)                │
│                    Private Subnet                                │
└─────────────────────────────────────────────────────────────────┘
```

## Features

- **Secure Access**: CloudFront provides HTTPS, ALB only accepts CloudFront traffic (via AWS managed prefix list)
- **Auto Start**: code-server and nginx start automatically on boot with health checks
- **WebSocket Support**: ALB idle timeout set to 3600s for stable WebSocket connections
- **Flexible Storage**: Configurable root volume (default 200GB) and data volume (default 2TB GP3)
- **Bring Your Own Volume**: Option to attach existing EBS volume instead of creating new one
- **GPU Support**: Default g6.xlarge instance for ML/AI workloads
- **Ubuntu 24.04 LTS**: Latest long-term support Ubuntu with cloud-init optimizations
- **Reusable**: Easy to deploy across multiple environments/regions

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- VPC with public subnets (for ALB) and private subnets (for EC2)
- NAT Gateway for private subnet outbound internet access
- g6.xlarge requires availability in selected AZ (check ap-northeast-1a or ap-northeast-1c)

## Quick Start

### 1. Configure Environment

```bash
cd envs/dev

# Edit configuration - MUST change vscode_password!
vi terraform.tfvars
```

### 2. Deploy

```bash
# Initialize Terraform
terraform init

# Review changes
terraform plan -var-file=terraform.tfvars

# Deploy
terraform apply -var-file=terraform.tfvars
```

### 3. Access VSCode Web

After deployment (~15 minutes for CloudFront), access via:

```bash
terraform output vscode_web_url
# https://d1234567890.cloudfront.net
```

## Configuration

### Required Variables

| Variable | Description |
|----------|-------------|
| `region` | AWS region (e.g., ap-northeast-1) |
| `vpc_id` | VPC ID |
| `public_subnet_ids` | List of public subnet IDs for ALB |
| `private_subnet_id` | Private subnet ID for EC2 instance |
| `vscode_password` | Password for VSCode Web UI |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `name` | vscode-web | Name prefix for resources |
| `instance_type` | g6.xlarge | EC2 instance type |
| `root_volume_size` | 200 | Root volume size (GB) |
| `data_volume_size` | 2000 | Data volume size (GB), set 0 to disable |
| `existing_data_volume_id` | "" | Existing EBS volume ID to attach |
| `key_name` | "" | SSH key pair name (optional) |
| `iam_instance_profile` | "" | IAM instance profile (optional) |
| `vscode_port` | 8080 | VSCode Web internal port |
| `cloudfront_price_class` | PriceClass_All | CloudFront price class |

### Using Existing Data Volume

To attach an existing EBS volume instead of creating a new one:

```hcl
# In terraform.tfvars
data_volume_size = 0  # Disable new volume creation
existing_data_volume_id = "vol-0123456789abcdef0"
```

## Project Structure

```
vscode-web-terraform/
├── main.tf                    # Root module
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── modules/
│   ├── ec2/                   # EC2 instance + EBS volumes
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── user_data.sh       # Auto-start script
│   ├── alb/                   # Application Load Balancer
│   ├── cloudfront/            # CloudFront distribution
│   └── security-groups/       # Security groups (CloudFront-only ALB)
└── envs/
    └── dev/                   # Development environment
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── backend.tf         # Backend config (optional)
        └── terraform.tfvars   # Environment configuration
```

## Multi-Environment Setup

Create new environments by copying dev:

```bash
# Create new environment
cp -r envs/dev envs/production

# Update configuration
vi envs/production/terraform.tfvars

# Deploy
cd envs/production
terraform init
terraform apply -var-file=terraform.tfvars
```

## Security

- EC2 instance deployed in private subnet (no public IP)
- ALB security group only allows traffic from CloudFront (AWS managed prefix list)
- EC2 security group only allows traffic from ALB
- CloudFront provides HTTPS termination with TLSv1.2
- All EBS volumes encrypted by default

## Data Volume

The data volume is mounted at `/data` and persists across instance restarts:

- Auto-formatted with ext4 on first boot
- Added to /etc/fstab for auto-mount
- Use `existing_data_volume_id` to preserve data across deployments

## Outputs

| Output | Description |
|--------|-------------|
| `instance_id` | EC2 instance ID |
| `instance_private_ip` | EC2 private IP |
| `data_volume_id` | Data volume ID (for backup) |
| `alb_dns_name` | ALB DNS name |
| `cloudfront_distribution_id` | CloudFront distribution ID |
| `cloudfront_domain_name` | CloudFront domain |
| `vscode_web_url` | Full HTTPS URL to access VSCode Web |

## Troubleshooting

### Instance Creation Takes Too Long

If EC2 instance creation hangs for more than 10 minutes:
- g6.xlarge may not be available in the selected AZ
- Try changing `private_subnet_id` to a subnet in ap-northeast-1a or ap-northeast-1c
- Check AWS Service Health Dashboard for capacity issues

### VSCode Web Shows nginx Default Page

If you see the nginx welcome page instead of code-server:
1. SSH/SSM into the instance
2. Check user-data log: `cat /var/log/user-data.log`
3. Check code-server status: `systemctl status code-server@root`
4. Check nginx config: `cat /etc/nginx/sites-enabled/code-server`

### WebSocket Connection Issues

If code-server disconnects frequently:
- ALB idle_timeout is set to 3600s (1 hour)
- CloudFront origin_read_timeout is set to 60s
- Check browser console for WebSocket errors

### Check Instance Logs via SSM

```bash
# Get instance ID
INSTANCE_ID=$(terraform output -raw instance_id)

# Connect via SSM
aws ssm start-session --target $INSTANCE_ID

# View user-data log
sudo cat /var/log/user-data.log

# Check service status
sudo systemctl status code-server@root
sudo systemctl status nginx
```

## Cleanup

```bash
terraform destroy -var-file=terraform.tfvars
```

## Known Limitations

- CloudFront distribution takes ~15 minutes to deploy
- g6.xlarge instances may have limited availability in some AZs
- Data volume must be in the same AZ as the instance

## License

MIT License
