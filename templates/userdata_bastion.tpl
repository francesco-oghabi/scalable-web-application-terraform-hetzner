#!/bin/bash -x
# Path /var/lib/cloud/instance/scripts


# --- NAT CONFIGURATION ---
apt update && apt upgrade -y
cat > /etc/networkd-dispatcher/routable.d/10-eth0-post-up << 'EOF_NAT_SCRIPT'
#!/bin/bash
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s '${private_network_ip_range}' -o eth0 -j MASQUERADE
EOF_NAT_SCRIPT

chmod +x /etc/networkd-dispatcher/routable.d/10-eth0-post-up
echo "Original NAT configuration has been set up."

systemctl restart networkd-dispatcher.service
echo "Applied network configuration changes"

# --- INTERNAL SSH KEY SETUP ---
echo "Setting up internal SSH key for bastion..."
mkdir -p /root/.ssh
chmod 700 /root/.ssh
cat << 'EOF_SSH_PRIVATE_KEY' > /root/.ssh/id_rsa_internal
${internal_ssh_private_key}
EOF_SSH_PRIVATE_KEY
chmod 600 /root/.ssh/id_rsa_internal
echo "Internal SSH key setup complete."

###########################################
# Configure DNSmasq for internal domain
##########################################
mkdir -p /etc/systemd/resolved.conf.d
cat > /etc/systemd/resolved.conf.d/internal-dns.conf << 'EOF_RESOLVED'
[Resolve]
DNS=127.0.0.1:53
Domains=~internal ~internal.local
DNSStubListener=no
EOF_RESOLVED

# --- DNSMASQ DNS SERVER CONFIGURATION ---
echo "Installing and configuring dnsmasq for internal DNS..."
apt install -y dnsmasq

# Get the bastion's private IP dynamically
BASTION_PRIVATE_IP=$(ip -4 addr show enp7s0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
echo "Detected bastion private IP: $BASTION_PRIVATE_IP"

# Get the bastion's public IP dynamically
BASTION_PUBLIC_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
echo "Detected bastion public IP: $BASTION_PUBLIC_IP"

#################################################
# Configure dnsmasq for internal DNS resolution
################################################
cat > /etc/dnsmasq.d/internal.conf << EOF_DNSMASQ

# DNS forwarding for external queries
server=8.8.8.8
server=1.1.1.1

# Listen on localhost and private network interface
listen-address=127.0.0.1,$BASTION_PRIVATE_IP
bind-interfaces

# Domain configuration
domain=internal.local
expand-hosts
cache-size=1000

# Logging
log-queries
log-facility=/var/log/dnsmasq.log
EOF_DNSMASQ

# Restart dnsmasq
systemctl enable dnsmasq
systemctl restart dnsmasq
echo "dnsmasq DNS server configured and running."



# Restart systemd-resolved
systemctl restart dnsmasq
systemctl restart systemd-networkd
systemctl restart systemd-resolved


############################################
# Configure Reverse Proxy for Netdata
############################################
echo "Installing and configuring Nginx reverse proxy for Netdata..."
apt install -y nginx

# Create Nginx configuration for Netdata proxy
cat > /etc/nginx/sites-available/netdata-proxy << EOF_NGINX_PROXY
# Upstream for database server
upstream netdata_database {
    server ${database_static_ip}:80;
    keepalive 64;
}

# Upstream for OpenSearch server
upstream netdata_opensearch {
    server ${opensearch_static_ip}:80;
    keepalive 64;
}

# Upstream for Redis server
upstream netdata_redis {
    server ${redis_static_ip}:80;
    keepalive 64;
}

# Upstream for RabbitMQ server
upstream netdata_rabbit {
    server ${rabbit_static_ip}:80;
    keepalive 64;
}

server {
    listen 8080;
    server_name _;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Database Netdata
    location /netdata-database/ {
        proxy_pass http://netdata_database/;

        # Proxy headers
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # WebSocket support (required for Netdata real-time updates)
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # Buffering
        proxy_buffering off;
        proxy_cache off;
    }

    # OpenSearch Netdata
    location /netdata-opensearch/ {
        proxy_pass http://netdata_opensearch/;

        # Proxy headers
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # WebSocket support (required for Netdata real-time updates)
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # Buffering
        proxy_buffering off;
        proxy_cache off;
    }

    # Redis Netdata
    location /netdata-redis/ {
        proxy_pass http://netdata_redis/;

        # Proxy headers
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # WebSocket support (required for Netdata real-time updates)
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # Buffering
        proxy_buffering off;
        proxy_cache off;
    }

    # RabbitMQ Netdata
    location /netdata-rabbit/ {
        proxy_pass http://netdata_rabbit/;

        # Proxy headers
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # WebSocket support (required for Netdata real-time updates)
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # Buffering
        proxy_buffering off;
        proxy_cache off;
    }

    # Root location (dashboard with links)
    location = / {
        return 200 '<!DOCTYPE html>
<html>
<head>
    <title>Netdata Monitoring Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        h1 { color: #333; }
        .server { background: #f5f5f5; padding: 20px; margin: 10px 0; border-radius: 5px; }
        a { color: #0066cc; text-decoration: none; font-size: 18px; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Netdata Monitoring Dashboard</h1>
    <div class="server">
            <h2>PHP_NGINX Server (${php_nginx_static_ip})</h2>
            <p><a href="/netdata-database/" target="_blank">View PHP NGINX Netdata</a></p>
            <p>PHP_NGINX monitoring, system resources, and performance metrics</p>
        </div>
    <div class="server">
        <h2>Database Server (${database_static_ip})</h2>
        <p><a href="/netdata-database/" target="_blank">View Database Netdata</a></p>
        <p>MariaDB monitoring, system resources, and performance metrics</p>
    </div>
    <div class="server">
        <h2>OpenSearch Server (${opensearch_static_ip})</h2>
        <p><a href="/netdata-opensearch/" target="_blank">View OpenSearch Netdata</a></p>
        <p>OpenSearch monitoring, system resources, and performance metrics</p>
    </div>
    <div class="server">
        <h2>Redis Server (${redis_static_ip})</h2>
        <p><a href="/netdata-redis/" target="_blank">View Redis Netdata</a></p>
        <p>Redis monitoring, system resources, and performance metrics</p>
    </div>
    <div class="server">
        <h2>RabbitMQ Server (${rabbit_static_ip})</h2>
        <p><a href="/netdata-rabbit/" target="_blank">View RabbitMQ Netdata</a></p>
        <p>RabbitMQ monitoring, system resources, and performance metrics</p>
    </div>
    <hr>
    <p><small>Access protected by basic authentication on backend servers</small></p>
</body>
</html>';
        add_header Content-Type text/html;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }
}
EOF_NGINX_PROXY

# Enable the site
ln -sf /etc/nginx/sites-available/netdata-proxy /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
nginx -t && systemctl reload nginx

echo "Netdata reverse proxy configured on port 8080"
echo "Access dashboard at: http://$BASTION_PUBLIC_IP:8080/"

