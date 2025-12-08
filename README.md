# VSCode Web Terraform

使用 Terraform 在 AWS 上部署 VSCode Web (code-server)。本项目创建一个安全的、生产就绪的 VSCode Web 环境，通过 CloudFront HTTPS 访问。

## 架构

```
┌─────────────────────────────────────────────────────────────────┐
│                         CloudFront                               │
│                    (HTTPS 终端)                                  │
└─────────────────────────────────┬───────────────────────────────┘
                              │ (仅允许 CloudFront IP)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    公有 ALB                                      │
│              (HTTP:80, idle_timeout=3600s)                       │
│                  公有子网                                        │
└─────────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      EC2 实例                                    │
│              Ubuntu 24.04 LTS + code-server + nginx              │
│              200GB 系统盘 + 2TB 数据盘 (GP3)                     │
│                    私有子网                                      │
└─────────────────────────────────────────────────────────────────┘
```

## 功能特性

- **安全访问**: CloudFront 提供 HTTPS，ALB 仅接受 CloudFront 流量（通过 AWS 托管前缀列表）
- **自动启动**: code-server 和 nginx 开机自动启动并带健康检查
- **WebSocket 支持**: ALB 空闲超时设置为 3600s，确保 WebSocket 连接稳定
- **灵活存储**: 可配置根卷（默认 200GB）和数据卷（默认 2TB GP3）
- **自带卷**: 支持挂载现有 EBS 卷而非创建新卷
- **GPU 支持**: 默认 g6.xlarge 实例，适用于 ML/AI 工作负载
- **Ubuntu 24.04 LTS**: 最新长期支持版 Ubuntu，优化 cloud-init
- **可复用**: 易于跨多环境/区域部署

## 前置条件

- Terraform >= 1.0
- 已配置 AWS CLI
- 具有公有子网（用于 ALB）和私有子网（用于 EC2）的 VPC
- 私有子网需要 NAT 网关以访问互联网
- g6.xlarge 需要在选定的可用区有容量（检查 ap-northeast-1a 或 ap-northeast-1c）

## 快速开始

### 1. 配置环境

```bash
cd envs/dev

# 编辑配置 - 必须修改 vscode_password！
vi terraform.tfvars
```

### 2. 部署

```bash
# 初始化 Terraform
terraform init

# 查看变更
terraform plan -var-file=terraform.tfvars

# 部署
terraform apply -var-file=terraform.tfvars
```

### 3. 访问 VSCode Web

部署完成后（CloudFront 约需 15 分钟），通过以下方式访问：

```bash
terraform output vscode_web_url
# https://d1234567890.cloudfront.net
```

## 配置说明

### 必需变量

| 变量 | 描述 |
|----------|-------------|
| `region` | AWS 区域（如 ap-northeast-1） |
| `vpc_id` | VPC ID |
| `public_subnet_ids` | ALB 使用的公有子网 ID 列表 |
| `private_subnet_id` | EC2 实例使用的私有子网 ID |
| `vscode_password` | VSCode Web UI 密码 |

### 可选变量

| 变量 | 默认值 | 描述 |
|----------|---------|-------------|
| `name` | vscode-web | 资源名称前缀 |
| `instance_type` | g6.xlarge | EC2 实例类型 |
| `root_volume_size` | 200 | 根卷大小（GB） |
| `data_volume_size` | 2000 | 数据卷大小（GB），设为 0 禁用 |
| `existing_data_volume_id` | "" | 要挂载的现有 EBS 卷 ID |
| `key_name` | "" | SSH 密钥对名称（可选） |
| `iam_instance_profile` | "" | IAM 实例配置文件（可选） |
| `vscode_port` | 8080 | VSCode Web 内部端口 |
| `cloudfront_price_class` | PriceClass_All | CloudFront 价格等级 |

### 使用现有数据卷

要挂载现有 EBS 卷而非创建新卷：

```hcl
# 在 terraform.tfvars 中
data_volume_size = 0  # 禁用新卷创建
existing_data_volume_id = "vol-0123456789abcdef0"
```

## 项目结构

```
vscode-web-terraform/
├── main.tf                    # 根模块
├── variables.tf               # 输入变量
├── outputs.tf                 # 输出值
├── modules/
│   ├── ec2/                   # EC2 实例 + EBS 卷
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── user_data.sh       # 自动启动脚本
│   ├── alb/                   # 应用负载均衡器
│   ├── cloudfront/            # CloudFront 分发
│   └── security-groups/       # 安全组（仅 CloudFront 访问 ALB）
└── envs/
    └── dev/                   # 开发环境
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── backend.tf         # 后端配置（可选）
        └── terraform.tfvars   # 环境配置
```

## 多环境设置

复制 dev 目录创建新环境：

```bash
# 创建新环境
cp -r envs/dev envs/production

# 更新配置
vi envs/production/terraform.tfvars

# 部署
cd envs/production
terraform init
terraform apply -var-file=terraform.tfvars
```

## 安全性

- EC2 实例部署在私有子网（无公有 IP）
- ALB 安全组仅允许来自 CloudFront 的流量（AWS 托管前缀列表）
- EC2 安全组仅允许来自 ALB 的流量
- CloudFront 提供 HTTPS 终端，使用 TLSv1.2
- 所有 EBS 卷默认加密

## 数据卷

数据卷挂载在 `/data`，实例重启后持久保存：

- 首次启动时自动格式化为 ext4
- 添加到 /etc/fstab 实现自动挂载
- 使用 `existing_data_volume_id` 在部署间保留数据

## 输出

| 输出 | 描述 |
|--------|-------------|
| `instance_id` | EC2 实例 ID |
| `instance_private_ip` | EC2 私有 IP |
| `data_volume_id` | 数据卷 ID（用于备份） |
| `alb_dns_name` | ALB DNS 名称 |
| `cloudfront_distribution_id` | CloudFront 分发 ID |
| `cloudfront_domain_name` | CloudFront 域名 |
| `vscode_web_url` | 访问 VSCode Web 的完整 HTTPS URL |

## 故障排除

### 实例创建时间过长

如果 EC2 实例创建超过 10 分钟：
- g6.xlarge 可能在选定的可用区不可用
- 尝试将 `private_subnet_id` 更改为 ap-northeast-1a 或 ap-northeast-1c 的子网
- 检查 AWS 服务健康状况仪表板是否有容量问题

### VSCode Web 显示 nginx 默认页面

如果看到 nginx 欢迎页面而非 code-server：
1. 通过 SSH/SSM 连接到实例
2. 检查 user-data 日志：`cat /var/log/user-data.log`
3. 检查 code-server 状态：`systemctl status code-server@root`
4. 检查 nginx 配置：`cat /etc/nginx/sites-enabled/code-server`

### WebSocket 连接问题

如果 code-server 频繁断开连接：
- ALB idle_timeout 已设置为 3600s（1 小时）
- CloudFront origin_read_timeout 已设置为 60s
- 检查浏览器控制台是否有 WebSocket 错误

### 通过 SSM 检查实例日志

```bash
# 获取实例 ID
INSTANCE_ID=$(terraform output -raw instance_id)

# 通过 SSM 连接
aws ssm start-session --target $INSTANCE_ID

# 查看 user-data 日志
sudo cat /var/log/user-data.log

# 检查服务状态
sudo systemctl status code-server@root
sudo systemctl status nginx
```

## 清理

```bash
terraform destroy -var-file=terraform.tfvars
```

## 已知限制

- CloudFront 分发部署约需 15 分钟
- g6.xlarge 实例在某些可用区可能容量有限
- 数据卷必须与实例在同一可用区

## 许可证

MIT License
