#!/bin/bash -ex

# Create user for Nginx & PHP and add to sudoers
addgroup -g 1000 -S edge
adduser -u 1000 -DS -s /bin/bash -g edge -G edge edge
addgroup edge wheel
echo "edge ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/edge
chmod 0440 /etc/sudoers.d/edge
chown -R edge:edge /var/www

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

# Install shinto-cli
pip install --no-cache-dir shinto-cli

# Install prestissimo for parallel composer installs (until v2 is out)
sudo -u edge composer global require hirak/prestissimo
sudo -u edge composer clear-cache

# Download ioncube loaders
apk add --no-cache --virtual .build-deps php7-dev
SV=(${PHP_VERSION//./ })
IONCUBE_VERSION="${SV[0]}.${SV[1]}"
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O - | tar -zxf - -C /tmp
cp /tmp/ioncube/ioncube_loader_lin_$IONCUBE_VERSION.so $(php-config --extension-dir)/ioncube.so
apk del .build-deps

# Cleanup
rm -rf /tmp/*
