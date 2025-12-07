#!/bin/bash
set -e

# Logging
exec > >(tee /var/log/user-data.log) 2>&1
echo "Starting user_data script at $(date)"

# Update system
echo "Updating system packages..."
dnf update -y

# Install dependencies
# Note: Amazon Linux 2023 has curl-minimal by default, use --allowerasing to replace with full curl
echo "Installing dependencies..."
dnf install -y wget git
dnf install -y --allowerasing curl || echo "curl already available via curl-minimal"

# Install code-server
echo "Installing code-server..."
curl -fsSL https://code-server.dev/install.sh | sh

# Verify code-server installed
if ! command -v code-server &> /dev/null; then
    echo "ERROR: code-server installation failed!"
    exit 1
fi
echo "code-server installed successfully: $(code-server --version)"

# Create code-server config directory
mkdir -p /home/ec2-user/.config/code-server

# Create code-server configuration
cat > /home/ec2-user/.config/code-server/config.yaml << 'CONFIGEOF'
bind-addr: 0.0.0.0:${vscode_port}
auth: password
password: ${vscode_password}
cert: false
CONFIGEOF

# Set correct ownership
chown -R ec2-user:ec2-user /home/ec2-user/.config

# Create systemd service for code-server
cat > /etc/systemd/system/code-server.service << 'SERVICEEOF'
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

# Enable and start code-server
echo "Starting code-server service..."
systemctl daemon-reload
systemctl enable code-server
systemctl start code-server

# Wait and verify code-server is running
sleep 5
if systemctl is-active --quiet code-server; then
    echo "code-server is running successfully!"
    systemctl status code-server --no-pager
else
    echo "ERROR: code-server failed to start!"
    journalctl -u code-server --no-pager -n 50
    exit 1
fi

echo "User data script completed successfully at $(date)"
