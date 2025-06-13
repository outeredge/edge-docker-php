#!/bin/bash -ex

# Install mcrypt for PHP 7.1
if [ "$PHP_VERSION" = "7.1" ]; then
    apt-get update
    apt-get install --no-install-recommends --yes php${PHP_VERSION}-mcrypt
    rm -Rf /var/www/*
    rm -rf /var/lib/apt/lists/*
fi

# Download ioncube loaders for PHP < 8
if [ ${PHP_VERSION%.*} -lt 8 ]; then
    SV=(${PHP_VERSION//./ })
    IONCUBE_VERSION="${SV[0]}.${SV[1]}"
    wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O - | tar -zxf - -C /tmp
    cp /tmp/ioncube/ioncube_loader_lin_$IONCUBE_VERSION.so $(php -i | grep ^extension_dir | cut -d '>' -f3)/ioncube.so
fi

# Redirect PHP cli to fpm configs
cp /templates/php.ini /etc/php/$PHP_VERSION/fpm/php.ini
rm -Rf /etc/php/$PHP_VERSION/cli
ln -s /etc/php/$PHP_VERSION/fpm /etc/php/$PHP_VERSION/cli

# Set up sudo for passwordless access to edge and sudo users
chmod g=u /etc/passwd
echo 'Set disable_coredump false' > /etc/sudo.conf
echo "edge ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/edge
chmod 0440 /etc/sudoers.d/edge
sed -i 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Create default user
addgroup --gid 1000 --system edge
adduser --uid 1000 --system --home /home/edge --shell /bin/bash --ingroup edge edge
usermod -a -G sudo edge
usermod -a -G edge www-data
touch /home/edge/.hushlogin
chown -Rf edge:edge /var/www

# Create user for nginx
adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx
usermod -a -G edge nginx

# Logging for nginx and PHP
mkdir -p /var/log/php
chown -Rf www-data:www-data /var/log/php
chown -Rf nginx:nginx /var/log/nginx

# Create default host keys
mkdir -p /var/run/sshd
ssh-keygen -A

# Replace sendmail with msmtp
ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# Use host as SERVER_NAME
sed -i "s/server_name/host/" /etc/nginx/fastcgi_params
sed -i "s/server_name/host/" /etc/nginx/fastcgi.conf

# Set HTTPS according to forwarded protocol
sed -i "s/\$https/on/" /etc/nginx/fastcgi_params
sed -i "s/\$https/on/" /etc/nginx/fastcgi.conf

# Don't time out SSH connections
echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 720" >> /etc/ssh/sshd_config

# Install Chisel TCP/UDP tunnel
curl https://i.jpillora.com/chisel! | bash

## Temporary solution until next Ubuntu release to upgrade PIPX
sudo pipx install pipx # Install 1.7 in ~/.local/bin/
sudo ~/.local/bin/pipx install --global pipx # Install 1.7 in /usr/local/bin/pipx
sudo /usr/local/bin/pipx uninstall pipx # Remove 1.7 from ~/.local/

## Install J2 globally
sudo pipx install --global jinjanator

# Install yarn & gulp-cli
npm install --global yarn gulp-cli

if [ "$NODE_VERSION" -lt "10" ]; then
    npm install --global n
    sudo n $NODE_VERSION
fi

npm cache clean --force

# Install Composer
wget -O /usr/local/bin/composer "https://getcomposer.org/composer-$COMPOSER_VERSION.phar"
chmod a+x /usr/local/bin/composer

# Install prestissimo for parallel composer installs (v1 only)
if [ "$COMPOSER_VERSION" = "1" ]; then
    sudo -H -u edge composer global require hirak/prestissimo
    sudo -H -u edge composer clear-cache
fi

# Cleanup
rm -rf /tmp/*
