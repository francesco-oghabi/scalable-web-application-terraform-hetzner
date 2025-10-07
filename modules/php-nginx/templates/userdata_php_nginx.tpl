#!/bin/bash -x

apt update && apt upgrade -y

# Nginx
apt install nginx apache2-utils -y

# Php
# dom  simplexml  xmlwriter --> xml
# ctype sockets pdo, iconv, ftp, fileinfo tokenizer -> common
# hash, filter, json, libxml, openssl, pcre sodium zlib?

add-apt-repository ppa:ondrej/php -y
apt install php8.3 php8.3-cli php8.3-fpm php8.3-common \
    php8.3-bcmath php8.3-curl php8.3-gd  \
    php8.3-intl php8.3-mbstring \
    php8.3-mysql php8.3-zip php8.3-soap \
     php8.3-xml  php8.3-xsl   -y

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

reboot