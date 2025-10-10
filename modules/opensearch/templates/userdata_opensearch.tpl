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

# Create directories for OpenSearch data persistence
mkdir -p ${opensearch_data_path}
chmod 777 ${opensearch_data_path}

# Set vm.max_map_count for OpenSearch
sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" >> /etc/sysctl.conf

# Create custom opensearch.yml configuration
mkdir -p /etc/opensearch
cat > /etc/opensearch/opensearch.yml << 'EOF_OPENSEARCH_CONFIG'
cluster.name: ${opensearch_cluster_name}
node.name: opensearch-node1
network.host: 0.0.0.0
discovery.type: single-node

# Security
plugins.security.ssl.http.enabled: false

# Memory settings
indices.memory.index_buffer_size: 30%
indices.memory.min_index_buffer_size: 96mb

# Thread pool settings
thread_pool.write.queue_size: 1000
thread_pool.search.queue_size: 1000

# Cache settings
indices.queries.cache.size: 25%

# Disk allocation
cluster.routing.allocation.disk.threshold_enabled: false
EOF_OPENSEARCH_CONFIG

# Create Dockerfile for OpenSearch with plugins
cat > /root/Dockerfile.opensearch << 'EOF_DOCKERFILE'
FROM opensearchproject/opensearch:${opensearch_version}

# Install plugins as opensearch user
USER opensearch
RUN /usr/share/opensearch/bin/opensearch-plugin install --batch analysis-phonetic
RUN /usr/share/opensearch/bin/opensearch-plugin install --batch analysis-icu
EOF_DOCKERFILE

# Build custom OpenSearch image with plugins
echo "Building custom OpenSearch image with plugins..."
docker build -f /root/Dockerfile.opensearch -t opensearch-custom:${opensearch_version} /root/

# Run OpenSearch container
echo "Starting OpenSearch container..."
docker run -d \
  --name opensearch \
  --restart=unless-stopped \
  -e "discovery.type=single-node" \
  -e "OPENSEARCH_JAVA_OPTS=-Xms${opensearch_heap_size} -Xmx${opensearch_heap_size}" \
  -e "DISABLE_SECURITY_PLUGIN=true" \
  -v ${opensearch_data_path}:/usr/share/opensearch/data \
  -p 9200:9200 \
  -p 9600:9600 \
  opensearch-custom:${opensearch_version}

# Wait for OpenSearch to be ready
echo "Waiting for OpenSearch to start..."
sleep 30
until curl -XGET "http://localhost:9200/_cluster/health?pretty" -H 'Content-Type: application/json' 2>/dev/null; do
  echo "Waiting for OpenSearch to be ready..."
  sleep 5
done

echo "OpenSearch is ready!"

# Verify installed plugins
echo "Verifying installed plugins..."
docker exec opensearch /usr/share/opensearch/bin/opensearch-plugin list

# Show cluster info
echo "OpenSearch cluster information:"
curl -XGET "http://localhost:9200/_cluster/health?pretty" -H 'Content-Type: application/json'

reboot