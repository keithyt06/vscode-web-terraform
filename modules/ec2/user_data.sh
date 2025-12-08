#!/bin/bash
set -ex

# Set HOME environment variable (required for cloud-init on Ubuntu 24.04)
export HOME=/root
export DEBIAN_FRONTEND=noninteractive

# Log output to file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Starting VSCode Web setup ==="
echo "Timestamp: $(date)"

# Update system
echo "=== Updating system packages ==="
apt-get update
apt-get upgrade -y

# Install required packages
echo "=== Installing required packages ==="
apt-get install -y curl wget git nginx jq

# Mount data volume if specified
%{ if data_device != "" }
DATA_DEVICE="${data_device}"
DATA_MOUNT="/data"

# Wait for the device to be available (up to 5 minutes)
echo "=== Waiting for data volume ==="
WAIT_COUNT=0
MAX_WAIT=60
while [ ! -b "$DATA_DEVICE" ] && [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    echo "Waiting for $DATA_DEVICE... ($WAIT_COUNT/$MAX_WAIT)"
    sleep 5
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

if [ -b "$DATA_DEVICE" ]; then
    echo "Data volume found: $DATA_DEVICE"

    # Check if filesystem exists
    if ! blkid "$DATA_DEVICE" | grep -q "TYPE="; then
        echo "Creating filesystem on $DATA_DEVICE..."
        mkfs.ext4 -L data "$DATA_DEVICE"
    fi

    # Create mount point and mount
    mkdir -p "$DATA_MOUNT"

    # Add to fstab for persistence
    UUID=$(blkid -s UUID -o value "$DATA_DEVICE")
    if ! grep -q "$UUID" /etc/fstab; then
        echo "UUID=$UUID $DATA_MOUNT ext4 defaults,nofail 0 2" >> /etc/fstab
    fi

    mount -a
    echo "Data volume mounted at $DATA_MOUNT"

    # Set proper permissions
    chmod 755 "$DATA_MOUNT"
else
    echo "WARNING: Data volume $DATA_DEVICE not found after waiting"
fi
%{ endif }

# Install code-server (VSCode Web)
echo "=== Installing code-server ==="
curl -fsSL https://code-server.dev/install.sh | sh

# Verify code-server installation
if ! command -v code-server &> /dev/null; then
    echo "ERROR: code-server installation failed"
    exit 1
fi
echo "code-server version: $(code-server --version)"

# Create code-server configuration directory
mkdir -p /root/.config/code-server

# Configure code-server
cat > /root/.config/code-server/config.yaml <<EOF
bind-addr: 0.0.0.0:${vscode_port}
auth: password
password: ${vscode_password}
cert: false
EOF

# Enable and start code-server using the built-in systemd service
echo "=== Starting code-server service ==="
systemctl daemon-reload
systemctl enable --now code-server@root

# Wait for code-server to start
echo "Waiting for code-server to start..."
sleep 5

# Verify code-server is running
if systemctl is-active --quiet code-server@root; then
    echo "code-server is running"
else
    echo "WARNING: code-server may not be running properly"
    systemctl status code-server@root --no-pager || true
fi

# Configure nginx as reverse proxy with WebSocket support
echo "=== Configuring nginx ==="
cat > /etc/nginx/sites-available/code-server <<EOF
server {
    listen 80;
    server_name _;

    # WebSocket support for code-server
    location / {
        proxy_pass http://127.0.0.1:${vscode_port};
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;

        # Increase timeouts for WebSocket connections
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

# Enable nginx site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/code-server /etc/nginx/sites-enabled/

# Test nginx configuration
nginx -t

# Restart nginx
systemctl restart nginx
systemctl enable nginx

# Final health check
echo "=== Final health check ==="
echo "nginx status: $(systemctl is-active nginx)"
echo "code-server status: $(systemctl is-active code-server@root)"

# Test local connectivity
if curl -s -o /dev/null -w "%%{http_code}" http://127.0.0.1:80 | grep -q "302"; then
    echo "Local health check: PASSED"
else
    echo "Local health check: Response code $(curl -s -o /dev/null -w "%%{http_code}" http://127.0.0.1:80)"
fi

echo "=== VSCode Web setup completed ==="
echo "Timestamp: $(date)"
