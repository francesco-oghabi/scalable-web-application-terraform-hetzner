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



# --- DNSMASQ DNS SERVER CONFIGURATION ---
echo "Installing and configuring dnsmasq for internal DNS..."
apt install -y dnsmasq

# Get the bastion's private IP dynamically
BASTION_PRIVATE_IP=$(ip -4 addr show enp7s0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
echo "Detected bastion private IP: $BASTION_PRIVATE_IP"

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

# Restart systemd-resolved
systemctl restart dnsmasq
systemctl restart systemd-networkd
systemctl restart systemd-resolved