#!/bin/bash -x

# --- NETWORK CONFIGURATION ---
cat > /etc/systemd/network/10-enp7s0.network << 'EOF'
[Match]
Name=enp7s0

[Network]
DHCP=yes
Gateway=10.0.0.1
EOF

# Configure DNS to use bastion's internal DNS server
cat > /etc/systemd/resolved.conf << 'EOF_RESOLVED'
[Resolve]
DNS=${bastion_private_ip}
FallbackDNS=8.8.8.8 1.1.1.1
Domains=~internal ~internal.local
DNSStubListener=no
EOF_RESOLVED

echo "DNS configuration complete - using bastion DNS at ${bastion_private_ip}"

# --- APPLY NETWORK CHANGES ---
echo "Restarting network services to apply changes..."
systemctl restart systemd-networkd
systemctl restart systemd-resolved
echo "Network changes applied."

# --- INTERNAL SSH KEY SETUP ---
echo "Setting up internal SSH public key..."
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "${internal_ssh_public_key}" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
echo "Internal SSH key setup complete."

apt update && apt upgrade -y

# Nginx
apt install nginx apache2-utils -y

# Netdata per monitoring
bash <(curl -Ss https://get.netdata.cloud/kickstart.sh) --non-interactive

# Wait for Netdata to be installed
sleep 10

# Configure Netdata to listen only on localhost:19998
cat > /etc/netdata/netdata.conf << 'EOF'
[global]
    # Listen only on localhost
    bind socket to IP = 127.0.0.1
    default port = 19998

[web]
    # Allow connections from localhost
    allow connections from = localhost 127.* 10.* 192.168.* 172.16.* 172.17.* 172.18.* 172.19.* 172.20.* 172.21.* 172.22.* 172.23.* 172.24.* 172.25.* 172.26.* 172.27.* 172.28.* 172.29.* 172.30.* 172.31.*
EOF

# Restart Netdata
systemctl restart netdata

# Create htpasswd file for Netdata authentication
echo "${netdata_password}" | htpasswd -ci /etc/nginx/.htpasswd_netdata ${netdata_username}

# Create Nginx configuration for Netdata
cat > /etc/nginx/sites-available/netdata << 'EOF'
${nginx_netdata_config}
EOF

# Enable Netdata site
ln -sf /etc/nginx/sites-available/netdata /etc/nginx/sites-enabled/netdata

# Remove default website
rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
nginx -t && systemctl reload nginx

# Install Docker
apt install -y ca-certificates curl gnupg lsb-release
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Run RabbitMQ container
echo "Starting RabbitMQ container..."
docker run -d \
  --name rabbitmq \
  --restart=unless-stopped \
  --hostname rabbitmq-node \
  -p 5672:5672 \
  -p 15672:15672 \
  -e RABBITMQ_DEFAULT_USER=${rabbitmq_user} \
  -e RABBITMQ_DEFAULT_PASS=${rabbitmq_password} \
  -e RABBITMQ_ERLANG_COOKIE=${rabbitmq_erlang_cookie} \
  -v rabbitmq_data:/var/lib/rabbitmq \
  rabbitmq:${rabbitmq_version}-management

# Wait for RabbitMQ to be ready
echo "Waiting for RabbitMQ to start..."
sleep 30

# Test RabbitMQ connection
echo "Testing RabbitMQ connection..."
until docker exec rabbitmq rabbitmqctl status 2>/dev/null; do
  echo "Waiting for RabbitMQ to be ready..."
  sleep 5
done

# Show RabbitMQ status
echo "RabbitMQ is ready!"
docker exec rabbitmq rabbitmqctl status
docker exec rabbitmq rabbitmqctl cluster_status

echo "RabbitMQ Management UI available at http://SERVER_IP:15672"
echo "Login with username: ${rabbitmq_user}"

reboot