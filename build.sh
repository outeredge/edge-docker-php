#!/bin/bash -ex

# Create user for php-fpm
adduser -u 82 -D -S -s /sbin/nologin -h /var/www -G www-data www-data
mkdir -p /var/log/php5
chown -Rf www-data:www-data /var/log/php5

# Set up sudo for passwordless access to edge and wheel users
chmod g=u /etc/passwd
echo 'Set disable_coredump false' > /etc/sudo.conf
echo "edge ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/edge
chmod 0440 /etc/sudoers.d/edge
sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

# Create default user
addgroup -g 1000 -S edge
adduser -u 1000 -D -S -s /bin/bash -g edge -G edge edge
addgroup edge wheel
addgroup nginx edge
addgroup www-data edge
chown -Rf edge:edge /var/www

# Create default host keys
ssh-keygen -A

# Replace sendmail with msmtp
ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# Use host as SERVER_NAME
sed -i "s/server_name/host/" /etc/nginx/fastcgi_params
sed -i "s/server_name/host/" /etc/nginx/fastcgi.conf

# Set HTTPS according to forwarded protocol
sed -i "s/https/fe_https/" /etc/nginx/fastcgi_params
sed -i "s/https/fe_https/" /etc/nginx/fastcgi.conf

# Add php aliases
ln -s /usr/bin/php5 /usr/bin/php
ln -s /usr/bin/php-config5 /usr/bin/php-config

# Don't time out SSH connections
echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 720" >> /etc/ssh/sshd_config

# Install shinto-cli
pip install --no-cache-dir shinto-cli

# Install older Composer 1
wget -O /usr/local/bin/composer "https://getcomposer.org/composer-1.phar"
chmod a+x /usr/local/bin/composer

# Install Chisel TCP/UDP tunnel
curl https://i.jpillora.com/chisel! | bash

# Install prestissimo for parallel composer installs (until v2 is out)
sudo -u edge composer global require hirak/prestissimo
sudo -u edge composer clear-cache

# Download ioncube loaders
apk add --no-cache --virtual .build-deps php5-dev
SV=(${PHP_VERSION//./ })
IONCUBE_VERSION="${SV[0]}.${SV[1]}"
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O - | tar -zxf - -C /tmp
cp /tmp/ioncube/ioncube_loader_lin_$IONCUBE_VERSION.so $(php-config --extension-dir)/ioncube.so
sudo sed -i 1i"zend_extension = ioncube.so" /etc/php5/php.ini
apk del .build-deps

# Cleanup
rm -rf /tmp/*
