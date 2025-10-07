#!/bin/bash -x


# --- NETWORK CONFIGURATION (Using the same correct method as the other private VM) ---

# The hcloud_network_route resource will handle forwarding from there.
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



# --- APPLY NETWORK CHANGES (Replaces Reboot) ---
echo "Restarting network services to apply changes..."
systemctl restart systemd-networkd
systemctl restart systemd-resolved
echo "Network changes applied."


# --- INTERNAL SSH KEY SETUP (New Requirement) ---
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

# Create directory for MariaDB data persistence
mkdir -p /var/lib/mariadb

# Run MariaDB container
docker run -d \
  --name mariadb \
  --restart=unless-stopped \
  -e MYSQL_ROOT_PASSWORD=${mariadb_root_password} \
  -e MYSQL_DATABASE=${mariadb_database} \
  -e MYSQL_USER=${mariadb_user} \
  -e MYSQL_PASSWORD=${mariadb_password} \
  -v /var/lib/mariadb:/var/lib/mysql \
  -p 3306:3306 \
  mariadb:latest

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to start..."
sleep 30
until docker exec mariadb mysqladmin ping -h localhost --silent; do
  echo "Waiting for MariaDB to be ready..."
  sleep 5
done

# Create read-only user for monitoring
docker exec mariadb mysql -uroot -p${mariadb_root_password} -e "
CREATE USER IF NOT EXISTS '${mariadb_readonly_user}'@'%' IDENTIFIED BY '${mariadb_readonly_password}';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO '${mariadb_readonly_user}'@'%';
FLUSH PRIVILEGES;
"

# Configure Netdata to monitor MariaDB
mkdir -p /etc/netdata/go.d
cat > /etc/netdata/go.d/mysql.conf << 'EOF'
jobs:
  - name: local
    dsn: ${mariadb_readonly_user}:${mariadb_readonly_password}@tcp(127.0.0.1:3306)/
    my_cnf: ""
EOF

# Restart Netdata to apply MySQL monitoring configuration
systemctl restart netdata

reboot