#!/bin/bash
set -e

# Update system
dnf update -y

# Install dependencies
dnf install -y curl wget git

# Install code-server
curl -fsSL https://code-server.dev/install.sh | sh

# Create code-server config directory
mkdir -p /home/ec2-user/.config/code-server

# Create code-server configuration
cat > /home/ec2-user/.config/code-server/config.yaml << 'EOF'
bind-addr: 0.0.0.0:${vscode_port}
auth: password
password: ${vscode_password}
cert: false
EOF

# Set correct ownership
chown -R ec2-user:ec2-user /home/ec2-user/.config

# Create systemd service for code-server
cat > /etc/systemd/system/code-server.service << EOF
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
EOF

# Enable and start code-server
systemctl daemon-reload
systemctl enable code-server
systemctl start code-server

# Verify code-server is running
sleep 5
systemctl status code-server
