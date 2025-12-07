#!/bin/bash
set -e

# Logging
exec > >(tee /var/log/user-data.log) 2>&1
echo "=========================================="
echo "Starting user_data script at $(date)"
echo "=========================================="

# Variables
CODE_SERVER_VERSION="4.96.2"

# Update system
echo "[1/6] Updating system packages..."
dnf update -y

# Install dependencies (wget and git only, curl-minimal is sufficient)
echo "[2/6] Installing dependencies..."
dnf install -y wget git

# Install code-server via RPM (most reliable for Amazon Linux 2023)
echo "[3/6] Installing code-server v$${CODE_SERVER_VERSION} via RPM..."
cd /tmp
wget -q "https://github.com/coder/code-server/releases/download/v$${CODE_SERVER_VERSION}/code-server-$${CODE_SERVER_VERSION}-amd64.rpm"
rpm -i "code-server-$${CODE_SERVER_VERSION}-amd64.rpm"
rm -f "code-server-$${CODE_SERVER_VERSION}-amd64.rpm"

# Verify installation
if ! command -v code-server &> /dev/null; then
    echo "ERROR: code-server installation failed!"
    exit 1
fi
echo "code-server installed: $(code-server --version)"

# Create config directory
echo "[4/6] Configuring code-server..."
mkdir -p /home/ec2-user/.config/code-server

# Create configuration file
cat > /home/ec2-user/.config/code-server/config.yaml << 'CONFIGEOF'
bind-addr: 0.0.0.0:${vscode_port}
auth: password
password: ${vscode_password}
cert: false
CONFIGEOF

# Set ownership
chown -R ec2-user:ec2-user /home/ec2-user/.config

# Create systemd service
echo "[5/6] Creating systemd service..."
cat > /etc/systemd/system/code-server.service << SERVICEEOF
[Unit]
Description=code-server
After=network.target

[Service]
Type=simple
User=ec2-user
Environment=HOME=/home/ec2-user
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/code-server --bind-addr 0.0.0.0:${vscode_port}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Start service
echo "[6/6] Starting code-server service..."
systemctl daemon-reload
systemctl enable code-server
systemctl start code-server

# Verify service
sleep 3
if systemctl is-active --quiet code-server; then
    echo "=========================================="
    echo "SUCCESS: code-server is running!"
    echo "Port: ${vscode_port}"
    echo "=========================================="
    systemctl status code-server --no-pager
else
    echo "ERROR: code-server failed to start!"
    journalctl -u code-server --no-pager -n 30
    exit 1
fi

echo "User data completed at $(date)"
