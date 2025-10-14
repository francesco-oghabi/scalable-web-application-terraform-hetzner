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

# Enable and start PHP-FPM
systemctl enable php8.3-fpm
systemctl start php8.3-fpm


# Certbot for SSL certificates
apt install certbot python3-certbot-nginx -y

# Install Composer
echo "Installing Composer..."
EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    echo 'ERROR: Invalid Composer installer checksum'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer
COMPOSER_EXIT_CODE=$?
rm composer-setup.php

if [ $COMPOSER_EXIT_CODE -ne 0 ]; then
    echo 'ERROR: Composer installation failed'
    exit 1
fi

echo "Composer installed successfully"
composer --version

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

####################################################
# Create magento user with appropriate permissions
####################################################
echo "Creating magento user..."

# Create magento user
useradd -m -s /bin/bash magento

# Create www-html directory if it doesn't exist
mkdir -p /var/www/html

# Set read permissions for magento user on /var/www/html
# Add magento to www-data group for proper web permissions
# Add magento to adm group to read nginx logs
usermod -aG www-data,adm magento

# Set directory permissions so magento can read
chmod 755 /var/www/html
chown -R www-data:www-data /var/www/html

# Configure sudo for magento user to run Magento CLI commands
cat > /etc/sudoers.d/magento << 'EOF_MAGENTO_SUDO'
# Allow magento user to run Magento CLI commands
magento ALL=(www-data) NOPASSWD: /usr/bin/php /var/www/html/bin/magento setup:upgrade*
magento ALL=(www-data) NOPASSWD: /usr/bin/php /var/www/html/bin/magento setup:di:compile*
magento ALL=(www-data) NOPASSWD: /usr/bin/php /var/www/html/bin/magento setup:static-content:deploy*
magento ALL=(www-data) NOPASSWD: /usr/bin/php /var/www/html/bin/magento cache:*
magento ALL=(www-data) NOPASSWD: /usr/bin/php /var/www/html/bin/magento indexer:*
EOF_MAGENTO_SUDO

# Set proper permissions on sudoers file
chmod 0440 /etc/sudoers.d/magento

echo "Magento user created successfully with appropriate permissions"
echo "User 'magento' can run Magento CLI commands using: sudo -u www-data php /var/www/html/bin/magento <command>"

reboot