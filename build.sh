#!/bin/bash -ex

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
userdel -r ubuntu || true
addgroup --gid 1000 --system edge
adduser --uid 1000 --system --home /home/edge --shell /bin/bash --ingroup edge edge
usermod -a -G sudo edge
usermod -a -G edge www-data
touch /home/edge/.hushlogin
chown -Rf edge:edge /var/www

# Create user for nginx
adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx
usermod -a -G edge nginx

# Logging for nginx (PHP errors now go to /dev/stderr via php.ini)
chown -Rf nginx:nginx /var/log/nginx

# Install env-driven sendmail wrapper (msmtp). msmtp merges CLI flags with
# /etc/msmtprc (rendered at runtime by msmtprc.j2 on this track), so existing
# behaviour is preserved while php.ini's sendmail_path resolves on both tracks.
install -m 0755 -o root -g root /templates/sendmail /usr/local/bin/sendmail
ln -sf /usr/local/bin/sendmail /usr/sbin/sendmail

# Install profile.d snippet so docker exec shell sessions auto-load $WEB_ROOT/.env
install -m 0644 -o root -g root /templates/profile.d/edge-env.sh /etc/profile.d/edge-env.sh
grep -q '/etc/profile.d/edge-env.sh' /etc/bash.bashrc \
    || echo '. /etc/profile.d/edge-env.sh' >> /etc/bash.bashrc

# Use host as SERVER_NAME
sed -i "s/server_name/host/" /etc/nginx/fastcgi_params
sed -i "s/server_name/host/" /etc/nginx/fastcgi.conf

# Set HTTPS according to forwarded protocol
sed -i "s/\$https/on/" /etc/nginx/fastcgi_params
sed -i "s/\$https/on/" /etc/nginx/fastcgi.conf

# Don't time out SSH connections
echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 720" >> /etc/ssh/sshd_config

# Install Composer
wget -O /usr/local/bin/composer "https://getcomposer.org/composer-$COMPOSER_VERSION.phar"
chmod a+x /usr/local/bin/composer

# Cleanup
rm -rf /tmp/*
